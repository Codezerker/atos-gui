//
//  ATSCrashListViewController.m
//  atos
//
//  Created by Yan Li on 7/19/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSCrashListViewController.h"


@interface ATSCrashListViewController ()<NSTableViewDelegate, NSTableViewDataSource>

- (IBAction)addCrashList:(id)sender;
- (IBAction)removeCrashList:(id)sender;

@end


@implementation ATSCrashListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


#pragma mark - IBActions

- (void)addCrashList:(id)sender {
    NSLog(@"add crash list...");
}


- (void)removeCrashList:(id)sender {
    NSLog(@"remove crash list...");
}


#pragma mark - NSTableView Delegate and Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 5;
}

@end
