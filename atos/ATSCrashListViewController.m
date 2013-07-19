//
//  ATSCrashListViewController.m
//  atos
//
//  Created by Yan Li on 7/19/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSCrashListViewController.h"
#import "ATSCrashListCellView.h"
#import "ATSCrashSymbol.h"


@interface ATSCrashListViewController ()<NSTableViewDelegate, NSTableViewDataSource, ATSCrashListCellViewDelegate>

@property (weak) IBOutlet NSTableView *listView;

- (IBAction)addCrashListItem:(id)sender;
- (IBAction)removeCrashListItem:(id)sender;

@property (nonatomic, strong) NSMutableArray *items;

@end


@implementation ATSCrashListViewController

#pragma mark - IBActions

- (void)addCrashListItem:(id)sender {
    ATSCrashSymbol *symbol = [[ATSCrashSymbol alloc] initWithSymbol:@""];
    [self.items insertObject:symbol atIndex:0];
    [self.listView reloadData];
    
    [self beginEditRow];
}


- (void)beginEditRow {
    [self.listView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    NSTableRowView *rowView = [self.listView rowViewAtRow:0 makeIfNecessary:YES];
    ATSCrashListCellView *cellView = [rowView.subviews lastObject];
    [cellView.symbol becomeFirstResponder];
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


static NSString * cellID = @"CrashListCell";

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ATSCrashListCellView *cellView = [tableView makeViewWithIdentifier:cellID owner:self];
    cellView.delegate = self;
    
    ATSCrashSymbol *symbol = self.items[row];
    cellView.checkBox.state = symbol.checked;
    cellView.symbol.stringValue = symbol.symbol;
    
    if (symbol.checked == NSOnState) {
        cellView.symbol.textColor = [NSColor lightGrayColor];
    } else if (symbol.checked == NSOffState) {
        cellView.symbol.textColor = [NSColor textColor];
    }

    return cellView;
}


- (void)cellView:(ATSCrashListCellView *)cellView checkBoxCheckedTo:(NSCellStateValue)state {
    ATSCrashSymbol *symbolChanged = [self symbolForCellView:cellView];
    symbolChanged.checked = state;
    [self.listView reloadData]; // TODO: reload changed row only
}


- (void)cellView:(ATSCrashListCellView *)cellView symbolChangedTo:(NSString *)symbol {
    ATSCrashSymbol *symbolChanged = [self symbolForCellView:cellView];
    symbolChanged.symbol = symbol;    
    [self.listView reloadData]; // TODO: reload changed row only
}


- (ATSCrashSymbol *)symbolForCellView:(ATSCrashListCellView *)cellView {
    ATSCrashSymbol *symbolChanged;
    NSInteger changedIndex = [self.listView rowForView:cellView.superview];
    
    if (changedIndex >= 0) {
        symbolChanged = self.items[changedIndex];
    }
    
    return symbolChanged;
}


#pragma Getters

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    
    return _items;
}

@end
