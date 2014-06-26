//
//  HCSViewController.m
//  Progress Report
//
//  Created by Roger on 6/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSViewController.h"
#import <EventKit/EventKit.h>
//@import EventKitUI;

@interface HCSViewController ()

@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UITextField *titleButton;
@property (nonatomic) BOOL isStart;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@end

@implementation HCSViewController

// default isStart = YES
- (BOOL) isStart
{
    if (!_isStart) _isStart = YES;
    return _isStart;
}

- (void)scheduleEvent
{
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSLog(@"meh");
    EKEventStore *eventStore = [[EKEventStore alloc]init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = self.titleButton.text;
    event.startDate = self.startDate;
    event.endDate = self.endDate;
    NSLog(@"much success");
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        NSLog(@"gran");
        if (granted) {
            //user lets calendar access
            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
            NSError *err;
            [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
            NSLog(@"win");
        } else {
            //user no calendar access
            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
            NSError *err;
            [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        }
    }];
}

- (void)updateUI
{
    if (self.isStart)
        self.bigButton.titleLabel.text = @"Start";
    else
        self.bigButton.titleLabel.text = @"Stop";
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateUI];
    //self.startDate = [NSDate date];
    //self.endDate = [[NSDate alloc] initWithTimeInterval:600 sinceDate:self.startDate];
    //[self scheduleEvent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
