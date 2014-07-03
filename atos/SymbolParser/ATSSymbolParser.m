//
//  ATSSymbolParser.m
//  atos
//
//  Created by Yan Li on 3/12/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSSymbolParser.h"
#import "NSTask+EasyExecute.h"


static NSString * const kXCArchiveExt = @".xcarchive";
static NSString * const kAppExt       = @".app";

static NSString * const kdSYMDirName  = @"dSYMs";
static NSString * const kAppDirName   = @"Products/Applications";

static NSString * const kAddressRegex = @"0[xX][0-9a-fA-F]+";
static NSString * kLoadAddressRegexString;
static NSString * kAddressRegexString;


@interface ATSSymbolParser ()

@property (nonatomic, strong) dispatch_queue_t parsingQueue;
@property (nonatomic, strong) NSString *symbolString;
@property (nonatomic, strong) NSString *internalApplicationFilePath;
@property (nonatomic, strong) NSString *internalApplicationName;

@property (nonatomic, assign) BOOL isFileXCArchive;

@end


@implementation ATSSymbolParser

#pragma mark - Public Methods

- (instancetype)initWithDelegate:(id <ATSSymbolParserDelegate>)delegate {
    if (self = [super init]) {
        kLoadAddressRegexString = [NSString stringWithFormat:@"(%@ %@)", kAddressRegex, kAddressRegex];
        kAddressRegexString = [NSString stringWithFormat:@"(%@)", kAddressRegex];
        
        _parsingQueue = dispatch_queue_create("com.eyeplum.atos.parsing", NULL);
        _delegate = delegate;
    }

    return self;
}


- (void)setApplicationLocationWithFilePath:(NSString *)applicationFilePath {
    self.isFileXCArchive = [applicationFilePath.lastPathComponent rangeOfString:kXCArchiveExt].location != NSNotFound;

    if (self.isFileXCArchive) {
        NSString *appDirPath  = [applicationFilePath stringByAppendingPathComponent:kAppDirName];
        NSString *appFilePath = [self neededFilePathInDirectory:appDirPath withFileNameHint:nil];

        NSString *dSYMDirPath  = [applicationFilePath stringByAppendingPathComponent:kdSYMDirName];
        NSString *dSYMFilePath = [self neededFilePathInDirectory:dSYMDirPath withFileNameHint:[appFilePath lastPathComponent]];

        NSString *tempDirPath = NSTemporaryDirectory();

        applicationFilePath = [tempDirPath stringByAppendingPathComponent:[appFilePath lastPathComponent]] ;

        [[NSFileManager defaultManager] copyItemAtPath:dSYMFilePath
                                                toPath:[tempDirPath stringByAppendingPathComponent:[dSYMFilePath lastPathComponent]]
                                                 error:NULL];

        [[NSFileManager defaultManager] copyItemAtPath:appFilePath
                                                toPath:applicationFilePath
                                                 error:NULL];
    }

    self.internalApplicationName = [[applicationFilePath lastPathComponent] stringByReplacingOccurrencesOfString:kAppExt withString:@""];
    self.internalApplicationFilePath = [applicationFilePath stringByDeletingLastPathComponent];
}


- (NSString *)applicationName {
    return [self.internalApplicationName copy];
}


- (NSString *)applicationFilePath {
    return self.isFileXCArchive ? nil : [self.internalApplicationFilePath copy];
}


- (NSString *)loadAddress {
    return [[self internalLoadAddress] copy];
}


- (NSArray *)symbolAddresses {
    return [[self matchesString] copy];
}


- (void)parseWithString:(NSString *)symbolString {
    if (symbolString.length == 0) {
        return;
    }

    self.symbolString = symbolString;

    dispatch_async(self.parsingQueue, ^{
        [self reSymbolicateWithLoadAddress:[self loadAddress]
                             matchesString:[self matchesString]];
    });
}


#pragma mark - Private Methods

- (NSString *)neededFilePathInDirectory:(NSString *)dirPath withFileNameHint:(NSString *)hint {
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];

    __block NSString *fileName;
    if (hint.length > 0) {
        [[dirEnum allObjects] enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
            if ([file rangeOfString:hint].location != NSNotFound) {
                fileName = file;
                *stop = YES;
            }
        }];
    }

    if (fileName.length == 0) {
        fileName = [[dirEnum allObjects] firstObject];
    }

    NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];

    return filePath;
}


- (void)reSymbolicateWithLoadAddress:(NSString *)loadAddress matchesString:(NSArray *)matchesString {

    if (loadAddress.length == 0) {
        return;
    }

    [[matchesString copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *address = (NSString *)obj;
        if (![address isEqualToString:loadAddress]) {
            NSString *symbol = [self reSymbolicateAddress:address loadAddress:loadAddress];
            if (![symbol isEqualToString:address]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(symbolParser:didFindValidSymbol:fromAddress:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate symbolParser:self didFindValidSymbol:symbol fromAddress:address];
                    });
                } else {
                    *stop = YES;
                }
            }
        }
    }];
}


- (NSString *)internalLoadAddress {

    NSRegularExpression *loadAddressRegex = [NSRegularExpression regularExpressionWithPattern:kLoadAddressRegexString
                                                                                      options:0
                                                                                        error:NULL];
    NSArray *loadMatches = [loadAddressRegex matchesInString:self.symbolString
                                                     options:0
                                                       range:NSMakeRange(0, self.symbolString.length)];

    NSTextCheckingResult *loadAddressMatch = [loadMatches lastObject];

    if (!loadAddressMatch) {
        return @"";
    }

    NSString *loadAddress = [self.symbolString substringWithRange:loadAddressMatch.range];
    NSArray *addressComponents = [loadAddress componentsSeparatedByString:@" "];
    loadAddress = [addressComponents lastObject];

    return loadAddress;
}


- (NSArray *)matchesString {
    NSRegularExpression *addressRegex = [NSRegularExpression regularExpressionWithPattern:kAddressRegexString
                                                                                  options:0
                                                                                    error:NULL];
    NSArray *matches = [[addressRegex matchesInString:self.symbolString
                                              options:0
                                                range:NSMakeRange(0, self.symbolString.length)] mutableCopy];

    NSMutableArray *matchesString = [NSMutableArray arrayWithCapacity:matches.count];

    for (NSTextCheckingResult *match in matches) {
        [matchesString addObject:[self.symbolString substringWithRange:match.range]];
    }

    return matchesString;
}


- (NSString *)reSymbolicateAddress:(NSString *)address loadAddress:(NSString *)loadAddress {
    if (!self.internalApplicationFilePath) {
        return address;
    }

    NSString *atosBinaryPath = [[NSBundle mainBundle] pathForResource:@"atos" ofType:nil];
    NSString *shellCommand = [NSString stringWithFormat:@"cd %@; %@ -o %@.app/Contents/MacOS/%@ -l %@ %@",
                                                        self.internalApplicationFilePath,
                                                        atosBinaryPath,
                                                        self.internalApplicationName,
                                                        self.internalApplicationName,
                                                        loadAddress,
                                                        address];

    NSString *symbol = [NSTask executeAndReturnStdOut:@"/bin/sh" arguments:@[@"-c", shellCommand]];
    return symbol;
}

@end
