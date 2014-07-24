//
//  HCSReminderTableViewController.m
//  Track This Moment
//
//  Created by Roger on 7/22/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSReminderTableViewController.h"

@interface HCSReminderTableViewController ()

@property (nonatomic, strong) NSMutableArray *timeIntervalSelectionArray;

@end

@implementation HCSReminderTableViewController

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// should probably add a custom and let that be a UIPicker for minutes/hours
- (NSMutableArray *)timeIntervalSelectionArray
{
    if (!_timeIntervalSelectionArray) {
        _timeIntervalSelectionArray = [@[@1, @5, @10, @15, @30, @45, @60, @90, @120, @180, @300, @480, @600, @720]mutableCopy];
    }
    return _timeIntervalSelectionArray;
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
    return [self.timeIntervalSelectionArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTimeCell" forIndexPath:indexPath];
    int minplacehold = [self.timeIntervalSelectionArray[indexPath.row]intValue];
    double hours;
    NSString *timeText;
    if (minplacehold >= 60) {
        hours = minplacehold/60.0;
        if (hours == 1)
            timeText = @"1 hour";
        else
            timeText = [NSString stringWithFormat:@"%.1f hours", hours];
    } else if (minplacehold == 1)
        timeText = @"1 minute";
    else
        timeText = [NSString stringWithFormat:@"%i minutes", minplacehold];
    cell.textLabel.text = timeText;
    // Configure the cell...
    cell.detailTextLabel.text = @"";
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
    NSLog(@"%@", sender);
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        self.minutes = [self.timeIntervalSelectionArray[[self.tableView indexPathForCell:cell].row] intValue];
    }
}


@end
