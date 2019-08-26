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

@property (nonatomic, strong) NSMutableArray<NSString *> *requestedAddresses;
@property (nonatomic, strong) NSMutableArray<NSString *> *requestedLoadAddresses;
@property (nonatomic, strong) NSMutableArray<NSString *> *requestedExecutablePaths;
@property (nonatomic, strong) NSMutableDictionary *resultSymbolTable;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end
