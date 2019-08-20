//
//  SymbolicatorTests.m
//  SymbolicatorTests
//
//  Created by Yan Li on 21/08/19.
//  Copyright © 2019 Codezerker. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Foundation/Foundation.h>

#import "Mock/MockSymbolConverter.h"

@interface SymbolicatorTests : XCTestCase

@property (nonatomic, strong) MockSymbolConverter *mockSymbolConverter;
@property (nonatomic, strong) ATSSymbolicator *symbolicator;

@end

@implementation SymbolicatorTests

- (void)setUp
{
    self.mockSymbolConverter = [[MockSymbolConverter alloc] init];
    self.symbolicator = [[ATSSymbolicator alloc] initWithSymbolConverter:self.mockSymbolConverter];
}

- (void)testLoadAddressMatching
{
    NSArray *lines = @[
        @"7   ReportCrash                       0x0000000103677652 0x103660000 + 95826",
        @"8   ReportCrash                       0x000000010367765A 0x103660000 + 95834",
        @"0x103660000 -        0x10367fff7  ReportCrash (15007) <BCE573F4-0EF5-3A29-9D8A-D54EF484BC22> /System/Library/CoreServices/ReportCrash",
    ];
    NSString *string = [lines componentsJoinedByString:@"\n"];
    
    NSURL *executableURL = [NSURL fileURLWithPath:@"/path/to/test.app"];
    
    __block XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Symbolicating completed"];
    [self.symbolicator symbolicateString:string
                           executableURL:executableURL
                     withCompletionBlock:^(BOOL succeeded, NSDictionary * symbolLookupTable) {
        if (succeeded)
        {
            [expectation fulfill];
        }
    }];
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    NSSet *expectedRequestedAddresses = [NSSet setWithObjects:@"0x0000000103677652", @"0x000000010367765A", nil];
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedAddresses,
        expectedRequestedAddresses
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedLoadAddresses,
        [NSSet setWithObject:@"0x103660000"]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedExecutablePaths,
        [NSSet setWithObject:executableURL.path]
    );
    
    NSDictionary *expectedResults = @{
        @"0x0000000103677652" : @"0x0000000103677652 - 0x103660000",
        @"0x000000010367765A" : @"0x000000010367765A - 0x103660000",
    };
    XCTAssertEqualObjects(
        self.mockSymbolConverter.resultSymbolTable,
        expectedResults
    );
}

@end
