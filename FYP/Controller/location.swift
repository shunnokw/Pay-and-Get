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
    let cellSpacingHeight: CGFloat = 5
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tranList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
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
    
    @IBAction func topupTapped(_ sender: Any) {
        var topupValue = -1
        let alert = UIAlertController(title: "Top-Up", message: "How much would you like to top-up?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textField in textField.text = ""; textField.keyboardType = UIKeyboardType.decimalPad})
        alert.addAction(UIAlertAction(title: "Top-up", style: .default, handler: { action in
            let textField = alert.textFields![0]
            guard let validInput = textField.text, !validInput.isEmpty else{
                print("No value input")
                return
            }
            guard validInput.isNumeric else{
                print("Not Number")
                return
            }
            topupValue = Int(validInput)!
            topupValue += Int(self._deposit.text!)!
            self.ref.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["deposit": topupValue])
            
            
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
                    "payee_id": "Self top up" as NSString,
                    "payer_id": "Self top up" as NSString,
                    "time": formatter.string(from: date) as NSString
                    ] as [String : Any]
                newTransactionRef.setValue(newTransactionData)
            
            
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var refresher : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        ///  Download data from network JSON file
        let objectNetworkCall: NetworkCall = NetworkCall()
        objectNetworkCall.downloadJson()
        
        if #available(iOS 10.0, *){
            scrollView.refreshControl = refresher
            refresher.bounds.origin.y -= 70
        } else{
            scrollView.addSubview(refresher)
            refresher.bounds.origin.y -= 70
        }
    }
    
    @objc func didPullToRefresh() {
        print("Refershing")
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline){
            self.loadData()
            self.refresher.endRefreshing()
        }
    }
    
    
    
    func loadData(){
        print("Loading data")
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
                
                //iterating through all the values
                for transactions in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let tranObject = transactions.value as? [String: AnyObject]
                    let tranDate  = tranObject?["time"]
                    let tranAmount  = tranObject?["amount"]
                    let tranTarget = tranObject?["payee_id"] as? String
                    let tranFrom = tranObject?["payer_id"] as? String
                    
                    //appending it to list
                    if (tranTarget == userID  || tranFrom == userID){
                        //creating artist object with model and fetched values
                        let transaction = TransactionModel(date: tranDate as? String, target: tranTarget, amount: tranAmount as? String)
                        if(tranFrom == userID){
                            transaction.amount = "-" + transaction.amount!
                        }
                        else{
                            transaction.amount = "+" + transaction.amount!
                        }
                        self.tranList.append(transaction)
                    }
                }
                
                //reloading the tableview
                self.tranList = self.tranList.reversed()
                self.tableViewTransaction.reloadData()
            }
        })
        print("Finish loading data")
    }
}

extension String {
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
