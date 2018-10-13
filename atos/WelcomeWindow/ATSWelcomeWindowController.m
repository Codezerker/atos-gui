//
//  ATSWelcomeWindowController.m
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSWelcomeWindowController.h"
#import "ATSMainWindowController.h"
#import "ATSArchiveFileWrapper.h"
#import "ATSArchiveFileTableCellView.h"


static NSString * const kXCArchiveFilePath = @"/Library/Developer/Xcode/Archives";
static NSString * const kCellID = @"com.codezerker.archiveCell";
static NSString * const kFileExtensionXcodeArchive = @"xcarchive";
static NSString * const kFileExtensionApplicationBundle = @"app";


@interface ATSWelcomeWindowController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTextField *versionLabel;
@property (nonatomic, strong) NSArray *archiveFileWrappers;

- (IBAction)openOther:(id)sender;

@end


@implementation ATSWelcomeWindowController

#pragma mark - Initializer

- (id)init {
    if (self = [super initWithWindowNibName:[self className]]) {
        _archiveFileWrappers = [NSMutableArray array];
    }

    return self;
}


#pragma mark - Window Lifecycle

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupVersionLabel];
    [self setupTableView];
    [self scanArchiveFolder];
}


- (void)setupVersionLabel {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"Version %@ (%@)",
                    info[@"CFBundleShortVersionString"],
                    info[(NSString *) kCFBundleVersionKey]];
    [self.versionLabel setStringValue:version];
}


- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.doubleAction = @selector(tableViewDidBeDoubleClicked:);
}


- (void)scanArchiveFolder {
    NSArray *prefetchKeys = @[NSURLIsPackageKey, NSURLCreationDateKey, NSURLEffectiveIconKey];
    NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles;
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[self archiveURL]
                                                                      includingPropertiesForKeys:prefetchKeys
                                                                                         options:options
                                                                                    errorHandler:NULL];

    NSMutableArray *wrappers = [NSMutableArray array];
    for (NSURL *fileURL in directoryEnumerator) {
        NSNumber *isPackage;
        [fileURL getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
        if ([isPackage boolValue]) {
            ATSArchiveFileWrapper *wrapper = [ATSArchiveFileWrapper fileWrapperWithURL:fileURL];
            if (wrapper) {
                [wrappers addObject:wrapper];
            }
        }
    }
    self.archiveFileWrappers = [[wrappers reverseObjectEnumerator] allObjects];

    [self.tableView reloadData];
}


- (NSURL *)archiveURL {
    NSURL *homeDir = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
    NSURL *archiveURL = [homeDir URLByAppendingPathComponent:kXCArchiveFilePath isDirectory:YES];
    return archiveURL;
}


#pragma mark - NSTableView Delegate & Data Source

- (void)tableViewDidBeDoubleClicked:(id)sender {
    ATSArchiveFileWrapper *fileWrapper = self.archiveFileWrappers[(NSUInteger) self.tableView.clickedRow];
    [self postNotificationWithFileWrapper:fileWrapper];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.archiveFileWrappers.count;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ATSArchiveFileTableCellView *cellView = [tableView makeViewWithIdentifier:kCellID owner:self];
    cellView.fileWrapper = self.archiveFileWrappers[(NSUInteger) row];
    return cellView;
}


#pragma mark - IBAction

- (IBAction)openOther:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:@[kFileExtensionXcodeArchive, kFileExtensionApplicationBundle]];

    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            if ([[[openPanel.URLs firstObject] pathExtension] isEqualToString:kFileExtensionXcodeArchive]) {
                ATSArchiveFileWrapper *fileWrapper = [ATSArchiveFileWrapper fileWrapperWithURL:[openPanel.URLs firstObject]];
                [self postNotificationWithFileWrapper:fileWrapper];
            } else if ([openPanel.URLs firstObject]) {
                [self postNotificationWithFileURL:[openPanel.URLs firstObject]];
            }
        }
    }];

}


#pragma mark - Notification Helper

- (void)postNotificationWithFileWrapper:(ATSArchiveFileWrapper *)fileWrapper {
    [[NSNotificationCenter defaultCenter] postNotificationName:ATSWelcomeWindowDidSelectArchiveNotification
                                                        object:self
                                                      userInfo:@{ATSArchiveFileWrapperKey:fileWrapper}];
}


- (void)postNotificationWithFileURL:(NSURL *)fileURL {
    [[NSNotificationCenter defaultCenter] postNotificationName:ATSWelcomeWindowDidSelectAppNotification
                                                        object:self
                                                      userInfo:@{ATSAppFileURLKey:fileURL}];
}


@end
