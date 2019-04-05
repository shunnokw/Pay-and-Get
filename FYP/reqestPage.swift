//
//  reqestPage.swift
//  FYP
//
//  Created by Jason Wong on 3/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import CoreLocation

class reqestPage: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var collectInput: UITextField!
    
    var locationManager = CLLocationManager()
    
    @IBAction func clickedOnRequest(_ sender: Any) {
        if(checkLocation()){
            self.performSegue(withIdentifier: "requestSegue", sender: nil)
        }
        else{
            print("Location Problem")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let QRGen = segue.destination as? qrcodeGen else { return }
        QRGen.amount = collectInput.text!
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func checkLocation() -> Bool{
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            if hasLocationPermission(){
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                return true
            }
            else{
                let main = UIStoryboard(name: "Main", bundle: nil)
                let target = main.instantiateViewController(withIdentifier: "EnableLocaVC")
                self.present(target, animated: true, completion: nil)
                return false
            }
        }
        else{
            let main = UIStoryboard(name: "Main", bundle: nil)
            let target = main.instantiateViewController(withIdentifier: "EnableLocaVC")
            self.present(target, animated: true, completion: nil)
            return false
        }
    }
    
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
}
