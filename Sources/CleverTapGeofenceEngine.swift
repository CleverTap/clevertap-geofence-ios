
import os.log
import Foundation
import CoreLocation
import CleverTapSDK


/// `CleverTapGeofenceEngine` runs all the Geofence setup & Core Location interactions.
/// - Warning: Client apps are __NOT__ expected to interact with this class.
internal final class CleverTapGeofenceEngine: NSObject {
    
    private var locationManager: CLLocationManager?
    
    
    // MARK: - Lifecycle
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal override init() {
        os_log(#function, log: CleverTapGeofenceUtils.logger)
    }
    
    deinit {
        os_log(#function, log: CleverTapGeofenceUtils.logger)
    }
    
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func start() {
        
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        
        guard CleverTap.sharedInstance() != nil,
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
            else {
                
                if CleverTap.sharedInstance() == nil {
                    recordGeofencesError(type: .fault, description: "CleverTap SDK is not initialized")
                } else {
                    recordGeofencesError(type: .fault, description: "Device does not supports Location Region Monitoring")
                }
                
                return
        }
        
        if locationManager == nil {
            locationManager = CLLocationManager()
        } else {
            os_log("%@ Will utilize existing location manager instance", log: CleverTapGeofenceUtils.logger, #function)
        }
        
        locationManager?.delegate = self
        
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringVisits()
        locationManager?.startMonitoringSignificantLocationChanges()
//        locationManager?.distanceFilter
        
        observeNotification()
    }
    
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func stop() {
        
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        
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
    
    
    // MARK: - Setup Geofences
    
    private func observeNotification() {
        NotificationCenter.default.addObserver(forName: CleverTapGeofenceUtils.geofencesNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { [weak self] (notification) in
                                                
                                                os_log("CleverTapGeofencesNotification was observed", log: CleverTapGeofenceUtils.logger)
                                                
                                                if let strongSelf = self {
                                                    
                                                    if let userInfo = notification.userInfo {
                                                        
                                                        if let geofences = userInfo["geofences"] as? [[AnyHashable: Any]] {
                                                            strongSelf.startMonitoring(geofences)
                                                        } else {
                                                            strongSelf.recordGeofencesError(description: "Unexpected geofences data format received")
                                                        }
                                                    } else {
                                                        strongSelf.recordGeofencesError(description: "Could not extract userInfo from notification")
                                                    }
                                                } else {
                                                    
                                                    let description: StaticString = "Unexpected scenario where CleverTapGeofenceEngine is nil"
                                                    
                                                    os_log(description, log: CleverTapGeofenceUtils.logger, type: .error)
                                                    
                                                    let error = NSError(domain: "CleverTapGeofence",
                                                                        code: 0,
                                                                        userInfo: [NSLocalizedDescriptionKey: description])
                                                    
                                                    if let instance = CleverTap.sharedInstance() {
                                                        instance.didFailToRegisterForGeofencesWithError(error)
                                                    } else {
                                                        os_log("CleverTap SDK is not initialized", log: CleverTapGeofenceUtils.logger, type: .fault)
                                                    }
                                                }
        }
    }
    
    private func startMonitoring(_ geofences: [[AnyHashable: Any]]) {
        
        for geofence in geofences {
            
            guard let latitude = geofence["lat"] as? CLLocationDegrees,
                let longitude = geofence["lng"] as? CLLocationDegrees,
                let radius = geofence["r"] as? CLLocationDistance,
                let identifier = geofence["id"] as? Int
                else {
                    recordGeofencesError(description: "Could not parse from geofence data")
                    return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = CLCircularRegion(center: coordinate, radius: radius, identifier: "\(identifier)")
            
            if let manager = locationManager {
                manager.startMonitoring(for: region)
            } else {
                recordGeofencesError(description: "Location Manager instance is nil")
            }
            
            os_log("Will start monitoring for region: ", log: CleverTapGeofenceUtils.logger, region)
        }
    }
    
    private func recordGeofencesError(type: OSLogType = .error, code: Int = 0, description: StaticString) {
        
        os_log(description, log: CleverTapGeofenceUtils.logger, type: type)
        
        let error = NSError(domain: "CleverTapGeofence",
                            code: code,
                            userInfo: [NSLocalizedDescriptionKey: description])
        
        if let instance = CleverTap.sharedInstance() {
            instance.didFailToRegisterForGeofencesWithError(error)
        } else {
            os_log("CleverTap SDK is not initialized", log: CleverTapGeofenceUtils.logger, type: .fault)
        }
    }
}



// MARK: - Location Manager Delegate

/// Extension on `CleverTapGeofenceEngine` conforming to `CLLocationManagerDelegate` handles interacting with all Location Manager updates triggered by iOS.
extension CleverTapGeofenceEngine: CLLocationManagerDelegate {
    
    // MARK: - Standard Location
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        
        switch status {
        case .authorizedAlways:
            os_log("User allow app to get location data when app is active or in background", log: CleverTapGeofenceUtils.logger)
            locationManager?.startUpdatingLocation()
        case .authorizedWhenInUse:
            os_log("user allow app to get location data only when app is active", log: CleverTapGeofenceUtils.logger)
            locationManager?.startUpdatingLocation()
        case .denied:
            os_log("User tapped 'disallow' on the permission dialog, cannot get location data", log: CleverTapGeofenceUtils.logger)
        case .restricted:
            os_log("parental control setting disallow location data", log: CleverTapGeofenceUtils.logger)
        case .notDetermined:
            os_log("the location permission dialog has not been shown yet, user hasn't tap allow/disallow", log: CleverTapGeofenceUtils.logger)
        @unknown default: break
            //fatalError()
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        dump(locations)
        
        if let location = locations.last {
            if let instance = CleverTap.sharedInstance() {
                instance.setLocationForGeofences(location.coordinate, withPluginVersion: CleverTapGeofenceUtils.pluginVersion)
            } else {
                // error log
            }
            
            //            CleverTap.sharedInstance()?.setLocationForGeofences(location.coordinate, withPluginVersion: "100000")
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // MAIN SDK SET ERROR CODE
        os_log(#function, log: CleverTapGeofenceUtils.logger)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        locationManager?.requestLocation()
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        locationManager?.startUpdatingLocation()
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Log state. Helpful while debugging
        os_log(#function, log: CleverTapGeofenceUtils.logger)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        dump(visit)
        
        if let instance = CleverTap.sharedInstance() {
            instance.setLocationForGeofences(visit.coordinate, withPluginVersion: "100000")
        } else {
            os_log("CleverTap SDK is not initialized", log: CleverTapGeofenceUtils.logger, type: .error)
        }
    }
    
    
    // MARK: - Region Monitoring
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // Log state. Helpful while debugging
        os_log(#function, log: CleverTapGeofenceUtils.logger)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        // MAIN SDK SET ERROR CODE
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        
        switch state {
        case .inside:
            CleverTap.sharedInstance()?.recordGeofenceEnteredEvent(["id": region.identifier])
        case .outside:
            CleverTap.sharedInstance()?.recordGeofenceExitedEvent(["id": region.identifier])
        default:
            recordGeofencesError(description: "Could not determine user region state")
        }

    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        CleverTap.sharedInstance()?.recordGeofenceEnteredEvent(["id": region.identifier])
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        os_log(#function, log: CleverTapGeofenceUtils.logger)
        CleverTap.sharedInstance()?.recordGeofenceExitedEvent(["id": region.identifier])
    }
}
