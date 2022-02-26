//
//  Firebase.swift
//  FYP
//
//  Created by Jason Wong on 3/2/2020.
//  Copyright © 2020 Jason Wong. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService {
    var ref: DatabaseReference
    
    init() {
        self.ref = Database.database().reference()
    }
    
    func login(email: String, password: String, loginCompletion: @escaping(Bool)->()) {
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user,error) in
            guard error == nil else{
                print(error!.localizedDescription)
                loginCompletion(false)
                return
            }
            loginCompletion(true)
        })
    }
    
    func autoLogin(completion: @escaping(Bool)->()) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                completion(true)
            } else {
                // No user is signed in.
                completion(false)
            }
        }
    }
    
    func signUp(email: String, password: String, bankAcc: String, signUpCompletion: @escaping(Bool)->()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            guard error == nil else{
                print(error!.localizedDescription)
                signUpCompletion(false)
                return
            }
            guard let user = user else { return }
            print(user.user.email ?? "Missing Email")
            print(user.user.uid)
            
            self.ref = Database.database().reference()
            
            self.ref.child("users").child(user.user.uid).setValue(["username": email,"deposit": 0, "bankAcc": Int(bankAcc) ?? -1])
            signUpCompletion(true)
        })
    }
    
    func logout() {
        
    }
    
    func getUserName() -> String {
        guard let username = Auth.auth().currentUser?.email else { return "" }
        return username
    }
    
    func getUserId() -> String {
        guard let userID = Auth.auth().currentUser?.uid else { return "" }
        return userID
    }
    
    func getDeposite(completion: @escaping(Decimal)->()) {
        ref.child("users").child(getUserId()).child("deposit").observeSingleEvent(of: .value, with: { (snapshot) in
            if let deposit = snapshot.value as? NSNumber {
                completion(NSDecimalNumber(decimal: deposit.decimalValue) as Decimal)
            }
        })
    }
    
    func getTransactionRecords(completion: @escaping([TransactionModel])->()) {
        var tranList = [TransactionModel]()
        print("Loading data")
        
        //load table now
        ref.child("transaction").observe(DataEventType.value, with: { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                print("children count is: \(snapshot.childrenCount)")
                
                //iterating through all the values
                for transactions in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let tranObject = transactions.value as? [String: AnyObject]
                    let tranDate  = tranObject?["time"]
                    let tranAmount  = tranObject?["amount"]
                    let tranTarget = tranObject?["payee_id"] as? String
                    let tranFrom = tranObject?["payer_id"] as? String
                    
                    //appending it to list
                    if (tranTarget == self.getUserId()  || tranFrom == self.getUserId()){
                        //creating artist object with model and fetched values
                        let transaction = TransactionModel(date: tranDate as? String, target: tranTarget, amount: tranAmount as? String)
                        if(tranFrom == self.getUserId()){
                            transaction.amount = "-" + transaction.amount!
                        }
                        else{
                            transaction.amount = "+" + transaction.amount!
                        }
                        tranList.append(transaction)
                    }
                }
                print("Finish loading data")
                completion(tranList)
            }
        })
    }
    
    func topUp(topupValue: Int) {
        self.ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["deposit": topupValue])
        
        print("Creating transaction record")
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy.HH.mm.ss"
        
        let newTransactionRef = self.ref
            .child("transaction")
            .childByAutoId()
        let newTransactionID = newTransactionRef.key
        
        let newTransactionData = [
            "transaction_id": newTransactionID ?? -1,
            "amount": String(topupValue) as NSString,
            "payee_id": "Self top up" as NSString,
            "payer_id": "Self top up" as NSString,
            "time": formatter.string(from: date) as NSString
        ] as [String : Any]
        newTransactionRef.setValue(newTransactionData)
    }
}
