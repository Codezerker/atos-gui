//
//  atosTests.m
//  atosTests
//
//  Created by eyeplum on 3/23/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSSymbolParser.h"


static NSString * const kCrashLogFragment =
    @"0x000000010ffd78f4 0x10ffd6000 + 6388";

static NSString * const kSampleTextFragment =
    @"    +       2700 ???  load address 0x1026c7000 + 0x34c5c  [0x1026fbc5c]\n"
     "    +         2700 ???  load address 0x1026c7000 + 0x34a8b  [0x1026fba8b]\n"
     "    +           2700 ???  load address 0x1026c7000 + 0x340a4  [0x1026fb0a4]\n";


@interface ATSTests : XCTestCase <ATSSymbolParserDelegate>

@property (nonatomic, strong) ATSSymbolParser *parser;

@end


@implementation ATSTests

#pragma mark - Set Up and Tear Down

- (void)setUp {
    [super setUp];
    self.parser = [[ATSSymbolParser alloc] initWithDelegate:self];
}


- (void)tearDown {
    self.parser = nil;
    [super tearDown];
}


#pragma mark - Tests

- (void)testCrashLogParsing {
    [self.parser parseWithString:kCrashLogFragment];
    XCTAssertEqualObjects([self.parser symbolString], kCrashLogFragment);
    XCTAssertEqualObjects([self.parser loadAddress], @"0x10ffd6000");
    XCTAssertTrue([[self.parser symbolAddresses] containsObject:@"0x000000010ffd78f4"]);
}


- (void)testSampleTextParsing {
    [self.parser parseWithString:kSampleTextFragment];
    XCTAssertEqualObjects([self.parser symbolString], kSampleTextFragment);
    XCTAssertEqualObjects([self.parser loadAddress], @"0x1026c7000");
    XCTAssertTrue([[self.parser symbolAddresses] containsObject:@"0x1026fbc5c"]);
}

@end
