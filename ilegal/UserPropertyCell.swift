//
//  UserPropertyCell.swift
//  ilegal
//
//  Created by Matthew Rigdon on 2/7/17.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit

struct UserProperty {
    var displayName = ""
    var value = ""
    var sqlName = ""
    
    init(displayName: String, value: String, sqlName: String) {
        self.displayName = displayName
        self.value = value
        self.sqlName = sqlName
    }
}

class UserPropertyCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    // MARK: - Properties
    
    var userProperty: UserProperty! {
        didSet {
            keyLabel.text = userProperty.displayName
            valueLabel.text = userProperty.value
        }
    }

}
