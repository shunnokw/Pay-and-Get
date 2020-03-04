//
//  SignUpVC.swift
//  FYP
//
//  Created by Jason Wong on 5/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var _email: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _bankAcc: UITextField!
    
    let firebaseService = FirebaseService()
    
    @IBAction func onSignUpTapped(_ sender: Any) {
        guard let email = _email.text,
            email != "",
            let password = _password.text,
            password != ""
            else{
                AlertController.showAlert(self, title: "Missing Info", message: "Please fill in all information")
                return
        }
        
        firebaseService.signUp(email: email, password: password, bankAcc: _bankAcc.text!) {
            signUpSuccess in
            if (signUpSuccess) {
                self.performSegue(withIdentifier: "signUpSegue", sender: nil)
            } else {
                print("SignUp Success")
            }
        }
    }
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
