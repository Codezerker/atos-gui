//
//  ATSMainWindowController.m
//  atos
//
//  Created by Yan Li on 7/18/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSMainWindowController.h"
#import "ATSSymbolParser.h"
#import "NSColor+ATSAddition.h"


static const CGFloat kFontSize    = 13.0f;
static const CGFloat kLineHeight  = 14.0f;
static const CGFloat kLineSpacing = 8.0f;

@interface ATSMainWindowController ()<ATSSymbolParserDelegate, NSWindowDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;
@property (nonatomic, weak) IBOutlet NSTextField *loadAddressTextField;
@property (nonatomic, strong) ATSSymbolParser *symbolParser;

@end


@implementation ATSMainWindowController

#pragma mark - Window Lifecycle

- (instancetype)initWithAppFileURL:(NSURL *)appFileURL {
    if (self = [super initWithWindowNibName:[self className]]) {
        _symbolParser = [[ATSSymbolParser alloc] initWithDelegate:self];
        [_symbolParser setApplicationLocationWithFilePath:[appFileURL path]];
    }
    
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupViews];
    [self setupParser];
}


- (void)setupViews {
    [self.window setDelegate:self];

    // Preferred text font is SourceCodePro-Regular
    NSFont *textFont = [NSFont fontWithName:@"SourceCodePro-Regular" size:kFontSize];

    // If preferred font not found, fallback to system font
    if (!textFont) {
        if (@available(macOS 10.15, *)) {
            textFont = [NSFont monospacedSystemFontOfSize:kFontSize weight:NSFontWeightRegular];
        } else {
            textFont = [NSFont systemFontOfSize:kFontSize];
        }
    }

    [self.textView setFont:textFont];
    [self.textView setTextColor:[NSColor ats_textColor]];
    [self.textView setBackgroundColor:[NSColor ats_backgroundColor]];
    [self.textView setSelectedTextAttributes:@{NSBackgroundColorAttributeName : [NSColor ats_highlightedBackgroundColor]}];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setMinimumLineHeight:kLineHeight];
    [paragraphStyle setMaximumLineHeight:kLineHeight];
    [paragraphStyle setLineSpacing:kLineSpacing];
    [self.textView setDefaultParagraphStyle:paragraphStyle];
}


- (void)setupParser {
    if (self.symbolParser.applicationFilePath.length > 0) {
        self.window.title = [NSString stringWithFormat:@"%@ - (%@)",
                                                       self.symbolParser.applicationName,
                                                       self.symbolParser.applicationFilePath];
    } else {
        self.window.title = self.symbolParser.applicationName;
    }
}


- (BOOL)windowShouldClose:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ATSMainWindowDidCloseNotification object:self];
    return YES;
}


#pragma mark - Action

- (IBAction)performReSymbolicate:(id)sender {
    [self.textView scrollPoint:NSZeroPoint];
    [self.symbolParser parseWithString:[self.textView.string copy]];
}


- (IBAction)updateLoadAddress:(id)sender {
    [self.symbolParser setLoadAddress:self.loadAddressTextField.stringValue];
}


#pragma mark - Parser Delegate

- (void)symbolParser:(ATSSymbolParser *)parser didFindValidSymbol:(NSString *)symbol fromAddress:(NSString *)address {
    [[self.textView.textStorage mutableString] replaceOccurrencesOfString:address
                                                               withString:[NSString stringWithFormat:@"%@ %@", address, symbol]
                                                                  options:NSCaseInsensitiveSearch
                                                                    range:NSMakeRange(0, self.textView.textStorage.length)];

    [self.textView.textStorage addAttributes:@{NSForegroundColorAttributeName : [NSColor ats_highlightedTextColor]}
                                       range:[self.textView.string rangeOfString:symbol]];
    
    if (parser.loadAddress) {
        [self.loadAddressTextField setStringValue:parser.loadAddress];
    }
}

@end
