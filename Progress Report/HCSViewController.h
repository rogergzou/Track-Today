//
//  HCSViewController.h
//  Progress Report
//
//  Created by Roger on 6/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

//autoset start after stop? so always is running? cool feature add to sttings plz
//Track Today is here to answer the quintessential question: What did I do today? This app lets you track that. Use a timer to record the start and end of an activity, and see it added to the calendar with just one tap. Track Today features simple, customizable event labeling to calendar events that make tracking your day a breeze.
//Track Today answers the quintessential question: What did I do today? Just tap to start or end an activity, with automatic placement onto the calendar for future reference. Track Today features simple, customizable event labeling that makes tracking your day a breeze.

//Track Today answers the quintessential question: What did I do today? Track activities in real-time, with automatic placement onto the calendar for future reference. Track Today features simple, customizable event labeling that makes tracking your day a breeze.
/*
//Track Today answers the quintessential question: What did I do today? Track activities in real-time, with automatic placement onto the calendar for future reference. Track Today features simple, customizable event labeling that makes tracking your day a breeze.
 
 Features include:
 
 -Timer for real-time event tracking
 -Automatic iCal event scheduling upon ending event
 -Customizable quickfills for event descriptions
 -Works even in background
 
 Questions/Suggestions can be forwarded to the.roger.zou@gmail.com
 Quickfill icons by Nick Frost at ballicons.net
*/
/*
 Track Today answers the quintessential question: What did I do today? Track activities in real-time, with automatic placement onto the calendar for future reference. Track Today features simple, customizable event labeling that makes tracking your day a breeze.
 
 Main Features include:
 
 -Timer for real-time event tracking
 -Automatic iCal event scheduling upon ending event
 -Customizable quickfills for event descriptions
 
 Questions/Suggestions can be forwarded to the.roger.zou@gmail.com
 Quickfill icons by Nick Frost at ballicons.net
 */
//have advanced setting option that lets you add time. Two buttons to add minutes/seconds to timer. Would also move starting date.
//have in advanced setting ability to set reminders to turn on/off the timing.

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
