
import Foundation
import CleverTapSDK


/// `CleverTapGeofenceEngine` runs all the Geofence setup & Core Location interactions.
/// - Warning: Client apps are __NOT__ expected to interact with this class.
internal final class CleverTapGeofenceEngine: NSObject {
    
    private var locationManager: CLLocationManager?
    
    // TODO: - var recentLocations: [CLLocation]?
    
    
    // MARK: - Lifecycle
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func start(distanceFilter: CLLocationDistance = 100) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, distanceFilter)
        
        guard CleverTap.sharedInstance() != nil,
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
            else {
                
                if CleverTap.sharedInstance() == nil {
                    recordGeofencesError(message: .uninitialized)
                } else {
                    recordGeofencesError(message: .monitoringUnsupported)
                }
                
                return
        }
        
        if locationManager == nil {
            locationManager = CLLocationManager()
        } else {
            CleverTapGeofenceUtils.log("Will utilize existing location manager instance", type: .debug)
        }
        
        locationManager?.delegate = self
        locationManager?.distanceFilter = distanceFilter
        
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringVisits()
        locationManager?.startMonitoringSignificantLocationChanges()
        
        observeNotification()
    }
    
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func stop() {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        NotificationCenter.default.removeObserver(self)
        
        resetRegions()
        
        locationManager?.stopMonitoringVisits()
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    private func resetRegions() {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        if let regions = locationManager?.monitoredRegions {
            for region in regions {
                locationManager?.stopMonitoring(for: region)
            }
        }
    }
    
    
    // MARK: - Setup Geofences
    
    private func observeNotification() {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        NotificationCenter.default.addObserver(forName: CleverTapGeofenceUtils.geofencesNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { [weak self] (notification) in
                                                
                                                CleverTapGeofenceUtils.log("CleverTapGeofencesDidUpdateNotification was observed: %@", type: .debug, notification.description)
                                                
                                                if let strongSelf = self {
                                                    
                                                    if let userInfo = notification.userInfo {
                                                        
                                                        if let geofences = userInfo["geofences"] as? [[AnyHashable: Any]] {
                                                            strongSelf.resetRegions()
                                                            strongSelf.startMonitoring(geofences)
                                                        } else {
                                                            strongSelf.recordGeofencesError(message: .unexpectedData)
                                                        }
                                                    } else {
                                                        strongSelf.recordGeofencesError(message: .unexpectedData)
                                                    }
                                                } else {
                                                    
                                                    CleverTapGeofenceUtils.log("%@", type: .error, ErrorMessages.engineNil.rawValue)
                                                    
                                                    let error = NSError(domain: "CleverTapGeofence",
                                                                        code: 0,
                                                                        userInfo: [NSLocalizedDescriptionKey: ErrorMessages.engineNil.rawValue])
                                                    
                                                    if let instance = CleverTap.sharedInstance() {
                                                        instance.didFailToRegisterForGeofencesWithError(error)
                                                    } else {
                                                        CleverTapGeofenceUtils.log("%@", type: .error, ErrorMessages.uninitialized.rawValue)
                                                    }
                                                }
        }
    }
    
    private func startMonitoring(_ geofences: [[AnyHashable: Any]]) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, geofences.description)
        
        for geofence in geofences {
            
            guard let latitude = geofence["lat"] as? CLLocationDegrees,
                let longitude = geofence["lng"] as? CLLocationDegrees,
                let radius = geofence["r"] as? CLLocationDistance,
                let identifier = geofence["id"] as? Int,
                let manager = locationManager
                else {
                    if locationManager == nil {
                        recordGeofencesError(message: .locationManagerNil)
                    } else {
                        recordGeofencesError(message: .unexpectedData)
                    }
                    return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let region = CLCircularRegion(center: coordinate, radius: radius, identifier: "\(identifier)")
            
            manager.startMonitoring(for: region)
            
            CleverTapGeofenceUtils.log("Submitted for monitoring region: %@", type: .debug, region.description)
        }
    }
    
    private func recordGeofencesError(code: Int = 0,
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
    
    private func getDetails(for region: CLRegion) -> (String, CleverTap)? {
        
        guard let instance = CleverTap.sharedInstance()
            else {
                
                if CleverTap.sharedInstance() == nil {
                    recordGeofencesError(message: .uninitialized)
                } else {
                    recordGeofencesError(message: .unexpectedData)
                }
                
                return nil
        }
        
        return (region.identifier, instance)
    }
}



// MARK: - Location Manager Delegate

/// Extension on `CleverTapGeofenceEngine` conforming to `CLLocationManagerDelegate` handles interacting with all Location Manager updates triggered by iOS.
extension CleverTapGeofenceEngine: CLLocationManagerDelegate {
    
    
    // MARK: - Standard Location
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        switch status {
        case .authorizedAlways:
            CleverTapGeofenceUtils.log("User allow app to get location data when app is active or in background.", type: .debug)
            locationManager?.startUpdatingLocation()
        case .authorizedWhenInUse:
            recordGeofencesError(message: .permissionOnlyWhileUsing)
            locationManager?.startUpdatingLocation()
        case .denied:
            recordGeofencesError(message: .permissionDenied)
        case .restricted:
            recordGeofencesError(message: .permissionRestricted)
        case .notDetermined:
            recordGeofencesError(message: .permissionUndetermined)
        @unknown default:
            recordGeofencesError(message: .permissionUnknownState)
            break
        }
    }
    
    
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, locations.description)
        
        // TODO: - let distanceDifference = latestLocation?.distance(from: (recentLocations?.last)!)
        //        if recentLocations == nil {
        //            recentLocations = [CLLocation]()
        //        }
        //
        //        for loc in locations {
        //            recentLocations?.append(loc)
        //        }
        //
        //        let latestLocation = locations.last
        //
        //        let distanceDifference = latestLocation?.distance(from: (recentLocations?.last)!)
        
        
        guard let instance = CleverTap.sharedInstance(),
            let location = locations.last
            else {
                if CleverTap.sharedInstance() == nil {
                    recordGeofencesError(message: .uninitialized)
                } else {
                    recordGeofencesError(message: .emptyLocation)
                }
                return
        }
        
        instance.setLocationForGeofences(location.coordinate, withPluginVersion: CleverTapGeofenceUtils.pluginVersion)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        recordGeofencesError(error, message: .currentLocation)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        CleverTapGeofenceUtils.log(#function, type: .debug)
        locationManager?.requestLocation()
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        CleverTapGeofenceUtils.log(#function, type: .debug)
        locationManager?.startUpdatingLocation()
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        locationManager?.requestLocation()
        recordGeofencesError(error, message: .deferredUpdates)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, visit.description)
        
        guard let instance = CleverTap.sharedInstance() else {
            recordGeofencesError(message: .uninitialized)
            return
        }
        
        instance.setLocationForGeofences(visit.coordinate, withPluginVersion: CleverTapGeofenceUtils.pluginVersion)
    }
    
    
    // MARK: - Region Monitoring
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, region.description)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        recordGeofencesError(error, message: .cannotMonitor)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        // TODO: verify if need to use file manager to diff & get current state
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, "\(state.rawValue)", region.description)
        
        if let (identifier, instance) = getDetails(for: region) {
            
            switch state {
            case .inside:
                instance.recordGeofenceEnteredEvent(["id": identifier])
                
            case .outside:
                break
                
            default:
                recordGeofencesError(message: .undeterminedState)
            }
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, region.description)
        
        if let (identifier, instance) = getDetails(for: region) {
            instance.recordGeofenceEnteredEvent(["id": identifier])
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, region.description)
        
        if let (identifier, instance) = getDetails(for: region) {
            instance.recordGeofenceExitedEvent(["id": identifier])
        }
    }
}
