//
//  location.swift
//  FYP
//
//  Created by Jason Wong on 9/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class MainPageViewModel {
    let firebaseService = FirebaseService()
    
    var usernameSubject = PublishSubject<String>()
    var depositSubject = PublishSubject<Decimal>()
    var tranList = PublishSubject<[TransactionModel]>()
    
    func getUserData() {
        usernameSubject.onNext(firebaseService.getUserName())
        
        firebaseService.getDeposite(){
            deposit in
            self.depositSubject.onNext(deposit)
        }
        
        firebaseService.getTransactionRecords() {
            records in
            self.tranList.onNext(records.reversed())
        }
    }
}

class location: UIViewController{
    @IBOutlet weak var _username: UILabel!
    @IBOutlet weak var _deposit: UILabel!
    @IBOutlet weak var tableViewTransaction: UITableView!
    @IBOutlet weak var topupButton: UIButton!
    @IBOutlet weak var colorBGView: UIView!
    
    let firebaseService = FirebaseService()
    let cellSpacingHeight: CGFloat = 5
    
    private let vm = MainPageViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm.usernameSubject.bind(to: _username.rx.text).disposed(by: bag)
        vm.depositSubject.map { "\($0)" }.bind(to: _deposit.rx.text).disposed(by: bag)
        vm.tranList.bind(to: tableViewTransaction.rx.items(cellIdentifier: "cell", cellType: VCTableViewCell.self)) {
            row, transaction, cell in
            cell.labelDate.text = transaction.date
            cell.labelAmount.text = transaction.amount
            cell.labelTarget.text = transaction.target
        }.disposed(by: bag)
        
        vm.getUserData()
        
        topupButton.layer.cornerRadius = topupButton.bounds.size.width / 2
        topupButton.clipsToBounds = true
        
        tableViewTransaction.backgroundColor = UIColor.clear
        colorBGView.layer.cornerRadius = 10
        colorBGView.layer.masksToBounds = true
    }
    
    @IBAction func topupTapped(_ sender: Any) {
        var topupValue = -1
        let alert = UIAlertController(title: "Top-Up", message: "How much wo uld you like to top-up?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textField in textField.text = ""; textField.keyboardType = UIKeyboardType.decimalPad})
        alert.addAction(UIAlertAction(title: "Top-up", style: .default, handler: { action in
            let textField = alert.textFields![0]
            
            guard let validInput = textField.text, !validInput.isEmpty else{
                print("No value input")
                AlertController.showAlert(self, title: "No value input", message: "Please try again")
                return
            }
            guard validInput.isNumeric else{
                print("Not Number")
                AlertController.showAlert(self, title: "Only number is accepted", message: "Please try again")
                return
            }
            guard Int(validInput)! < 100000 else{
                print("Max topup value is 100000")
                AlertController.showAlert(self, title: "Max topup value is 100000", message: "Please try again")
                return
            }
            
            topupValue = Int(validInput)!
            topupValue += Int(self._deposit.text!)!
            
            self.firebaseService.topUp(topupValue: topupValue)
            
            self.vm.getUserData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refreshBtnOnClick(_ sender: Any) {
        vm.getUserData()
    }
}

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}
