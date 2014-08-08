//
//  HCSAppDelegate.m
//  Track Today
//
//  Created by Roger on 6/25/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "HCSAppDelegate.h"
#import "HCSViewController.h"

@interface HCSAppDelegate()

@property (nonatomic, strong) NSDate *exitDate;

@end

@implementation HCSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// Override point for customization after application launch.
    
                    //NOTE also done in viewDidLoad so not needed
    /*
    UIViewController *rootVC = self.window.rootViewController; //should be HCSViewController. Check anyway.
    if ([rootVC isKindOfClass:[HCSViewController class]]) {
        HCSViewController *hcsVC = (HCSViewController *)rootVC;
        UILocalNotification *localnotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localnotif) {
            //application.applicationIconBadgeNumber = localnotif.applicationIconBadgeNumber-1; //No idea why to do this, see https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1
            if ([localnotif.userInfo[@"typeKey"] isEqualToString:@"reminder"] && ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] == 0)) {
                //hide if no more schedule notifs (assuming reminders are the only notifs...this may break lol WARNING
                [hcsVC hideReminderLabel];
                

            }
        }
    }
    */
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"finish launch");
    if (!self.decoded) {
        //get it from NSUserdefaults
        NSLog(@"s1");
        NSDictionary *savDict = [defaults dictionaryForKey:@"restorationDictionary"];
        if (savDict) {
            NSLog(@"s2");
            UIViewController *rootVC = self.window.rootViewController; //should be HCSViewController. Check anyway.
            if ([rootVC isKindOfClass:[HCSViewController class]]) {
                HCSViewController *hcsVC = (HCSViewController *)rootVC;
                NSLog(@"s3");
                [hcsVC jankyRestoreStateWithDict:savDict];
            }
        }
        
        self.decoded = YES;
    }
    //reset just in case next time
    [defaults setObject:nil forKey:@"restorationDictionary"];
    [defaults synchronize];
    */
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    //NSLog(@"resign active");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //NSLog(@"background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIViewController *rootVC = self.window.rootViewController; //should be HCSViewController. Check anyway.
    if ([rootVC isKindOfClass:[HCSViewController class]]) {
        HCSViewController *hcsVC = (HCSViewController *)rootVC;
        if (!hcsVC.isPaused && !hcsVC.isStart) {
            [hcsVC endTimer];
            self.exitDate = [NSDate date];
        }
        
        //set restoration info into nsuserdefaults
        //[hcsVC jankySaveState];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //NSLog(@"enter foreground");

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    UIViewController *rootVC = self.window.rootViewController; //should be HCSViewController. Modals aren't rootVC's. Check anyway
    if ([rootVC isKindOfClass:[HCSViewController class]]) {
        HCSViewController *hcsVC = (HCSViewController *)rootVC;
        if (!hcsVC.isPaused && !hcsVC.isStart) {
            hcsVC.seconds -= floor([self.exitDate timeIntervalSinceNow]); //-= b/c timeIntervalSince returns a neg #
            //developer's note: screw timeIntervalSinceReferenceDate and autocomplete. Didn't realize, meant timeIntervalSinceNow
            self.exitDate = nil; //resets for next time just in case
            [hcsVC beginTimer];
        }
        if ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] == 0) {
            [hcsVC hideReminderLabel];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //NSLog(@"active");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //NSLog(@"terminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIViewController *rootVC = self.window.rootViewController; //should be HCSViewController. Check anyway.
    if ([rootVC isKindOfClass:[HCSViewController class]]) {
        HCSViewController *hcsVC = (HCSViewController *)rootVC;
        //application.applicationIconBadgeNumber = localnotif.applicationIconBadgeNumber-1; //No idea why to do this, see https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1
        if ([notification.userInfo[@"typeKey"] isEqualToString:@"reminder"]) {
            [hcsVC hideReminderLabel];
            if  (application.applicationState == UIApplicationStateActive) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Reminder!" message:[NSString stringWithFormat:@"This is your %@ reminder.", notification.userInfo[@"timeStringKey"]] delegate:hcsVC cancelButtonTitle:@"OK" otherButtonTitles: nil];
                alertView.tag = 123456; //shouldn't do anything basically and shouldn't be recognized
                [alertView show];
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}
/*
- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Reminder!" message:[NSString stringWithFormat:@"This is your decoded."] delegate:application cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //alertView.tag = 123456; //shouldn't do anything basically and shouldn't be recognized
    [alertView show];
    self.decoded = YES;
    NSLog(@"did decoded");
}
*/
@end
