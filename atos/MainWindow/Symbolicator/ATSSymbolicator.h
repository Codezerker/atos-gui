//
//  ATSSymbolicator.h
//  atos-gui
//
//  Created by Yan Li on 20/08/19.
//  Copyright © 2019 Codezerker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ATSSymbolicator;
@protocol ATSSymbolConverter <NSObject>

- (NSArray<NSString *> *)symbolicator:(ATSSymbolicator *)symbolicator
                  symbolsForAddresses:(NSArray<NSString *> *)addresses
                          loadAddress:(NSString *)loadAddress
                       executablePath:(NSString *)executablePath;

@end

@interface ATSSymbolicator : NSObject

@property (nonatomic, strong, readonly) id<ATSSymbolConverter> symbolConverter;
@property (nonatomic, assign) BOOL alwaysMatchAllHexadecimalStringsAsSymbolAddress;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithSymbolConverter:(id<ATSSymbolConverter>)symbolConverter NS_DESIGNATED_INITIALIZER;

- (void)symbolicateString:(NSString *)stringToSymbolicate
            executableURL:(NSURL *)executableURL
      overrideLoadAddress:(NSString * _Nullable)overrideLoadAddress
      withCompletionBlock:(void (^)(NSDictionary *symbolLookupTable))completion;

@end

NS_ASSUME_NONNULL_END
