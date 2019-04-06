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

class location: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var _username: UILabel!
    @IBOutlet weak var _deposit: UILabel!
    @IBOutlet weak var tableViewTransaction: UITableView!
    var ref: DatabaseReference!
    var tranList = [TransactionModel]()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tranList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //creating a cell using the custom class
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VCTableViewCell
        
        let transaction: TransactionModel
        
        transaction = tranList[indexPath.row]
        
        //adding values to labels
        cell.labelDate.text = transaction.date
        cell.labelAmount.text = transaction.amount
        cell.labelTarget.text = transaction.target
        
        //returning cell
        return cell
    }
   
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
        //load table now
        ref.child("transaction").observe(DataEventType.value, with: { (snapshot) in
            
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                print("children count is: \(snapshot.childrenCount)")
                
                //clearing the list
                self.tranList.removeAll()
                
                //TODO: query the real record according to user id")
                //iterating through all the values
                for transactions in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let tranObject = transactions.value as? [String: AnyObject]
                    let tranDate  = tranObject?["time"]
                    let tranAmount  = tranObject?["amount"]
                    let tranTarget = tranObject?["payee_id"]
                    
                    //creating artist object with model and fetched values
                    let transaction = TransactionModel(date: tranDate as! String?, target: tranTarget as! String?, amount: tranAmount as! String?)
                    
                    //appending it to list
                    self.tranList.append(transaction)
                }
                
                //reloading the tableview
                self.tableViewTransaction.reloadData()
            }
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
