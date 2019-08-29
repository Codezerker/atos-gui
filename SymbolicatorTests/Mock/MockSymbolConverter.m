//
//  MockSymbolConverter.m
//  SymbolicatorTests
//
//  Created by Yan Li on 21/08/19.
//  Copyright © 2019 Codezerker. All rights reserved.
//

#import "MockSymbolConverter.h"

@implementation MockSymbolConverter

- (instancetype)init
{
    if (self = [super init])
    {
        _requestedAddresses = [NSMutableArray array];
        _requestedLoadAddresses = [NSMutableArray array];
        _requestedExecutablePaths = [NSMutableArray array];
        _resultSymbolTable = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<NSString *> *)symbolicator:(ATSSymbolicator *)symbolicator
                  symbolsForAddresses:(NSArray<NSString *> *)addresses
                          loadAddress:(NSString *)loadAddress
                       executablePath:(NSString *)executablePath
{
    if (addresses.count == 0)
    {
        return @[@""];
    }
    
    NSMutableArray<NSString *> *results = [NSMutableArray arrayWithCapacity:addresses.count];
        
    [addresses enumerateObjectsUsingBlock:^(NSString * _Nonnull address, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.requestedAddresses addObject:address];
        
        NSString *convertedSymbol = [NSString stringWithFormat:@"%@ - %@", address, loadAddress];
        self.resultSymbolTable[address] = convertedSymbol;
        
        [results addObject:convertedSymbol];
    }];
    
    [self.requestedLoadAddresses addObject:loadAddress];
    [self.requestedExecutablePaths addObject:executablePath];
    
    return results;
}

@end
