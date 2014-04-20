//
//  ATSAppDelegate.m
//  atos
//
//  Created by Yan Li on 7/16/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSAppDelegate.h"
#import "ATSWelcomeWindowController.h"
#import "ATSMainWindowController.h"
#import "ATSArchiveFileWrapper.h"


@interface ATSAppDelegate()

@property (nonatomic, strong) ATSWelcomeWindowController *welcomeWindowController;
@property (nonatomic, strong) ATSMainWindowController *mainWindowController;

- (IBAction)performReSymbolicate:(id)sender;
- (IBAction)performSetExecutable:(id)sender;

@end


@implementation ATSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [self.window orderOut:self];

    self.welcomeWindowController = [[ATSWelcomeWindowController alloc] init];
    [self.welcomeWindowController.window makeKeyAndOrderFront:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(archiveDidBeSelected:)
                                                 name:ATSArchiveDidBeSelectedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainWindowDidClose:)
                                                 name:ATSMainWindowDidCloseNotification
                                               object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        // TODO: handle reopen when main window is key
        [self.welcomeWindowController.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}


- (void)archiveDidBeSelected:(NSNotification *)notification {
    ATSArchiveFileWrapper *fileWrapper = notification.userInfo[ATSArchiveFileWrapperKey];
    self.mainWindowController = [[ATSMainWindowController alloc] initWithArchiveFileWrapper:fileWrapper];

    [self.welcomeWindowController.window orderOut:self];
    [self.mainWindowController.window makeKeyAndOrderFront:self];
}


- (void)mainWindowDidClose:(__unused NSNotification *)notification {
    self.mainWindowController = nil;
    [self.welcomeWindowController.window makeKeyAndOrderFront:self];
}


- (IBAction)performReSymbolicate:(id)sender {
    [self.mainWindowController performReSymbolicate];
}


- (IBAction)performSetExecutable:(id)sender {
    // [self.mainWindowController performSetExecutable];
}

@end
