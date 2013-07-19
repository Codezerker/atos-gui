//
//  ATSCrashSymbol.m
//  atos
//
//  Created by Yan Li on 7/19/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSCrashSymbol.h"

@implementation ATSCrashSymbol

- (instancetype)initWithSymbol:(NSString *)symbol {
    if (self = [super init]) {
        _symbol  = symbol;
        _checked = NSOffState;
    }
    
    return self;
}

@end
