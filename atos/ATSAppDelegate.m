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

// Notes: Is this the only way to display multiple Windows in the same instance of the application?
@property (nonatomic, strong) NSMutableArray<ATSMainWindowController *> *mainWindowControllers;

@end


@implementation ATSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.welcomeWindowController = [[ATSWelcomeWindowController alloc] init];
    [self.welcomeWindowController.window makeKeyAndOrderFront:self];

    self.mainWindowControllers = [NSMutableArray array];
    
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
    [self.welcomeWindowController.window makeKeyAndOrderFront:self];
    return NO;
}


- (void)welcomeWindowDidSelectArchive:(NSNotification *)notification {
    ATSArchiveFileWrapper *fileWrapper = notification.userInfo[ATSArchiveFileWrapperKey];
    ATSMainWindowController *mainWindowController = [[ATSMainWindowController alloc] initWithAppFileURL:fileWrapper.fileURL];

    [self.welcomeWindowController.window orderOut:self];
    [mainWindowController.window makeKeyAndOrderFront:self];
    [self.mainWindowControllers addObject:mainWindowController];
}


- (void)welcomeWindowDidSelectApp:(NSNotification *)notification {
    NSURL *fileURL = notification.userInfo[ATSAppFileURLKey];
    ATSMainWindowController *mainWindowController = [[ATSMainWindowController alloc] initWithAppFileURL:fileURL];
    
    [self.welcomeWindowController.window orderOut:self];
    [mainWindowController.window makeKeyAndOrderFront:self];
    [self.mainWindowControllers addObject:mainWindowController];
}


- (void)mainWindowDidClose:(NSNotification *)notification {
    [self.mainWindowControllers removeObject:notification.object];
    
    if (self.mainWindowControllers.count == 0) {
        [self.welcomeWindowController.window makeKeyAndOrderFront:self];
    }
}

@end
