//
//  HCSActivityRecord.m
//  Track Today
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
- (NSMutableArray *)startDateArray
{
    if (!_startDateArray) _startDateArray = [NSMutableArray array];
    return _startDateArray;
}
- (NSMutableArray *)endDateArray
{
    if (!_endDateArray) _endDateArray = [NSMutableArray array];
    return _endDateArray;
}
- (NSMutableArray *)secondsArray
{
    if (!_secondsArray) _secondsArray = [NSMutableArray array];
    return _secondsArray;
}
- (NSMutableArray *)pausedSecondsArray
{
    if (!_pausedSecondsArray) _pausedSecondsArray = [NSMutableArray array];
    return _pausedSecondsArray;
}
- (NSMutableArray *)pauseNumberArray
{
    if (!_pauseNumberArray) _pauseNumberArray = [NSMutableArray array];
    return _pauseNumberArray;
}
- (NSMutableArray *)eventTitleArray
{
    if (!_eventTitleArray) _eventTitleArray = [NSMutableArray array];
    return _eventTitleArray;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:@"titleDuh"];
    [encoder encodeInt:self.activityNumber forKey:@"activityNumber"];
    [encoder encodeInt:self.pauseNumber forKey:@"pauseNumber"];
    [encoder encodeDouble:self.seconds forKey:@"seconds"];
    [encoder encodeDouble:self.pausedSeconds forKey:@"pausedSeconds"];
    [encoder encodeObject:self.startDateArray forKey:@"startDateArray"];
    [encoder encodeObject:self.endDateArray forKey:@"endDateArray"];
    [encoder encodeObject:self.secondsArray forKey:@"secondsArray"];
    [encoder encodeObject:self.pausedSecondsArray forKey:@"pausedSecondsArray"];
    [encoder encodeObject:self.pauseNumberArray forKey:@"pauseNumberArray"];
    [encoder encodeObject:self.eventTitleArray forKey:@"eventTitleArray"];
}
/* @property (nonatomic, strong) NSMutableArray *startDateArray;
 @property (nonatomic, strong) NSMutableArray *endDateArray;
 @property (nonatomic, strong) NSMutableArray *secondsArray;
 @property (nonatomic, strong) NSMutableArray *pausedSecondsArray;
 @property (nonatomic, strong) NSMutableArray *pauseNumberArray;
 */

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.title = [decoder decodeObjectForKey:@"titleDuh"];
        self.seconds = [decoder decodeDoubleForKey:@"seconds"];
        self.pausedSeconds = [decoder decodeDoubleForKey:@"pausedSeconds"];
        self.activityNumber = [decoder decodeIntForKey:@"activityNumber"];
        self.pauseNumber = [decoder decodeIntForKey:@"pauseNumber"];
        self.startDateArray = [decoder decodeObjectForKey:@"startDateArray"];
        self.endDateArray = [decoder decodeObjectForKey:@"endDateArray"];
        self.secondsArray = [decoder decodeObjectForKey:@"secondsArray"];
        self.pausedSecondsArray = [decoder decodeObjectForKey:@"pausedSecondsArray"];
        self.pauseNumberArray = [decoder decodeObjectForKey:@"pauseNumberArray"];
        self.eventTitleArray = [decoder decodeObjectForKey:@"eventTitleArray"];
    }
    
    return self;
}
/*
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    HCSActivityRecord *newRecord = [[HCSActivityRecord alloc]init];
    newRecord.title = [self.title copy];
    newRecord.seconds = self.seconds; //no copy for nonobjects?
    newRecord.pausedSeconds = self.pausedSeconds;
    newRecord.pauseNumber = self.pauseNumber;
    newRecord.activityNumber = self.activityNumber;
    newRecord.secondsArray = [self.secondsArray copy];
    newRecord.startDateArray = [self.startDateArray copy];
    newRecord.endDateArray = [self.endDateArray copy];
    newRecord.pausedSecondsArray = [self.pausedSecondsArray copy];
    newRecord.pauseNumberArray = [self.pauseNumberArray copy];
    newRecord.eventTitleArray = [self.eventTitleArray copy];
    return newRecord;
}
*/
@end
