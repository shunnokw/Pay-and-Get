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
    
    override func viewDidAppear(_ animated: Bool) {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            if hasLocationPermission(){
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
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
