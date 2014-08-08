//
//  HCSModifyReminderViewController.m
//  Track Today
//
//  Created by Roger on 7/23/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSModifyReminderViewController.h"

@interface HCSModifyReminderViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation HCSModifyReminderViewController


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
    
    //set datepicker date
    NSArray *scheduledLocalNotifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if ([scheduledLocalNotifs count]) {
        //exists local notif. Just in case, go thru array and get the reminder notif of which there should be only one
        for (UILocalNotification *localNotif in scheduledLocalNotifs) {
            if ([localNotif.userInfo[@"typeKey"] isEqualToString:@"reminder"]) {
                self.datePicker.date = localNotif.fireDate;
                break;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        self.date = self.datePicker.date;
    }
}


@end
