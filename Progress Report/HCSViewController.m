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

- (IBAction)buttonPushed:(UIButton *)sender {
    /*
    NSLog(self.isStart ? @"y" : @"n");
    BOOL whatTheShitIsThis = !self.isStart;
    NSLog(whatTheShitIsThis ? @"y" : @"n");
    self.isStart = whatTheShitIsThis;
    NSLog(self.isStart ? @"ye" : @"no");
    NSLog(!self.isStart ? @"yes" : @"noo");
    */
    
    if (self.isStart) {
        self.startDate = [NSDate date];
        [self beginTimer];
    } else {
        self.endDate = [NSDate date];
        [self endTimer];
        [self scheduleEvent];
    }
    
    self.isStart = !self.isStart;
    [self updateUI];
}

// default isStart = YES
/*
 //why the shit does this code break it
 //edit nvm http://stackoverflow.com/questions/16082003/property-doesnt-set-after-lazy-initialization-objective-c screw these primitive types
- (BOOL) isStart
{
    if (!_isStart) {
        _isStart = YES;
    }
    return _isStart;
}
 */

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

- (void)beginTimer
{
    
}
- (void)endTimer
{
    
}

- (void)updateUI
{
    if (self.isStart)
        //self.bigButton.titleLabel.text = @"Start";
        [self.bigButton setTitle:@"Start" forState:UIControlStateNormal];
    else
        //self.bigButton.titleLabel.text = @"Stop";
        [self.bigButton setTitle:@"Stop" forState:UIControlStateNormal];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //default bool value at start
    self.isStart = YES;
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
