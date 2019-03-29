//
//  LoginPage.swift
//  FYP
//
//  Created by Jason Wong on 5/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import Firebase

class LoginPage: UIViewController {
    @IBOutlet weak var _email: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBAction func didClickLogin(_ sender: Any) {
        guard let email = _email.text,
        email != "",
        let password = _password.text,
        password != ""
            else{
                AlertController.showAlert(self, title: "Missing Info", message: "Please fill in all information")
                return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user,error) in
            guard error == nil else{
                AlertController.showAlert(self, title: "Error", message: error!.localizedDescription)
                return
            }
            //guard let user = user else { return }
            //print(user.user.email ?? "Missing Email")
            
            self.performSegue(withIdentifier: "signInSegue", sender: nil)
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.performSegue(withIdentifier: "signInSegue", sender: nil)
            } else {
                // No user is signed in.
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
