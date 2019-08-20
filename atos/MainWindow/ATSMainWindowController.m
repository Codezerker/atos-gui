//
//  ATSMainWindowController.m
//  atos
//
//  Created by Yan Li on 7/18/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSMainWindowController.h"

#import "ATSSymbolicator.h"
#import "NSColor+ATSAddition.h"


static const CGFloat kFontSize    = 13.0f;
static const CGFloat kLineHeight  = 14.0f;
static const CGFloat kLineSpacing = 8.0f;

@interface ATSMainWindowController ()<NSWindowDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;
@property (nonatomic, weak) IBOutlet NSTextField *loadAddressTextField;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) NSBundle *appBundle;
@property (nonatomic, strong) NSURL *appExecutableURL;
@property (nonatomic, strong) NSString *overrideLoadAddress;

@property (nonatomic, strong) ATSSymbolicator *symbolicator;
@property (nonatomic, strong) dispatch_queue_t symbolEmplacementQueue;

@end


@implementation ATSMainWindowController

#pragma mark - Window Lifecycle

- (instancetype)initWithAppFileURL:(NSURL *)appFileURL {
    if (self = [super initWithWindowNibName:[self className]]) {
        _appBundle = [NSBundle bundleWithURL:appFileURL];
        if (_appBundle) {
            _appExecutableURL = [_appBundle executableURL];
        } else {
            _appExecutableURL = appFileURL;
        }
        
        _symbolicator = [[ATSSymbolicator alloc] init];
        _symbolEmplacementQueue = dispatch_queue_create("com.codezerker.atos-gui.symbolEmplacement", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupViews];
}


- (void)setupViews {
    self.window.delegate = self;
    self.window.title = [NSString stringWithFormat:@"%@ - (%@)",
                         self.appExecutableURL.lastPathComponent,
                         self.appExecutableURL.path];
    
    {
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
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setMinimumLineHeight:kLineHeight];
    [paragraphStyle setMaximumLineHeight:kLineHeight];
    [paragraphStyle setLineSpacing:kLineSpacing];
    [self.textView setDefaultParagraphStyle:paragraphStyle];
}


- (BOOL)windowShouldClose:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ATSMainWindowDidCloseNotification object:self];
    return YES;
}


#pragma mark - Action

- (IBAction)performReSymbolicate:(id)sender {
    [self.textView scrollPoint:NSZeroPoint];
    
    [self.progressIndicator startAnimation:nil];
    
    [self.symbolicator symbolicateString:self.textView.string
                           executableURL:self.appExecutableURL
                     overrideLoadAddress:self.overrideLoadAddress
                     withCompletionBlock:^(NSDictionary *symbolLookupTable) {        
        
        NSDictionary *textAttrs = @{
            NSForegroundColorAttributeName : [NSColor ats_textColor],
            NSFontAttributeName : self.textView.font,
        };
        NSMutableAttributedString *resultAttrString = [[NSMutableAttributedString alloc] initWithString:self.textView.string
                                                                                             attributes:textAttrs];
        
        dispatch_async(self.symbolEmplacementQueue, ^{
            [symbolLookupTable enumerateKeysAndObjectsUsingBlock:^(NSString *address, NSString *symbol, BOOL *stop) {
                NSMutableDictionary *highlightedTextAttrs = [textAttrs mutableCopy];
                highlightedTextAttrs[NSForegroundColorAttributeName] = [NSColor ats_highlightedTextColor];
                NSAttributedString *emplacedSymbol = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", address, symbol]
                                                                                     attributes:highlightedTextAttrs];
            
                NSRange addressRange = [resultAttrString.string rangeOfString:address];
                while (addressRange.location != NSNotFound) {
                    [resultAttrString replaceCharactersInRange:addressRange withAttributedString:emplacedSymbol];
                    
                    NSUInteger nextSearchLocation = addressRange.location + 1;
                    if (nextSearchLocation < resultAttrString.length) {
                        NSRange searchRange = NSMakeRange(nextSearchLocation, resultAttrString.length - nextSearchLocation);
                        addressRange = [resultAttrString.string rangeOfString:address
                                                                      options:NSLiteralSearch
                                                                        range:searchRange];
                    } else {
                        break;
                    }
                }
            }];
                
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.textView.textStorage setAttributedString:resultAttrString];
                [self.progressIndicator stopAnimation:nil];
            });
        });
    }];
}


- (IBAction)updateLoadAddress:(id)sender {
    NSString *loadAddress = self.loadAddressTextField.stringValue;
    if (loadAddress.length > 0) {
        self.overrideLoadAddress = loadAddress;
    } else {
        self.overrideLoadAddress = nil;
    }
}

@end
