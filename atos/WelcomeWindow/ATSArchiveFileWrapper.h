//
//  ATSArchiveFileWrapper.h
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//



@interface ATSArchiveFileWrapper : NSObject

@property (nonatomic, strong, readonly) NSImage *fileIcon;
@property (nonatomic, strong, readonly) NSImage *appIcon;
@property (nonatomic, strong, readonly) NSString *appName;
@property (nonatomic, strong, readonly) NSString *appVersion;
@property (nonatomic, strong, readonly) NSString *appComment;
@property (nonatomic, strong, readonly) NSDate *appCreationDate;
@property (nonatomic, strong, readonly, getter=isSubmittedToAppStore) NSNumber *submittedToAppStore;

+ (instancetype)fileWrapperWithURL:(NSURL *)fileURL;
- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end
