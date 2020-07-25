
import Foundation
import CoreLocation
import CleverTapSDK


/// `CleverTapGeofenceEngine` runs all the Geofence setup & Core Location interactions.
/// - Warning: Client apps are __NOT__ expected to interact with this class.
internal final class CleverTapGeofenceEngine: NSObject {
    
    private var locationManager: CLLocationManager?
    
    // TODO: - var recentLocations: [CLLocation]?
    
    
    // MARK: - Lifecycle
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal override init() {
        CleverTapGeofenceUtils.log(#function, type: .debug)
    }
    
    deinit {
        CleverTapGeofenceUtils.log(#function, type: .debug)
    }
    
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func start() {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
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
            CleverTapGeofenceUtils.log("%@ Will utilize existing location manager instance", type: .debug, #function)
        }
        
        locationManager?.delegate = self
        
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringVisits()
        locationManager?.startMonitoringSignificantLocationChanges()
        // TODO: - locationManager?.distanceFilter
        
        observeNotification()
    }
    
    
    /// - Warning: Client apps are __NOT__ expected to interact with this function.
    internal func stop() {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
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
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        NotificationCenter.default.addObserver(forName: CleverTapGeofenceUtils.geofencesNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { [weak self] (notification) in
                                                
                                                CleverTapGeofenceUtils.log("CleverTapGeofencesDidUpdateNotification was observed", type: .debug)
                                                
                                                if let strongSelf = self {
                                                    
                                                    if let userInfo = notification.userInfo {
                                                        
                                                        if let geofences = userInfo["geofences"] as? [[AnyHashable: Any]] {
                                                            strongSelf.startMonitoring(geofences)
                                                        } else {
                                                            strongSelf.recordGeofencesError(message: .unexpectedData, userInfo.description)
                                                        }
                                                    } else {
                                                        strongSelf.recordGeofencesError(message: .unexpectedData, notification.description)
                                                    }
                                                } else {
                                                    
                                                    CleverTapGeofenceUtils.log("%@", ErrorMessages.engineNil.rawValue)
                                                    
                                                    let error = NSError(domain: "CleverTapGeofence",
                                                                        code: 0,
                                                                        userInfo: [NSLocalizedDescriptionKey: ErrorMessages.engineNil.rawValue])
                                                    
                                                    if let instance = CleverTap.sharedInstance() {
                                                        instance.didFailToRegisterForGeofencesWithError(error)
                                                    } else {
                                                        CleverTapGeofenceUtils.log("%@", ErrorMessages.uninitialized.rawValue)
                                                    }
                                                }
        }
    }
    
    private func startMonitoring(_ geofences: [[AnyHashable: Any]]) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        
        for geofence in geofences {
            
            guard let latitude = geofence["lat"] as? CLLocationDegrees,
                let longitude = geofence["lng"] as? CLLocationDegrees,
                let radius = geofence["r"] as? CLLocationDistance,
                let manager = locationManager
                else {
                    if locationManager == nil {
                        recordGeofencesError(message: .locationManagerNil, geofence)
                    } else {
                        recordGeofencesError(message: .unexpectedData, geofence)
                    }
                    return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let region = CLCircularRegion(center: coordinate, radius: radius, identifier: geofence.description)
            
            manager.startMonitoring(for: region)
            
            CleverTapGeofenceUtils.log("Submitted for monitoring region: %@", region.description)
        }
    }
    
    private func recordGeofencesError(type: CleverTapGeofenceLogLevel = .error,
                                      code: Int = 0,
                                      _ error: Error? = nil,
                                      message: ErrorMessages,
                                      _ args: CVarArg...) {
        
        CleverTapGeofenceUtils.log("%@ %@", type: type, message.rawValue, args)
        
        var generatedError: Error
        
        if let error = error {
            generatedError = error
        } else {
            generatedError = NSError(domain: "CleverTapGeofence",
                                     code: code,
                                     userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        if let instance = CleverTap.sharedInstance() {
            instance.didFailToRegisterForGeofencesWithError(generatedError)
        } else {
            CleverTapGeofenceUtils.log("%@", ErrorMessages.uninitialized.rawValue)
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
            CleverTapGeofenceUtils.log("User allow app to get location data when app is active or in background.")
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
        
        CleverTapGeofenceUtils.log(#function, type: .debug)
        dump(locations)
        
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
                    recordGeofencesError(message: .uninitialized, locations.description)
                } else {
                    recordGeofencesError(message: .emptyLocation, locations.description)
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
        
        CleverTapGeofenceUtils.log(#function, type: .debug, visit.description)
        
        guard let instance = CleverTap.sharedInstance() else {
            recordGeofencesError(message: .uninitialized, visit.description)
            return
        }
        
        instance.setLocationForGeofences(visit.coordinate, withPluginVersion: CleverTapGeofenceUtils.pluginVersion)
    }
    
    
    // MARK: - Region Monitoring
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug, region.description)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        recordGeofencesError(error, message: .cannotMonitor)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug, region.description)
        
        switch state {
        case .inside:
            
            guard let geofenceDetails = CleverTapGeofenceUtils.convertStringToDictionary(text: region.identifier),
                let instance = CleverTap.sharedInstance()
                else {
                    
                    if CleverTap.sharedInstance() == nil {
                        recordGeofencesError(message: .uninitialized, region.description)
                    } else {
                        recordGeofencesError(message: .unexpectedData, region.description)
                    }
                    
                    return
            }
            
            instance.recordGeofenceEnteredEvent(geofenceDetails)
            
        case .outside:
            
            guard let geofenceDetails = CleverTapGeofenceUtils.convertStringToDictionary(text: region.identifier),
                let instance = CleverTap.sharedInstance()
                else {
                    
                    if CleverTap.sharedInstance() == nil {
                        recordGeofencesError(message: .uninitialized, region.description)
                    } else {
                        recordGeofencesError(message: .unexpectedData, region.description)
                    }
                    
                    return
            }
            
            instance.recordGeofenceExitedEvent(geofenceDetails)
            
        default:
            recordGeofencesError(message: .undeterminedState, region.description)
        }
        
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug, region.description)
        
        guard let geofenceDetails = CleverTapGeofenceUtils.convertStringToDictionary(text: region.identifier),
            let instance = CleverTap.sharedInstance()
            else {
                
                if CleverTap.sharedInstance() == nil {
                    recordGeofencesError(message: .uninitialized, region.description)
                } else {
                    recordGeofencesError(message: .unexpectedData, region.description)
                }
                
                return
        }
        
        instance.recordGeofenceEnteredEvent(geofenceDetails)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        CleverTapGeofenceUtils.log(#function, type: .debug, region.description)
        
        guard let geofenceDetails = CleverTapGeofenceUtils.convertStringToDictionary(text: region.identifier),
            let instance = CleverTap.sharedInstance()
            else {
                
                if CleverTap.sharedInstance() == nil {
                    recordGeofencesError(message: .uninitialized, region.description)
                } else {
                    recordGeofencesError(message: .unexpectedData, region.description)
                }
                
                return
        }
        
        instance.recordGeofenceExitedEvent(geofenceDetails)
    }
}
