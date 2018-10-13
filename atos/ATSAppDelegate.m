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

@end


@implementation ATSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"NSApplicationCrashOnExceptions" : @YES}];
    
    [self.window orderOut:self];

    self.welcomeWindowController = [[ATSWelcomeWindowController alloc] init];
    [self.welcomeWindowController.window makeKeyAndOrderFront:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(welcomeWindowDidSelectArchive:)
                                                 name:ATSWelcomeWindowDidSelectArchiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(welcomeWindowDidSelectApp:)
                                                 name:ATSWelcomeWindowDidSelectAppNotification
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
        [self.welcomeWindowController.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}


- (void)welcomeWindowDidSelectArchive:(NSNotification *)notification {
    ATSArchiveFileWrapper *fileWrapper = notification.userInfo[ATSArchiveFileWrapperKey];
    self.mainWindowController = [[ATSMainWindowController alloc] initWithAppFileURL:fileWrapper.fileURL];

    [self.welcomeWindowController.window orderOut:self];
    [self.mainWindowController.window makeKeyAndOrderFront:self];
}


- (void)welcomeWindowDidSelectApp:(NSNotification *)notification {
    NSURL *fileURL = notification.userInfo[ATSAppFileURLKey];
    self.mainWindowController = [[ATSMainWindowController alloc] initWithAppFileURL:fileURL];
    
    [self.welcomeWindowController.window orderOut:self];
    [self.mainWindowController.window makeKeyAndOrderFront:self];
}


- (void)mainWindowDidClose:(__unused NSNotification *)notification {
    self.mainWindowController = nil;
    [self.welcomeWindowController.window makeKeyAndOrderFront:self];
}

@end
