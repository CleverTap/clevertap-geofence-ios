
import Foundation
//import CleverTap
import CoreLocation

// CleverTapGeofence.shared.startMonitoring()
// CleverTapGeofence.shared.stopMonitoring()

final public class CleverTapGeofence: NSObject {
    
    private var locationManager: CLLocationManager?
    private let geofencesNotification = NSNotification.Name("CleverTapGeofencesNotification")
    
    
    public class func shared() -> CleverTapGeofence {
        return CleverTapGeofence()
    }
    
    public func startMonitoring() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringVisits()
        locationManager?.startMonitoringSignificantLocationChanges()
        
        observeForNotification()
    }
    
    public func stopMonitoring() {
        
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
    
    
    private func observeForNotification() {
        NotificationCenter.default.addObserver(forName: geofencesNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { (notification) in
                                             
                                                if let userInfo = notification.userInfo {
                                                    
                                                    if let geofence = userInfo["geofence"] as? [AnyHashable: Any] {
                                                     
                                                        let latitude = geofence["lat"] as! CLLocationDegrees
                                                        let longitude = geofence["lng"] as! CLLocationDegrees
                                                        let radius = geofence["rad"] as! CLLocationDistance
                                                        let identifier = geofence["id"] as! String
                                                        
                                                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                                        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
                                                        
                                                        self.locationManager?.startMonitoring(for: region)
                                                    }
                                                }
                                            }
    }
}



// MARK: - Location Manager Delegate

extension CleverTapGeofence: CLLocationManagerDelegate {
    
    // MARK: - Standard Location
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
        
        switch status {
        case .authorizedAlways:
            print("user allow app to get location data when app is active or in background")
        case .authorizedWhenInUse:
            print("user allow app to get location data only when app is active")
        case .denied:
            print("user tap 'disallow' on the permission dialog, cant get location data")
        case .restricted:
            print("parental control setting disallow location data")
        case .notDetermined:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
        @unknown default: break
            //fatalError()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // MAIN SDK SET LOCATION API
        
//        CleverTap.sharedInstance.setLocation()
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // MAIN SDK SET ERROR CODE
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
    }
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Log state. Helpful while debugging
    }
    
    
    // MARK: - Region Monitoring
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // Log state. Helpful while debugging
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        // if let region = region as? CLCircularRegion {
            //let identifier = region.identifier
            // Main SDK ENTER API
        // }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // if let region = region as? CLCircularRegion {
            // let identifier = region.identifier
            // Main SDK EXIT API
        // }
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        // Log state. Helpful while debugging
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        // MAIN SDK SET ERROR CODE
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // Log state. Helpful while debugging
    }
}
