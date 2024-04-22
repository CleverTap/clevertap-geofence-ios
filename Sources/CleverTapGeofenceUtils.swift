
import os.log
import Foundation
import CleverTapSDK

internal struct CleverTapGeofenceUtils {
    
    // MARK: - Static Constants
    
    internal static let pluginVersion = "10006"
    internal static let geofenceErrorCode = 515
    internal static let defaultDistanceFilter: CLLocationDistance = 200
    internal static let defaultTimeFilter: TimeInterval = 1800
    internal static let geofencesNotification = NSNotification.Name("CleverTapGeofencesDidUpdateNotification")
    internal static let geofenceEntered = NSNotification.Name("CleverTapGeofenceEntered")
    internal static let geofenceExited = NSNotification.Name("CleverTapGeofenceExited")
    internal static let geofencesKey = "CleverTapGeofencesData"
    internal static let regionStateKey = "regionState"
    internal static let timeStampKey = "timeStamp"
    internal static let formatter = ISO8601DateFormatter()
    private static let logger = OSLog(subsystem: "com.clevertap.CleverTapGeofence", category: "CleverTapGeofence")
    
    
    // MARK: - Util Functions
    
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
    
    
    internal static func recordError(_ error: Error? = nil,
                                     message: ErrorMessages) {
        
        CleverTapGeofenceUtils.log("%@", type: .error, message.rawValue)
        
        var generatedError: Error
        
        if let error = error as NSError? {
            
            let description = message.rawValue + " | " + error.domain + " | " + "\(error.code)" + " | " + error.localizedDescription
            
            generatedError = NSError(domain: "CleverTapGeofence",
                                     code: geofenceErrorCode,
                                     userInfo: [NSLocalizedDescriptionKey: description])
        } else {
            generatedError = NSError(domain: "CleverTapGeofence",
                                     code: geofenceErrorCode,
                                     userInfo: [NSLocalizedDescriptionKey: message.rawValue])
        }
        
        if let instance = CleverTap.sharedInstance() {
            instance.didFailToRegisterForGeofencesWithError(generatedError)
        } else {
            CleverTapGeofenceUtils.log("%@", type: .error, ErrorMessages.uninitialized.rawValue)
        }
    }
    
    
    internal static func write(_ geofences: [[AnyHashable: Any]]) {
        
        log("%@", type: .debug, #function)
        
        guard let filePath = getFilePath() else { return }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: geofences)
        do {
            try data.write(to: filePath)
            log("Successfully wrote geofences to disk: %@", type: .debug, geofences)
        } catch {
            recordError(message: .diskWrite)
        }
    }
    
    internal static func read(remove: Bool = true) -> [[AnyHashable: Any]]? {
        
        log("%@", type: .debug, #function, remove)
        
        guard let filePath = getFilePath() else { return nil }
        
        do {
            let data = try Data(contentsOf: filePath)
            
            if let geofences = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[AnyHashable: Any]] {
                
                if remove {
                    removeFile(at: filePath)
                }
                log("Geofences list as read from disk: %@", type: .debug, geofences)
                return geofences
            } else {
                recordError(message: .diskRead)
            }
        } catch {
            recordError(error, message: .diskRead)
        }
        
        return nil
    }
    
    private static func getFilePath() -> URL? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return path.appendingPathComponent(geofencesKey)
        } else {
            recordError(message: .diskFilePath)
            return nil
        }
    }
    
    private static func removeFile(at path: URL) {
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            recordError(error, message: .diskRemove)
        }
    }
}


// MARK: -

internal enum ErrorMessages: String {
    case monitoringUnsupported      = "Device does not supports Location Region Monitoring."
    case significantUnsupported     = "Device does not supports Significant Location Change Monitoring."
    case uninitialized              = "CleverTap SDK is not initialized."
    case unexpectedData             = "Unexpected Geofences Data format received."
    case engineNil                  = "Unexpected scenario where CleverTapGeofenceEngine is nil."
    case locationManagerNil         = "Location Manager instance is nil."
    case permissionOnlyWhileUsing   = "User allowed app to get location data only when app is active."
    case permissionDenied           = "User tapped 'disallow' on the permission dialog, cannot get location data."
    case permissionRestricted       = "Access to location data is restricted."
    case permissionUndetermined     = "Location permission dialog not shown yet, user has not tapped allow/disallow."
    case permissionUnknownState     = "Unkown location permission status detected."
    case permissionReduced          = "Only Reduced accuracy permission granted by user."
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


// MARK: -

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
