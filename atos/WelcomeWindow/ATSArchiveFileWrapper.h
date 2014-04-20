//
//  ATSArchiveFileWrapper.h
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//



@interface ATSArchiveFileWrapper : NSObject

@property (nonatomic, strong, readonly) NSImage *fileIcon;
@property (nonatomic, strong, readonly) NSString *appName;
@property (nonatomic, strong, readonly) NSDate *creationDate;

+ (instancetype)fileWrapperWithURL:(NSURL *)fileURL;
- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end
