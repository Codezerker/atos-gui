//
//  atosTests.m
//  atosTests
//
//  Created by eyeplum on 3/23/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATSSymbolParser.h"

static NSString * const kCrashLogTestFragment = @"0x000000010ffd78f4 0x10ffd6000 + 6388";

@interface ATSTests : XCTestCase <ATSSymbolParserDelegate>

@property (nonatomic, strong) ATSSymbolParser *parser;

@end

@implementation ATSTests

#pragma mark - Set Up and Tear Down

- (void)setUp
{
    [super setUp];
    
    self.parser = [[ATSSymbolParser alloc] initWithDelegate:self];
    [self.parser parseWithString:kCrashLogTestFragment];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests

- (void)testParserStringSetter
{
    XCTAssertEqualObjects([self.parser symbolString], kCrashLogTestFragment);
}

- (void)testLoadAddressParsingInCrashLog
{
    XCTAssertEqualObjects([self.parser loadAddress], @"0x10ffd6000");
}

@end
