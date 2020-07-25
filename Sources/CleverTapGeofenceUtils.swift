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
    
    
    internal static func log(_ message: StaticString,
                             type: CleverTapGeofenceLogLevel = .error,
                             _ args: CVarArg...) {
        
        print("CleverTapGeofence.logLevel: \(CleverTapGeofence.logLevel.rawValue)")
        
        switch CleverTapGeofence.logLevel {
        case .error:
            os_log(message, log: logger, type: .error, args.count > 0 ? args : "")
            
        case .debug:
            os_log(message, log: logger, type: .debug, args.count > 0 ? args : "")
            
        case .off:
            break
            
        default:
            break
        }
    }
    
    
    internal static func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}


internal enum ErrorMessages: String {
    case monitoringUnsupported = "Device does not supports Location Region Monitoring."
    case uninitialized = "CleverTap SDK is not initialized."
    case unexpectedData = "Unexpected Geofences Data format received."
    case engineNil = "Unexpected scenario where CleverTapGeofenceEngine is nil."
    case locationManagerNil = "Location Manager instance is nil."
    case permissionOnlyWhileUsing = "User allowed app to get location data only when app is active."
    case permissionDenied = "User tapped 'disallow' on the permission dialog, cannot get location data."
    case permissionRestricted = "Access to location data is restricted."
    case permissionUndetermined = "The location permission dialog has not been shown yet, user hasn't tap allow/disallow."
    case permissionUnknownState = "Unkown location permission  status detected."
    case emptyLocation = "Locations array updated by delegate is empty."
    case currentLocation = "Error in getting user's current location."
    case deferredUpdates = "Finished deferred location updates."
    case cannotMonitor = "Could not start monitoring for region."
    case undeterminedState = "Could not determine user's current region state"
}
