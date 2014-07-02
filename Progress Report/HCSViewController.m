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
//@import EventKitUI;

@interface HCSViewController () <UITextFieldDelegate, UIAlertViewDelegate>
//@property (weak, nonatomic) IBOutlet UIButton *ob;

@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UITextField *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *shortcutButton;

@property (nonatomic, readwrite) BOOL isStart;
@property (nonatomic, readwrite) BOOL isPaused;
//@property (nonatomic) BOOL isConfirm;
@property (strong, nonatomic) NSDate *startDate;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *pauseStartDate;

@property (nonatomic) NSTimeInterval pausedSeconds; //lol typedef double
@property (strong, nonatomic) NSTimer *timer;
//MOVED PUBLIC SO APPDEL CAN ACCESS @property (nonatomic) int seconds;

@property (nonatomic) int pauseNumber;

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
        self.isStart = !self.isStart;
    } else {
        self.endDate = [NSDate date];
        [self runScheduleAlert]; //then will run scheduleEvent and handle resets
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
    
    //self.isPaused = !self.isPaused; Moved to resume/pause timer methods so delegate works when app goes to background
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
- (void)runScheduleAlert
{
    UIAlertView *confirmAlert = [[UIAlertView alloc]initWithTitle:@"Schedule" message:[NSString stringWithFormat:@"Place event onto iCal? %@ to %@", self.startDate, self.endDate] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", @"Cancel", nil];
    confirmAlert.cancelButtonIndex = 1; //set cancel as cancel
    // tag for identification when handling
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
    // tag indicates is Schedule alert
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
    // tag indicates Reset alert
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
    //event.location
    
    int mins = floor(self.seconds/60);
    int secs = self.seconds - (mins * 60);
    int pmins = floor(self.pausedSeconds/60);
    int psecs = floor(self.pausedSeconds - (pmins * 60));
    event.notes = [NSString stringWithFormat:@"%i:%02i active, %i:%02i inactive, paused %i times", mins, secs, pmins, psecs, self.pauseNumber];
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
    self.isPaused = YES;
}
- (void)resumeTimer
{
    //new additions stop rapidfire pause/resume from increasing time, but also basically pauses it entirely. idk how apple's code works. Tied to system clock? Whatever...please don't try to break this.
    self.isPaused = NO;
    [self updateUI];
    
    float pauseTimeWas = -1 * [self.pauseStartDate timeIntervalSinceNow]; //results in positive #
    if (floor(pauseTimeWas) >= 1) {
        [self.timer setFireDate:[self.startDate initWithTimeInterval:pauseTimeWas sinceDate:self.startDate]];
        
        //tracks pause time
        self.pausedSeconds += pauseTimeWas;
        //self.isPaused = NO;
    } else {
        [self performSelector:@selector(resumeTimer) withObject:nil afterDelay:(1 - pauseTimeWas)];
        
        //just to trick into updatingUI so doesn't appear wrong
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
        [self.bigButton setTitle:@"Start" forState:UIControlStateNormal];
        //prior design
        //self.bigButton.backgroundColor = [UIColor greenColor];
        //self.pauseButton.hidden = YES;
        //self.resetButton.hidden = YES;
        
        //current design
        
        //set defaults
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
        //self.bigButton.backgroundColor = [UIColor colorWithRed:1 green:0.0335468 blue:0.00867602 alpha:1];
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
            //[self.pauseButton setTitleColor:[UIColor colorWithRed:0.720482 green:1 blue:0.632028 alpha:1] forState:UIControlStateNormal];
            //self.pauseButton.layer.borderColor = [UIColor colorWithRed:0.720482 green:1 blue:0.632028 alpha:1].CGColor;
        } else {
            [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
            [self.pauseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.pauseButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
    }
    
    
    self.testButton.layer.cornerRadius = self.testButton.frame.size.width/2;
    self.testButton.layer.borderWidth = 1;
    [self.testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.testButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.testButton setTitle:@"ttEn" forState:UIControlStateNormal];
    [self.testButton setTitle:@"gg" forState:UIControlStateDisabled];
    if (self.testButton.enabled) {
        //[self.testButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.testButton.backgroundColor = [UIColor whiteColor];
        self.testButton.layer.borderColor = [UIColor blueColor].CGColor;
        
    } else {
        //[self.testButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; //UIControlStateDisabled only resets textcolor, not bordercolor fml idk why. Or maybe self.testButton.titleLabel.textColor.CGColor only takes UIControlStateNormal color
        self.testButton.backgroundColor = nil;//[UIColor whiteColor];
        self.testButton.layer.borderColor = [UIColor grayColor].CGColor;
        
    }
    
    
    //self.testButton.titleLabel.textColor = [UIColor grayColor];
    //self.testButton.layer.borderColor = self.testButton.titleLabel.textColor.CGColor;
    
    
    //timerLabel updated on increaseTimerCount: method
}

- (IBAction)testButtonChecked:(UIButton *)sender {
    self.testButton.enabled = !self.testButton.enabled;
    [self updateUI];
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
    //NSLog(@"%@", self.ob.backgroundColor);
    //set defaults
    self.isStart = YES;
    self.isPaused = NO;
    self.timerLabel.text = @"00:00";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"firstTime"]) {
        //set defaults
        NSArray *wordArr = @[@"Procrastination", @"Internet", @"Work", @"Shopping", @"Fun", @"Movies", @"Social", @"Travel", @"Drinking"]; //custom has no im, should be nil
        NSMutableArray *storeWords = [NSMutableArray array];
        
        for (NSString *word in wordArr) {
            NSData *encodedSampleWorkObj = [NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:word image:[UIImage imageNamed:word]]];
            [storeWords addObject:encodedSampleWorkObj];
        }
        [defaults setObject:storeWords forKey:@"shortcuts"];
        [defaults setObject:@[[NSKeyedArchiver archivedDataWithRootObject:[[HCSShortcut alloc]initWithTitle:@"School" image:nil]]] forKey:@"textShortcuts"];
        [defaults setBool:true forKey:@"firstTime"];
        [defaults synchronize];
    }
    
    //[defaults setObject:@[@"Addcustom"] forKey:@"customShortcuts"];
    //[defaults synchronize];
    
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
