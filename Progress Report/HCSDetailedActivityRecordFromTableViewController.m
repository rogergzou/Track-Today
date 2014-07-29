//
//  HCSDetailedActivityRecordFromTableViewController.m
//  Track This Moment
//
//  Created by Roger on 7/27/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSDetailedActivityRecordFromTableViewController.h"
#import "HCSDetailedActivityRecordTableViewCell.h"

@interface HCSDetailedActivityRecordFromTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HCSDetailedActivityRecordFromTableViewController


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
    
    self.navigationItem.title = self.record.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //title already covered. one for each of start->end events.
    return [self.record.startDateArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    if ([cell isKindOfClass:[HCSDetailedActivityRecordTableViewCell class]]) {
        HCSDetailedActivityRecordTableViewCell *detailedCell = (HCSDetailedActivityRecordTableViewCell *)cell;
        
        NSDate *startDate = self.record.startDateArray[indexPath.row];
        NSDate *endDate = self.record.endDateArray[indexPath.row];
        
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

        detailedCell.dateLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
        
        int pnum = [self.record.pauseNumberArray[indexPath.row]intValue];
        detailedCell.pauseNumberLabel.text = [NSString stringWithFormat:@"%d %@", pnum, (pnum - 1 ? @"pauses" : @"pause")];
        
        int recsecs = [self.record.secondsArray[indexPath.row] intValue];
        NSTimeInterval recpsecs = [self.record.pausedSecondsArray[indexPath.row] doubleValue];
        NSLog(@"%f fwef %@", recpsecs, self.record.pausedSecondsArray);
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
        
        detailedCell.activeLabel.text = [NSString stringWithFormat:@"%@ active", timeString];
        if (pnum)
            detailedCell.inactiveLabel.text = [NSString stringWithFormat:@"%@ paused", pTimeString];
        else
            detailedCell.inactiveLabel.text = @"";
    }
    return cell;
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