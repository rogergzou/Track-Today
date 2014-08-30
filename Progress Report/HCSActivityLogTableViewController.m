//
//  HCSActivityLogTableViewController.m
//  Track Today
//
//  Created by Roger on 7/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSActivityLogTableViewController.h"
#import "HCSActivityRecord.h"
#import "HCSActivityRecordTableViewCell.h"
//#import "HCSExportActivityLogViewController.h"
#import "HCSDetailedActivityRecordFromTableViewController.h"
#import <MessageUI/MessageUI.h>

@interface HCSActivityLogTableViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *activityRecordArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortBarButtonItem;

@end

@implementation HCSActivityLogTableViewController

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sortButtonPressed:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Order By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Time", @"Date", @"Log", @"Events", @"Paused Time", nil];
    //actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)emailButtonPressed:(id)sender {
    NSString *placeholderString = @"Activity log for Track Today:\n\n";
    NSString *fullString = @"Individual event logs:\n\n";
    for (HCSActivityRecord *record in self.activityRecordArray) {
        
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
        
        placeholderString = [placeholderString stringByAppendingString:[NSString stringWithFormat:@"'%@' was scheduled %d %@, active %@, paused %@, %d %@.\n", record.title, record.activityNumber, (record.activityNumber-1 ? @"times" : @"time"), timeString, pTimeString, record.pauseNumber, (record.pauseNumber-1 ? @"pauses" : @"pause")]];
        fullString = [fullString stringByAppendingString:[NSString stringWithFormat:@"'%@' was scheduled %d %@, active %@, paused %@, %d %@.\n", record.title, record.activityNumber, (record.activityNumber-1 ? @"times" : @"time"), timeString, pTimeString, record.pauseNumber, (record.pauseNumber-1 ? @"pauses" : @"pause")]];
        
         int arraytotal = (int)[record.startDateArray count];
         
         for (int i = arraytotal - 1; i >= 0; i--) {
             NSDate *startDate = record.startDateArray[i];
             NSDate *endDate = record.endDateArray[i];
             
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
             
             NSString *eventTitleString = @"";
             if (i < [record.eventTitleArray count]) {
                 if ([record.eventTitleArray[i] length]) {
                     eventTitleString = [NSString stringWithFormat:@" '%@'.", record.eventTitleArray[i]];
                 }
             }
             fullString = [fullString stringByAppendingString:[NSString stringWithFormat:@"    %@ - %@. Active %@, paused %@, %@.%@\n", startDateString, endDateString, timeString, pTimeString, pauseNumString, eventTitleString]];
         }
        fullString = [fullString stringByAppendingString:@"\n"];
        //placeholderString = [placeholderString stringByAppendingString:@"\n"];
    };
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"Activity Log for Track Today %@", [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"%@\n\n\n\n%@", placeholderString, fullString];
    // To address
    //NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    //[mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (NSMutableArray *)activityRecordArray
{
    if (!_activityRecordArray) _activityRecordArray = [NSMutableArray array];
    return _activityRecordArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *statsDict = [defaults dictionaryForKey:@"fullStatsDict"];
    NSMutableArray *statsArray = [NSMutableArray array];
    for (NSString *key in statsDict) {
        [statsArray addObject:[NSKeyedUnarchiver unarchiveObjectWithData:statsDict[key]]];
    }
    //NSArray *sortedArray = [self sortMutableArray:statsArray ByType:@"seconds"];
    
    [statsArray sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
        return [@(obj2.seconds) compare: @(obj1.seconds)];
    }];
    
    self.activityRecordArray = statsArray;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (NSArray *)sortMutableArray:(NSMutableArray *)array ByType:(NSString *)typeString
{
    if ([typeString isEqualToString:@"seconds"]) {
        //NSMutableArray *secondsArray = [NSMutableArray array];
        //NSMutableArray *p = [NSMutableArray array];
        //int i = 0;
        //for (HCSActivityRecord *record in array) {
          //  [secondsArray addObject:@(record.seconds)];
            //[p addObject:@(i)];
//            i++;
  //      }
        
        [array sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
            return [@(obj1.seconds) compare: @(obj2.seconds)];
        }];
        
        
        
        [p sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
            // Modify this to use [first objectAtIndex:[obj1 intValue]].name property
            NSString *lhs = [first objectAtIndex:[obj1 intValue]];
            // Same goes for the next line: use the name
            NSString *rhs = [first objectAtIndex:[obj2 intValue]];
            return [lhs compare:rhs];
        }];
        NSMutableArray *sortedFirst = [NSMutableArray arrayWithCapacity:first.count];
        NSMutableArray *sortedSecond = [NSMutableArray arrayWithCapacity:first.count];
        [p enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSUInteger pos = [obj intValue];
            [sortedFirst addObject:[first objectAtIndex:pos]];
            [sortedSecond addObject:[second objectAtIndex:pos]];
        }];
        
        
        
        
    }
    
    return nil;
}
 */

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%li", (long)buttonIndex);
    switch (buttonIndex) {
        case 0:
            [self.activityRecordArray sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
             return [@(obj2.seconds) compare: @(obj1.seconds)];
             }];
            [self.tableView reloadData];
            self.sortBarButtonItem.title = @"Order: Time";
            break;
        case 1:
             [self.activityRecordArray sortUsingComparator:^(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
             if (![obj2.startDateArray firstObject]) {
             if (![obj1.startDateArray firstObject])
             return NSOrderedSame;
             else
             return NSOrderedAscending;
             } else if (![obj1.startDateArray firstObject])
             return NSOrderedDescending;
             //NSLog(@"%ld is -1", (long)NSOrderedAscending);
             //NSLog(@"o2 %@ to o1 %@ results in %ld", [obj2.startDateArray firstObject], [obj1.startDateArray firstObject], [[obj2.startDateArray firstObject] compare: [obj1.startDateArray firstObject]]);
             return [[obj2.startDateArray firstObject] compare: [obj1.startDateArray firstObject]];
             }];
             [self.tableView reloadData];
            self.sortBarButtonItem.title = @"Order: Date";
            break;
        case 2:
            self.sortBarButtonItem.title = @"Order: Log";
            break;
        case 3:
            [self.activityRecordArray sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
                return [@(obj2.activityNumber) compare: @(obj1.activityNumber)];
            }];
            [self.tableView reloadData];
            self.sortBarButtonItem.title = @"Order: Events";
            break;
        case 4:
            [self.activityRecordArray sortUsingComparator:^NSComparisonResult(HCSActivityRecord *obj1, HCSActivityRecord *obj2) {
                return [@(obj2.pausedSeconds) compare: @(obj1.pausedSeconds)];
            }];
            [self.tableView reloadData];
            self.sortBarButtonItem.title = @"Order: Paused Time";
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.activityRecordArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if ([cell isKindOfClass:[HCSActivityRecordTableViewCell class]]) {
        HCSActivityRecordTableViewCell *recordCell = (HCSActivityRecordTableViewCell *)cell;
        HCSActivityRecord *record = self.activityRecordArray[indexPath.row];
        recordCell.titleLabel.text = record.title;
        
        recordCell.timesLabel.text = [NSString stringWithFormat:@"%i %@", record.activityNumber, ((record.activityNumber-1) ? @"events": @"event")];
        
        
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
        recordCell.activeLabel.text = [NSString stringWithFormat:@"%@ active", timeString];
        recordCell.pausedTimeLabel.text = [NSString stringWithFormat:@"%@ paused", pTimeString];
        
        return recordCell;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*
    if ([segue.identifier isEqualToString:@"writeSegue"])
    {
        //HCSExportActivityLogViewController *segueVC = (HCSExportActivityLogViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        HCSExportActivityLogViewController *segueVC = (HCSExportActivityLogViewController *)[segue destinationViewController];
        segueVC.actRecArr = self.activityRecordArray;
    } else if ([segue.identifier isEqualToString:@"infoSegue"]) {*/
    if ([segue.identifier isEqualToString:@"infoSegue"]) {
        HCSDetailedActivityRecordFromTableViewController *detailedVC = (HCSDetailedActivityRecordFromTableViewController *)[segue destinationViewController];
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)sender;
            detailedVC.record = self.activityRecordArray[[self.tableView indexPathForCell:cell].row];
            //NSLog(@"%@ f", detailedVC.record.startDateArray);
        }
    }
}


@end
