//
//  NSColor+ATSAddition.m
//  atos
//
//  Created by Yan Li on 3/13/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "NSColor+ATSAddition.h"

@implementation NSColor (ATSAddition)

+ (NSColor *)ats_backgroundColor {
    return [NSColor colorWithDeviceRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0];
}


+ (NSColor *)ats_highlightedBackgroundColor {
    return [NSColor colorWithDeviceRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
}


+ (NSColor *)ats_textColor {
    return [NSColor lightGrayColor];
}


+ (NSColor *)ats_highlightedTextColor {
    return [NSColor colorWithDeviceRed:204.0/255 green:120.0/255 blue:50.0/255 alpha:1.0];
}

@end
