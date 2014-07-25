//
//  HCSViewController.m
//  Progress Report
//
//  Created by Roger on 6/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSViewController.h"
#import <EventKit/EventKit.h>
#import "HCSShortcut.h"
#import "HCSShortCutViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HCSReminderTableViewController.h"
#import "HCSModifyReminderViewController.h"

//set reminder
//terminate, then reopen
//reminder is not there, only setReminder

const int scheduleAlertTextFieldTag = 4;
const int scheduleAlertTag = 1;
const int resetAlertTag = 2;
const int calendarAccessMissingAlertTag = 99999999;
const double roundButtonBorderWidth = 1.15;

@interface HCSViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UITextField *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *shortcutButton;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UIButton *addReminderButton;

@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@property (nonatomic, readwrite) BOOL isStart;
@property (nonatomic, readwrite) BOOL isPaused;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *pauseStartDate;
@property (nonatomic) UIAlertView *confirmAlertProperty;

@property (nonatomic) NSTimeInterval pausedSeconds; //lol typedef double
@property (strong, nonatomic) NSTimer *timer;
//MOVED PUBLIC SO APPDEL CAN ACCESS
//@property (nonatomic) int seconds;

@property (nonatomic) int pauseNumber;

@end



@implementation HCSViewController



- (IBAction)buttonPushed:(UIButton *)sender {
    if (self.isStart) {
        self.startDate = [NSDate date];
        [self beginTimer];
        self.isStart = !self.isStart;
    } else {
        self.endDate = [NSDate date];
        [self runScheduleAlert]; //will run scheduleEvent and handle resets
    }
    [self updateUI];
}

