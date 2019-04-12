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
    let uid = Auth.auth().currentUser?.uid
    
    func payment(){
        let myContext = LAContext()
        let myLocalizedReasonString = "Please approve the payment"
        print("User authenticating")
        var authError: NSError?
        print("Checking iOS Version")
        if #available(iOS 8.0, *) {
            print("Checking evaluation policy")
            if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    DispatchQueue.main.async{
                        print("Dispatch")
                        if success {
                            print("User authenticated successfully")
                            print("Ready to process payment")
                            
                            if(self.pay()){
                                let alert = UIAlertController(title: "Alert", message: "Payment Success!", preferredStyle: .alert)
                                self.createRecord()
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{action in self.performSegue(withIdentifier: "paymentDone", sender: nil)}))
                                self.present(alert, animated: true, completion: nil)
                            }
                            else{
                                let alert3 = UIAlertController(title: "Failed Payment!", message: "Not enough deposit. Please top up", preferredStyle: .alert)
                                alert3.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(alert3, animated: true, completion: nil)
                            }
                            
                        } else {
                            // User did not authenticate successfully, look at error and take appropriate action
                            print("Sorry. Authenticate Failed")
                            let alert2 = UIAlertController(title: "Authenticate Failed", message: "Please try again and pay with password", preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert2, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                // Could not evaluate policy; look at authError and present an appropriate message to user
                let alert2 = UIAlertController(title: "Alert", message: "Sorry. Authenticate Failed. Please try again and pay with your device password", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert2, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
            print("This feature is not supported on your device.")
        }
    }
    
    @IBAction func payButton(_ sender: UIButton) {
        if(checkLocation()){
            let p = locationManager.location!.coordinate
            let userLocation = CLLocation(latitude: p.latitude, longitude: p.longitude)
            let d = userLocation.distance(from: targetLocation) //meters
            if(d<=10){ //distance should be under 10 meters
                if(isWithInTimeLimit()){
                   payment()
                }
                else{
                    print("Time Error")
                    let alertt = UIAlertController(title: "Time Error", message: "The QR Code is not used within 60 seconds", preferredStyle: .alert)
                    alertt.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertt, animated: true, completion: nil)
                }
            }
            else if(isSameAP()){
                payment()
            }
            else{
                print("Distance Error")
                let alertD = UIAlertController(title: "Distance Error", message: "Location are not close enough. Try connect to same WiFi newtwork", preferredStyle: .alert)
                alertD.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertD, animated: true, completion: nil)
            }
        }
        else{
            print("Location Services Error")
//            let alertk = UIAlertController(title: "Alert", message: "Location Services Error", preferredStyle: .alert)
//            alertk.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(alertk, animated: true, completion: nil)
        }
    }
    
    func isSameAP() -> Bool{
        guard let bssid = Network().getWiFiSsid() else{
            let alertW = UIAlertController(title: "Wifi Error", message: "Device may have Wifi issue", preferredStyle: .alert)
            alertW.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertW, animated: true, completion: nil)
            return false
        }
        if (bssid == targetBSSID){
            return true
        }
        else{
            return false
        }
    }
    
    func isWithInTimeLimit() -> Bool {
        let timeDifference = time.timeIntervalSinceNow
        print("Time difference is: \(timeDifference)")
        if (timeDifference < 60 && timeDifference > -60){
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
                print("amount: \(self.amount)")
                let result = origin - self.amount
                if (result >= 0){
                    print("result")
                    self.ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["deposit": result])
                    finsih = true
                }
            }
        })
        if (finsih == false){
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
    
    func createRecord(){
        print("Creating transaction record")
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy.HH.mm.ss"
        
        let newTransactionRef = self.ref!
                                .child("transaction")
                                .childByAutoId()
        let newTransactionID = newTransactionRef.key
        
        let newTransactionData = [
            "transaction_id": newTransactionID ?? -1,
            "amount": String(amount) as NSString,
            "payee_id": name as NSString,
            "payer_id": uid! as NSString,
            "time": formatter.string(from: date) as NSString
            ] as [String : Any]
        newTransactionRef.setValue(newTransactionData)
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
                
                addChildViewController(target)
                target.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
                view.addSubview(target.view)
                target.didMove(toParentViewController: self)
                
                //self.present(target, animated: true, completion: nil)
                return false
            }
        }
        else{
            let main = UIStoryboard(name: "Main", bundle: nil)
            let target = main.instantiateViewController(withIdentifier: "EnableLocaVC")
            
            addChildViewController(target)
            target.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            view.addSubview(target.view)
            view.tag = 0
            target.didMove(toParentViewController: self)
            
            //self.present(target, animated: true, completion: nil)
            return false
        }
    }
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
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
        var realName = ""
        self.ref = Database.database().reference()
        ref.child("users").child(self.name).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            realName = (snapshot.value as? String)!
        })
        showName.text = name
        showAmount.text = "$ \(amount)"
    }
}
