//
//  AppDelegate.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationsManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate ()

@property (nonatomic, retain) LocationsManager *locationsManager;

@end

@implementation AppDelegate

@synthesize locationsManager = _locationsManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // The locations manager should start as soon as it can. It will validate if it shouldnt start since the user isnt set up yet, etc.
    
    self.locationsManager = [LocationsManager sharedLocationsManager];
    [self.locationsManager startUpdatingUserStatusForeground];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // The locations manager has a background mode as well. If the location is updated in the background it should update all of the significant times, etc.

    [self.locationsManager startUpdatingUserStatusBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.locationsManager startUpdatingUserStatusForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
