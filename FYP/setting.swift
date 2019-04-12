//
//  setting.swift
//  FYP
//
//  Created by Jason Wong on 11/4/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import Firebase

class setting: UIViewController {
    
    @IBAction func onSignOutTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        } catch{
            print(error)
        }
    }
    
    @IBAction func tranTapped(_ sender: Any) {
        let userID = Auth.auth().currentUser?.uid
        var ref: DatabaseReference!
        ref.child("users").child(userID!).updateChildValues(["deposit": 0])
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
