//
//  WalkthroughView.swift
//  Walkthrough
//
//  Created by Matthew Rigdon on 2/13/17.
//  Copyright © 2017 Matthew Rigdon. All rights reserved.
//

import UIKit

protocol WalkthroughViewDelegate {
    func tappedButton(atIndex index: Int)
}

class WalkthroughView: UIView {
    
    // MARK: - Properties
    
    var delegate: WalkthroughViewDelegate?
    var strings = [String]()
    var width: CGFloat = 0
    var height: CGFloat = 0
    var selectedButton: WalkthroughButton! {
        didSet {
            selectedButton.setSelected(selected: true)
        }
    }
    var buttons = [WalkthroughButton]()
    
    private var separators = [UIView]()
    private var buttonMargin: CGFloat {
        return (width - (height * CGFloat(strings.count))) / CGFloat(strings.count - 1)
    }
    
    // MARK: - Initializers
    
    convenience init(strings: [String], width: CGFloat, height: CGFloat) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        self.strings = strings
        self.width = width
        self.height = height
    }
    
    // MARK: - Methods

    func load() {
        for i in 0..<strings.count {
            let button = WalkthroughButton(withIndex: i, withHeight: height)
            button.addTarget(self, action: #selector(tappedButton(button:)), for: .touchUpInside)
            buttons.append(button)
            
            addSubview(button)
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
            
            if i < strings.count - 1 {
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = .lightGray
                separators.append(separator)
                addSubview(separator)
                NSLayoutConstraint(item: separator, attribute: .top, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
                NSLayoutConstraint(item: separator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1).isActive = true
                NSLayoutConstraint(item: separator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonMargin).isActive = true
                NSLayoutConstraint(item: separator, attribute: .left, relatedBy: .equal, toItem: button, attribute: .right, multiplier: 1, constant: 0).isActive = true
                
                
            }
            if i == 0 {
                selectedButton = button
                NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 16).isActive = true
            } else {
                NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: separators[i - 1], attribute: .right, multiplier: 1, constant: 0).isActive = true
            }
        }
    }
    
    @objc private func tappedButton(button: WalkthroughButton) {
        // update selected button
        selectedButton.setSelected(selected: false)
        selectedButton = button
        
        delegate?.tappedButton(atIndex: button.index)
    }

}
