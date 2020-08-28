//
//  ViewController.swift
//  GeofenceCarthageExample
//
//  Created by Yogesh Singh on 09/07/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestLocation()
    }
    
    func requestLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
    }
}

