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

- (void)testSimpleCrashReportMatching
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
                     overrideLoadAddress:nil
                     withCompletionBlock:^(NSDictionary * _Nonnull symbolLookupTable) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    NSArray *expectedRequestedAddresses = @[@"0x0000000103677652", @"0x000000010367765A"];
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedAddresses,
        expectedRequestedAddresses
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedLoadAddresses,
        @[@"0x103660000"]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedExecutablePaths,
        @[executableURL.path]
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

- (void)testSimpleCrashReportMatchingWithWhitespaceBinaryImageNames
{
    NSArray *lines = @[
        @"7   Report Crash                       0x0000000103677652 0x103660000 + 95826",
        @"8   Report Crash                       0x000000010367765A 0x103660000 + 95834",
        @"0x103660000 -        0x10367fff7  Report Crash (15007) <BCE573F4-0EF5-3A29-9D8A-D54EF484BC22> /System/Library/CoreServices/ReportCrash",
    ];
    NSString *string = [lines componentsJoinedByString:@"\n"];
    
    NSURL *executableURL = [NSURL fileURLWithPath:@"/path/to/test.app"];
    
    __block XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Symbolicating completed"];
    [self.symbolicator symbolicateString:string
                           executableURL:executableURL
                     overrideLoadAddress:nil
                     withCompletionBlock:^(NSDictionary * _Nonnull symbolLookupTable) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    NSArray *expectedRequestedAddresses = @[@"0x0000000103677652", @"0x000000010367765A"];
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedAddresses,
        expectedRequestedAddresses
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedLoadAddresses,
        @[@"0x103660000"]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedExecutablePaths,
        @[executableURL.path]
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

- (void)testSimpleCrashReportMatchingWithLoadAddressOverride
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
                     overrideLoadAddress:@"0xC0FFEE"
                     withCompletionBlock:^(NSDictionary * _Nonnull symbolLookupTable) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    NSArray *expectedRequestedAddresses = @[@"0x0000000103677652", @"0x000000010367765A"];
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedAddresses,
        expectedRequestedAddresses
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedLoadAddresses,
        @[@"0xC0FFEE"]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedExecutablePaths,
        @[executableURL.path]
    );
    
    NSDictionary *expectedResults = @{
        @"0x0000000103677652" : @"0x0000000103677652 - 0xC0FFEE",
        @"0x000000010367765A" : @"0x000000010367765A - 0xC0FFEE",
    };
    XCTAssertEqualObjects(
        self.mockSymbolConverter.resultSymbolTable,
        expectedResults
    );
}

- (void)testFreeStyleMatching
{
    NSArray *lines = @[
        @"Some random string with hexadecimal addresses such as 0x000000010367765A 0x000000010367765A",
        @"And 0x000000010367765B 0x000000010367765C",
    ];
    NSString *string = [lines componentsJoinedByString:@"\n"];
    
    NSURL *executableURL = [NSURL fileURLWithPath:@"/path/to/test.app"];
    
    __block XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Symbolicating completed"];
    [self.symbolicator symbolicateString:string
                           executableURL:executableURL
                     overrideLoadAddress:nil
                     withCompletionBlock:^(NSDictionary * _Nonnull symbolLookupTable) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    NSArray *expectedRequestedAddresses = @[@"0x000000010367765A", @"0x000000010367765B", @"0x000000010367765C"];
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedAddresses,
        expectedRequestedAddresses
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedLoadAddresses,
        @[@"LoadAddressNotFound"]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedExecutablePaths,
        @[executableURL.path]
    );
    
    NSDictionary *expectedResults = @{
        @"0x000000010367765A" : @"0x000000010367765A - LoadAddressNotFound",
        @"0x000000010367765B" : @"0x000000010367765B - LoadAddressNotFound",
        @"0x000000010367765C" : @"0x000000010367765C - LoadAddressNotFound",
    };
    XCTAssertEqualObjects(
        self.mockSymbolConverter.resultSymbolTable,
        expectedResults
    );
}

- (void)testFreeStyleMatchingWithLoadAddressOverride
{
    NSArray *lines = @[
        @"Some random string with hexadecimal addresses such as 0x000000010367765A 0x000000010367765A",
        @"And 0x000000010367765B 0x000000010367765C",
    ];
    NSString *string = [lines componentsJoinedByString:@"\n"];
    
    NSURL *executableURL = [NSURL fileURLWithPath:@"/path/to/test.app"];
    
    __block XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Symbolicating completed"];
    [self.symbolicator symbolicateString:string
                           executableURL:executableURL
                     overrideLoadAddress:@"0xC0FFEE"
                     withCompletionBlock:^(NSDictionary * _Nonnull symbolLookupTable) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    NSArray *expectedRequestedAddresses = @[@"0x000000010367765A", @"0x000000010367765B", @"0x000000010367765C"];
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedAddresses,
        expectedRequestedAddresses
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedLoadAddresses,
        @[@"0xC0FFEE"]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedExecutablePaths,
        @[executableURL.path]
    );
    
    NSDictionary *expectedResults = @{
        @"0x000000010367765A" : @"0x000000010367765A - 0xC0FFEE",
        @"0x000000010367765B" : @"0x000000010367765B - 0xC0FFEE",
        @"0x000000010367765C" : @"0x000000010367765C - 0xC0FFEE",
    };
    XCTAssertEqualObjects(
        self.mockSymbolConverter.resultSymbolTable,
        expectedResults
    );
}

- (void)testMatchingWithNoAddresses
{
    NSArray *lines = @[
        @"hello world",
    ];
    NSString *string = [lines componentsJoinedByString:@"\n"];
    
    NSURL *executableURL = [NSURL fileURLWithPath:@"/path/to/test.app"];
    
    __block XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Symbolicating completed"];
    [self.symbolicator symbolicateString:string
                           executableURL:executableURL
                     overrideLoadAddress:nil
                     withCompletionBlock:^(NSDictionary * _Nonnull symbolLookupTable) {
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:1.0];
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedAddresses,
        @[]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedLoadAddresses,
        @[]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.requestedExecutablePaths,
        @[]
    );
    
    XCTAssertEqualObjects(
        self.mockSymbolConverter.resultSymbolTable,
        @{}
    );
}

@end
