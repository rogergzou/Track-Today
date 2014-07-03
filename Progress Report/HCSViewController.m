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

@interface HCSViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UITextField *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *shortcutButton;

@property (nonatomic, readwrite) BOOL isStart;
@property (nonatomic, readwrite) BOOL isPaused;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *pauseStartDate;

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
    resetAlert.tag = 2;
    [resetAlert show];
}
- (void)runScheduleAlert
{
    UIAlertView *confirmAlert = [[UIAlertView alloc]initWithTitle:@"Schedule" message:[NSString stringWithFormat:@"Place event onto iCal? %@ to %@", self.startDate, self.endDate] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", @"Cancel", nil];
    confirmAlert.cancelButtonIndex = 1; //set cancel as cancel
    //tag for identification when handling
    confirmAlert.tag = 1;
    confirmAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertInputTextField = [confirmAlert textFieldAtIndex:0];
    alertInputTextField.delegate = self;
    //sets text to default
    alertInputTextField.text = self.titleButton.text;
    alertInputTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    //if not paused, pause
    if (!self.isPaused)
        [self pauseTimer];
    [self updateUI];
    
    //show alert after pausing
    [confirmAlert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //tag indicates is Schedule alert
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            //OK
            case 0:
                self.titleButton.text = [alertView textFieldAtIndex:0].text;
                [self scheduleEvent];
                [self endTimer];
                [self resetVars];
                [self updateUI];
                break;
                
            //Cancel
            case 1:
                [self updateUI];
                break;
            default:
                break;
        }
    //tag indicates Reset alert
    } else if (alertView.tag == 2) {
        switch (buttonIndex) {
            //OK
            case 0:
                if (self.timer)
                    [self endTimer];
                [self resetVars];
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
            NSLog(@"No access :(");
            UIAlertView *accessAlert = [[UIAlertView alloc]initWithTitle:@"Please allow calendar access for full app functionality" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            // tag for identification when handling
            accessAlert.tag = 99999999;
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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(increaseTimerCount:) userInfo:nil repeats:YES];
}
//see http://stackoverflow.com/questions/1189252/how-to-convert-an-nstimeinterval-seconds-into-minutes if want to convert to more complex hours/days/months

- (void)increaseTimerCount: (NSTimer *)timer
{
    self.seconds++;
    
    int mins = floor(self.seconds/60);
    int hours = 0;
    if (mins > 59) {
        hours = floor(mins/60);
        mins -= hours * 60;
    }
    int secs = self.seconds - (mins * 60);
    if (hours == 0)
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
    else
        self.timerLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d", hours, mins, secs];
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
    self.isPaused = NO;
    self.isStart = YES;
}
- (void)updateUI
{
    if (self.isStart) {
        //set default states for title textcolor backgroundcolor bordercolor borderwidth cornerradius enabling
        [self.bigButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.bigButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        self.bigButton.backgroundColor = [UIColor whiteColor];
        self.bigButton.layer.borderColor = [UIColor greenColor].CGColor;
        self.bigButton.layer.borderWidth = 1.15;
        self.bigButton.layer.cornerRadius = self.bigButton.frame.size.width/2;
        
        self.pauseButton.enabled = NO;
        [self.pauseButton setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
        self.pauseButton.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        self.pauseButton.backgroundColor = nil;
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateDisabled];
        self.pauseButton.layer.borderWidth = 1.15;
        self.pauseButton.layer.cornerRadius = self.pauseButton.frame.size.width/2;
        
        self.resetButton.enabled = NO;
        [self.resetButton setTitleColor:[UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:0.3] forState:UIControlStateDisabled];
        //title never changes so just set here
        [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        self.resetButton.layer.borderColor = [UIColor colorWithRed:0.903978 green:0.344816 blue:0.823626 alpha:0.3].CGColor;
        self.resetButton.backgroundColor = nil;
        self.resetButton.layer.borderWidth = 1.15;
        self.resetButton.layer.cornerRadius = self.resetButton.frame.size.width/2;
        
        self.shortcutButton.layer.borderWidth = 1;
        self.shortcutButton.layer.cornerRadius = self.shortcutButton.frame.size.height/6;
        self.shortcutButton.layer.borderColor = self.shortcutButton.titleLabel.textColor.CGColor;
        //self.shortcutButton.backgroundColor = [UIColor whiteColor];
        
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

//title is set in prepareSegue
- (IBAction)myShortcutTextUnwindSegueCallback:(UIStoryboardSegue *)segue
{
    UIViewController *sourceVC = segue.sourceViewController;
    if ([sourceVC isKindOfClass:[HCSShortCutViewController class]]) {
        HCSShortCutViewController *shortcutVC = (HCSShortCutViewController *)sourceVC;
        self.titleButton.text = shortcutVC.title;
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
    self.isStart = YES;
    self.isPaused = NO;
    self.timerLabel.text = @"00:00";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"firstTime"];
    if (![defaults boolForKey:@"firstTime"]) {
        //set firstTime defaults
        NSArray *wordArr = @[@"Procrastination", @"Internet", @"Work", @"Shopping", @"Fun", @"Movies", @"Social", @"Travel", @"Drinking"];
        NSMutableArray *storeWords = [NSMutableArray array];
        
        //encoding so able to store is nsuserdefaults
        for (NSString *word in wordArr) {
            NSData *encodedSampleWorkObj = [NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:word image:[UIImage imageNamed:word]]];
            [storeWords addObject:encodedSampleWorkObj];
        }
        [defaults setObject:storeWords forKey:@"shortcuts"];
        [defaults setObject:@[[NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:@"School" image:nil]]] forKey:@"textShortcuts"];
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
