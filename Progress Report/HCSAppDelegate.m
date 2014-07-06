//
//  HCSAppDelegate.m
//  Progress Report
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
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIViewController *rootVC = self.window.rootViewController; //should be HCSViewController. Check anyway.
    if ([rootVC isKindOfClass:[HCSViewController class]]) {
        HCSViewController *hcsVC = (HCSViewController *)rootVC;
        if (!hcsVC.isPaused && !hcsVC.isStart) {
            [hcsVC endTimer];
            self.exitDate = [NSDate date];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
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
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
