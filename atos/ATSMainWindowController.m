//
//  ATSMainWindowController.m
//  atos
//
//  Created by Yan Li on 7/18/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSMainWindowController.h"
#import "ATSSymbolParser.h"
#import "ATSArchiveFileWrapper.h"
#import "NSColor+ATSAddition.h"


static const CGFloat kFontSize    = 13.0f;
static const CGFloat kLineHeight  = 14.0f;
static const CGFloat kLineSpacing = 8.0f;

@interface ATSMainWindowController ()<ATSSymbolParserDelegate, NSWindowDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;
@property (nonatomic, strong) ATSArchiveFileWrapper *fileWrapper;
@property (nonatomic, strong) ATSSymbolParser *symbolParser;

@end


@implementation ATSMainWindowController

#pragma mark - Window Lifecycle

- (instancetype)initWithArchiveFileWrapper:(ATSArchiveFileWrapper *)fileWrapper {
    if (self = [super initWithWindowNibName:[self className]]) {
        _fileWrapper = fileWrapper;
        _symbolParser = [[ATSSymbolParser alloc] initWithDelegate:self];
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
        textFont = [NSFont systemFontOfSize:kFontSize];
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
    // TODO: Adapt fileWrapper in symbolParser
    NSString *appPath = [self.fileWrapper.fileURL path];
    [self.symbolParser setApplicationLocationWithFilePath:appPath];

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

- (void)performReSymbolicate {
    [self.textView scrollPoint:NSZeroPoint];
    [self.symbolParser parseWithString:self.textView.string];
}


#pragma mark - Parser Delegate

- (void)symbolParser:(ATSSymbolParser *)parser didFindValidSymbol:(NSString *)symbol fromAddress:(NSString *)address {
    [[self.textView.textStorage mutableString] replaceOccurrencesOfString:address
                                                               withString:symbol
                                                                  options:NSCaseInsensitiveSearch
                                                                    range:NSMakeRange(0, self.textView.textStorage.length)];

    [self.textView.textStorage addAttributes:@{NSForegroundColorAttributeName : [NSColor ats_highlightedTextColor]}
                                       range:[self.textView.string rangeOfString:symbol]];
}

@end
