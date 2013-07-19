//
//  ATSCrashListViewController.m
//  atos
//
//  Created by Yan Li on 7/19/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSCrashListViewController.h"


@interface ATSCrashListViewController ()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *listView;

- (IBAction)addCrashListItem:(id)sender;
- (IBAction)removeCrashListItem:(id)sender;

@property (nonatomic, strong) NSMutableArray *items;

@end


@implementation ATSCrashListViewController

#pragma mark - IBActions

- (void)addCrashListItem:(id)sender {
    [self.items addObject:@"dummy"];
    [self.listView reloadData];
}


- (void)removeCrashListItem:(id)sender {
    if (self.listView.selectedRowIndexes.count > 0) {
        [self.items removeObjectsAtIndexes:self.listView.selectedRowIndexes];
        [self.listView reloadData];
    }
}


#pragma mark - NSTableView Delegate and Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.items.count;
}


#pragma Getters

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    
    return _items;
}

@end
