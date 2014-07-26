//
//  HCSActivityLogTableViewController.m
//  Track This Moment
//
//  Created by Roger on 7/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSActivityLogTableViewController.h"
#import "HCSActivityRecord.h"
#import "HCSActivityRecordTableViewCell.h"
#import "HCSExportActivityLogViewController.h"

@interface HCSActivityLogTableViewController ()

@property (nonatomic, strong) NSMutableArray *activityRecordArray;

@end

@implementation HCSActivityLogTableViewController

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"writeSegue"])
    {
        //HCSExportActivityLogViewController *segueVC = (HCSExportActivityLogViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        HCSExportActivityLogViewController *segueVC = (HCSExportActivityLogViewController *)[segue destinationViewController];
        segueVC.actRecArr = self.activityRecordArray;
    }
}


@end
