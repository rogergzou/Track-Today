//
//  HCSShortCutViewController.m
//  Progress Report
//
//  Created by Roger on 6/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSShortCutViewController.h"
#import "HCSShortCutTextViewCell.h"
#import "HCSAddCustomViewCell.h"
#import "HCSCustomViewCell.h"
#import "HCSShortcut.h"
#import "HCSMyHeaderReusableView.h"

@interface HCSShortCutViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) BOOL textDeleteActive;
@property (nonatomic) BOOL imageDeleteActive;

@end

@implementation HCSShortCutViewController

- (void)TextHeaderDeleteButtonDynamicHandler
{
    self.textDeleteActive = !self.textDeleteActive;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
}
- (void)ImageHeaderDeleteButtonDynamicHandler
{
    self.imageDeleteActive = !self.imageDeleteActive;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}
- (void)TextCellDeleteButtonDynamicHandler:(id)sender event:(id)event
{
    [self deleteItemAndReloadCollectionView:sender event:event defaultsKey:@"textShortcuts"];
}
- (void)ImageCellDeleteButtonDynamicHandler:(id)sender event:(id)event
{
    [self deleteItemAndReloadCollectionView:sender event:event defaultsKey:@"shortcuts"];
 
}
- (void)deleteItemAndReloadCollectionView:(id)sender event:(id)event defaultsKey:(NSString *)key
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *shortcuts = [[defaults arrayForKey:key] mutableCopy];
    [shortcuts removeObjectAtIndex:indexPath.row];
    [defaults setObject:shortcuts forKey:key];
    [defaults synchronize];
    [self.collectionView reloadData];
}

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
    
    //set defaults
    self.textDeleteActive = NO;
    self.imageDeleteActive = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)myCreateShortcutUnwindSegueCallback:(UIStoryboardSegue *)segue
{
    //only called if something went thru and data changed
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2; //images and textonly
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"shortcuts"] count];
            break;
        case 1:
            return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"textShortcuts"] count];
            break;
        default:
            return 0;
            break;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    long fRow = [indexPath row];
    switch ([indexPath section]) {
        case 0:
            if (true) {
                NSString *imageCellReuseIdentifier;
                if (self.imageDeleteActive) {
                    imageCellReuseIdentifier = @"MyDeleteShortCut";
                } else {
                    imageCellReuseIdentifier = @"MyShortCut";
                }
                NSData *shortcutData = [[NSUserDefaults standardUserDefaults]arrayForKey:@"shortcuts"][fRow];
                HCSShortcut *shortcut = (HCSShortcut *)[NSKeyedUnarchiver unarchiveObjectWithData:shortcutData];
                HCSShortCutTextViewCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellReuseIdentifier forIndexPath:indexPath];
                theCell.imageView.image = shortcut.image;
                theCell.titleLabel.text = shortcut.title;
                
                if (self.imageDeleteActive) {
                    theCell.deleteButton.hidden = NO;
                    [theCell startJiggling];
                    
                } else {
                    theCell.deleteButton.hidden = YES;
                }
                
                
                [theCell.deleteButton addTarget:self action:@selector(ImageCellDeleteButtonDynamicHandler:event:) forControlEvents:UIControlEventTouchUpInside];
                return theCell;
            }
            break;
        case 1:
            if (true) {
                NSString *textCellReuseIdentifier;
                if (self.textDeleteActive) {
                    textCellReuseIdentifier = @"MyDeleteCustom";
                } else {
                    textCellReuseIdentifier = @"MyCustom";
                }
                NSData *shortcutCustomData = [[NSUserDefaults standardUserDefaults]arrayForKey:@"textShortcuts"][fRow];
                HCSShortcut *shortcut = (HCSShortcut *)[NSKeyedUnarchiver unarchiveObjectWithData:shortcutCustomData];
                HCSCustomViewCell *theCustCell = [collectionView dequeueReusableCellWithReuseIdentifier:textCellReuseIdentifier forIndexPath:indexPath];
                theCustCell.titleLabel.text = shortcut.title;
                //no image
                
                if (self.textDeleteActive) {
                    theCustCell.deleteButton.hidden = NO;
                    [theCustCell startJiggling];
                } else {
                    theCustCell.deleteButton.hidden = YES;
                }
                
                
                [theCustCell.deleteButton addTarget:self action:@selector(TextCellDeleteButtonDynamicHandler:event:) forControlEvents:UIControlEventTouchUpInside];
                return theCustCell;
                }
            break;
        default:
            return nil;
            break;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //handled by the storyboard segue
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        switch ([indexPath section]) {
            case 0:
                if (true) {
                    HCSMyHeaderReusableView *theCell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
                    theCell.titleLabel.text = @"Image Shortcuts";
                    if (self.imageDeleteActive)
                        theCell.deleteButton.titleLabel.text = @"Done";
                    else
                        theCell.deleteButton.titleLabel.text = @"Edit";
                    theCell.deleteButtonNumTwo.hidden = YES;
                    theCell.deleteButton.hidden = NO;
                    [theCell.deleteButton addTarget:self action:@selector(ImageHeaderDeleteButtonDynamicHandler) forControlEvents:UIControlEventTouchUpInside];
                    return theCell;
                }
                break;
            case 1:
                if (true) {
                    HCSMyHeaderReusableView *theCell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
                    theCell.titleLabel.text = @"Text Shortcuts";
                    if (self.textDeleteActive)
                        theCell.deleteButtonNumTwo.titleLabel.text = @"Done";
                    else
                        theCell.deleteButtonNumTwo.titleLabel.text = @"Edit";
                    theCell.deleteButtonNumTwo.hidden = NO;
                    theCell.deleteButton.hidden = YES;
                    [theCell.deleteButtonNumTwo addTarget:self action:@selector(TextHeaderDeleteButtonDynamicHandler) forControlEvents:UIControlEventTouchUpInside];
                    return theCell;
                }
                break;
            default:
                return nil;
                break;
        }
    } else
        return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
