//
//  ATSMainWindowController.h
//  atos
//
//  Created by Yan Li on 7/18/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATSArchiveFileWrapper;

@interface ATSMainWindowController : NSWindowController

- (instancetype)initWithArchiveFileWrapper:(ATSArchiveFileWrapper *)fileWrapper;

- (void)performReSymbolicate;

@end
