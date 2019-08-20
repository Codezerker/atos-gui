//
//  ATSWelcomeWindowController.m
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSWelcomeWindowController.h"
#import "ATSMainWindowController.h"

static NSString * const kFileExtensionApplicationBundle = @"app";

@interface ATSWelcomeWindowController ()

@property (nonatomic, weak) IBOutlet NSTextField *versionLabel;

- (IBAction)openOther:(id)sender;

@end


@implementation ATSWelcomeWindowController

#pragma mark - Initializer

- (instancetype)init {
    if (self = [super initWithWindowNibName:[self className]]) {
        // ...
    }
    return self;
}


#pragma mark - Window Lifecycle

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setMovable:YES];
    [self.window setMovableByWindowBackground:YES];
    
    [self setupVersionLabel];
}


- (void)setupVersionLabel {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"Version %@ (%@)",
                    info[@"CFBundleShortVersionString"],
                    info[(NSString *) kCFBundleVersionKey]];
    [self.versionLabel setStringValue:version];
}


#pragma mark - IBAction

- (IBAction)openOther:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:@[kFileExtensionApplicationBundle]];

    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton && [openPanel.URLs firstObject]) {
            [self postNotificationWithFileURL:[openPanel.URLs firstObject]];
        }
    }];

}


#pragma mark - Notification Helper

- (void)postNotificationWithFileURL:(NSURL *)fileURL {
    [[NSNotificationCenter defaultCenter] postNotificationName:ATSWelcomeWindowDidSelectAppNotification
                                                        object:self
                                                      userInfo:@{ATSAppFileURLKey:fileURL}];
}


@end
