//
//  HCSDetailedActivityRecordFromTableViewController.m
//  Track Today
//
//  Created by Roger on 7/27/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSDetailedActivityRecordFromTableViewController.h"
#import "HCSDetailedActivityRecordTableViewCell.h"

@interface HCSDetailedActivityRecordFromTableViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortBarButtonItem;

@end

@implementation HCSDetailedActivityRecordFromTableViewController

- (IBAction)sortBarButtonPressed:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Order By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Time", @"Date", @"Paused Time", @"Reverse", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
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
    
    self.navigationItem.title = self.record.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)sortLogWithButtonIndex:(NSInteger)buttonIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //resets the activity record array to not-logged state
    //HCSActivityRecord *testRecord = [self.record copy];
    //NSMutableArray *storeSortArray = [NSMutableArray array];
    //NSMutableArray *counterArray = [NSMutableArray array];
    switch (buttonIndex) {
        case 0:
            //time
            //seconds
            /*[self.record sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
                return [@(obj2.seconds) compare: @(obj1.seconds)];
            }];
            
             // //
             
            [storeSortArray addObjectsFromArray:self.record.secondsArray];
            [storeSortArray sortUsingComparator:^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
                return [num2 compare:num1];
            }];
            
            //inefficient sort
            for (NSNumber *number in self.record.secondsArray) {
                for (NSNumber *sortedNum in storeSortArray) {
                    if ([sortedNum isEqualToNumber:number]) {
                        [counterArray addObject:@([storeSortArray indexOfObject:sortedNum])];
                        break;
                    }
                }
            }
            
            //reorder
            for (int i = 0; i < [storeSortArray count]; i++) {
                int newIndex = [counterArray[i] intValue];
                self.record.secondsArray[i] = testRecord.secondsArray[newIndex];
                self.record.startDateArray[i] = testRecord.startDateArray[newIndex];
                self.record.endDateArray[i] = testRecord.endDateArray[newIndex];
                self.record.pausedSecondsArray[i] = testRecord.pausedSecondsArray[newIndex];
                self.record.pauseNumberArray[i] = testRecord.pauseNumberArray[newIndex];
                self.record.eventTitleArray[i] = testRecord.eventTitleArray[newIndex];
            }
            
            [self.tableView reloadData];
            self.sortBarButtonItem.title = @"Order: Time";
            break;
        case 1:
            //date
            [storeSortArray addObjectsFromArray:self.record.startDateArray];
            [storeSortArray sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
                return [date2 compare:date1];
            }];
            
            //inefficient sort
            for (NSDate *date in self.record.startDateArray) {
                for (NSDate *sortedDate in storeSortArray) {
                    if ([sortedDate isEqualToDate:date]) {
                        [counterArray addObject:@([storeSortArray indexOfObject:sortedDate])];
                        break;
                    }
                }
            }
            
            //reorder
            for (int i = 0; i < [storeSortArray count]; i++) {
                int newIndex = [counterArray[i] intValue];
                self.record.secondsArray[i] = testRecord.secondsArray[newIndex];
                self.record.startDateArray[i] = testRecord.startDateArray[newIndex];
                self.record.endDateArray[i] = testRecord.endDateArray[newIndex];
                self.record.pausedSecondsArray[i] = testRecord.pausedSecondsArray[newIndex];
                self.record.pauseNumberArray[i] = testRecord.pauseNumberArray[newIndex];
                self.record.eventTitleArray[i] = testRecord.eventTitleArray[newIndex];
            }
            
            [self.tableView reloadData];
            self.sortBarButtonItem.title = @"Order: Date";
            break;*/
            break;
        case 1:
            //date
            break;
        case 2:
            //paused time
            break;
        case 3:
            //reverse
            break;
        default:
            //cancel
            break;
    }
    //if not cancel or reverse, save to defaults
    //not done
    if (buttonIndex < 3) {
        [defaults setInteger:buttonIndex forKey:@"detailedButtonIndex"];
        [defaults synchronize];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self sortLogWithButtonIndex:buttonIndex];
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
        NSDate *endDateUnmodified = endDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:startDate];
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&endDate interval:NULL forDate:endDate];
        if ([startDate compare:endDate] == NSOrderedSame) {
            //endDateString = [endDateString substringFromIndex:[endDateString length]-10];
            
            //this is the Grant bug
            //endDateString = [endDateString componentsSeparatedByString:@", "][1];
            endDateString = [NSDateFormatter localizedStringFromDate:endDateUnmodified dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        }

        detailedCell.dateLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
        
        int pnum = [self.record.pauseNumberArray[indexPath.row]intValue];
        //detailedCell.pauseNumberLabel.text = [NSString stringWithFormat:@"%d %@", pnum, (pnum - 1 ? @"pauses" : @"pause")];
        //redesign lol for category instead of autofill. Means event title instead of pause #
        
        //lol some people may already have used, this avoids crash between version 1.2 and version 1.3
        if (indexPath.row < [self.record.eventTitleArray count]) {
            if (pnum) {
                detailedCell.eventTitleLabel.text = self.record.eventTitleArray[indexPath.row];
                detailedCell.longerEventTitleLabel.hidden = YES;
                detailedCell.inactiveLabel.hidden = NO;
                detailedCell.eventTitleLabel.hidden = NO;
            } else {
                detailedCell.longerEventTitleLabel.text = self.record.eventTitleArray[indexPath.row];
                detailedCell.eventTitleLabel.hidden = YES;
                detailedCell.inactiveLabel.hidden = YES;
                detailedCell.longerEventTitleLabel.hidden = NO;
            }
        } else {
            detailedCell.eventTitleLabel.text = [NSString stringWithFormat:@"%d %@", pnum, (pnum - 1 ? @"pauses" : @"pause")];
            detailedCell.longerEventTitleLabel.hidden = YES;
        }
        int recsecs = [self.record.secondsArray[indexPath.row] intValue];
        NSTimeInterval recpsecs = [self.record.pausedSecondsArray[indexPath.row] doubleValue];
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
