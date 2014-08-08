//
//  HCSActivityRecordTableViewCell.h
//  Track Today
//
//  Created by Roger on 7/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCSActivityRecordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timesLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pausedTimeLabel;

@end
