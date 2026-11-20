//
//  AppDelegate.m
//  GeofenceObjCPodsExample
//
//  Created by Yogesh Singh on 09/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

#import "AppDelegate.h"

@import CleverTapSDK;
@import CleverTapGeofence;
// or you can use
//#import <CleverTapGeofence/CleverTapGeofence.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // perform other app launch functions
    
    [CleverTap autoIntegrate];
    
//    CleverTapGeofence.logLevel = CleverTapGeofenceLogLevelDebug;
//    CleverTapGeofence.logLevel = CleverTapGeofenceLogLevelOff;
    
    [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions];
//    [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions distanceFilter:200 timeFilter:1800];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
}

@end
