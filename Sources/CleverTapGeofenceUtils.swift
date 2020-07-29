//
//  CleverTapGeofenceUtils.swift
//  CleverTapGeofence
//
//  Created by Yogesh Singh on 22/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

import os.log
import Foundation
import CleverTapSDK

internal struct CleverTapGeofenceUtils {
    
    // MARK: -
    
    internal static let pluginVersion = "100000"
    
    internal static let geofencesNotification = NSNotification.Name("CleverTapGeofencesDidUpdateNotification")
    
    internal static let geofencesKey = "CleverTapGeofencesData"
    
    internal static let regionStateKey = "regionState"
    
    private static let logger = OSLog(subsystem: "com.clevertap.CleverTapGeofence", category: "CleverTapGeofence")
    
    
    // MARK: -
    
    internal static func log(_ message: StaticString,
                             type: CleverTapGeofenceLogLevel,
                             _ args: CVarArg...) {
        
        switch CleverTapGeofence.logLevel {
        case .error:
            if type == .error {
                os_log(message, log: logger, type: .error, args)
            }
            
        case .debug:
            if type == .error || type == .debug {
                os_log(message, log: logger, type: .debug, args)
            }
            
        case .off:
            break
            
        default:
            break
        }
    }
    
    
    internal static func recordGeofencesError(code: Int = 0,
                                              _ error: Error? = nil,
                                              message: ErrorMessages) {
        
        CleverTapGeofenceUtils.log("%@", type: .error, message.rawValue)
        
        var generatedError: Error
        
        if let error = error {
            generatedError = error
        } else {
            generatedError = NSError(domain: "CleverTapGeofence",
                                     code: code,
                                     userInfo: [NSLocalizedDescriptionKey: message.rawValue])
        }
        
        if let instance = CleverTap.sharedInstance() {
            instance.didFailToRegisterForGeofencesWithError(generatedError)
        } else {
            CleverTapGeofenceUtils.log("%@", type: .error, ErrorMessages.uninitialized.rawValue)
        }
    }
    
    
    internal static func write(_ geofences: [[AnyHashable: Any]]) {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = path.appendingPathComponent(geofencesKey)
            let filePathStr = String(describing: filePath)
            if  NSKeyedArchiver.archiveRootObject(geofences, toFile: filePathStr) == false {
                recordGeofencesError(message: .diskWrite)
            }
        } else {
            recordGeofencesError(message: .diskFilePath)
        }
    }
    
    internal static func read(remove: Bool = true) -> [[AnyHashable: Any]]? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = path.appendingPathComponent(geofencesKey)
            let filePathStr = String(describing: filePath)
            if let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePathStr) as? [[AnyHashable: Any]] {
                
                if remove {
                    if FileManager.default.fileExists(atPath: filePathStr) {
                        do {
                            try FileManager.default.removeItem(atPath: filePathStr)
                        } catch {
                            recordGeofencesError(message: .diskRemove)
                        }
                    } else {
                        log("%@", type: .debug, "File does not exists at path: ", filePathStr)
                    }
                }
                
                return data
            } else {
                recordGeofencesError(message: .diskRead)
            }
        } else {
            recordGeofencesError(message: .diskFilePath)
        }
        
        return nil
    }
}


// MARK: -

internal enum ErrorMessages: String {
    case monitoringUnsupported      = "Device does not supports Location Region Monitoring."
    case uninitialized              = "CleverTap SDK is not initialized."
    case unexpectedData             = "Unexpected Geofences Data format received."
    case engineNil                  = "Unexpected scenario where CleverTapGeofenceEngine is nil."
    case locationManagerNil         = "Location Manager instance is nil."
    case permissionOnlyWhileUsing   = "User allowed app to get location data only when app is active."
    case permissionDenied           = "User tapped 'disallow' on the permission dialog, cannot get location data."
    case permissionRestricted       = "Access to location data is restricted."
    case permissionUndetermined     = "The location permission dialog has not been shown yet, user hasn't tap allow/disallow."
    case permissionUnknownState     = "Unkown location permission status detected."
    case emptyLocation              = "Locations array updated by delegate is empty."
    case currentLocation            = "Error in getting user's current location."
    case deferredUpdates            = "Finished deferred location updates."
    case cannotMonitor              = "Could not start monitoring for region."
    case undeterminedState          = "Could not determine user's current region state."
    case diskFilePath               = "Could not find Documents directory file path."
    case diskWrite                  = "Could not save geofences data to disk."
    case diskRead                   = "Could not read geofences data from disk."
    case diskRemove                 = "Could not remove stale geofences data from disk."
}
