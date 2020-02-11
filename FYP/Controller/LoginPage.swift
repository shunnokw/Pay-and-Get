//
//  LoginPage.swift
//  FYP
//
//  Created by Jason Wong on 5/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit

class LoginPage: UIViewController {
    @IBOutlet weak var _email: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var loginCardView: UIView!
    
    let firebaseService = FirebaseService()
    
    @IBAction func didClickLogin(_ sender: Any) {
        guard let email = _email.text,
        email != "",
        let password = _password.text,
        password != ""
            else{
                AlertController.showAlert(self, title: "Missing Info", message: "Please fill in all information")
                return
        }
        
        firebaseService.login(email: email, password: password) {
            loginSuccess in
            if loginSuccess {
                self.performSegue(withIdentifier: "signInSegue", sender: nil)
            } else {
                print("Login failed")
            }
        }
    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseService.autoLogin() {
            alreadyLogin in
            if alreadyLogin {
                self.performSegue(withIdentifier: "signInSegue", sender: nil)
            }
        }
        self.hideKeyboardWhenTappedAround()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
