//
//  ATSAppDelegate.m
//  atos
//
//  Created by Yan Li on 7/16/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSAppDelegate.h"
#import "NSTask+EasyExecute.h"


@interface ATSAppDelegate ()

@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appPath;

@end


@implementation ATSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self performSetExcutable:self];
}


- (IBAction)performSetExcutable:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:@[@"app"]];
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        NSString *appPath = [openPanel.URLs[0] path];
        self.appName      = [[appPath lastPathComponent] stringByReplacingOccurrencesOfString:@".app" withString:@""];
        self.appPath      = [appPath stringByDeletingLastPathComponent];
    }
}


- (IBAction)performReSymbolicate:(id)sender {
    dispatch_async(dispatch_queue_create("com.atos.AddressSeaching", NULL), ^{
        if (self.textView.string.length > 0) {
            NSString *baseAddress   = [self baseAddress];
            NSArray  *matchesString = [self matchesString];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self reSymbolicateWithBaseAddress:baseAddress
                                     matchesString:matchesString];
            });
        }
    });
}


- (void)reSymbolicateWithBaseAddress:(NSString *)baseAddress matchesString:(NSArray *)matchesString {
    
    if (baseAddress.length == 0) {
        return;
    }
    
    [[matchesString copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *address = (NSString *)obj;
        if (![address isEqualToString:baseAddress]) {
            NSString *symbol = [self reSymbolicateAddress:address
                                              baseAddress:baseAddress];
            
            [[self.textView.textStorage mutableString] replaceOccurrencesOfString:address
                                                                       withString:symbol
                                                                          options:NSCaseInsensitiveSearch
                                                                            range:NSMakeRange(0, self.textView.textStorage.length)];
        }
    }];
}


- (NSString *)baseAddress {
    
    NSRegularExpression *baseAddressRegex = [NSRegularExpression regularExpressionWithPattern:@"(0[xX][0-9a-fA-F]+) \\+ ([0-9]+)"
                                                                                      options:0
                                                                                        error:NULL];
    NSArray *baseMatches = [baseAddressRegex matchesInString:self.textView.string
                                                     options:0
                                                       range:NSMakeRange(0, self.textView.string.length)];
    
    NSTextCheckingResult *baseAddressMatch = [baseMatches lastObject];
    
    if (!baseAddressMatch) {
        return @"";
    }
    
    NSString *baseAddress = [self.textView.string substringWithRange:baseAddressMatch.range];
    
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
    NSArray *matches = [[addressRegex matchesInString:self.textView.string
                                              options:0
                                                range:NSMakeRange(0, self.textView.string.length)] mutableCopy];
    
    NSMutableArray *matchesString = [NSMutableArray arrayWithCapacity:matches.count];
    
    for (NSTextCheckingResult *match in matches) {
        [matchesString addObject:[self.textView.string substringWithRange:match.range]];
    }
    
    return matchesString;
}


- (NSString *)reSymbolicateAddress:(NSString *)address baseAddress:(NSString *)baseAddress {
    
    if (!self.appPath) {
        return address;
    }
    
    NSString *shellCommand = [NSString stringWithFormat:@"cd %@; xcrun atos -o %@.app/Contents/MacOS/%@ -l %@ %@",
                              self.appPath,
                              self.appName, self.appName, baseAddress, address];
    
    NSString *symbol = [NSTask executeAndReturnStdOut:@"/bin/sh" arguments:@[@"-c", shellCommand]];
    return symbol;
}

@end
