//
//  ATSAppDelegate.m
//  atos
//
//  Created by Yan Li on 7/16/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSAppDelegate.h"
#import "ATSMainWindowController.h"


@interface ATSAppDelegate()

@property (nonatomic, strong) ATSMainWindowController *mainWindowController;

- (IBAction)performReSymbolicate:(id)sender;
- (IBAction)performSetExecutable:(id)sender;

@end


@implementation ATSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self.window orderOut:self];
    
    self.mainWindowController = [[ATSMainWindowController alloc] init];
    [self.mainWindowController.window makeKeyAndOrderFront:self];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [self.mainWindowController.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}


- (void)performReSymbolicate:(id)sender {
    [self.mainWindowController performReSymbolicate];
}


- (void)performSetExecutable:(id)sender {
    [self.mainWindowController performSetExecutable];
}

@end
