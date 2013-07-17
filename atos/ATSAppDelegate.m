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
            NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"0[xX][0-9a-fA-F]+"
                                                                                               options:0
                                                                                                 error:NULL];
            NSMutableArray *matches = [[regularExpression matchesInString:self.textView.string
                                                                  options:0
                                                                    range:NSMakeRange(0, self.textView.string.length)] mutableCopy];

            NSMutableArray *matchesString = [NSMutableArray arrayWithCapacity:matches.count];

            for (NSTextCheckingResult *match in matches) {
                [matchesString addObject:[self.textView.string substringWithRange:match.range]];
            }

            NSMutableDictionary *matchesStringMapping = [NSMutableDictionary dictionaryWithCapacity:matches.count];

            for (NSString *string in matchesString) {
                matchesStringMapping[string] = matchesStringMapping[string] ? @([matchesStringMapping[string] intValue] + 1) : @0;
            }

            NSString *baseAddress = [[matchesStringMapping allKeysForObject:[[matchesStringMapping allValues] valueForKeyPath:@"@max.intValue"]] lastObject];

            [matchesString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *address = (NSString *)obj;
                if ([address isEqualToString:baseAddress]) {
                    [matchesString removeObjectAtIndex:idx];
                }
            }];

            dispatch_sync(dispatch_get_main_queue(), ^{
                [matchesString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *address = (NSString *)obj;
                    [[self.textView.textStorage mutableString] replaceOccurrencesOfString:address
                                                                               withString:[self reSymbolicateAddress:address baseAddress:baseAddress]
                                                                                  options:NSCaseInsensitiveSearch
                                                                                    range:NSMakeRange(0, self.textView.textStorage.length)];
                }];
            });
        }
    });
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
