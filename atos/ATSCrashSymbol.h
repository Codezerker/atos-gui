//
//  ATSCrashSymbol.h
//  atos
//
//  Created by Yan Li on 7/19/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATSCrashSymbol : NSObject

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, assign) NSCellStateValue checked;

- (instancetype)initWithSymbol:(NSString *)symbol;

@end
