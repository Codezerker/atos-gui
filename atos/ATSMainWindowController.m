//
//  ATSMainWindowController.m
//  atos
//
//  Created by Yan Li on 7/18/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSMainWindowController.h"
#import "ATSSymbolParser.h"


@interface ATSMainWindowController ()<ATSSymbolParserDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;
@property (nonatomic, strong) ATSSymbolParser *symbolParser;

@end


@implementation ATSMainWindowController

#pragma mark - View Controller Lifecycle

- (instancetype)init {
    if (self = [super initWithWindowNibName:self.className]) {
        _symbolParser = [[ATSSymbolParser alloc] initWithDelegate:self];
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
        NSString *appPath = [[openPanel.URLs firstObject] path];
        [self.symbolParser setApplicationLocationWithFilePath:appPath];

        self.window.title = [NSString stringWithFormat:@"%@ - (%@)",
                        self.symbolParser.applicationName,
                        self.symbolParser.applicationFilePath];
    }
}


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

    [self.textView.textStorage addAttributes:@{NSForegroundColorAttributeName : [NSColor colorWithDeviceRed:204.0/255 green:120.0/255 blue:50.0/255 alpha:1.0]}
                                       range:[self.textView.string rangeOfString:symbol]];
}

@end
