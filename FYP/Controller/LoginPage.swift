//
//  LoginPage.swift
//  FYP
//
//  Created by Jason Wong on 5/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewModel {
    let usernameSubject = PublishSubject<String>()
    let passwordSubject = PublishSubject<String>()
    
    func isValid () -> Observable<Bool> {
        Observable.combineLatest(usernameSubject.asObserver(), passwordSubject.asObserver()).map {
            username, password in
            return username.count >= 8 && password.count >= 8
        }.startWith(false)
    }
}

class LoginPage: UIViewController {
    @IBOutlet weak var _email: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    private let firebaseService = FirebaseService()
    private let loginViewModel = LoginViewModel()
    private let bag = DisposeBag()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _email.rx.text.map { $0 ?? "" }.bind(to: loginViewModel.usernameSubject).disposed(by: bag)
        _password.rx.text.map { $0 ?? "" }.bind(to: loginViewModel.passwordSubject).disposed(by: bag)
        
        loginViewModel.isValid().bind(to: loginBtn.rx.isEnabled).disposed(by: bag)
        
        loginViewModel.isValid().map{ $0 ? 1 : 0.1 }.bind(to: loginBtn.rx.alpha).disposed(by: bag)
        
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
