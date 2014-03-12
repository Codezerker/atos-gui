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

@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) NSString *applicationFilePath;
@property (nonatomic, strong, readonly) NSString *symbolString;

@property (nonatomic, weak) id<ATSSymbolParserDelegate> delegate;

- (instancetype)init;
- (void)parseWithString:(NSString *)symbolString;

@end
