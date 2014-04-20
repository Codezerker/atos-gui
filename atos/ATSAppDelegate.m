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

    // self.mainWindowController = [[ATSMainWindowController alloc] init];
    // [self.mainWindowController.window makeKeyAndOrderFront:self];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        // [self.mainWindowController.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}


- (IBAction)performReSymbolicate:(id)sender {
    [self.mainWindowController performReSymbolicate];
}


- (IBAction)performSetExecutable:(id)sender {
    [self.mainWindowController performSetExecutable];
}

@end
