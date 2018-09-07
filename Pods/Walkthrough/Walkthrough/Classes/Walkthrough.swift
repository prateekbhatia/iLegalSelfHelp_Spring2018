//
//  Walkthrough.swift
//  Walkthrough
//
//  Created by Matthew Rigdon on 2/15/17.
//  Copyright © 2017 Matthew Rigdon. All rights reserved.
//

import UIKit

extension Walkthrough: WalkthroughViewDelegate {
    func tappedButton(atIndex index: Int) {
        promptView.label.text = strings[index]
    }
}

public class Walkthrough: UIView {
    
    // MARK: - Properties
    
    var width: CGFloat!
    var walkthroughView: WalkthroughView!
    var promptView: PromptView!
    var strings = [String]()
    
    // MARK: - Initializers
    
    public convenience init(strings: [String], width: CGFloat) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        self.strings = strings
        self.width = width
        setupWalkthroughView()
        setupPromptView()
    }
    
    // MARK: - Methods
    
    public func next() {
        let index = walkthroughView.selectedButton.index + 1
        if index < walkthroughView.buttons.count {
            walkthroughView.selectedButton.setSelected(selected: false)
            walkthroughView.selectedButton = walkthroughView.buttons[index]
            promptView.label.text = strings[index]
        }
    }
    
    public func prev() {
        let index = walkthroughView.selectedButton.index - 1
        if index >= 0 {
            walkthroughView.selectedButton.setSelected(selected: false)
            walkthroughView.selectedButton = walkthroughView.buttons[index]
            promptView.label.text = strings[index]
        }
    }

    private func setupWalkthroughView() {
        let height: CGFloat = 20
        walkthroughView = WalkthroughView(strings: strings, width: width - 32, height: height)
        walkthroughView.delegate = self
        addSubview(walkthroughView)
        NSLayoutConstraint(item: walkthroughView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: walkthroughView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: walkthroughView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
        NSLayoutConstraint(item: walkthroughView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
        walkthroughView.load()
    }
    
    private func setupPromptView() {
        promptView = PromptView(strings: strings)
        addSubview(promptView)
        NSLayoutConstraint(item: promptView, attribute: .top, relatedBy: .equal, toItem: walkthroughView, attribute: .bottom, multiplier: 1, constant: 24).isActive = true
        NSLayoutConstraint(item: promptView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: promptView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -8).isActive = true
        NSLayoutConstraint(item: promptView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
    }

}
