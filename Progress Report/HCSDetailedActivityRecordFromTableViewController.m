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
@property (strong, nonatomic) NSString *customDetailedButtonIndex;

@end

@implementation HCSDetailedActivityRecordFromTableViewController

- (IBAction)sortBarButtonPressed:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Order By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log", @"Time", @"Paused Time", @"Reverse", nil];
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
    self.customDetailedButtonIndex = [NSString stringWithFormat:@"detailedButtonIndex%@", self.record.title];
    [self checkEventArray];
    self.navigationItem.title = self.record.title;
    //NSInteger buttonIndex;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //if ([defaults integerForKey:@"detailedButtonIndex"]) {
    NSInteger buttonIndex = [defaults integerForKey:self.customDetailedButtonIndex];
    //}
    [self sortLogWithButtonIndex:buttonIndex];
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//cleanup to prevent nsrangeexception: index is beyond bounds is in checkEventArray method
- (void)checkEventArray {
    if ([self.record.eventTitleArray count] < [self.record.secondsArray count]) {
        [self.record.eventTitleArray addObject:@""];
        [self checkEventArray];
    }
}

- (void)sortLogWithButtonIndex:(NSInteger)buttonIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //resets the activity record array to not-logged state
    //HCSActivityRecord *testRecord = [self.record copy];
    NSMutableArray *storeSortArray = [NSMutableArray array];
    NSUInteger arrLen = [self.record.secondsArray count];
    
    //NSMutableArray *counterArray = [NSMutableArray array];
    
    //basically: make a new HCSActivityRecord for each object in array. Sort via selector. redistribute to record after.
    //need to add start/end date to hcsactivityrecord before this ^^
    for (NSUInteger i = 0; i < arrLen; i++) {
        HCSActivityRecord *rec = [[HCSActivityRecord alloc]init];
        rec.seconds = [self.record.secondsArray[i] doubleValue];
        rec.pausedSeconds = [self.record.pausedSecondsArray[i] doubleValue];
        rec.pauseNumber = [self.record.pauseNumberArray[i] intValue];
        
        if (self.record.startDateArray[i])
            rec.startDate = self.record.startDateArray[i];
        if (self.record.endDateArray[i])
            rec.endDate = self.record.endDateArray[i];
        if (self.record.eventTitleArray[i])
            rec.title = self.record.eventTitleArray[i];
        [storeSortArray addObject:rec];
    }
    
    switch (buttonIndex) {
        case 1:
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
            /*
            // Put the two arrays into a dictionary as keys and values
            NSDictionary *dictSecs = [NSDictionary dictionaryWithObjects:secondArray forKeys:firstArray];
            // Sort the first array
            NSArray *sortedFirstArray = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
            // Sort the second array based on the sorted first array
            NSArray *sortedSecondArray = [dictionary objectsForKeys:sortedFirstArray notFoundMarker:[NSNull null]];
             */
            [storeSortArray sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
                return [@(obj2.seconds) compare: @(obj1.seconds)];
            }];
            self.sortBarButtonItem.title = @"Order: Time";
            break;
        case 0:
            //date
            [storeSortArray sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
                return [obj2.startDate compare: obj1.startDate];
            }];
            self.sortBarButtonItem.title = @"Order: Log";

            break;
        case 2:
            //paused time
            [storeSortArray sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
                return [@(obj2.pausedSeconds) compare: @(obj1.pausedSeconds)];
            }];
            self.sortBarButtonItem.title = @"Order: Paused Time";

            break;
        case 3:
            //reverse
            storeSortArray = [[[storeSortArray reverseObjectEnumerator] allObjects] mutableCopy];
            //title below
            if ([[self.sortBarButtonItem.title substringFromIndex:[self.sortBarButtonItem.title length] - 4] isEqualToString:@"sed)"]) {
                //checks if ends in "(Reverse)"
                
                // define the range you're interested in
                NSRange stringRange = {0, MIN([self.sortBarButtonItem.title length], [self.sortBarButtonItem.title length] - 11)};
                
                // adjust the range to include dependent chars
                stringRange = [self.sortBarButtonItem.title rangeOfComposedCharacterSequencesForRange:stringRange];
                
                // Now you can create the short string
                self.sortBarButtonItem.title = [self.sortBarButtonItem.title substringWithRange:stringRange];
            } else
                self.sortBarButtonItem.title = [self.sortBarButtonItem.title stringByAppendingString:@" (Reversed)"];
            
            break;
        default:
            //cancel
            break;
    }
    //make storeSortArray records back into self.record.yadaArray stuff
    for (NSUInteger i = 0; i < arrLen; i++) {
        HCSActivityRecord *rec= storeSortArray[i];
        if (rec.startDate)
            self.record.startDateArray[i] = rec.startDate;
        if (rec.endDate)
            self.record.endDateArray[i] = rec.endDate;
        self.record.secondsArray[i] = @(rec.seconds);
        self.record.pausedSecondsArray[i] = @(rec.pausedSeconds);
        self.record.pauseNumberArray[i] = @(rec.pauseNumber);
        if (rec.title)
            self.record.eventTitleArray[i] = rec.title;
    }
    [self.tableView reloadData];
    //if not cancel or reverse, save to defaults
    //not done
    if (buttonIndex < 3) {
        [defaults setInteger:buttonIndex forKey:self.customDetailedButtonIndex];
        [defaults synchronize];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self sortLogWithButtonIndex:buttonIndex];
}

#pragma mark - UITableViewDelegate

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
