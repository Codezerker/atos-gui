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

@interface ATSMainWindowController ()<NSWindowDelegate, NSTextFieldDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *outputView;
@property (nonatomic, weak) IBOutlet NSView *separatorView;
@property (nonatomic, weak) IBOutlet NSStackView *bottomBarStackView;
@property (nonatomic, weak) IBOutlet NSButton *autoLoadAddressCheckBox;
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
    [self.textView setTextColor:[NSColor textColor]];
    [self.textView setBackgroundColor:[NSColor textBackgroundColor]];
    [self.textView setAllowsUndo:YES];
    
    [self.outputView setFont:textFont];
    [self.outputView setTextColor:[NSColor textColor]];
    [self.outputView setBackgroundColor:[NSColor controlBackgroundColor]];
    
    [self.bottomBarStackView setEdgeInsets:NSEdgeInsetsMake(0, 10, 0, 10)];
    
    [self.loadAddressTextField setDelegate:self];
}


- (BOOL)windowShouldClose:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ATSMainWindowDidCloseNotification object:self];
    return YES;
}


#pragma mark - Action

- (IBAction)performReSymbolicate:(id)sender {
    [self.progressIndicator startAnimation:nil];
    
    [self.symbolicator symbolicateString:self.textView.string
                           executableURL:self.appExecutableURL
                     overrideLoadAddress:self.overrideLoadAddress
                     withCompletionBlock:^(NSDictionary *symbolLookupTable) {        
        
        NSDictionary *textAttrs = @{
            NSForegroundColorAttributeName : self.outputView.textColor,
            NSFontAttributeName : self.outputView.font,
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
                [self.outputView.textStorage setAttributedString:resultAttrString];
                [self.progressIndicator stopAnimation:nil];
            });
        });
    }];
}


- (IBAction)symbolicatorConfigurationChanged:(id)sender {
    if (self.autoLoadAddressCheckBox.state == NSControlStateValueOn) {
        self.loadAddressTextField.enabled = NO;
        [self _resetOverrideLoadAddress];
    } else {
        self.loadAddressTextField.enabled = YES;
        [self.loadAddressTextField becomeFirstResponder];
        [self _updateOverrideLoadAddress];
    }
}


#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj {
    [self _updateOverrideLoadAddress];
}


#pragma mark - Helper methods

- (void)_updateOverrideLoadAddress {
    NSString *loadAddress = self.loadAddressTextField.stringValue;
    if (loadAddress.length > 0) {
        self.overrideLoadAddress = loadAddress;
    } else {
        self.overrideLoadAddress = nil;
    }
    NSLog(@"Overriding load address to: %@", self.overrideLoadAddress);
}


- (void)_resetOverrideLoadAddress {
    self.overrideLoadAddress = nil;
    NSLog(@"Resetting load address override.");
}

@end
