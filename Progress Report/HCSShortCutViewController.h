//
//  HCSShortCutViewController.h
//  Progress Report
//
//  Created by Roger on 6/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionView+Draggable.h"

@interface HCSShortCutViewController : UICollectionViewController <UICollectionViewDataSource_Draggable, UICollectionViewDelegate>

@property (nonatomic, strong) NSString *title;

- (IBAction)myCreateShortcutUnwindSegueCallback:(UIStoryboardSegue *)segue;

@end
