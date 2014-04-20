//
//  NSURL+ATSAddition.m
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "NSURL+ATSAddition.h"

@implementation NSURL (ATSAddition)

- (id)ats_valueForProperty:(NSString *)propertyKey {
    id value;
    NSError *error;

    [self getResourceValue:&value forKey:propertyKey error:&error];

    if (!error) {
        return value;
    } else {
        return nil;
    }
}

@end
