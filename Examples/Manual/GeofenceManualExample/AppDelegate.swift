//
//  AppDelegate.swift
//  GeofenceManualExample
//
//  Created by Yogesh Singh on 03/09/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

import UIKit
import CleverTapSDK
import CleverTapGeofence

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // other app launch functions
        
        CleverTap.autoIntegrate()
        
        // CleverTapGeofence.logLevel = .debug
        // CleverTapGeofence.logLevel = .off
        
        CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)
        
        // CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions, distanceFilter: 200, timeFilter: 1800)
        
        return true
    }
    
    func someScenarioWhereLocationMonitoringShouldBeOff() {
        
        CleverTapGeofence.monitor.stop()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

