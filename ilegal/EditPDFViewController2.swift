//
//  EditPDFViewController2.swift
//  ilegal
//
//  Created by Matthew Rigdon on 2/20/17.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit
import Walkthrough

class EditPDFViewController2: UIViewController {
    
    // MARK: - Properties
    
    var form: Form!
    var walkthrough: Walkthrough!
    
    
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        Backend.getPDF(withID: form.id) { questions, error in
            if let questions = questions {
                self.walkthrough = Walkthrough(strings: questions, width: self.view.bounds.width - 32)
                self.view.addSubview(self.walkthrough)
                NSLayoutConstraint(item: self.walkthrough, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 16).isActive = true
                NSLayoutConstraint(item: self.walkthrough, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 16).isActive = true
                NSLayoutConstraint(item: self.walkthrough, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: -16).isActive = true
            } else {
                if let error = error {
                    print(error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
