
import Foundation

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
    
    
    private let engine: CleverTapGeofenceEngine
    
    
    /// Client apps are not expected to initialize an instance of `CleverTapGeofence` via `init` function
    private override init() {
        engine = CleverTapGeofenceEngine()
        print("CleverTapGeofenceEngine initialzed")
    }
    
    deinit {
        print("CleverTapGeofenceEngine deallocated")
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
    @objc public func start(didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        
        dump(launchOptions)
        
        engine.start()
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
        engine.stop()
    }
}
