//
//  HCSAddReminderViewController.m
//  Track Today
//
//  Created by Roger on 9/3/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSAddReminderViewController.h"

@interface HCSAddReminderViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) NSArray *secondsArray;
@property (strong, nonatomic) NSArray *minutesArray;
@property (strong, nonatomic) NSArray *hoursArray;

@end

@implementation HCSAddReminderViewController

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (int)seconds
{
    if (!_seconds) _seconds = 0;
    return _seconds;
}
- (int)minutes
{
    if (!_minutes) _minutes = 0;
    return _minutes;
}
- (int)hours
{
    if (!_hours) _hours = 0;
    return _hours;
}
- (NSArray *)secondsArray
{
    if (!_secondsArray) _secondsArray = @[@0, @5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @55];
    return _secondsArray;
}
- (NSArray *)minutesArray
{
    if (!_minutesArray) {
        NSMutableArray *placeholder = [NSMutableArray array];
        for (int i = 0; i < 60; i++) {
            [placeholder addObject:@(i)];
        }
        _minutesArray = placeholder;
    }
    return _minutesArray;
}
- (NSArray *)hoursArray
{
    if (!_hoursArray) {
        NSMutableArray *placeholder = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            [placeholder addObject:@(i)];
        }
        _hoursArray = placeholder;
    }
    return _hoursArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.addButton.layer.borderWidth = 1;
    self.addButton.layer.cornerRadius = self.addButton.frame.size.height/6;
    self.addButton.layer.borderColor = self.addButton.titleLabel.textColor.CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *tView = (UILabel *)view;
    if (!tView) {
        tView = [[UILabel alloc]init];
        //set font
        [tView setFont:[UIFont fontWithName:@"Courier New" size:64]];
        tView.textAlignment = NSTextAlignmentCenter;
    }
    if (component == 0)
        tView.text = [NSString stringWithFormat:@"%02i", [self.hoursArray[row] intValue]];
    else if (component == 1) {
        tView.text = [NSString stringWithFormat:@"%02i", [self.minutesArray[row] intValue]];
        /*
        CALayer* layer = [tView layer];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRectMake(1, layer.frame.size.height+1, layer.frame.size.width, 1);
        [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
        [layer addSublayer:bottomBorder];
        */
    }
    else if (component == 2)
        tView.text = [NSString stringWithFormat:@"%02i", [self.secondsArray[row] intValue]];
    return tView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            self.hours = [self.hoursArray[row] intValue];
            break;
        case 1:
            self.minutes = [self.minutesArray[row] intValue];
            break;
        case 2:
            self.seconds = [self.secondsArray[row] intValue];
            break;
        default:
            break;
    }
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.hoursArray count];
            break;
        case 1:
            return [self.minutesArray count];
            break;
        case 2:
            return [self.secondsArray count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 80;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
