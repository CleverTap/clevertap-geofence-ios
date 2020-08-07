//
//  AppDelegate.m
//  GeofenceObjCPodsExample
//
//  Created by Yogesh Singh on 09/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

#import "AppDelegate.h"
@import CleverTapSDK;
#import <CleverTapGeofence/CleverTapGeofence-Swift.h>
// or you can use #import <CleverTapGeofence-Swift.h>
// or you can use @import CleverTapGeofence;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // other app setup logic
    
    [CleverTap autoIntegrate];
    
    CleverTapGeofence.logLevel = CleverTapGeofenceLogLevelDebug;
    
    [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)someScenarioWhereLocationMonitoringShouldBeOff {
    
    [[CleverTapGeofence monitor] stop]; // or you can use CleverTapGeofence.monitor.stop;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
