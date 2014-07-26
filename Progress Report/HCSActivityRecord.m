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

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:@"titleDuh"];
    [encoder encodeInt:self.activityNumber forKey:@"activityNumber"];
    [encoder encodeInt:self.pauseNumber forKey:@"pauseNumber"];
    [encoder encodeDouble:self.seconds forKey:@"seconds"];
    [encoder encodeDouble:self.pausedSeconds forKey:@"pausedSeconds"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.title = [decoder decodeObjectForKey:@"titleDuh"];
        self.seconds = [decoder decodeDoubleForKey:@"seconds"];
        self.pausedSeconds = [decoder decodeDoubleForKey:@"pausedSeconds"];
        self.activityNumber = [decoder decodeIntForKey:@"activityNumber"];
        self.pauseNumber = [decoder decodeIntForKey:@"pauseNumber"];
    }
    
    return self;
}

@end
