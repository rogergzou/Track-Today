//
//  HCSCustomViewCell.m
//  Progress Report
//
//  Created by Roger on 6/29/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSCustomViewCell.h"

@implementation HCSCustomViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - LXLayout
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
//    self.imageView.alpha = highlighted ? 0.75f : 1.0f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
