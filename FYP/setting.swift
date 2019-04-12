//
//  setting.swift
//  FYP
//
//  Created by Jason Wong on 11/4/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class setting: UIViewController {
    var ref: DatabaseReference!

    @IBAction func onSignOutTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        } catch{
            print(error)
        }
    }
    
    @IBAction func tranTapped(_ sender: Any) {
        ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        self.ref.child("users").child(uid!).updateChildValues(["deposit": 0])
        
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
            "amount": String(topupValue) as NSString,
            "payee_id": "Transfer to bank" as NSString,
            "payer_id": "Transfer to bank" as NSString,
            "time": formatter.string(from: date) as NSString
            ] as [String : Any]
        newTransactionRef.setValue(newTransactionData)
        
        let alertt = UIAlertController(title: "Success", message: "All money transfer to bank", preferredStyle: .alert)
        alertt.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertt, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
