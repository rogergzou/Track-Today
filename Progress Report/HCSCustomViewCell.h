//
//  HCSCustomViewCell.h
//  Track Today
//
//  Created by Roger on 6/29/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCSCustomViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (void)startJiggling;

@end
