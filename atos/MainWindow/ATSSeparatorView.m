//
//  ATSSeparatorView.m
//  atos-gui
//
//  Created by Yan Li on 29/08/19.
//  Copyright © 2019 Codezerker. All rights reserved.
//

#import "ATSSeparatorView.h"

#import "NSColor+ATSAddition.h"

@implementation ATSSeparatorView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor ats_separatorColor] setFill];
    NSRectFill(dirtyRect);
}

@end
