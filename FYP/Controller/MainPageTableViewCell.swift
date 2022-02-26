//
//  VCTableViewCell.swift
//  FYP
//
//  Created by Jason Wong on 6/4/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit

class VCTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTarget: UILabel!
    @IBOutlet weak var labelAmount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
