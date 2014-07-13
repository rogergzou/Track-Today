//
//  HCSShortCutTextViewCell.m
//  Progress Report
//
//  Created by Roger on 6/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSShortCutTextViewCell.h"

@implementation HCSShortCutTextViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startJiggling
{
    //code courtesy of http://stackoverflow.com/questions/14025600/uicollectionviewcell-shake
#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 0.5
#define kAnimationTranslateX 1.0
#define kAnimationTranslateY 1.0
    
    //startJiggling
    
    int count = 1;
    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? +1 : -1 ) ));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? -1 : +1 ) ));
    CGAffineTransform moveTransform = CGAffineTransformTranslate(rightWobble, -kAnimationTranslateX, -kAnimationTranslateY);
    CGAffineTransform conCatTransform = CGAffineTransformConcat(rightWobble, moveTransform);
    
    self.transform = leftWobble;  // starting point
    
    [UIView animateWithDuration:0.1
                          delay:(count * 0.08)
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{ self.transform = conCatTransform; }
                     completion:nil];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.titleLabel.alpha = highlighted ? 0.75f : 1.0f;
    
    self.imageView.alpha = highlighted ? 0.75f : 1.0f;
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
