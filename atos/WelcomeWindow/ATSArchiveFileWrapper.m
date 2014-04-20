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
@property (nonatomic, strong) NSDictionary *archiveBundleInfo;

@property (nonatomic, strong) NSImage *fileIcon;
@property (nonatomic, strong) NSImage *appIcon;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *appComment;
@property (nonatomic, strong) NSDate *appCreationDate;
@property (nonatomic, strong, getter=isSubmittedToAppStore) NSNumber *submittedToAppStore;

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

#pragma mark - File Properties

- (NSImage *)fileIcon {
    if (!_fileIcon) {
        _fileIcon = [_fileURL ats_valueForProperty:NSURLEffectiveIconKey];
    }

    return _fileIcon;
}


#pragma mark - Bundle Properties


- (NSDictionary *)archiveBundleInfo {
    if (!_archiveBundleInfo) {
        _archiveBundleInfo = [[NSBundle bundleWithURL:_fileURL] infoDictionary];
    }

    return _archiveBundleInfo;
}


- (NSImage *)appIcon {
    if (!_appIcon) {
        NSString *iconPath = [self.archiveBundleInfo[@"ApplicationProperties"][@"IconPaths"] firstObject];
        if (iconPath) {
            NSURL *iconURL = [[_fileURL URLByAppendingPathComponent:@"Products"] URLByAppendingPathComponent:iconPath];
            _appIcon = [[NSImage alloc] initWithContentsOfURL:iconURL];
        } else {
            _appIcon = [self fileIcon];
        }
    }

    return _appIcon;
}


- (NSString *)appName {
    if (!_appName) {
        _appName = self.archiveBundleInfo[@"Name"];
    }

    return _appName;
}


- (NSString *)appVersion {
    if (!_appVersion) {
        NSDictionary *info = self.archiveBundleInfo;
        _appVersion = info[@"ApplicationProperties"][@"CFBundleShortVersionString"];

        NSString *versionNumber = info[@"ApplicationProperties"][@"CFBundleVersion"];
        if (versionNumber.length > 0 && ![_appVersion isEqualToString:versionNumber]) {
            _appVersion = [_appVersion stringByAppendingFormat:@" (%@)", versionNumber];
        }
    }

    return _appVersion;
}


- (NSDate *)appCreationDate {
    if (!_appCreationDate) {
        _appCreationDate = self.archiveBundleInfo[@"CreationDate"];
    }

    return _appCreationDate;
}


- (NSString *)appComment {
    if (!_appComment) {
        _appComment = self.archiveBundleInfo[@"Comment"];
    }

    return _appComment;
}


- (NSNumber *)isSubmittedToAppStore {
    if (!_submittedToAppStore) {
        _submittedToAppStore = @([self.archiveBundleInfo[@"Status"] isEqualToString:@"Submitted"]);
    }

    return _submittedToAppStore;
}

@end
