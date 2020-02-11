//
//  location.swift
//  FYP
//
//  Created by Jason Wong on 9/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import Foundation
import UIKit

class location: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var _username: UILabel!
    @IBOutlet weak var _deposit: UILabel!
    @IBOutlet weak var tableViewTransaction: UITableView!
    let firebaseService = FirebaseService()
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
            
            self.firebaseService.topUp(topupValue: topupValue)
            
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!

/// Stop using pull to refresh due to new UI design
    
//    lazy var refresher : UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .gray
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh")
//        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
//        return refreshControl
//    }()
//
    
    @IBOutlet weak var topupButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        topupButton.layer.cornerRadius = topupButton.bounds.size.width / 2
        topupButton.clipsToBounds = true

/// Download data from network JSON file
        let objectNetworkCall: NetworkCall = NetworkCall()
        objectNetworkCall.downloadJson()

//        if #available(iOS 10.0, *){
//            scrollView.refreshControl = refresher
//            refresher.bounds.origin.y -= 70
//        } else{
//            scrollView.addSubview(refresher)
//            refresher.bounds.origin.y -= 70
//        }
    }

    @IBAction func refreshBtnOnClick(_ sender: Any) {
        didPullToRefresh()
    }
    
    @objc func didPullToRefresh() {
        print("Refershing")
        tableViewTransaction.isHidden = true
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline){
            self.loadData()
            self.tableViewTransaction.isHidden = false
        }
    }
    
    func loadData(){
        _username.text = firebaseService.getUserName()
        firebaseService.getDeposite(){
            deposit in
            self._deposit.text = String(deposit)
        }
        
        //clearing the list
        self.tranList.removeAll()

        firebaseService.getTransactionRecords() {
            records in
            self.tranList = records
            
            //reloading the tableview
            self.tranList = self.tranList.reversed()
            self.tableViewTransaction.reloadData()
        }
    }
}

extension String {
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
