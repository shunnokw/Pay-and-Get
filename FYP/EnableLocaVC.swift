//
//  EnableLocaVC.swift
//  FYP
//
//  Created by Jason Wong on 7/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class EnableLocaVC: UIViewController,CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    func hasLocationPermission() -> Bool {
        var hasPermission = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                hasPermission = false
            case .authorizedAlways, .authorizedWhenInUse:
                hasPermission = true
            }
        } else {
            hasPermission = false
        }
        return hasPermission
    }

    @IBAction func enableLS(_ sender: Any) {
        
        if !CLLocationManager.locationServicesEnabled() {
            if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                // If general location settings are disabled then open general location settings
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                // If general location settings are enabled then open location settings for the app
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else{
                //let main = UIStoryboard(name: "Main", bundle: nil)
                //let target2 = main.instantiateViewController(withIdentifier: "location")
                
                if CLLocationManager.locationServicesEnabled(){
                    if hasLocationPermission(){
                        //self.present(target2, animated: true, completion: nil)
                        performSegueToReturnBack()
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //let main = UIStoryboard(name: "Main", bundle: nil)
        //let target2 = main.instantiateViewController(withIdentifier: "location")
        
        if CLLocationManager.locationServicesEnabled(){
            if hasLocationPermission(){
                //self.present(target2, animated: true, completion: nil)
                performSegueToReturnBack()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
