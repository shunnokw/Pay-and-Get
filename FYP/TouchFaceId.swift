//
//  TouchFaceId.swift
//  FYP
//
//  Created by Jason Wong on 10/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import LocalAuthentication
import Firebase
import CoreLocation

class TouchFaceId: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var showName: UILabel!
    @IBOutlet weak var showAmount: UILabel!
    
    var locationManager = CLLocationManager()
    var ref: DatabaseReference!
    var name = "Error"
    var amount = -1
    var targetLocation = CLLocation(latitude: 0, longitude: 0)
    var targetBSSID = ""
    var time = Date()
    
    
    @IBAction func payButton(_ sender: UIButton) {
        let myContext = LAContext()
        let myLocalizedReasonString = "Please approve the payment"
        
        if(checkLocation()){
            let p = locationManager.location!.coordinate
            let userLocation = CLLocation(latitude: p.latitude, longitude: p.longitude)
            let d = userLocation.distance(from: targetLocation) //meters
            if(d<=10 || isSameAP()){ //distance should be under 10 meters
                if(isWithInTimeLimit()){
                    var authError: NSError?
                    if #available(iOS 8.0, macOS 10.12.1, *) {
                        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                                DispatchQueue.main.async{
                                    if success {
                                        // User authenticated successfully, take appropriate action
                                        print("User authenticated successfully")
                                        print("Ready to process payment")
                                        
                                        if(self.pay()){
                                            let alert = UIAlertController(title: "Alert", message: "Payment Success!", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{action in self.performSegue(withIdentifier: "paymentDone", sender: nil)}))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        else{
                                            let alert3 = UIAlertController(title: "Failed Payment!", message: "You have not enough deposit", preferredStyle: .alert)
                                            self.present(alert3, animated: true, completion: nil)
                                        }
                                        
                                    } else {
                                        // User did not authenticate successfully, look at error and take appropriate action
                                        print("Sorry. Authenticate Failed")
                                        let alert2 = UIAlertController(title: "Alert", message: "Sorry. Authenticate Failed. Do you want to pay with passcode?", preferredStyle: .alert)
                                        alert2.addAction(UIAlertAction(title: "OK", style: .default))
                                        self.present(alert2, animated: true, completion: nil)
                                    }
                                }
                            }
                        } else {
                            // Could not evaluate policy; look at authError and present an appropriate message to user
                            let alert2 = UIAlertController(title: "Alert", message: "Do you want to pay with passcode?", preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert2, animated: true, completion: nil)
                        }
                    } else {
                        // Fallback on earlier versions
                        print("This feature is not supported on your device.")
                    }
                }
                else{
                    print("Time Error")
                }
            }
            else{
                print("Distance Error")
            }
        }
        else{
            print("Location Services Error")
        }
    }
    
    func isSameAP() -> Bool{
        let bssid = Network().getWiFiSsid()
        if (bssid == targetBSSID){
            return true
        }
        else{
            return false
        }
    }
    
    func isWithInTimeLimit() -> Bool {
        let timeDifference = time.timeIntervalSinceNow
        if (timeDifference < 60){
            return true
        }
        else{
            return false
        }
    }
    
    func pay() -> Bool{
        var origin = 0
        var targetOrigin = 0
        var finsih = false
        //deduct from
        ref.child("users").child((Auth.auth().currentUser?.uid)!).child("deposit").observeSingleEvent(of: .value, with: { (snapshot) in
            if let deposit = snapshot.value as? Int {
                origin = deposit
                print("origin: \(origin)")
                let result = origin - self.amount
                if (result >= 0){
                    self.ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["deposit": result])
                    finsih = true
                }
            }
        })
        if (finsih == true){
           return false
        }
        //plus target
        ref.child("users").child(self.name).child("deposit").observeSingleEvent(of: .value, with: { (snapshot) in
            if let deposit = snapshot.value as? Int {
                targetOrigin = deposit
                print("target origin: \(targetOrigin)")
                let result2 = targetOrigin + self.amount
                self.ref.child("users").child(self.name).updateChildValues(["deposit": result2])
            }
        })
        return true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ref = Database.database().reference()
        showName.text = name
        showAmount.text = "$ \(amount)"
    }
}
