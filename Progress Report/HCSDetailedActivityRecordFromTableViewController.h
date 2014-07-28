//
//  HCSDetailedActivityRecordFromTableViewController.h
//  Track This Moment
//
//  Created by Roger on 7/27/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSActivityRecord.h"

@interface HCSDetailedActivityRecordFromTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) HCSActivityRecord *record;

@end
