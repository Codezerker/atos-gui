//
//  atosTests.m
//  atosTests
//
//  Created by eyeplum on 3/23/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATSSymbolParser.h"

@interface ATSTests : XCTestCase <ATSSymbolParserDelegate>

@end

@implementation ATSTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoadAddressParsingInCrashLog
{
    ATSSymbolParser *parser = [[ATSSymbolParser alloc] initWithDelegate:self];
    [parser parseWithString:@"0x000000010ffd78f4 0x10ffd6000 + 6388"];
    XCTAssertEqualObjects([parser loadAddress], @"0x10ffd6000");
}

@end
