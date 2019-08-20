//
//  MockSymbolConverter.h
//  SymbolicatorTests
//
//  Created by Yan Li on 21/08/19.
//  Copyright © 2019 Codezerker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATSSymbolicator.h"

@interface MockSymbolConverter : NSObject<ATSSymbolConverter>

@property (nonatomic, strong) NSMutableSet *requestedAddresses;
@property (nonatomic, strong) NSMutableSet *requestedLoadAddresses;
@property (nonatomic, strong) NSMutableSet *requestedExecutablePaths;
@property (nonatomic, strong) NSMutableDictionary *resultSymbolTable;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end
