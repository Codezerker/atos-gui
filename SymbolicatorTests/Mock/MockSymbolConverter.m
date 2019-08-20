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
        _requestedAddresses = [NSMutableSet set];
        _requestedLoadAddresses = [NSMutableSet set];
        _requestedExecutablePaths = [NSMutableSet set];
        _resultSymbolTable = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)symbolicator:(ATSSymbolicator *)symbolicator
          symbolForAddress:(NSString *)address
               loadAddress:(NSString *)loadAddress
            executablePath:(NSString *)executablePath
{
    [self.requestedAddresses addObject:address];
    [self.requestedLoadAddresses addObject:loadAddress];
    [self.requestedExecutablePaths addObject:executablePath];
    
    NSString *convertedSymbol = [NSString stringWithFormat:@"%@ - %@", address, loadAddress];
    self.resultSymbolTable[address] = convertedSymbol;
    
    return convertedSymbol;
}

@end
