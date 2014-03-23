//
//  ATSSymbolParser.h
//  atos
//
//  Created by Yan Li on 3/12/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//


@class ATSSymbolParser;

@protocol ATSSymbolParserDelegate <NSObject>
@optional

- (void)symbolParser:(ATSSymbolParser *)parser didFindValidSymbol:(NSString *)symbol fromAddress:(NSString *)address;

@end


@interface ATSSymbolParser : NSObject

@property (nonatomic, strong, readonly) NSString *applicationName;
@property (nonatomic, strong, readonly) NSString *applicationFilePath;
@property (nonatomic, strong, readonly) NSString *symbolString;
@property (nonatomic, strong, readonly) NSString *loadAddress;
@property (nonatomic, strong, readonly) NSArray  *symbolAddresses;

@property (nonatomic, weak) id<ATSSymbolParserDelegate> delegate;

- (instancetype)initWithDelegate:(id<ATSSymbolParserDelegate>)delegate;
- (void)setApplicationLocationWithFilePath:(NSString *)applicationFilePath;
- (void)parseWithString:(NSString *)symbolString;

@end
