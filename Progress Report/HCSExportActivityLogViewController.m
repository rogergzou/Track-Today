//
//  HCSExportActivityLogViewController.m
//  Track This Moment
//
//  Created by Roger on 7/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSExportActivityLogViewController.h"
#import "HCSActivityRecord.h"

@interface HCSExportActivityLogViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textview;

@end

@implementation HCSExportActivityLogViewController

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
    
    
    
    NSString *placeholderString = @"Activity log for Track This Moment:\n\n";
    for (HCSActivityRecord *record in self.actRecArr) {
        
        int mins = floor(record.seconds/60);
        int secs = record.seconds - (mins * 60);
        int hours = 0;
        if (mins > 59) {
            hours = floor(mins/60);
            mins -= hours * 60;
        }
        int pmins = floor(record.pausedSeconds/60);
        int psecs = floor(record.pausedSeconds - (pmins * 60));
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
        
        placeholderString = [placeholderString stringByAppendingString:[NSString stringWithFormat:@"'%@' was scheduled %d %@, %@ active, %@ inactive, paused %d %@.\n", record.title, record.activityNumber, (record.activityNumber-1 ? @"times" : @"time"), timeString, pTimeString, record.pauseNumber, (record.pauseNumber-1 ? @"times" : @"time")]];
        
        /*
        int arraytotal = (int)[record.startDateArray count];
        
        for (int i = arraytotal - 1; i >= 0; i--) {
            NSDate *startDate = record.startDateArray[i];
            NSDate *endDate = record.endDateArray[i];
            
            NSString *startDateString = [NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
            NSString *endDateString = [NSDateFormatter localizedStringFromDate:endDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
            //NSDate *startDateOnly = self.startDate;
            //NSDate *endDateOnly = self.endDate;
            [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:startDate];
            [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&endDate interval:NULL forDate:endDate];
            if ([startDate compare:endDate] == NSOrderedSame) {
                //endDateString = [endDateString substringFromIndex:[endDateString length]-10];
                endDateString = [endDateString componentsSeparatedByString:@", "][1];
            }
            int pnum = [record.pauseNumberArray[i] intValue];
            NSString *pauseNumString = [NSString stringWithFormat:@"%d %@", pnum, (pnum - 1 ? @"pauses" : @"pause")];
            
            int recsecs = [record.secondsArray[i] intValue];
            NSTimeInterval recpsecs = [record.pausedSecondsArray[i] doubleValue];
            //NSLog(@"%f fwef %@", recpsecs, self.record.pausedSecondsArray);
            int mins = floor(recsecs/60);
            int secs = recsecs - (mins * 60);
            int hours = 0;
            if (mins > 59) {
                hours = floor(mins/60);
                mins -= hours * 60;
            }
            int pmins = floor(recpsecs/60);
            int psecs = floor(recpsecs - (pmins * 60));
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
            
            placeholderString = [placeholderString stringByAppendingString:[NSString stringWithFormat:@"    %@ - %@: %@ active, %@ paused, %@.\n", startDateString, endDateString, timeString, pTimeString, pauseNumString]];
        }
        */
        placeholderString = [placeholderString stringByAppendingString:@"\n"];
        
    }
    self.textview.text = placeholderString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
