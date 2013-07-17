//
//  ATSAppDelegate.h
//  atos
//
//  Created by Yan Li on 7/16/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

- (IBAction)performReSymbolicate:(id)sender;

@end
