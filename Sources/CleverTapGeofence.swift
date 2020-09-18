
import UIKit
import CoreLocation

/**
 CleverTapGeofence provides Geofencing capabilities to CleverTap iOS SDK.
 
 - Requires: CleverTap iOS SDK version __3.9.0__ or higher
 - Requires: Swift version __5.1__ or higher
 
 # Reference
 [CleverTap Documentation](https://developer.clevertap.com/docs/ios)
 */
public final class CleverTapGeofence: NSObject {
    
    /// Provides a shared singleton instance of `CleverTapGeofence` class.
    /// - Important: Should __always__ be used in conjunction with either `start` or `stop` function.
    @objc public static let monitor = CleverTapGeofence()
    
    ///`CleverTapGeofenceEngine` sets up Geofences & interacts with Core Location APIs.
    /// - Warning: Client apps are not expected to interact with this class.
    private let engine: CleverTapGeofenceEngine
    
    /// Client apps are not expected to initialize an instance of `CleverTapGeofence` via `init` function
    private override init() {
        engine = CleverTapGeofenceEngine()
        CleverTapGeofenceUtils.log("CleverTapGeofence class initialized", type: .debug)
    }
    
    deinit {
        CleverTapGeofenceUtils.log("CleverTapGeofence class deallocated", type: .debug)
    }
    
    
    /**
     Initiates the monitoring of Geofences set on CleverTap Dashboard.
     - Parameter launchOptions: A dictionary indicating the reason the app was launched.
     
     ~~~
     // Swift usage
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
     // other app setup logic
     
     CleverTap.autoIntegrate()
     
     CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)
     
     return true
     }
     
     // Objective-C usage
     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // other app setup logic
     
     [CleverTap autoIntegrate];
     
     [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions];
     
     return YES;
     }
     ~~~
     */
    @objc public func start(didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?) {
        start(didFinishLaunchingWithOptions: launchOptions,
              distanceFilter: CleverTapGeofenceUtils.defaultDistanceFilter,
              timeFilter: CleverTapGeofenceUtils.defaultTimeFilter)
    }
    
    
    /**
     Initiates the monitoring of Geofences set on CleverTap Dashboard.
     - Parameter launchOptions: A dictionary indicating the reason the app was launched.
     - Parameter distanceFilter: Specifies the minimum update distance in meters used by Geofence location manager.
     Client will not be notified of movements of less than the stated value, unless the accuracy has improved.
     By default, 200 meters is used.
     - Parameter timeFilter: Specifies the minimum time in seconds after which location should be updated.
     Location updates will not be triggered within less than the stated `timeFilter` value.
     By default, 1800 seconds is used.
     
     ~~~
     // Swift usage
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
     // other app setup logic
     
     CleverTap.autoIntegrate()
     
     CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions, distanceFilter: 200, timeFilter: 1800)
     
     return true
     }
     
     // Objective-C usage
     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // other app setup logic
     
     [CleverTap autoIntegrate];
     
     [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions distanceFilter:200 timeFilter:1800];
     
     return YES;
     }
     ~~~
     */
    @objc public func start(didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?,
                            distanceFilter: CLLocationDistance = 200,
                            timeFilter: TimeInterval = 1800) {
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, distanceFilter, timeFilter)
        engine.start(distanceFilter, timeFilter)
        
        if let options = launchOptions {
            if options[.location] != nil {
                CleverTapGeofenceUtils.log("The app was launched to handle an incoming location event.", type: .debug)
            } else {
                CleverTapGeofenceUtils.log("launchOptions: %@", type: .debug, options.description)
            }
        } else {
            CleverTapGeofenceUtils.log("didFinishLaunchingWithOptions launchOptions is empty", type: .debug)
        }
    }
    
    /**
     Stops the monitoring of registered Geofences.
     Also, disables further updates of user's location.
     
     ~~~
     // Swift usage
     func someScenarioWhereLocationMonitoringShouldBeOff() {
     CleverTapGeofence.monitor.stop()
     }
     
     // Objective-C usage
     - (void)someScenarioWhereLocationMonitoringShouldBeOff {
     [[CleverTapGeofence monitor] stop];
     }
     ~~~
     */
    @objc public func stop() {
        CleverTapGeofenceUtils.log(#function, type: .debug)
        engine.stop()
    }
}


/// An enum to be used for setting `logLevel` for `CleverTapGeofence`. By default, `.error` level is set.
@objc public enum CleverTapGeofenceLogLevel: Int {
    /// Only errors are logged to console. `.error` is the default
    case error
    /// Logs additional diagnostic info along with `.error` logs for debugging purposes.
    case debug
    /// Stops all logs from `CleverTapGeofence`
    case off
}


@objc extension CleverTapGeofence {
    /**
     Specify a `logLevel` for `CleverTapGeofence`. By default, `.error` level is set.
     ~~~
     // Swift usage
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
     // other app setup logic
     
     CleverTap.autoIntegrate()
     
     CleverTapGeofence.logLevel = .debug
     
     CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)
     
     return true
     }
     
     // Objective-C usage
     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     // other app setup logic
     
     [CleverTap autoIntegrate];
     
     CleverTapGeofence.logLevel = CleverTapGeofenceLogLevelDebug;
     
     [[CleverTapGeofence monitor] startWithDidFinishLaunchingWithOptions:launchOptions distanceFilter:100];
     
     return YES;
     }
     ~~~
     */
    @objc public static var logLevel: CleverTapGeofenceLogLevel = .error {
        didSet {
            CleverTapGeofenceUtils.log("Log Level updated", type: .debug)
        }
    }    
}
