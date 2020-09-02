//
//  ViewController.swift
//  GeofenceCarthageExample
//
//  Created by Yogesh Singh on 02/09/20.
//  Copyright © 2020 CleverTap. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func requestLocationPermission(_ sender: UIButton) {
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
    }
}

