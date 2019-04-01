//
//  location.swift
//  FYP
//
//  Created by Jason Wong on 9/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FirebaseDatabase
import Firebase
import CoreLocation

class location: UIViewController , CLLocationManagerDelegate{
    @IBOutlet weak var _username: UILabel!
    @IBOutlet weak var _deposit: UILabel!
    var locationManager = CLLocationManager()
    var ref: DatabaseReference!
   
    @IBAction func payTapped(_ sender: Any) {
        checkLocation()
    }
    
    @IBAction func topupTapped(_ sender: Any) {
        var topupValue = -1
        let alert = UIAlertController(title: "Top-Up", message: "How much would you like to top-up?", preferredStyle: .alert)
        alert.addTextField{(textField) in textField.text = ""}
        alert.addAction(UIAlertAction(title: "Top-up", style: .default, handler: { action in
            let textField = alert.textFields![0]
            textField.keyboardType = UIKeyboardType.decimalPad
            topupValue = Int(textField.text!)!
            topupValue += Int(self._deposit.text!)!
            self.ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["deposit": topupValue])
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSignOutTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        } catch{
            print(error)
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
        loadData()
    }
    
    func loadData(){
        self.ref = Database.database().reference()
        guard let username = Auth.auth().currentUser?.email else { return }
        let userID = Auth.auth().currentUser?.uid
        
        _username.text = username
        ref.child("users").child(userID!).child("deposit").observeSingleEvent(of: .value, with: { (snapshot) in
            if let deposit = snapshot.value as? Int {
                self._deposit.text = "\(deposit)"
            }
        })
    }
    
    func checkLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            if hasLocationPermission(){
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                self.performSegue(withIdentifier: "scanSegue", sender: nil)
            }
            else{
                let main = UIStoryboard(name: "Main", bundle: nil)
                let target = main.instantiateViewController(withIdentifier: "EnableLocaVC")
                self.present(target, animated: true, completion: nil)
            }
        }
        else{
            let main = UIStoryboard(name: "Main", bundle: nil)
            let target = main.instantiateViewController(withIdentifier: "EnableLocaVC")
            self.present(target, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        //let userLocation = locations.last
        //let viewRegion = MKCoordinateRegionMakeWithDistance((userLocation?.coordinate)!, 600, 600)
        //self.map.setRegion(viewRegion, animated: true)
    }
    
}