- (IBAction)pauseButtonPushed:(UIButton *)sender {
    if (self.isPaused)
        [self resumeTimer];
    else {
        [self pauseTimer];
        self.pauseNumber++;
    }
    //Moved to resume/pause timer methods so delegate works when app goes to background
    //self.isPaused = !self.isPaused;
    [self updateUI];
}
- (IBAction)resetButtonPushed:(UIButton *)sender {
    [self runResetAlert];
}
- (void)runResetAlert
{
    UIAlertView *resetAlert = [[UIAlertView alloc]initWithTitle:@"Reset?" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Reset", @"Cancel", nil];
    resetAlert.cancelButtonIndex = 1; //set cancel as cancel
    // tag for identification when handling
    resetAlert.tag = resetAlertTag;
    [resetAlert show];
}
- (void)runScheduleAlert
{
    NSString *startDateString = [NSDateFormatter localizedStringFromDate:self.startDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
    NSString *endDateString = [NSDateFormatter localizedStringFromDate:self.endDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
    NSDate *startDateOnly = self.startDate;
    NSDate *endDateOnly = self.endDate;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDateOnly interval:NULL forDate:startDateOnly];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&endDateOnly interval:NULL forDate:endDateOnly];
    if ([startDateOnly compare:endDateOnly] == NSOrderedSame) {
        //endDateString = [endDateString substringFromIndex:[endDateString length]-10];
        endDateString = [endDateString componentsSeparatedByString:@", "][1];
    }
    
    UIAlertView *confirmAlert = [[UIAlertView alloc]initWithTitle:@"Schedule" message:[NSString stringWithFormat:@"Place event onto iCal? %@ to %@", startDateString, endDateString] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", @"Cancel", nil];
    confirmAlert.cancelButtonIndex = 1; //set cancel as cancel
    //tag for identification when handling
    confirmAlert.tag = scheduleAlertTag;
    confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertInputTextField = [confirmAlert textFieldAtIndex:0];
    alertInputTextField.tag = scheduleAlertTextFieldTag;
    alertInputTextField.delegate = self;
    alertInputTextField.returnKeyType = UIReturnKeyDone;
    
    //sets text to default
    alertInputTextField.text = self.titleButton.text;
    alertInputTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    //if not paused, pause
    if (!self.isPaused)
        [self pauseTimer];
    [self updateUI];
    
    //assign to property so uitextfield can access
    self.confirmAlertProperty = confirmAlert;
    
    //show alert after pausing
    [confirmAlert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //tag indicates is Schedule alert
    if (alertView.tag == scheduleAlertTag) {
        switch (buttonIndex) {
            //OK
            case 0:
                //make sure matches textFieldShouldReturn too
                self.titleButton.text = [alertView textFieldAtIndex:0].text;
                [self scheduleEvent];
                [self resultLabelUpdate];
                [self endTimer];
                [self resetVars];
                [self cancelAllReminderLocalNotifs];
                [self hideReminderLabel];
                [self updateUI];
                self.confirmAlertProperty = nil;
                break;
                
            //Cancel
            case 1:
                [self updateUI];
                self.confirmAlertProperty = nil;
                break;
            default:
                break;
        }
    //tag indicates Reset alert
    } else if (alertView.tag == resetAlertTag) {
        switch (buttonIndex) {
            //OK
            case 0:
                if (self.timer)
                    [self endTimer];
                [self resetVars];
                [self cancelAllReminderLocalNotifs];
                [self hideReminderLabel];
                [self updateUI];
                break;
                
            //Cancel
            case 1:
                break;
            default:
                break;
        }
    }
}
- (void)scheduleEvent
{
    //NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    EKEventStore *eventStore = [[EKEventStore alloc]init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = self.titleButton.text;
    event.startDate = self.startDate;
    event.endDate = self.endDate;
    //event.location for later updates
    
    int mins = floor(self.seconds/60);
    int secs = self.seconds - (mins * 60);
    int hours = 0;
    if (mins > 59) {
        hours = floor(mins/60);
        mins -= hours * 60;
    }
    int pmins = floor(self.pausedSeconds/60);
    int psecs = floor(self.pausedSeconds - (pmins * 60));
    int phours = 0;
    if (pmins > 59) {
        phours = floor(pmins/60);
        pmins -= phours * 60;
    }
    NSString *timeString;
    NSString *pTimeString;
    if (hours == 0)
        timeString = [NSString stringWithFormat:@"%i:%02i", mins, secs];
    else
        timeString = [NSString stringWithFormat:@"%i:%02i:%02i", hours, mins, secs];
    if (phours == 0)
        pTimeString = [NSString stringWithFormat:@"%i:%02i", pmins, psecs];
    else
        pTimeString = [NSString stringWithFormat:@"%i:%02i:%02i", phours, pmins, psecs];
    event.notes = [NSString stringWithFormat:@"%@ active, %@ inactive, paused %i times", timeString, pTimeString, self.pauseNumber];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            //user lets calendar access
            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
            NSError *err;
            [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
            
        } else {
            //user no calendar access
            //NSLog(@"No access :(");
            UIAlertView *accessAlert = [[UIAlertView alloc]initWithTitle:@"Please allow calendar access for full app functionality" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            // tag for identification when handling
            accessAlert.tag = calendarAccessMissingAlertTag;
            [accessAlert show];

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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
    //note change from increaseTimerCount: to increaseTimerCount
}
//see http://stackoverflow.com/questions/1189252/how-to-convert-an-nstimeinterval-seconds-into-minutes if want to convert to more complex hours/days/months

//note took off the :(NSTimer *)timer part
- (void)increaseTimerCount
{
    self.seconds++;
    
    int mins = floor(self.seconds/60);
    int secs = self.seconds - (mins * 60);
    int hours = 0;
    if (mins > 59) {
        hours = floor(mins/60);
        mins -= hours * 60;
    }
    if (hours == 0)
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
    else
        self.timerLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d", hours, mins, secs];
    if (hours >= 10) {
        if (hours >= 100)
            [self.timerLabel setFont:[UIFont fontWithName:self.timerLabel.font.fontName size:72]];
        else
            [self.timerLabel setFont:[UIFont fontWithName:self.timerLabel.font.fontName size:90]];
    }
    
    //[self.timerLabel sizeToFit];
}
- (void)endTimer
{
    [self.timer invalidate];
}
- (void)pauseTimer
{
    //ty to http://stackoverflow.com/questions/347219/how-can-i-programmatically-pause-an-nstimer
    self.pauseStartDate = [NSDate date];
    [self.timer setFireDate:[NSDate distantFuture]];
    self.isPaused = YES;
}
- (void)resumeTimer
{
    //new additions stop rapidfire pause/resume from increasing time, but also basically pauses timer during rapidfire switch. Apple's timer is better
    self.isPaused = NO;
    [self updateUI];
    
    float pauseTimeWas = -1 * [self.pauseStartDate timeIntervalSinceNow]; //results in positive #
    if (floor(pauseTimeWas) >= 1) {
        [self.timer setFireDate:[self.startDate initWithTimeInterval:pauseTimeWas sinceDate:self.startDate]];
        //tracks pause time
        self.pausedSeconds += pauseTimeWas;
        //self.isPaused = NO; moved to top
    } else {
        [self performSelector:@selector(resumeTimer) withObject:nil afterDelay:(1 - pauseTimeWas)];
    }
}
- (void)resetVars
{
    //reset stored vars
    self.seconds = 0;
    self.pausedSeconds = 0;
    self.pauseNumber = 0;
    self.timerLabel.text = @"00:00";
    [self.timerLabel setFont:[UIFont fontWithName:self.timerLabel.font.fontName size:96]];
    self.isPaused = NO;
    self.isStart = YES;
    self.titleButton.text = @"";
    //[self hideReminderLabel];
    //[self cancelAllReminderLocalNotifs];
    //holy shit this self induced stupidity cost me ~2 hours of manic frustration confronting a dumb nonissue
}
- (void)resultLabelUpdate
{
    //copypasta from scheduleAlert
    NSString *startDateString = [NSDateFormatter localizedStringFromDate:self.startDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
    NSString *endDateString = [NSDateFormatter localizedStringFromDate:self.endDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
    NSDate *startDateOnly = self.startDate;
    NSDate *endDateOnly = self.endDate;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDateOnly interval:NULL forDate:startDateOnly];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&endDateOnly interval:NULL forDate:endDateOnly];
    if ([startDateOnly compare:endDateOnly] == NSOrderedSame) {
        //endDateString = [endDateString substringFromIndex:[endDateString length]-10];
        endDateString = [endDateString componentsSeparatedByString:@", "][1];
    }
    
    self.resultLabel.text = [NSString stringWithFormat:@"Event '%@' added to calendar (%@ to %@)", self.titleButton.text, startDateString, endDateString];
    
    //animation fails and just is blank if user schedules events within 4.5 seconds of each ending. However, I find that unlikely and thus this should work
    [UIView animateWithDuration:5.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{ self.resultLabel.alpha = 0;} completion:^(BOOL finished){
        if (finished) {
            self.resultLabel.text = @"";
            self.resultLabel.alpha = 1;
        }
    }];
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:5.0];
    //self.resultLabel.text = @"";
    //[UIView commitAnimations];
}
- (void)updateUI
{
    if (self.isStart) {
        //set default states for title textcolor backgroundcolor bordercolor borderwidth cornerradius enabling
        [self.bigButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.bigButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        self.bigButton.backgroundColor = [UIColor whiteColor];
        self.bigButton.layer.borderColor = [UIColor greenColor].CGColor;
        self.bigButton.layer.borderWidth = roundButtonBorderWidth;
        self.bigButton.layer.cornerRadius = self.bigButton.frame.size.width/2;
        
        self.pauseButton.enabled = NO;
        [self.pauseButton setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
        self.pauseButton.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        self.pauseButton.backgroundColor = nil;
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateDisabled];
        self.pauseButton.layer.borderWidth = roundButtonBorderWidth;
        self.pauseButton.layer.cornerRadius = self.pauseButton.frame.size.width/2;
        
        self.resetButton.enabled = NO;
        [self.resetButton setTitleColor:[UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:0.3] forState:UIControlStateDisabled];
        //title never changes so just set here
        [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        self.resetButton.layer.borderColor = [UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:0.3].CGColor;
        self.resetButton.backgroundColor = nil;
        self.resetButton.layer.borderWidth = roundButtonBorderWidth;
        self.resetButton.layer.cornerRadius = self.resetButton.frame.size.width/2;
        
        self.shortcutButton.layer.borderWidth = 1;
        self.shortcutButton.layer.cornerRadius = self.shortcutButton.frame.size.height/6;
        self.shortcutButton.layer.borderColor = self.shortcutButton.titleLabel.textColor.CGColor;
        //self.shortcutButton.backgroundColor = [UIColor whiteColor];
        
        self.reminderButton.layer.borderWidth = 1;
        self.reminderButton.layer.cornerRadius = self.reminderButton.frame.size.height/6;
        self.reminderButton.layer.borderColor = self.reminderButton.titleLabel.textColor.CGColor;
        
        //self.reminderButton.hidden = YES;
        //self.reminderLabel.hidden = YES;
        //self.addReminderButton.hidden = NO;
        //[self hideReminderLabel];
        
        //self.reminderButton.enabled = NO;
        //self.reminderButton.alpha = 0.15;
        
        self.addReminderButton.layer.borderWidth = 1;
        self.addReminderButton.layer.cornerRadius = self.addReminderButton.frame.size.height/6;
        self.addReminderButton.layer.borderColor = self.addReminderButton.titleLabel.textColor.CGColor;
        
    } else {
        [self.bigButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.bigButton setTitleColor:[UIColor colorWithRed:1 green:0.0335468 blue:0.00867602 alpha:1] forState:UIControlStateNormal];
        self.bigButton.layer.borderColor = [UIColor colorWithRed:1 green:0.0335468 blue:0.00867602 alpha:1].CGColor;
        
        self.resetButton.enabled = YES;
        [self.resetButton setTitleColor:[UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:1] forState:UIControlStateNormal];
        self.resetButton.backgroundColor = [UIColor whiteColor];
        self.resetButton.layer.borderColor = [UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:1].CGColor;
        
        //pause button
       self.pauseButton.enabled = YES;
        self.pauseButton.backgroundColor = [UIColor whiteColor];
        if (self.isPaused) {
            [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
            [self.pauseButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            self.pauseButton.layer.borderColor = [UIColor greenColor].CGColor;
        } else {
            [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
            [self.pauseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.pauseButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
    }
    
    //timerLabel updated on increaseTimerCount: method
}
- (void)hideReminderLabel
{
    self.reminderButton.hidden = YES;
    self.reminderLabel.hidden = YES;
    self.addReminderButton.hidden = NO;
}

//title is set in prepareSegue
- (IBAction)myShortcutTextUnwindSegueCallback:(UIStoryboardSegue *)segue
{
    UIViewController *sourceVC = segue.sourceViewController;
    if ([sourceVC isKindOfClass:[HCSShortCutViewController class]]) {
        HCSShortCutViewController *shortcutVC = (HCSShortCutViewController *)sourceVC;
        self.titleButton.text = shortcutVC.title;
    }
}
- (IBAction)myReminderSegueCallback:(UIStoryboardSegue *)segue
{
    UIViewController *sourceVC = segue.sourceViewController;
    if ([sourceVC isKindOfClass:[HCSReminderTableViewController class]]) {
        HCSReminderTableViewController *reminderVC = (HCSReminderTableViewController *)sourceVC;

        int minstring = reminderVC.minutes;
        self.reminderButton.hidden = NO;
        self.reminderLabel.hidden = NO;
        self.addReminderButton.hidden = YES;
        
        double hourstring;
        NSString *timeText;
        if (minstring >= 60) {
            hourstring = minstring/60.0;
            if (hourstring == 1)
                timeText = @"1 hour";
            else
                timeText = [NSString stringWithFormat:@"%.1f hours", hourstring];
        } else if (minstring == 1)
            timeText = @"1 minute";
        else
            timeText = [NSString stringWithFormat:@"%i minutes", minstring];
        //self.reminderButton.titleLabel.text = timeText;
        NSDate *notificationDate = [NSDate dateWithTimeIntervalSinceNow:(reminderVC.minutes * 60)];
        UILocalNotification *notif = [[UILocalNotification alloc]init];
        notif.fireDate = notificationDate;
        notif.timeZone = [NSTimeZone defaultTimeZone];
        notif.alertBody = [NSString stringWithFormat: @"%@ has passed", timeText];
        notif.alertAction = @"OK";
        notif.soundName = UILocalNotificationDefaultSoundName;
        //notif.applicationIconBadgeNumber = 1;
        notif.userInfo = @{@"typeKey": @"reminder", @"timeStringKey": timeText};
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        [self.reminderButton setTitle:[NSString stringWithFormat:@"%@", [NSDateFormatter localizedStringFromDate:notificationDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]] forState:UIControlStateNormal];
        
    } else if ([sourceVC isKindOfClass:[HCSModifyReminderViewController class]]) {
        HCSModifyReminderViewController *modifyVC = (HCSModifyReminderViewController *)sourceVC;
        
        //cancel all reminder local notifs
        //same as [self cancelAllReminderLocalNotifs];
        /*
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *scheduledLocalNotifs = [app scheduledLocalNotifications];
        if ([scheduledLocalNotifs count]) {
            for (UILocalNotification *localNotif in scheduledLocalNotifs) {
                if ([localNotif.userInfo[@"typeKey"] isEqualToString:@"reminder"]) {
                    [app cancelLocalNotification:localNotif];
                    //NSLog(@"cancel notif");
                }
            }
        }*/
        [self cancelAllReminderLocalNotifs];
        
        //check to make sure date is later
        if ([modifyVC.date timeIntervalSinceNow] <= 0) {
            //time was earlier. Cancel everything and revert.
            [self hideReminderLabel];
        } else {
            //time is later, reschedule the local notif
            
            //schedule new reminder local notif
            NSTimeInterval seconds = [modifyVC.date timeIntervalSinceNow];
            int minstring = (int)(seconds/60);
            if (seconds - minstring * 60 > 0) {
                //extra seconds, round up?
                minstring++;
            }
            double hourstring;
            NSString *timeText;
            if (minstring >= 60) {
                hourstring = minstring/60.0;
                if (hourstring == 1)
                    timeText = @"1 hour";
                else
                    timeText = [NSString stringWithFormat:@"%.1f hours", hourstring];
            } else if (minstring == 1)
                timeText = @"1 minute";
            else
                timeText = [NSString stringWithFormat:@"%i minutes", minstring];
            
            UILocalNotification *notif = [[UILocalNotification alloc]init];
            notif.fireDate = modifyVC.date;
            notif.timeZone = [NSTimeZone defaultTimeZone];
            notif.alertBody = [NSString stringWithFormat: @"%@ has passed", timeText];
            notif.alertAction = @"OK";
            notif.soundName = UILocalNotificationDefaultSoundName;
            //notif.applicationIconBadgeNumber = 1;
            notif.userInfo = @{@"typeKey": @"reminder", @"timeStringKey": timeText};
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            
            [self.reminderButton setTitle:[NSString stringWithFormat:@"%@", [NSDateFormatter localizedStringFromDate:modifyVC.date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]] forState:UIControlStateNormal];
        }
    }
    
}

- (void)cancelAllReminderLocalNotifs
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *scheduledLocalNotifs = [app scheduledLocalNotifications];
    if ([scheduledLocalNotifs count]) {
        for (UILocalNotification *localNotif in scheduledLocalNotifs) {
            if ([localNotif.userInfo[@"typeKey"] isEqualToString:@"reminder"]) {
                [app cancelLocalNotification:localNotif];
            }
        }
    }
}
//lazy instantiation for seconds, pauseNumber, pausedSeconds
- (int)seconds
{
    if (!_seconds) _seconds = 0;
    return _seconds;
}
- (int)pauseNumber
{
    if (!_pauseNumber) _pauseNumber = 0;
    return _pauseNumber;
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
    [self resetVars];
    self.resultLabel.text = @"";
    //update reminder thingy
    if ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] > 0) {
        for (UILocalNotification *localnotif in [[UIApplication sharedApplication]scheduledLocalNotifications]) {
            if ([localnotif.userInfo[@"typeKey"] isEqualToString:@"reminder"]) {
                self.reminderButton.hidden = NO;
                self.reminderLabel.hidden = NO;
                self.addReminderButton.hidden = YES;
                [self.reminderButton setTitle:[NSString stringWithFormat:@"%@", [NSDateFormatter localizedStringFromDate:localnotif.fireDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]] forState:UIControlStateNormal];
            }
        }
    } else
        [self hideReminderLabel];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    
    //[defaults setBool:NO forKey:@"firstTime"];
    
    
    
    if (![defaults boolForKey:@"firstTime"]) {
        //set firstTime defaults
        //NSLog(@"first");
        NSArray *wordArr = @[@"Procrastination", @"Work", @"Eating", @"Exercise", @"Fun", @"Social", @"Travel", @"Shopping"];
        NSMutableArray *storeWords = [NSMutableArray array];
        
        //encoding so able to store is nsuserdefaults
        for (NSString *word in wordArr) {
            NSData *encodedSampleWorkObj = [NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:word image:[UIImage imageNamed:word]]];
            [storeWords addObject:encodedSampleWorkObj];
        }
        [defaults setObject:storeWords forKey:@"shortcuts"];
        
        NSArray *textOnlyArr = @[@"Sleep", @"Walk", @"Reading"];
        NSMutableArray *textWords = [NSMutableArray array];
        for (NSString *word in textOnlyArr) {
            NSData *encodedSampleWorkObj = [NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:word image:nil]];
            [textWords addObject:encodedSampleWorkObj];
        }
        [defaults setObject:textWords forKey:@"textShortcuts"];
        [defaults setBool:true forKey:@"firstTime"];
        [defaults synchronize];
    }
    [self updateUI];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Saving/Restoring States

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    if ([self.titleButton.text length])
        [coder encodeObject:self.titleButton.text forKey:@"Title Text"];
    
    [coder encodeBool:self.isStart forKey:@"isStart"];
    
    if (!self.isStart) {
        //only act if not new/isStart
        [coder encodeInt:self.seconds forKey:@"seconds"];
        [coder encodeObject:[NSDate date] forKey:@"wentBackgroundDate"];
        [coder encodeBool:self.isPaused forKey:@"isPaused"];
        [coder encodeInt:self.pauseNumber forKey:@"pauseNumber"];
        [coder encodeDouble:self.pausedSeconds forKey:@"pausedSeconds"];
        //start date should always exist if not isStart
        [coder encodeObject:self.startDate forKey:@"startDate"];
        //lol don't think end date is needed?
        
        //check if ever paused and if pauseStartDateExists
        if (self.pauseNumber > 0)
            [coder encodeObject:self.pauseStartDate forKey:@"pauseStartDate"];
    }
/*
    [coder encodeBool:self.isStart forKey:@"isStart"];
    [coder encodeBool:self.isPaused forKey:@"isPaused"];

    if (self.startDate)
        [coder encodeObject:self.startDate forKey:@"startDate"];
    if (self.endDate)
        [coder encodeObject:self.endDate forKey:@"endDate"];
    if (self.pauseStartDate)
        [coder encodeObject:self.pauseStartDate forKey:@"pauseStartDate"];
    if (self.confirmAlertProperty)
        [coder encodeObject:self.confirmAlertProperty forKey:@"confirmAlertProperty"];
    if (self.pausedSeconds)
        [coder encodeDouble:self.pausedSeconds forKey:@"pausedSeconds"];
    
    [coder encodeInt:self.seconds forKey:@"seconds"];
 
 */
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstTime"]) {
        self.titleButton.text = [coder decodeObjectForKey:@"Title Text"];
        
        self.isStart = [coder decodeBoolForKey:@"isStart"];
        if (!self.isStart) {
            //only act if not new/isStart
            
            //NSString *datestring = [NSDateFormatter localizedStringFromDate:[coder decodeObjectForKey:@"wentBackgroundDate"] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
            //self.testLabel.text = [NSString stringWithFormat:@"%i %d p%d %@", [coder decodeIntForKey:@"seconds"], [coder decodeBoolForKey:@"isStart"], [coder decodeBoolForKey:@"isPaused"], datestring];
            
            self.startDate = [coder decodeObjectForKey:@"startDate"];
            self.seconds = [coder decodeIntForKey:@"seconds"];
            self.isPaused = [coder decodeBoolForKey:@"isPaused"];
            self.pauseNumber = [coder decodeIntForKey:@"pauseNumber"];
            self.pausedSeconds = [coder decodeDoubleForKey:@"pausedSeconds"];
            
            [self beginTimer];
            [self updateUI];
            //if (!self.isStart && self.isPaused) {
            if (self.isPaused) {
                //was paused when terminated
                [self pauseTimer];
            } else {
                //not paused when terminated
                //adjust second count
                NSTimeInterval terminationToNow = fabs([[coder decodeObjectForKey:@"wentBackgroundDate"] timeIntervalSinceNow]); //would've been negative so must abs
                self.seconds += (int)floor(terminationToNow);
            }
            //update timer label
            self.seconds--;
            [self increaseTimerCount];
            
            if (self.pauseNumber > 0) {
                //check if was ever paused and if pauseStartDate exists
                self.pauseStartDate = [coder decodeObjectForKey:@"pauseStartDate"];
            }
        }
    }
/*
    self.isStart = [coder decodeBoolForKey:@"isStart"];
    self.isPaused = [coder decodeBoolForKey:@"isPaused"];
    
    if ([coder decodeObjectForKey:@"startDate"])
        self.startDate = [coder decodeObjectForKey:@"startDate"];
    if ([coder decodeObjectForKey:@"endDate"])
        self.endDate = [coder decodeObjectForKey:@"endDate"];
    if ([coder decodeObjectForKey:@"pauseStartDate"])
        self.pauseStartDate = [coder decodeObjectForKey:@"pauseStartDate"];
    if ([coder decodeObjectForKey:@"confirmAlertProperty"])
        self.confirmAlertProperty = [coder decodeObjectForKey:@"confirmAlertProperty"];
    if ([coder decodeDoubleForKey:@"pausedSeconds"])
        self.pausedSeconds = [coder decodeDoubleForKey:@"pausedSeconds"];
    
    self.seconds = [coder decodeIntForKey:@"seconds"];
 
 */
    [super decodeRestorableStateWithCoder:coder];
    //[self updateUI];
}

#pragma mark - UITextFieldDelegate
//NOTE: This solution would probably fail if a UIScrollView was used b/c it uses a static comparison on double status bar. Utilize with caution on regular UIViews

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.tag == scheduleAlertTextFieldTag && self.confirmAlertProperty) {
        //NSLog(@"%ld %@",(long)textField.tag, self.confirmAlertProperty.description);
        [self.confirmAlertProperty dismissWithClickedButtonIndex:0 animated:YES];
        [self alertView:self.confirmAlertProperty clickedButtonAtIndex:0];
    }
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
        rect.origin.y -= 75.0;
        rect.size.height += 75.0;
    } else {
        //revert
        rect.origin.y += 75.0;
        rect.size.height -= 75.0;
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

    if (self.view.frame.origin.y == 20 || self.view.frame.origin.y == 0) {
        //double status bar/call changed origin
        //don't move
        return;
    }
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
