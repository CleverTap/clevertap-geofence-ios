
import Foundation
import CleverTapSDK


/// `CleverTapGeofenceEngine` runs all the Geofence setup & Core Location interactions.
/// - Warning: Client apps are __NOT__ expected to interact with this class.
internal final class CleverTapGeofenceEngine: NSObject {
    
    private var locationManager: CLLocationManager?
    
    
    // MARK: - Lifecycle
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func start(distanceFilter: CLLocationDistance = 100) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, distanceFilter)
        
        guard CleverTap.sharedInstance() != nil,
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
            else {
                
                if CleverTap.sharedInstance() == nil {
                    CleverTapGeofenceUtils.recordGeofencesError(message: .uninitialized)
                } else {
                    CleverTapGeofenceUtils.recordGeofencesError(message: .monitoringUnsupported)
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
        
        guard let manager = locationManager,
            manager.monitoredRegions.count > 0
            else {
                if locationManager == nil {
                    CleverTapGeofenceUtils.recordGeofencesError(message: .locationManagerNil)
                } else {
                    CleverTapGeofenceUtils.log("No regions being monitored currently.", type: .debug)
                }
                return
        }
        
        if let geofences = CleverTapGeofenceUtils.read() {
            for region in manager.monitoredRegions {
                for geofence in geofences {
                    if let identifier = geofence["id"] as? Int {
                        if region.identifier == "\(identifier)" {
                            manager.stopMonitoring(for: region)
                        }
                    }
                }
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
                                                            CleverTapGeofenceUtils.recordGeofencesError(message: .unexpectedData)
                                                        }
                                                    } else {
                                                        CleverTapGeofenceUtils.recordGeofencesError(message: .unexpectedData)
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
                        CleverTapGeofenceUtils.recordGeofencesError(message: .locationManagerNil)
                    } else {
                        CleverTapGeofenceUtils.recordGeofencesError(message: .unexpectedData)
                    }
                    return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let region = CLCircularRegion(center: coordinate, radius: radius, identifier: "\(identifier)")
            
            manager.startMonitoring(for: region)
            
            CleverTapGeofenceUtils.log("Submitted for monitoring region: %@", type: .debug, region.description)
        }
        
        CleverTapGeofenceUtils.write(geofences)
    }
    
    private func getDetails(for region: CLRegion) -> ([AnyHashable: Any], CleverTap)? {
        
        guard let instance = CleverTap.sharedInstance(),
            let geofences = CleverTapGeofenceUtils.read(remove: false)
            else {
                
                if CleverTap.sharedInstance() == nil {
                    CleverTapGeofenceUtils.recordGeofencesError(message: .uninitialized)
                } else {
                    CleverTapGeofenceUtils.recordGeofencesError(message: .unexpectedData)
                }
                
                return nil
        }
        
        for geofence in geofences {
            if let identifier = geofence["id"] as? Int {
                if region.identifier == "\(identifier)" {
                    return (geofence, instance)
                }
            }
        }
        
        CleverTapGeofenceUtils.recordGeofencesError(message: .unexpectedData)
        
        return nil
    }
    
    private func updateState(for region: CLRegion, with state: CLRegionState) {
        
        guard var geofencesListToBeUpdated = CleverTapGeofenceUtils.read() else {
            CleverTapGeofenceUtils.recordGeofencesError(message: .unexpectedData)
            return
        }
        
        geofencesListToBeUpdated = geofencesListToBeUpdated.map({
            let geofence = $0
            if let identifier = geofence["id"] as? Int {
                if region.identifier == "\(identifier)" {
                    var geofenceToBeUpdated = geofence
                    geofenceToBeUpdated[CleverTapGeofenceUtils.regionStateKey] = state.rawValue
                    return geofenceToBeUpdated
                }
            }
            return geofence
        })
        
        CleverTapGeofenceUtils.write(geofencesListToBeUpdated)
        
        CleverTapGeofenceUtils.log("Updated State for geofences: %@", type: .debug, geofencesListToBeUpdated)
    }
    
    private func recordEventBased(on state: CLRegionState, for geofenceDetails: [AnyHashable: Any], with instance: CleverTap) {
        switch state {
        case .inside:
            instance.recordGeofenceEnteredEvent(geofenceDetails)
            
        case .outside:
            instance.recordGeofenceExitedEvent(geofenceDetails)
            
        default:
            CleverTapGeofenceUtils.recordGeofencesError(message: .undeterminedState)
        }
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
            CleverTapGeofenceUtils.log("User set Always permission, app can get location data in active & background state.", type: .debug)
            locationManager?.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager?.startUpdatingLocation()
            CleverTapGeofenceUtils.recordGeofencesError(message: .permissionOnlyWhileUsing)
        case .denied:
            CleverTapGeofenceUtils.recordGeofencesError(message: .permissionDenied)
        case .restricted:
            CleverTapGeofenceUtils.recordGeofencesError(message: .permissionRestricted)
        case .notDetermined:
            CleverTapGeofenceUtils.recordGeofencesError(message: .permissionUndetermined)
        @unknown default:
            CleverTapGeofenceUtils.recordGeofencesError(message: .permissionUnknownState)
            break
        }
    }
    
    
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, locations.description)
        
        guard let instance = CleverTap.sharedInstance(),
            let location = locations.last
            else {
                if CleverTap.sharedInstance() == nil {
                    CleverTapGeofenceUtils.recordGeofencesError(message: .uninitialized)
                } else {
                    CleverTapGeofenceUtils.recordGeofencesError(message: .emptyLocation)
                }
                return
        }
        
        instance.setLocationForGeofences(location.coordinate, withPluginVersion: CleverTapGeofenceUtils.pluginVersion)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        CleverTapGeofenceUtils.recordGeofencesError(error, message: .currentLocation)
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
        CleverTapGeofenceUtils.recordGeofencesError(error, message: .deferredUpdates)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, visit.description)
        
        guard let instance = CleverTap.sharedInstance() else {
            CleverTapGeofenceUtils.recordGeofencesError(message: .uninitialized)
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
        CleverTapGeofenceUtils.recordGeofencesError(error, message: .cannotMonitor)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, "\(state.rawValue)", region.description)
        
        if let (geofenceDetails, instance) = getDetails(for: region) {
            
            if let savedState = geofenceDetails[CleverTapGeofenceUtils.regionStateKey] as? Int {
                if savedState != state.rawValue {
                    recordEventBased(on: state, for: geofenceDetails, with: instance)
                }
            } else {
                recordEventBased(on: state, for: geofenceDetails, with: instance)
            }
            
            updateState(for: region, with: state)
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, region.description)
        
        if let (geofenceDetails, instance) = getDetails(for: region) {
            instance.recordGeofenceEnteredEvent(geofenceDetails)
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, region.description)
        
        if let (geofenceDetails, instance) = getDetails(for: region) {
            instance.recordGeofenceExitedEvent(geofenceDetails)
        }
    }
}
