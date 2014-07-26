//
//  HCSActivityRecord.m
//  Track This Moment
//
//  Created by Roger on 7/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSActivityRecord.h"

@implementation HCSActivityRecord

- (NSTimeInterval)seconds
{
    if (!_seconds) _seconds = 0;
    return _seconds;
}
- (NSTimeInterval)pausedSeconds
{
    if (!_pausedSeconds) _pausedSeconds = 0;
    return _pausedSeconds;
}
- (int)activityNumber
{
    if (!_activityNumber) _activityNumber = 0;
    return _activityNumber;
}
- (int)pauseNumber
{
    if (!_pauseNumber) _pauseNumber = 0;
    return _pauseNumber;
}

@end
