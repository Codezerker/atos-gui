//
//  ATSCrashListCellView.h
//  atos
//
//  Created by Yan Li on 7/19/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ATSCrashListCellViewDelegate;


@interface ATSCrashListCellView : NSTableCellView

@property (weak) IBOutlet NSButton *checkBox;
@property (weak) IBOutlet NSTextField *symbol;

- (IBAction)checkBoxChecked:(id)sender;

@property (weak) id<ATSCrashListCellViewDelegate> delegate;

@end


@protocol ATSCrashListCellViewDelegate<NSObject>

- (void)cellView:(ATSCrashListCellView *)cellView checkBoxCheckedTo:(NSCellStateValue)state;
- (void)cellView:(ATSCrashListCellView *)cellView symbolChangedTo:(NSString *)symbol;

@end