//
//  ATSCrashListCellView.m
//  atos
//
//  Created by Yan Li on 7/19/13.
//  Copyright (c) 2013 eyeplum. All rights reserved.
//

#import "ATSCrashListCellView.h"


@interface ATSCrashListCellView()<NSTextFieldDelegate>

@end


@implementation ATSCrashListCellView

- (void)checkBoxChecked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellView:checkBoxCheckedTo:)]) {
        [self.delegate cellView:self checkBoxCheckedTo:self.checkBox.state];
    }
}


- (void)controlTextDidEndEditing:(NSNotification *)obj {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellView:symbolChangedTo:)]) {
        [self.delegate cellView:self symbolChangedTo:self.symbol.stringValue];
    }
}

@end
