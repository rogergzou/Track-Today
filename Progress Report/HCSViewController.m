//
//  HCSViewController.m
//  Track Today
//
//  Created by Roger on 6/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSViewController.h"
#import <EventKit/EventKit.h>
#import "HCSShortcut.h"
#import "HCSShortCutViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "HCSReminderTableViewController.h"
#import "HCSAddReminderViewController.h"
#import "HCSModifyReminderViewController.h"
#import "HCSActivityRecord.h"

//set reminder
//terminate, then reopen
//reminder is not there, only setReminder

//need to fix app state not being saved
//need to add the extra tableview activity log info

const int scheduleAlertTextFieldTag = 4;
//const int scheduleAlertTag = 1;
const int scheduleAlertTag = 3;
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
@property (weak, nonatomic) IBOutlet UIButton *statsButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

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

//@property (nonatomic) BOOL skipResetVarForStatePls;

@property (strong, nonatomic) NSString *category;
@property (nonatomic) BOOL wasPausedBeforeStop;

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
        
        //this is the Grant bug
        //endDateString = [endDateString componentsSeparatedByString:@", "][1];
        endDateString = [NSDateFormatter localizedStringFromDate:self.endDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    }
    
    UIAlertView *confirmAlert = [[UIAlertView alloc]initWithTitle:@"Schedule" message:[NSString stringWithFormat:@"Place onto calendar? %@ to %@. Category: %@.", startDateString, endDateString, self.category] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", @"Cancel", nil];
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
    
    //if not paused, pause.
    if (!self.isPaused) {
        [self pauseTimer];
        self.pauseNumber++;
        self.wasPausedBeforeStop = NO;
    } else {
        self.wasPausedBeforeStop = YES;
    }
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
                if (self.wasPausedBeforeStop == NO)
                    self.pauseNumber--;
                else
                    [self resumeTimer]; //updates pausedSeconds
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
    NSString *cat;

    //will remove space in front of category if no title present
    if ([self.category isEqualToString:@"None"])
        cat = @"";
    else if ([self.titleButton.text length] == 0)
        cat = [NSString stringWithFormat:@"(%@)", self.category];
    else
        cat = [NSString stringWithFormat:@" (%@)", self.category];
    event.title = [NSString stringWithFormat:@"%@%@", self.titleButton.text, cat];
    
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
    
    //wow so long since this method was updated --7/25/14
    //set persistent info
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *statsDict = [[defaults dictionaryForKey:@"fullStatsDict"]mutableCopy];
    
    //have an array of objects in order of most time to least time
    //have a method to order them while linked? Basically like another array
    //goddamn I wish I had taken an algorithms class first
    /*
     event.title = self.titleButton.text;
     event.startDate = self.startDate;
     event.endDate = self.endDate;
     event.notes = [NSString stringWithFormat:@"%@ active, %@ inactive, paused %i times", timeString, pTimeString, self.pauseNumber];
     */
    
    //if (statsDict) {
    
    //dict exists b/c was created in viewDidLoad firstTime method
    
    //NSData *recordData = statsDict[self.titleButton.text];
    //use category now
    NSData *recordData = statsDict[self.category];

    HCSActivityRecord *record;
    if (!recordData) {
        //record is nil, set title & create obj
        record = [[HCSActivityRecord alloc]init];
        //record.title = self.titleButton.text;
        record.title = self.category;
    } else
        record = [NSKeyedUnarchiver unarchiveObjectWithData: recordData];
    
    //if record doesn't exist, lazy insantiation. If does, just adds
    record.seconds += self.seconds;
    record.pausedSeconds += self.pausedSeconds;
    record.pauseNumber += self.pauseNumber;
    record.activityNumber++;
    
    //[record.startDateArray addObject:self.startDate];
    //[record.endDateArray addObject:self.endDate];
    //[record.secondsArray addObject:@(self.seconds)];
    //[record.pausedSecondsArray addObject:@(self.pausedSeconds)];
    //NSLog(@"%@ ps %f", record.pausedSecondsArray, self.pausedSeconds);
    //[record.pauseNumberArray addObject:@(self.pauseNumber)];
    [record.startDateArray insertObject:self.startDate atIndex:0];
    [record.endDateArray insertObject:self.endDate atIndex:0];
    [record.secondsArray insertObject:@(self.seconds) atIndex:0];
    [record.pausedSecondsArray insertObject:@(self.pausedSeconds) atIndex:0];
    [record.pauseNumberArray insertObject:@(self.pauseNumber) atIndex:0];
    [record.eventTitleArray insertObject:self.titleButton.text atIndex:0];
    
    NSData *encodedRecord = [NSKeyedArchiver archivedDataWithRootObject:record];
    statsDict[self.category] = encodedRecord;
    
    [defaults setObject:statsDict forKey:@"fullStatsDict"]; //will be autoconvert to nonmutable anyway
    [defaults synchronize];
    
    //} else {
        //dict doesn't exist
      //  HCSActivityRecord *record = [[HCSActivityRecord alloc]init];
        //record.title = self.titleButton.text;
        
    //}
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
    //self.pauseNumber++;
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
    self.category = nil;
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
        
        //this is the Grant bug
        //endDateString = [endDateString componentsSeparatedByString:@", "][1];
        endDateString = [NSDateFormatter localizedStringFromDate:self.endDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    }
    
    NSString *cat;
    //will remove space in front of category if no title present
    if ([self.category isEqualToString:@"None"])
        cat = @"";
    else if ([self.titleButton.text length] == 0)
        cat = [NSString stringWithFormat:@"(%@)", self.category];
    else
        cat = [NSString stringWithFormat:@" (%@)", self.category];
    self.resultLabel.text = [NSString stringWithFormat:@"'%@%@' added to calendar (%@ to %@)", self.titleButton.text, cat, startDateString, endDateString];
    
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
        
        //Vivs caps
        [self.bigButton setTitle:@"START" forState:UIControlStateNormal];
        [self.bigButton.titleLabel setFont:[UIFont fontWithName:@"Abadi MT Condensed Light" size:17]];
        //Vivs
        //[self.bigButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        //self.bigButton.backgroundColor = [UIColor whiteColor];
        //self.bigButton.layer.borderColor = [UIColor greenColor].CGColor;
        //self.bigButton.layer.borderWidth = roundButtonBorderWidth;
        //self.bigButton.layer.cornerRadius = self.bigButton.frame.size.width/2;
        
        self.pauseButton.enabled = NO;
        [self.pauseButton.titleLabel setFont:[UIFont fontWithName:@"Abadi MT Condensed Light" size:17]];
        //[self.pauseButton setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
        //self.pauseButton.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        //self.pauseButton.backgroundColor = nil;
        
        //Vivs caps
        [self.pauseButton setTitle:@"PAUSE" forState:UIControlStateDisabled];
        //self.pauseButton.layer.borderWidth = roundButtonBorderWidth;
        //self.pauseButton.layer.cornerRadius = self.pauseButton.frame.size.width/2;
        
        self.resetButton.enabled = NO;
        [self.resetButton.titleLabel setFont:[UIFont fontWithName:@"Abadi MT Condensed Light" size:17]];
        //[self.resetButton setTitleColor:[UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:0.3] forState:UIControlStateDisabled];
        //title never changes so just set here
        
        //Vivs caps
        [self.resetButton setTitle:@"RESET" forState:UIControlStateNormal];
        //self.resetButton.layer.borderColor = [UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:0.3].CGColor;
        //self.resetButton.backgroundColor = nil;
        //self.resetButton.layer.borderWidth = roundButtonBorderWidth;
        //self.resetButton.layer.cornerRadius = self.resetButton.frame.size.width/2;
        
        self.shortcutButton.layer.borderWidth = 1;
        self.shortcutButton.layer.cornerRadius = self.shortcutButton.frame.size.height/6;
        self.shortcutButton.layer.borderColor = self.shortcutButton.titleLabel.textColor.CGColor;
        //self.shortcutButton.backgroundColor = [UIColor whiteColor];
        
        //self.statsButton.layer.borderWidth = 1;
        //self.statsButton.layer.cornerRadius = self.statsButton.frame.size.height/6;
        //self.statsButton.layer.borderColor = [UIColor colorWithRed:239 green:60 blue:57 alpha:1].CGColor;
        
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
        
        [self.categoryLabel setFont:[UIFont boldSystemFontOfSize:17]];
        //Vivs changed from Category to CATEGORY. plus font change
        self.categoryLabel.text = [NSString stringWithFormat:@"CATEGORY: %@", self.category];
        [self.categoryLabel setFont:[UIFont fontWithName:@"Abadi MT Condensed Light" size:17]];
        //self.categoryLabel.text =  [UIFont fontWithName:@"Abadi MT Condensed Light" size:17]
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
        //self.titleButton.text = shortcutVC.title;
        //changed to category
        self.category = shortcutVC.title;
        self.categoryLabel.text = [NSString stringWithFormat:@"Category: %@", self.category];
    }
}
- (IBAction)myReminderSegueCallback:(UIStoryboardSegue *)segue
{
    UIViewController *sourceVC = segue.sourceViewController;
    if ([sourceVC isKindOfClass:[HCSAddReminderViewController class]]) {
        HCSAddReminderViewController *reminderVC = (HCSAddReminderViewController *)sourceVC;

        self.reminderButton.hidden = NO;
        self.reminderLabel.hidden = NO;
        self.addReminderButton.hidden = YES;
        
        int secs = reminderVC.seconds;
        int mins = reminderVC.minutes;
        int hours = reminderVC.hours;
        
        double totalSeconds = secs + mins * 60 + hours * 3600;
        /*
        double hourstring;
        NSString *timeText;
        BOOL singular = NO;
        if (minstring >= 60) {
            hourstring = minstring/60.0;
            if (hourstring == 1) {
                timeText = @"1 hour";
                singular = YES;
            } else
                timeText = [NSString stringWithFormat:@"%.1f hours", hourstring];
        } else if (minstring == 1) {
            timeText = @"1 minute";
            singular = YES;
        } else
            timeText = [NSString stringWithFormat:@"%i minutes", minstring];
        //self.reminderButton.titleLabel.text = timeText;
         */
        NSString *timeString = @"";
        BOOL singular = NO;
        if (totalSeconds > 3600)
            timeString = [NSString stringWithFormat:@"%.1f hours", totalSeconds/3600];
        else if (totalSeconds == 3600) {
            singular = YES;
            timeString = @"1 hour";
        } else if (totalSeconds > 60)
            timeString = [NSString stringWithFormat:@"%.1f minutes", totalSeconds/60];
        else if (totalSeconds == 60) {
            singular = YES;
            timeString = @"1 minute";
        } else if (totalSeconds > 1)
            timeString = [NSString stringWithFormat:@"%i seconds", (int)totalSeconds];
        else if (totalSeconds == 1) {
            singular = YES;
            timeString = @"1 second";
        } else {
            self.reminderButton.hidden = YES;
            self.reminderLabel.hidden = YES;
            self.addReminderButton.hidden = NO;
            return;
        }
        
        NSDate *notificationDate = [NSDate dateWithTimeIntervalSinceNow:totalSeconds];
        UILocalNotification *notif = [[UILocalNotification alloc]init];
        notif.fireDate = notificationDate;
        notif.timeZone = [NSTimeZone defaultTimeZone];
        notif.alertBody = [NSString stringWithFormat: @"%@ %@ passed", timeString, (singular ? @"has" : @"have")];
        notif.alertAction = @"OK";
        notif.soundName = UILocalNotificationDefaultSoundName;
        //notif.applicationIconBadgeNumber = 1;
        //adjust timeString for grammar later
        if (!singular && [timeString length])
            timeString = [timeString substringToIndex:[timeString length]-1];
        notif.userInfo = @{@"typeKey": @"reminder", @"timeStringKey": timeString};
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
            BOOL singular = NO;
            if (minstring >= 60) {
                hourstring = minstring/60.0;
                if (hourstring == 1) {
                    timeText = @"1 hour";
                    singular = YES;
                } else
                    timeText = [NSString stringWithFormat:@"%.1f hours", hourstring];
            } else if (minstring == 1) {
                timeText = @"1 minute";
                singular = YES;
            } else
                timeText = [NSString stringWithFormat:@"%i minutes", minstring];
            
            UILocalNotification *notif = [[UILocalNotification alloc]init];
            notif.fireDate = modifyVC.date;
            notif.timeZone = [NSTimeZone defaultTimeZone];
            notif.alertBody = [NSString stringWithFormat: @"%@ %@ passed", timeText, (singular ? @"has" : @"have")];
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

/*

- (void)jankySaveState
{
    NSMutableDictionary *savDict = [[NSMutableDictionary alloc]init];
    if ([self.titleButton.text length]) {
        //[coder encodeObject:_titleButton.text forKey:@"Title Text"];
        savDict[@"Title Text"] = self.titleButton.text;
    }
    NSLog(@"dict janky encode");
    //[coder encodeBool:self.isStart forKey:@"isStart"];
    savDict[@"isStart"] = @(self.isStart);
    //NSLog(@"%d en", (self.isStart ? 1 : 0));
    
    if (!self.isStart) {
        //only act if not new/isStart
        
        savDict[@"seconds"] = @(self.seconds);
        savDict[@"wentBackgroundDate"] = [NSDate date];
        savDict[@"isPaused"] = @(self.isPaused);
        savDict[@"pauseNumber"] = @(self.pauseNumber);
        savDict[@"pausedSeconds"] = @(self.pausedSeconds);
        savDict[@"startDate"] = self.startDate;

        //[coder encodeInt:self.seconds forKey:@"seconds"];
        //[coder encodeObject:[NSDate date] forKey:@"wentBackgroundDate"];
        //[coder encodeBool:self.isPaused forKey:@"isPaused"];
        //[coder encodeInt:self.pauseNumber forKey:@"pauseNumber"];
        //[coder encodeDouble:self.pausedSeconds forKey:@"pausedSeconds"];
        //start date should always exist if not isStart
        //[coder encodeObject:self.startDate forKey:@"startDate"];
        //lol don't think end date is needed?
        NSLog(@"janky encode this was encoded too %f paused sec", self.pausedSeconds);
        //check if ever paused and if pauseStartDateExists
        if (self.pauseNumber > 0) {
            //[coder encodeObject:self.pauseStartDate forKey:@"pauseStartDate"];
            savDict[@"pauseStartDate"] = self.pauseStartDate;
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:savDict forKey:@"restorationDictionary"];
    NSLog(@"restdict %@", savDict);
    [defaults synchronize];
}

- (void)jankyRestoreStateWithDict:(NSDictionary *)savDict
{
    self.skipResetVarForStatePls = YES;
    NSString *titleText = savDict[@"Title Text"];
    NSLog(@"reached here");
    if (titleText) {
        self.titleButton.text = titleText;
    }
    self.isStart = [savDict[@"isStart"] boolValue];
    if (self.isStart)
        return;
    self.seconds = [savDict[@"seconds"] intValue];
    //background date shinanegins here
    self.isPaused = [savDict[@"isPaused"] boolValue];
    self.pauseNumber = [savDict[@"pauseNumber"]intValue];
    self.pausedSeconds = [savDict[@"pausedSeconds"]doubleValue];
    self.startDate = savDict[@"startDate"];
    NSLog(@"janky restore pause # %i", self.pauseNumber);
    
    if (self.pauseNumber > 0) {
        self.pauseStartDate = savDict[@"pauseStartDate"];
    }
}
*/

//lazy instantiation for seconds, pauseNumber, pausedSeconds,category
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
- (NSString *)category
{
    if (!_category) _category = @"None";
    return _category;
}

//failure when start timer/reminder, switch to another app, close this app, use local notif to load. Also happens if load even now with local notif. Reminder is irrelevant nvm.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewdid");
	// Do any additional setup after loading the view, typically from a nib.

    //set defaults
    /* if (self.skipResetVarForStatePls) {
        self.skipResetVarForStatePls = NO;
    } else {
        [self resetVars];
    }*/
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
    
    if (![defaults boolForKey:@"firstTimeForStats"]) {
        //also set statsDict for later
        [defaults setObject:@{} forKey:@"fullStatsDict"];
        [defaults setBool:true forKey:@"firstTimeForStats"];
    }
    
    if (![defaults boolForKey:@"firstTime"]) {
        //set firstTime defaults
        NSArray *wordArr = @[@"Procrastination", @"Work", @"Eating", @"Exercise", @"Social", @"Travel"];
        NSMutableArray *storeWords = [NSMutableArray array];
        
        //encoding so able to store is nsuserdefaults
        for (NSString *word in wordArr) {
            NSData *encodedSampleWorkObj = [NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:word image:[UIImage imageNamed:word]]];
            [storeWords addObject:encodedSampleWorkObj];
        }
        [defaults setObject:storeWords forKey:@"shortcuts"];
        
        NSArray *textOnlyArr = @[@"Sleep", @"Reading", @"Class", @"Fun", @"Shopping", @"Music"];
        NSMutableArray *textWords = [NSMutableArray array];
        for (NSString *word in textOnlyArr) {
            NSData *encodedSampleWorkObj = [NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:word image:nil]];
            [textWords addObject:encodedSampleWorkObj];
        }
        [defaults setInteger:0 forKey:@"appCounter"];
        [defaults setObject:textWords forKey:@"textShortcuts"];
        [defaults setBool:true forKey:@"firstTime"];
        
        //also set statsDict for later
        //[defaults setObject:@{} forKey:@"fullStatsDict"];
        //moved
        [defaults synchronize];
    }
    [defaults setInteger:([defaults integerForKey:@"appCounter"]+1) forKey:@"appCounter"];
    //NSLog(@"%li", (long)[defaults integerForKey:@"appCounter"]);
    
    //to resign keyboard. One liner lol. http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-textfield
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    //fml keyboardDismissMode only in scrollView
    
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
    //if ([self.titleButton.text length])
    [coder encodeObject:self.titleButton.text forKey:@"Title Text"];
    //NSLog(@"encode");
    if (self.category)
        [coder encodeObject:self.category forKey:@"category"];
    [coder encodeBool:self.isStart forKey:@"isStart"];
    //NSLog(@"%d en", (self.isStart ? 1 : 0));
    
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
        //NSLog(@"this was encoded too %f paused sec", self.pausedSeconds);
        
        
        //check if ever paused and if pauseStartDateExists
        if (self.pauseNumber > 0)
            [coder encodeObject:self.pauseStartDate forKey:@"pauseStartDate"];
    }

    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstTime"]) {
        self.titleButton.text = [coder decodeObjectForKey:@"Title Text"];
        if ([coder decodeObjectForKey:@"category"]) {
            self.category = [coder decodeObjectForKey:@"category"];
            self.categoryLabel.text = [NSString stringWithFormat:@"Category: %@", self.category];
        }
        //self.testLabel.text = [coder decodeObjectForKey:@"Title Text"];
        //self.testLabel.text = @"decoded";
        self.isStart = [coder decodeBoolForKey:@"isStart"];
        //NSLog(@"%d dec", (self.isStart ? 1 : 0));
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
            //NSLog(@"decode");
            //update timer label
            self.seconds--;
            [self increaseTimerCount];
            
            if (self.pauseNumber > 0) {
                //check if was ever paused and if pauseStartDate exists
                self.pauseStartDate = [coder decodeObjectForKey:@"pauseStartDate"];
            }
        }
    }

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
        
        //may be the issue? No, probably not. Most likely just a red herring.
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
