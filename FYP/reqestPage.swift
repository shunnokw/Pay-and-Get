//
//  reqestPage.swift
//  FYP
//
//  Created by Jason Wong on 3/3/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit

class reqestPage: UIViewController {
    
    @IBOutlet weak var collectInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let QRGen = segue.destination as? qrcodeGen else { return }
        QRGen.amount = collectInput.text!
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
