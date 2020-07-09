
import os.log
import Foundation
import CoreLocation
import CleverTapSDK

final public class CleverTapGeofence: NSObject {
    
    @objc public static let monitor = CleverTapGeofence()
    
    private var locationManager: CLLocationManager?
    private let geofencesNotification = NSNotification.Name("CleverTapGeofencesNotification")
    private let logger = OSLog(subsystem: "com.clevertap.CleverTapGeofence", category: "CleverTapGeofence")
    
    private override init() {
        os_log(#function, log: logger)
        locationManager = CLLocationManager()
    }
    
    @objc public func start() {
        
        os_log(#function, log: logger)
        
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringVisits()
        locationManager?.startMonitoringSignificantLocationChanges()
        
        observeNotification()
    }
    
    @objc public func stop() {
        
        os_log(#function, log: logger)
        
        NotificationCenter.default.removeObserver(self)
        
        if let regions = locationManager?.monitoredRegions {
            for region in regions {
                locationManager?.stopMonitoring(for: region)
            }
        }
        
        locationManager?.stopMonitoringVisits()
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    
    private func observeNotification() {
        NotificationCenter.default.addObserver(forName: geofencesNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { (notification) in
                                                
                                                os_log(#function, log: self.logger)
                                             
                                                if let userInfo = notification.userInfo {
                                                    
                                                    if let geofence = userInfo["geofence"] as? [AnyHashable: Any] {
                                                     
                                                        let latitude = geofence["lat"] as! CLLocationDegrees
                                                        let longitude = geofence["lng"] as! CLLocationDegrees
                                                        let radius = geofence["rad"] as! CLLocationDistance
                                                        let identifier = geofence["id"] as! String
                                                        
                                                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                                        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
                                                        
                                                        self.locationManager?.startMonitoring(for: region)
                                                        
                                                        os_log("Will start monitoring for region: ", log: self.logger, region)
                                                    }
                                                }
                                            }
    }
}



// MARK: - Location Manager Delegate

extension CleverTapGeofence: CLLocationManagerDelegate {
    
    // MARK: - Standard Location
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log(#function, log: logger)
        
        switch status {
        case .authorizedAlways:
            os_log("User allow app to get location data when app is active or in background", log: logger)
        case .authorizedWhenInUse:
            os_log("user allow app to get location data only when app is active", log: logger)
        case .denied:
            os_log("user tap 'disallow' on the permission dialog, cant get location data", log: logger)
        case .restricted:
            os_log("parental control setting disallow location data", log: logger)
        case .notDetermined:
            os_log("the location permission dialog haven't shown before, user haven't tap allow/disallow", log: logger)
        @unknown default: break
            //fatalError()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // MAIN SDK SET LOCATION API
        
//        CleverTap.sharedInstance()?.setLocation(<#T##location: CLLocationCoordinate2D##CLLocationCoordinate2D#>)
        
        os_log(#function, log: logger)
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // MAIN SDK SET ERROR CODE
        os_log(#function, log: logger)
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
    }
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
    }
    
    
    // MARK: - Region Monitoring
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        os_log(#function, log: logger)
        
        // if let region = region as? CLCircularRegion {
            //let identifier = region.identifier
            // Main SDK ENTER API
        // }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        os_log(#function, log: logger)
        
        // if let region = region as? CLCircularRegion {
            // let identifier = region.identifier
            // Main SDK EXIT API
        // }
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        os_log(#function, log: logger)
        // Log state. Helpful while debugging
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        os_log(#function, log: logger)
        // MAIN SDK SET ERROR CODE
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        os_log(#function, log: logger)
        // Log state. Helpful while debugging
    }
}
