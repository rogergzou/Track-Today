//
//  HCSActivityRecord.h
//  Track Today
//
//  Created by Roger on 7/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCSActivityRecord : NSObject //<NSCopying>

@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) NSDate *startDate;
//@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic) NSTimeInterval seconds;
@property (nonatomic) NSTimeInterval pausedSeconds;
@property (nonatomic) int pauseNumber;
@property (nonatomic) int activityNumber;
@property (nonatomic, strong) NSMutableArray *startDateArray;
@property (nonatomic, strong) NSMutableArray *endDateArray;
@property (nonatomic, strong) NSMutableArray *secondsArray;
@property (nonatomic, strong) NSMutableArray *pausedSecondsArray;
@property (nonatomic, strong) NSMutableArray *pauseNumberArray;
@property (nonatomic, strong) NSMutableArray *eventTitleArray;

@end
