//
//  CleverTapGeofenceEngine.swift
//  CleverTapGeofence
//
//  Created by Yogesh Singh on 15/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

import os.log
import Foundation
import CoreLocation
import CleverTapSDK


internal final class CleverTapGeofenceEngine: NSObject {
    
    private let logger = OSLog(subsystem: "com.clevertap.CleverTapGeofence", category: "CleverTapGeofenceEngine")
    
    private let geofencesNotification = NSNotification.Name("CleverTapGeofencesNotification")
    
    private var locationManager: CLLocationManager?
    
    
    internal override init() {
        os_log(#function, log: logger)
    }
    
    
    internal func start() {
        
        os_log(#function, log: logger)
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            
            locationManager?.delegate = self
            
            locationManager?.startUpdatingLocation()
            locationManager?.startMonitoringVisits()
            locationManager?.startMonitoringSignificantLocationChanges()
            
            observeNotification()
            
        } else {
            os_log("Device does not supports Region Monitoring", log: logger, type: .fault)
        }
    }
    
    
    internal func stop() {
        
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
                                               queue: OperationQueue.main) { [weak self] (notification) in
                                                
                                                os_log("CleverTapGeofencesNotification was observed", log: self?.logger ?? .default)
                                                
                                                if let userInfo = notification.userInfo {
                                                    
                                                    if let geofences = userInfo["geofences"] as? [[AnyHashable: Any]] {
                                                        
                                                        for geofence in geofences {
                                                            
                                                            let latitude = geofence["lat"] as! CLLocationDegrees
                                                            let longitude = geofence["lng"] as! CLLocationDegrees
                                                            let radius = geofence["rad"] as! CLLocationDistance
                                                            let identifier = geofence["id"] as! String
                                                            
                                                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                                            let region = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
                                                            
                                                            self?.locationManager?.startMonitoring(for: region)
                                                            
                                                            os_log("Will start monitoring for region: ", log: self?.logger ?? .default, region)
                                                        }
                                                    }
                                                }
        }
    }
}



// MARK: - Location Manager Delegate

/// Extension on `CleverTapGeofenceEngine` conforming to `CLLocationManagerDelegate` handles interacting with all Location Manager updates triggered by iOS.
extension CleverTapGeofenceEngine: CLLocationManagerDelegate {
    
    // MARK: - Standard Location
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log(#function, log: logger)
        
        switch status {
        case .authorizedAlways:
            os_log("User allow app to get location data when app is active or in background", log: logger)
            locationManager?.startUpdatingLocation()
        case .authorizedWhenInUse:
            os_log("user allow app to get location data only when app is active", log: logger)
            locationManager?.startUpdatingLocation()
        case .denied:
            os_log("user tap 'disallow' on the permission dialog, cant get location data", log: logger)
        case .restricted:
            os_log("parental control setting disallow location data", log: logger)
        case .notDetermined:
            os_log("the location permission dialog has not been shown yet, user hasn't tap allow/disallow", log: logger)
        @unknown default: break
            //fatalError()
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        os_log(#function, log: logger)
        dump(locations)
        
        if let location = locations.last {
            CleverTap.sharedInstance()?.setLocationForGeofences(location.coordinate)
        }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // MAIN SDK SET ERROR CODE
        os_log(#function, log: logger)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
        locationManager?.requestLocation()
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
        locationManager?.startUpdatingLocation()
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
    }
    
    
    // MARK: - Region Monitoring
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // Log state. Helpful while debugging
        os_log(#function, log: logger)
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        os_log(#function, log: logger)
        
        // if let region = region as? CLCircularRegion {
        //let identifier = region.identifier
        // Main SDK ENTER API
        // }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        os_log(#function, log: logger)
        
        // if let region = region as? CLCircularRegion {
        // let identifier = region.identifier
        // Main SDK EXIT API
        // }
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        os_log(#function, log: logger)
        // Log state. Helpful while debugging
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        os_log(#function, log: logger)
        CleverTap.sharedInstance()?.recordGeofenceEnteredEvent(["id": region.identifier])
    }
    
    /// - Warning: Client apps are __NOT__ expected to handle or interact with this function.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        os_log(#function, log: logger)
        CleverTap.sharedInstance()?.recordGeofenceExitedEvent(["id": region.identifier])
    }
}
