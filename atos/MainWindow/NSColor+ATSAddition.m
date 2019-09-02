//
//  NSColor+ATSAddition.m
//  atos
//
//  Created by Yan Li on 3/13/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "NSColor+ATSAddition.h"

@implementation NSColor (ATSAddition)

+ (NSColor *)ats_highlightedTextColor {
    return [NSColor colorWithCalibratedRed:204.0/255 green:90.0/255 blue:0 alpha:1.0];
}

+ (NSColor *)ats_separatorColor {
    if (@available(macOS 10.13, *)) {
        return [NSColor colorNamed:@"separator-color"];
    } else {
        return [NSColor colorWithCalibratedRed:0.572 green:0.572 blue:0.572 alpha:1.0];
    }
}

@end