//for sizing cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //warning hardcoded in, CAREFUL
    if ([indexPath section] == 0) {
        return CGSizeMake(100, 114);
    } else if ([indexPath section] == 1) {
        return CGSizeMake(100, 80);
    } else {
        return CGSizeMake(0, 0);
    }
}


#pragma mark - UICollectionViewDataSource_Draggable
//copy pasta from previous reverted commits

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Prevent item from being moved to index 0
    //    if (toIndexPath.item == 0) {
    //        return NO;
    //    }
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *myArray;
    NSMutableArray *myDestinationArray;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([fromIndexPath section] == 0) {
        //image
        myArray = [[defaults arrayForKey:@"shortcuts"] mutableCopy];
    } else if ([fromIndexPath section] == 1) {
        //text
        myArray = [[defaults arrayForKey:@"textShortcuts"] mutableCopy];
    }
    NSData *myData = [myArray objectAtIndex:fromIndexPath.item];
    
    [myArray removeObjectAtIndex:fromIndexPath.item];
    
    if ([fromIndexPath section] == [toIndexPath section])
        myDestinationArray = myArray;
    else if ([toIndexPath section] == 0)
        myDestinationArray = [[defaults arrayForKey:@"shortcuts"] mutableCopy];
    else if ([toIndexPath section] == 1)
        myDestinationArray = [[defaults arrayForKey:@"textShortcuts"] mutableCopy];
    
    
    [myDestinationArray insertObject:myData atIndex:toIndexPath.item]; //NOTE: Was myShortcut, but if NSUserDefaults should still use myData;
    
    if ([fromIndexPath section] == 0) {
        [defaults setObject:[NSArray arrayWithArray:myArray] forKey:@"shortcuts"];
    } else if ([fromIndexPath section] == 1) {
        [defaults setObject:[NSArray arrayWithArray:myArray] forKey:@"textShortcuts"];
    }
    
    if ([fromIndexPath section] != [toIndexPath section]) {
        if ([toIndexPath section] == 0) {
            [defaults setObject:[NSArray arrayWithArray:myArray] forKey:@"shortcuts"];
        } else if ([toIndexPath section] == 1) {
            [defaults setObject:[NSArray arrayWithArray:myArray] forKey:@"textShortcuts"];
        }
    }
    [defaults synchronize];
    
    //PlayingCard *playingCard = [self.deck objectAtIndex:fromIndexPath.item];
    //[self.deck removeObjectAtIndex:fromIndexPath.item];
    //[self.deck insertObject:playingCard atIndex:toIndexPath.item];
    
    //    NSMutableArray *data1 = [sections objectAtIndex:fromIndexPath.section];
    //  NSMutableArray *data2 = [sections objectAtIndex:toIndexPath.section];
    //NSString *index = [data1 objectAtIndex:fromIndexPath.item];
    
    //[data1 removeObjectAtIndex:fromIndexPath.item];
    //[data2 insertObject:index atIndex:toIndexPath.item];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //sets self.title. rest is handled in myShortCutTextSegueUnwind method in parent VC
    if ([sender isKindOfClass:[HCSShortCutTextViewCell class]]) {
        HCSShortCutTextViewCell *cell = (HCSShortCutTextViewCell *)sender;
        self.title = cell.titleLabel.text;
    } else if ([sender isKindOfClass:[HCSCustomViewCell class]]) {
        HCSCustomViewCell *cell = (HCSCustomViewCell *)sender;
        self.title = cell.titleLabel.text;
    }
}


@end
