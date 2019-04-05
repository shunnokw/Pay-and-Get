//
//  location.swift
//  FYP
//
//  Created by Jason Wong on 9/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase

class location: UIViewController{
    @IBOutlet weak var _username: UILabel!
    @IBOutlet weak var _deposit: UILabel!
    
    var ref: DatabaseReference!
   
    @IBAction func refreshTapped(_ sender: Any) {
        loadData() 
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
