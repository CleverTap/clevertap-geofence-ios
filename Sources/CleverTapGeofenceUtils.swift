//
//  CleverTapGeofenceUtils.swift
//  CleverTapGeofence
//
//  Created by Yogesh Singh on 22/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

import Foundation
import os.log

internal struct CleverTapGeofenceUtils {
    
    internal static let pluginVersion = "100000"
    
    
    internal static let geofencesNotification = NSNotification.Name("CleverTapGeofencesDidUpdateNotification")
    
    
    private static let logger = OSLog(subsystem: "com.clevertap.CleverTapGeofence", category: "CleverTapGeofence")
    
    
    internal static func log(_ message: StaticString, type: CleverTapGeofenceLogLevel = CleverTapGeofenceLogLevel.Error) {
        
        switch CleverTapGeofence.monitor.logLevel {
        case .Error:
            os_log(message, log: logger, type: .error)
        case .Debug:
            os_log(message, log: logger, type: .debug)
        case .Off:
            break
        default:
            break
        }
    }
}
