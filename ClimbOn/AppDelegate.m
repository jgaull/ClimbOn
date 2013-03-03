//
//  AppDelegate.m
//  ClimbOn
//
//  Created by Jonathan Gaull on 1/13/13.
//  Copyright (c) 2013 OneHeadedLlama. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //PROD DATABASE
    //[Parse setApplicationId:@"gKI8pAAG7fOo1xe96xVijup7etRDnejCrVJ5ds4P" clientKey:@"HL7bIFC9Xk2fgY9Cr73beFwQaILOEc5Pw2Bs6xge"];
    
    //DEV DATABASE
    [Parse setApplicationId:@"5fIMJLoPq55Wc902Z1etXgb0Ic9Za53yY4cfolad" clientKey:@"mBY4WJ5LVCPNjrE4rNZUWyDlSc54SYs7HfwGgpfj"];
    
    
    [PFFacebookUtils initializeWithApplicationId:@"400656610003830"];
    
    [self performSelector:@selector(displayLogin) withObject:nil afterDelay:0.01];
    
    [PFImageView class];
    
    return YES;
}

- (void)displayLogin {
    if (![PFUser currentUser]) {
        [self.window.rootViewController performSegueWithIdentifier:@"firstLoginFlow" sender:self];
    }
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

@end
