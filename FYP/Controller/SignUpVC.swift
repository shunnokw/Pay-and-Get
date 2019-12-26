//
//  SignUpVC.swift
//  FYP
//
//  Created by Jason Wong on 5/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class SignUpVC: UIViewController {

    @IBOutlet weak var _email: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _bankAcc: UITextField!
    var ref: DatabaseReference!

    @IBAction func onSignUpTapped(_ sender: Any) {
        guard let email = _email.text,
            email != "",
            let password = _password.text,
            password != ""
            else{
                AlertController.showAlert(self, title: "Missing Info", message: "Please fill in all information")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            guard error == nil else{
                AlertController.showAlert(self, title: "Error", message: error!.localizedDescription)
                return
            }
            guard let user = user else { return }
            print(user.user.email ?? "Missing Email")
            print(user.user.uid)
            
            self.ref = Database.database().reference()
            self.performSegue(withIdentifier: "signUpSegue", sender: nil)
            self.ref.child("users").child(user.user.uid).setValue(["username": email,"deposit": 0, "bankAcc": Int(self._bankAcc.text!) ?? -1])
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
