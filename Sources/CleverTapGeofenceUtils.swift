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
    
    internal static let geofencesNotification = NSNotification.Name("CleverTapGeofencesNotification")
    
    internal static let logger = OSLog(subsystem: "com.clevertap.CleverTapGeofence", category: "CleverTapGeofence")
}
