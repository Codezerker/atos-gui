//
//  ATSSymbolParser.m
//  atos
//
//  Created by Yan Li on 3/12/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSSymbolParser.h"
#import "NSTask+EasyExecute.h"


@interface ATSSymbolParser ()

@property (nonatomic, strong) dispatch_queue_t parsingQueue;
@property (nonatomic, strong) NSString *symbolString;

@end


@implementation ATSSymbolParser

- (instancetype)init {
    if (self = [super init]) {
        _parsingQueue = dispatch_queue_create("com.eyeplum.atos.parsing", NULL);
    }

    return self;
}


- (void)parseWithString:(NSString *)symbolString {
    if (symbolString.length == 0) {
        return;
    }

    self.symbolString = symbolString;

    dispatch_async(self.parsingQueue, ^{
        [self reSymbolicateWithBaseAddress:[self baseAddress]
                             matchesString:[self matchesString]];
    });
}


- (void)reSymbolicateWithBaseAddress:(NSString *)baseAddress matchesString:(NSArray *)matchesString {

    if (baseAddress.length == 0) {
        return;
    }

    [[matchesString copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *address = (NSString *)obj;
        if (![address isEqualToString:baseAddress]) {
            NSString *symbol = [self reSymbolicateAddress:address baseAddress:baseAddress];
            if (![symbol isEqualToString:address]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(symbolParser:didFindValidSymbol:fromAddress:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate symbolParser:self didFindValidSymbol:symbol fromAddress:address];
                    });
                }
            }
        }
    }];
}


- (NSString *)baseAddress {

    NSRegularExpression *baseAddressRegex = [NSRegularExpression regularExpressionWithPattern:@"(0[xX][0-9a-fA-F]+) \\+ ([0-9]+)"
                                                                                      options:0
                                                                                        error:NULL];
    NSArray *baseMatches = [baseAddressRegex matchesInString:self.symbolString
                                                     options:0
                                                       range:NSMakeRange(0, self.symbolString.length)];

    NSTextCheckingResult *baseAddressMatch = [baseMatches lastObject];

    if (!baseAddressMatch) {
        return @"";
    }

    NSString *baseAddress = [self.symbolString substringWithRange:baseAddressMatch.range];

    NSRegularExpression *baseAddressTail = [NSRegularExpression regularExpressionWithPattern:@" \\+ ([0-9]+)"
                                                                                     options:0
                                                                                       error:NULL];

    baseAddress = [baseAddressTail stringByReplacingMatchesInString:baseAddress
                                                            options:0
                                                              range:NSMakeRange(0, baseAddress.length)
                                                       withTemplate:@""];

    return baseAddress;
}


- (NSArray *)matchesString {
    NSRegularExpression *addressRegex = [NSRegularExpression regularExpressionWithPattern:@"(0[xX][0-9a-fA-F]+)"
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


- (NSString *)reSymbolicateAddress:(NSString *)address baseAddress:(NSString *)baseAddress {
    if (!self.applicationFilePath) {
        return address;
    }

    NSString *shellCommand = [NSString stringWithFormat:@"cd %@; xcrun atos -o %@.app/Contents/MacOS/%@ -l %@ %@",
                                                        self.applicationFilePath,
                                                        self.applicationName, self.applicationName, baseAddress, address];

    NSString *symbol = [NSTask executeAndReturnStdOut:@"/bin/sh" arguments:@[@"-c", shellCommand]];
    return symbol;
}

@end
