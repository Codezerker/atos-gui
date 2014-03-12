//
//  ATSMainWindowController.m
//  atos
//
//  Created by Yan Li on 7/18/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSMainWindowController.h"
#import "NSTask+EasyExecute.h"


@interface ATSMainWindowController ()<NSPopoverDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appPath;

@end


@implementation ATSMainWindowController

#pragma mark - View Controller Lifecycle

- (instancetype)init {
    if (self = [super initWithWindowNibName:self.className]) {
        //...
    }
    
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];

    NSColor *backgroundColor = [NSColor colorWithDeviceRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0];
    NSColor *selectedBackgroundColor = [NSColor colorWithDeviceRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];

    [self.textView setFont:[NSFont fontWithName:@"SourceCodePro-Regular" size:13]];
    [self.textView setTextColor:[NSColor lightGrayColor]];
    [self.textView setBackgroundColor:backgroundColor];
    [self.textView setSelectedTextAttributes:@{NSBackgroundColorAttributeName : selectedBackgroundColor}];
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [self performSetExecutable];
}


#pragma mark - Action

- (void)performSetExecutable {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:@[@"app"]];
    
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        NSString *appPath = [openPanel.URLs[0] path];
        self.appName      = [[appPath lastPathComponent] stringByReplacingOccurrencesOfString:@".app" withString:@""];
        self.appPath      = [appPath stringByDeletingLastPathComponent];
        
        self.window.title = [NSString stringWithFormat:@"%@ - (%@)", self.appName, appPath];
    }
}


- (void)performReSymbolicate {
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


#pragma mark - Utility

- (void)reSymbolicateWithBaseAddress:(NSString *)baseAddress matchesString:(NSArray *)matchesString {
    
    if (baseAddress.length == 0) {
        return;
    }
    
    NSMutableArray *validSymbols = [NSMutableArray arrayWithCapacity:matchesString.count];
    
    [[matchesString copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *address = (NSString *)obj;
        
        if (![address isEqualToString:baseAddress]) {
            NSString *symbol = [self reSymbolicateAddress:address
                                              baseAddress:baseAddress];
            
            if (![symbol isEqualToString:address]) {
                [[self.textView.textStorage mutableString] replaceOccurrencesOfString:address
                                                                           withString:symbol
                                                                              options:NSCaseInsensitiveSearch
                                                                                range:NSMakeRange(0, self.textView.textStorage.length)];
                [validSymbols addObject:symbol];
            }
        }
    }];
    
    for (NSString *validSymbol in validSymbols) {
        [self colorizeSymbol:validSymbol];
    }
}


- (void)colorizeSymbol:(NSString *)symbol {
    NSRange symbolRange = [self.textView.string rangeOfString:symbol];
    NSColor *highlightColor = [NSColor colorWithDeviceRed:204.0/255 green:120.0/255 blue:50.0/255 alpha:1.0];
    [self.textView.textStorage addAttributes:@{NSForegroundColorAttributeName : highlightColor}
                                       range:symbolRange];
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
