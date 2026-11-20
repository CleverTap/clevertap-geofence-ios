
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
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
    
}


