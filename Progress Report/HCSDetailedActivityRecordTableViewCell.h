//
//  HCSDetailedActivityRecordTableViewCell.h
//  Track This Moment
//
//  Created by Roger on 7/28/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCSDetailedActivityRecordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeLabel;
@property (weak, nonatomic) IBOutlet UILabel *inactiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *pauseNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *longerEventTitleLabel;

@end
