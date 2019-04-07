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
    @IBAction func alreadyTapped(_ sender: Any) {
        let viewWithTag = self.view.viewWithTag(0)
        viewWithTag?.removeFromSuperview()
    }
    
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
                        let viewWithTag = self.view.viewWithTag(0)
                        viewWithTag?.removeFromSuperview()
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
                let viewWithTag = self.view.viewWithTag(0)
                viewWithTag?.removeFromSuperview()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

}


