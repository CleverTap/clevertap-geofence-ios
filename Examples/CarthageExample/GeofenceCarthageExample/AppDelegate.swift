//
//  AppDelegate.swift
//  GeofenceCarthageExample
//
//  Created by Yogesh Singh on 09/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

import UIKit
import CleverTapSDK
import CleverTapGeofence

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // other app setup logic
        
        
        CleverTap.autoIntegrate()
        
//        CleverTapGeofence.logLevel = .debug
//        CleverTapGeofence.logLevel = .off
        
        CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)
        
//        CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions, distanceFilter: 200, timeFilter: 1800)
        
        return true
    }
    
    func someScenarioWhereLocationMonitoringShouldBeOff() {
        CleverTapGeofence.monitor.stop()
    }
}

