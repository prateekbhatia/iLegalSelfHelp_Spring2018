//
//  Walkthroughswift
//  Walkthrough
//
//  Created by Matthew Rigdon on 2/15/17.
//  Copyright © 2017 Matthew Rigdon. All rights reserved.
//

import UIKit

extension UIColor {
    static var darkGreen: UIColor {
        return UIColor(red: 49/255, green: 163/255, blue: 67/255, alpha: 1)
    }
}

class WalkthroughButton: UIButton {
    
    // MARK: - Properties
    
    private(set) var index: Int!

    // MARK: - Initializers
    
    convenience init(withIndex index: Int, withHeight height: CGFloat) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        self.index = index
        setTitle(String(index + 1), for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = titleLabel?.font.withSize(10)
        backgroundColor = .gray
        layer.cornerRadius = height / 2
    }
    
    // MARK: - Methods
    
    func setSelected(selected: Bool) {
        backgroundColor = selected ? .darkGreen : .gray
    }

}
