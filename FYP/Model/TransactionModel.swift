//
//  TransactionModel.swift
//  FYP
//
//  Created by Jason Wong on 6/4/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import Foundation

class TransactionModel{
    var date: String?
    var target: String?
    var amount: String?
    
    init(date: String?, target: String?, amount: String?) {
        self.date = date
        self.target = target
        self.amount = amount
    }
}
