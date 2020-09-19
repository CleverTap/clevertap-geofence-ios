
import Foundation
import CleverTapSDK


/// `CleverTapGeofenceEngine` runs all the Geofence setup & Core Location interactions.
/// - Warning: Client apps are __NOT__ expected to interact with this class.
internal final class CleverTapGeofenceEngine: NSObject {
    
    private var locationManager: CLLocationManager?
    private var recentLocations = [CLLocation]()
    private var specifiedDistanceFilter = CleverTapGeofenceUtils.defaultDistanceFilter
    private var specifiedTimeFilter = CleverTapGeofenceUtils.defaultTimeFilter
    
    
    // MARK: - Lifecycle
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func start(_ distanceFilter: CLLocationDistance, _ timeFilter: TimeInterval) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, distanceFilter)
        
        guard CleverTap.sharedInstance() != nil,
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
            else {
                if CleverTap.sharedInstance() == nil {
                    CleverTapGeofenceUtils.recordError(message: .uninitialized)
                } else {
                    CleverTapGeofenceUtils.recordError(message: .monitoringUnsupported)
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
        specifiedDistanceFilter = distanceFilter
        specifiedTimeFilter = timeFilter
        
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringVisits()
        
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager?.startMonitoringSignificantLocationChanges()
        } else {
            CleverTapGeofenceUtils.recordError(message: .significantUnsupported)
        }
        
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
                    CleverTapGeofenceUtils.recordError(message: .locationManagerNil)
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
                                                
                                                CleverTapGeofenceUtils.log("Geofences notification observed: %@", type: .debug, notification.description)
                                                
                                                if let strongSelf = self {
                                                    
                                                    if let userInfo = notification.userInfo {
                                                        
                                                        if let geofences = userInfo["geofences"] as? [[AnyHashable: Any]] {
                                                            strongSelf.resetRegions()
                                                            strongSelf.startMonitoring(geofences)
                                                        } else {
                                                            CleverTapGeofenceUtils.recordError(message: .unexpectedData)
                                                        }
                                                    } else {
                                                        CleverTapGeofenceUtils.recordError(message: .unexpectedData)
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
                        CleverTapGeofenceUtils.recordError(message: .locationManagerNil)
                    } else {
                        CleverTapGeofenceUtils.recordError(message: .unexpectedData)
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
    
    private func handlePermission(for status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
            CleverTapGeofenceUtils.log("User set Always permission, app can get location data in active & background state.", type: .debug)
        case .authorizedWhenInUse:
            locationManager?.startUpdatingLocation()
            CleverTapGeofenceUtils.recordError(message: .permissionOnlyWhileUsing)
        case .denied:
            CleverTapGeofenceUtils.recordError(message: .permissionDenied)
        case .restricted:
            CleverTapGeofenceUtils.recordError(message: .permissionRestricted)
        case .notDetermined:
            CleverTapGeofenceUtils.recordError(message: .permissionUndetermined)
        @unknown default:
            CleverTapGeofenceUtils.recordError(message: .permissionUnknownState)
            break
        }
    }
    
    private func getDetails(for region: CLRegion) -> ([AnyHashable: Any], CleverTap)? {
        
        guard let instance = CleverTap.sharedInstance(),
            let geofences = CleverTapGeofenceUtils.read(remove: false)
            else {
                
                if CleverTap.sharedInstance() == nil {
                    CleverTapGeofenceUtils.recordError(message: .uninitialized)
                } else {
                    CleverTapGeofenceUtils.recordError(message: .unexpectedData)
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
        
        CleverTapGeofenceUtils.recordError(message: .unexpectedData)
        
        return nil
    }
    
    private func recordEventBasedOn(_ state: CLRegionState, _ geofenceDetails: [AnyHashable: Any], _ region: CLRegion, _ instance: CleverTap) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, state.rawValue, geofenceDetails)
        
        guard let cachedRegionState = geofenceDetails[CleverTapGeofenceUtils.regionStateKey] as? Int,
            let cachedTimeStampStr = geofenceDetails[CleverTapGeofenceUtils.timeStampKey] as? String,
            let cachedTimeStamp = CleverTapGeofenceUtils.formatter.date(from: cachedTimeStampStr)
            else {
                CleverTapGeofenceUtils.log("Cached regionState / timeStamp does not exists: %@", type: .debug, state.rawValue, region, geofenceDetails)
                if state == .inside {
                    instance.recordGeofenceEnteredEvent(geofenceDetails)
                    NotificationCenter.default.post(name: CleverTapGeofenceUtils.geofenceEntered, object: nil, userInfo: geofenceDetails)
                    update(state, for: region)
                }
                return
        }
        
        if state.rawValue != cachedRegionState || abs(cachedTimeStamp.timeIntervalSinceNow) > specifiedTimeFilter {
            switch state {
            case .inside:
                instance.recordGeofenceEnteredEvent(geofenceDetails)
                NotificationCenter.default.post(name: CleverTapGeofenceUtils.geofenceEntered, object: nil, userInfo: geofenceDetails)
                
            case .outside:
                instance.recordGeofenceExitedEvent(geofenceDetails)
                NotificationCenter.default.post(name: CleverTapGeofenceUtils.geofenceExited, object: nil, userInfo: geofenceDetails)
                
            default:
                CleverTapGeofenceUtils.recordError(message: .undeterminedState)
            }
            update(state, for: region)
            
        } else {
            CleverTapGeofenceUtils.log("Will not record geofence event because neither region state has changed nor specified time interval has passed: %@", type: .debug, state.rawValue, specifiedTimeFilter, region, geofenceDetails)
        }
    }
    
    private func update(_ state: CLRegionState, for region: CLRegion) {
        
        guard var geofencesListToBeUpdated = CleverTapGeofenceUtils.read() else {
            CleverTapGeofenceUtils.recordError(message: .unexpectedData)
            return
        }
        
        geofencesListToBeUpdated = geofencesListToBeUpdated.map({
            let geofence = $0
            if let identifier = geofence["id"] as? Int {
                if region.identifier == "\(identifier)" {
                    var geofenceToBeUpdated = geofence
                    geofenceToBeUpdated[CleverTapGeofenceUtils.regionStateKey] = state.rawValue
                    geofenceToBeUpdated[CleverTapGeofenceUtils.timeStampKey] = CleverTapGeofenceUtils.formatter.string(from: Date())
                    return geofenceToBeUpdated
                }
            }
            return geofence
        })
        
        CleverTapGeofenceUtils.write(geofencesListToBeUpdated)
        CleverTapGeofenceUtils.log("Updated State for geofences: %@", type: .debug, geofencesListToBeUpdated)
    }
}



// MARK: - Location Manager Delegate

/// Extension on `CleverTapGeofenceEngine` conforming to `CLLocationManagerDelegate` handles interacting with all Location Manager updates triggered by iOS.
extension CleverTapGeofenceEngine: CLLocationManagerDelegate {
    
    
    // MARK: - Standard Location
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        handlePermission(for: status)
    }
    
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    @available(iOS 14, *)
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        handlePermission(for: manager.authorizationStatus)
        
        switch manager.accuracyAuthorization {
        case .fullAccuracy:
            CleverTapGeofenceUtils.log("User set Full Accuracy permission, app can get accurate location data.", type: .debug)
            
        case .reducedAccuracy:
            CleverTapGeofenceUtils.recordError(message: .permissionReduced)
        
        default:
            CleverTapGeofenceUtils.recordError(message: .permissionUnknownState)
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
                    CleverTapGeofenceUtils.recordError(message: .uninitialized)
                } else {
                    CleverTapGeofenceUtils.recordError(message: .emptyLocation)
                }
                return
        }
        
        let existingLocations = recentLocations.filter { $0.coordinate == location.coordinate }
        if existingLocations.count == 0 {
            recentLocations.append(location)
        } else {
            CleverTapGeofenceUtils.log("Location already exists in recentLocations array, will ignore", type: .debug, location, recentLocations)
        }
        
        if recentLocations.count > 1 {
            let lastTwoLocations = recentLocations.suffix(2)
            if let previousLocation = lastTwoLocations.first, let currentLocation = lastTwoLocations.last {
                
                if currentLocation.distance(from: previousLocation) > specifiedDistanceFilter && currentLocation.timestamp.timeIntervalSince(previousLocation.timestamp) > specifiedTimeFilter {
                    instance.setLocationForGeofences(currentLocation.coordinate, withPluginVersion: CleverTapGeofenceUtils.pluginVersion)
                } else {
                    CleverTapGeofenceUtils.log("Will not update location because specified distance & time filter not satisfied: %@", type: .debug, specifiedDistanceFilter, specifiedTimeFilter, recentLocations)
                }
            } else {
                CleverTapGeofenceUtils.recordError(message: .emptyLocation)
            }
        } else {
            instance.setLocationForGeofences(location.coordinate, withPluginVersion: CleverTapGeofenceUtils.pluginVersion)
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        CleverTapGeofenceUtils.recordError(error, message: .currentLocation)
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
        CleverTapGeofenceUtils.recordError(error, message: .deferredUpdates)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, visit.description)
        
        guard let instance = CleverTap.sharedInstance() else {
            CleverTapGeofenceUtils.recordError(message: .uninitialized)
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
        CleverTapGeofenceUtils.recordError(error, message: .cannotMonitor)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, "\(state.rawValue)", region.description)
        
        if let (geofenceDetails, instance) = getDetails(for: region) {
            recordEventBasedOn(state, geofenceDetails, region, instance)
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, region.description)
        
        if let (geofenceDetails, instance) = getDetails(for: region) {
            recordEventBasedOn(CLRegionState.inside, geofenceDetails, region, instance)
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log("%@", type: .debug, #function, region.description)
        
        if let (geofenceDetails, instance) = getDetails(for: region) {
            recordEventBasedOn(CLRegionState.outside, geofenceDetails, region, instance)
        }
    }
}
