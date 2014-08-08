//
//  HCSShortcut.h
//  Track Today
//
//  Created by Roger on 6/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCSShortcut : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithTitle: (NSString *)title image:(UIImage *)image;// selectedImage:(UIImage *)selectedImage;

@end
