//
//  HCSViewController.h
//  Progress Report
//
//  Created by Roger on 6/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

//autoset start after stop? so always is running? cool feature add to sttings plz
//Track Today is here to answer the quintessential question: What did I do today? This app lets you track that. Use a timer to record the start and end of an activity, and see it added to the calendar with just one tap. Track Today features simple, customizable event labeling to calendar events that make tracking your day a breeze.
//have advanced setting option that lets you add time. Two buttons to add minutes/seconds to timer. Would also move starting date.

#import <UIKit/UIKit.h>

@interface HCSViewController : UIViewController

//for appdelegate
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL isStart;
@property (nonatomic) int seconds;


- (IBAction)myShortcutTextUnwindSegueCallback:(UIStoryboardSegue *)segue;
- (void)endTimer;
- (void)beginTimer;

@end
