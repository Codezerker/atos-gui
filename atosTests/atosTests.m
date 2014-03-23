//
//  atosTests.m
//  atosTests
//
//  Created by eyeplum on 3/23/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ATSTests : XCTestCase

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

- (void)testExample
{
    NSString *string1 = [NSString stringWithFormat:@"%@", @"Hello World."];
    NSString *string2 = @"Hello World.";
    XCTAssertEqualObjects(string1, string2);
}

@end
