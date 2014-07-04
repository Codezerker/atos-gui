//
//  ATSArchiveFileTableCellView.m
//  atos
//
//  Created by eyeplum on 4/20/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "ATSArchiveFileTableCellView.h"


@interface ATSArchiveFileTableCellView ()

@property (nonatomic, weak) IBOutlet NSImageView *iconView;
@property (nonatomic, weak) IBOutlet NSTextField *nameLabel;
@property (nonatomic, weak) IBOutlet NSTextField *dateLabel;
@property (nonatomic, weak) IBOutlet NSTextField *statusLabel;

@end


@implementation ATSArchiveFileTableCellView

- (void)setFileWrapper:(ATSArchiveFileWrapper *)fileWrapper {
    _fileWrapper = fileWrapper;

    self.iconView.image = fileWrapper.appIcon;
    
    self.nameLabel.stringValue = [NSString stringWithFormat:@"%@ %@",
                                  fileWrapper.appName,
                                  fileWrapper.appComment ?: fileWrapper.appVersion] ?: @"";

    self.dateLabel.stringValue =
            [fileWrapper.appCreationDate descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:nil locale:nil] ?: @"";

    [self.statusLabel setHidden:!fileWrapper.isSubmittedToAppStore.boolValue];
}

@end
