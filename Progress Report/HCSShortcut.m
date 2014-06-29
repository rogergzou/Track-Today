//
//  HCSShortcut.m
//  Progress Report
//
//  Created by Roger on 6/26/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSShortcut.h"

@implementation HCSShortcut

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
    }
    return self;
}

/* //no lazy instantiation so can make nil comparison to tell if no default iamge
 - (UIImage *)image
{
    if (!_image) _image = [UIImage imageNamed:@"Default_Shortcut_Image"];
    return _image;
}
 */


//needed to make nsdata for property list storage via nsuserdefaults
- (void)encodeWithCoder:(NSCoder *)encoder
{
    //encode everything
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.image forKey:@"image"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        //decode everything
        self.title = [decoder decodeObjectForKey:@"title"];
        self.image = [decoder decodeObjectForKey:@"image"];
    }
    return self;
}


@end
