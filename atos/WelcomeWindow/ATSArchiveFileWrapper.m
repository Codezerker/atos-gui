//
//  ATSArchiveFileWrapper.m
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSArchiveFileWrapper.h"
#import "NSURL+ATSAddition.h"


@interface ATSArchiveFileWrapper ()

@property (nonatomic, strong) NSURL *fileURL;

@property (nonatomic, strong) NSImage *fileIcon;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSDate *creationDate;

@end


@implementation ATSArchiveFileWrapper

#pragma mark - Initializer

+ (instancetype)fileWrapperWithURL:(NSURL *)fileURL {
    return [[self alloc] initWithFileURL:fileURL];
}


- (instancetype)initWithFileURL:(NSURL *)fileURL {
    if (self = [super init]) {
        _fileURL = fileURL;
    }

    return self;
}


#pragma mark - Getters

- (NSImage *)fileIcon {
    if (!_fileIcon) {
        _fileIcon = [_fileURL ats_valueForProperty:NSURLEffectiveIconKey];
    }

    return _fileIcon;
}


- (NSString *)appName {
    if (!_appName) {
        _appName = @"<App Name>";
    }

    return _appName;
}


- (NSDate *)creationDate {
    if (!_creationDate) {
        _creationDate = [_fileURL ats_valueForProperty:NSURLCreationDateKey];
    }

    return _creationDate;
}

@end
