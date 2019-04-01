//
//  TouchFaceId.swift
//  FYP
//
//  Created by Jason Wong on 10/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import LocalAuthentication
import Firebase

class TouchFaceId: UIViewController {
    
    @IBOutlet weak var showName: UILabel!
    @IBOutlet weak var showAmount: UILabel!
    
    var ref: DatabaseReference!
    var oringinalAmount = 0
    var name = "Error"
    var amount = "Error"

    @IBAction func payButton(_ sender: UIButton) {
        let myContext = LAContext()
        let myLocalizedReasonString = "Please approve the payment"
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            // User authenticated successfully, take appropriate action
                            print("User authenticated successfully")
                            //get payer original amount
                            self.ref.child("users").child((Auth.auth().currentUser?.uid)!).child("deposit").observeSingleEvent(of: .value, with: { (snapshot) in
                                if let deposit = snapshot.value as? Int {
                                    self.oringinalAmount = deposit
                                }
                            })
                            //process payment (reduce payer amount)
                            let newAmount = self.oringinalAmount-Int(self.amount)!
                            self.ref.child("users").child((Auth.auth().currentUser?.uid)!).setValue(["deposit": newAmount])
                            //get payee origainal amount
                            //process payment (increase payee amount)
                            
                            let alert = UIAlertController(title: "Alert", message: "Payment Success!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{action in self.performSegue(withIdentifier: "paymentDone", sender: nil)}))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            // User did not authenticate successfully, look at error and take appropriate action
                            print("Sorry. Authenticate Failed")
                            let alert2 = UIAlertController(title: "Alert", message: "Sorry. Authenticate Failed. Do you want to pay with passcode?", preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert2, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                // Could not evaluate policy; look at authError and present an appropriate message to user
                let alert2 = UIAlertController(title: "Alert", message: "Do you want to pay with passcode?", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert2, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
            print("This feature is not supported on your device.")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ref = Database.database().reference()
        showName.text = name
        showAmount.text = "$ \(amount)"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
