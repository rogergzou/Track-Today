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

@interface HCSViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UITextField *titleButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (nonatomic) BOOL isStart;
@property (nonatomic) BOOL isPaused;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *pauseStartDate;
@property (nonatomic) NSTimeInterval pausedSeconds; //lol typedef double
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int seconds;

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
        
        //reset stored vars
        self.seconds = 0;
        self.pausedSeconds = 0;
        self.timerLabel.text = @"00:00";
    }
    
    self.isStart = !self.isStart;
    [self updateUI];
}

- (IBAction)pauseButtonPushed:(UIButton *)sender {
    if (self.isPaused)
        [self resumeTimer];
    else
        [self pauseTimer];
    
    self.isPaused = !self.isPaused;
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
    //NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    EKEventStore *eventStore = [[EKEventStore alloc]init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = self.titleButton.text;
    event.startDate = self.startDate;
    event.endDate = self.endDate;
    //event.location
    
    int mins = floor(self.seconds/60);
    int secs = self.seconds - (mins * 60);
    int pmins = floor(self.pausedSeconds/60);
    int psecs = floor(self.pausedSeconds - (pmins * 60));
    event.notes = [NSString stringWithFormat:@"%i:%02i active, %i:%02i paused", mins, secs, pmins, psecs];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            //user lets calendar access
            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
            NSError *err;
            [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
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
    //CFRunLoopGetCurrent();
    /*
     dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(increaseTimerCount:) userInfo:nil repeats:YES];
    });
     */
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(increaseTimerCount:) userInfo:nil repeats:YES];
    //self.timer = [NSTimer scheduledTimerWithTimeInterval: invocation: repeats:]
}
- (void)increaseTimerCount: (NSTimer *)timer
{
    //see http://stackoverflow.com/questions/1189252/how-to-convert-an-nstimeinterval-seconds-into-minutes if want to convert to more complex hours/days/months
    //double secs = timer.timeInterval;
    
    //damn misleading documentation
    /*
     int mins = floor(timer.timeInterval/60);
    int secs = timer.timeInterval - (mins * 60);
    */
    self.seconds++;
    
    int mins = floor(self.seconds/60);
    int secs = self.seconds - (mins * 60);
     self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
}
- (void)endTimer
{
    [self.timer invalidate];
}
- (void)pauseTimer
{
    //ty to http://stackoverflow.com/questions/347219/how-can-i-programmatically-pause-an-nstimer
    self.pauseStartDate = [NSDate date];
    [self.timer setFireDate:[NSDate distantFuture]]; //LOL NSDate distantFuture is actually a thing...
}
- (void)resumeTimer
{
    float pauseTimeWas = -1 * [self.pauseStartDate timeIntervalSinceNow]; //results in positive #
    [self.timer setFireDate:[self.startDate initWithTimeInterval:pauseTimeWas sinceDate:self.startDate]];
    
    //tracks pause time
    self.pausedSeconds += pauseTimeWas;
}
- (void)updateUI
{
    if (self.isStart) {
        [self.bigButton setTitle:@"Start" forState:UIControlStateNormal];
        self.bigButton.backgroundColor = [UIColor greenColor];
        self.pauseButton.hidden = YES;
    } else {
        [self.bigButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.bigButton.backgroundColor = [UIColor colorWithRed:1 green:0.0335468 blue:0.00867602 alpha:1];
        self.pauseButton.hidden = NO;
        
        if (self.isPaused) {
            [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
            self.pauseButton.backgroundColor = [UIColor colorWithRed:0.720482 green:1 blue:0.632028 alpha:1];
        } else {
            [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
            self.pauseButton.backgroundColor = [UIColor lightGrayColor];
        }
        
    }
    
    //timerLabel updated on increaseTimerCount: method
}
- (int)seconds
{
    if (!_seconds) _seconds = 0;
    return _seconds;
}
- (NSTimeInterval)pausedSeconds
{
    if (!_pausedSeconds) _pausedSeconds = 0;
    return _pausedSeconds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //set defaults
    self.isStart = YES;
    self.isPaused = NO;
    self.timerLabel.text = @"00:00";
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

//bigButton was pos 85 328,150 138 size

#pragma mark - UITextFieldDelegate
//yay copypasta from prototypeC

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void) setViewMoveUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        //move view origin up so textfield moves up
        //increase size of view so area behind keyboard is covered up
        rect.origin.y -= 80.0;
        rect.size.height += 80.0;
    } else {
        //revert
        rect.origin.y += 80.0;
        rect.size.height -= 80.0;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}
- (void)keyboardShow:(NSNotification *)notification {
    if (self.view.frame.origin.y >= 0) {
        [self setViewMoveUp:YES];
    } else if (self.view.frame.origin.y < 0) {
        [self setViewMoveUp:NO];
    }
}
- (void)keyboardHide:(NSNotification *)notification {
    if (self.view.frame.origin.y >= 0) {
        [self setViewMoveUp:YES];
    } else if (self.view.frame.origin.y < 0) {
        [self setViewMoveUp:NO];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
