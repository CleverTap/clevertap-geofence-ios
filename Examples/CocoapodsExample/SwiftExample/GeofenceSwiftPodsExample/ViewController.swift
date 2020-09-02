
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
    
    func performActionOnGeofenceEnter() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CleverTapGeofenceEntered"), object: nil, queue: OperationQueue.main) { (notification) in
            print("Perform custom action on Geofence Enter event")
        }
    }
    
    func performActionOnGeofenceExit() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CleverTapGeofenceExited"), object: nil, queue: OperationQueue.main) { (notification) in
            print("Perform custom action on Geofence Exit event")
        }
    }
}
