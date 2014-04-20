//
//  ATSWelcomeWindowController.m
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSWelcomeWindowController.h"


static NSString * const kXCArchiveFilePath = @"/Library/Developer/Xcode/Archives";

@interface ATSWelcomeWindowController ()

@property (nonatomic, strong) NSArray *archiveFiles;

@end


@implementation ATSWelcomeWindowController

- (id)init {
    if (self = [super initWithWindowNibName:[self className]]) {
        // ...
    }

    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];

    NSArray *prefetchKeys = @[NSURLIsPackageKey, NSURLCreationDateKey, NSURLEffectiveIconKey];
    NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles;
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[self archiveURL]
                                                                      includingPropertiesForKeys:prefetchKeys
                                                                                         options:options
                                                                                    errorHandler:NULL];
    for (NSURL *fileURL in directoryEnumerator) {
        NSNumber *isPackage;
        [fileURL getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
        if ([isPackage boolValue]) {
            NSLog(@"%@", fileURL);
        }
    }
}


- (NSURL *)archiveURL {
    NSURL *homeDir = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
    NSURL *archiveURL = [homeDir URLByAppendingPathComponent:kXCArchiveFilePath isDirectory:YES];
    return archiveURL;
}

@end
