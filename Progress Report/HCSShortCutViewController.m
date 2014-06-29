//
//  HCSShortCutViewController.m
//  Progress Report
//
//  Created by Roger on 6/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSShortCutViewController.h"
#import "HCSShortCutTextViewCell.h"
#import "HCSShortcut.h"

@interface HCSShortCutViewController ()

@end

@implementation HCSShortCutViewController

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1; //for now
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"shortcuts"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HCSShortCutTextViewCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyShortCut" forIndexPath:indexPath];
    long fRow = [indexPath row];
    
    NSData *shortcutData = [[NSUserDefaults standardUserDefaults]arrayForKey:@"shortcuts"][fRow];
    HCSShortcut *shortcut = (HCSShortcut *)[NSKeyedUnarchiver unarchiveObjectWithData:shortcutData];
    theCell.imageView.image = shortcut.image;
    theCell.titleLabel.text = shortcut.title;
    //[theCell.titleLabel setText:shortcut.title];
    return theCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /* handled by the storyboard segue
     
     UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HCSShortCutTextViewCell class]]) {
        HCSShortCutTextViewCell *shortcutCell = (HCSShortCutTextViewCell *)cell;
        NSString *title = shortcutCell.titleLabel.text;
     
        //segue with?
        //?????????????????
        //[self dismissViewControllerAnimated:YES completion:nil];
        
        //shortcutCell.titleLabel.text;
    }
     */
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[HCSShortCutTextViewCell class]]) {
        HCSShortCutTextViewCell *cell = (HCSShortCutTextViewCell *)sender;
        self.title = cell.titleLabel.text;
        //assigning of text handled in myShortCutTextSegueUnwind method in parent VC
    }
}


@end
