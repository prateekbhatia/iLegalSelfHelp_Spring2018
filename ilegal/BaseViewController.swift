//
//  BaseViewController.swift
//  ilegal
//
//  Created by Prateek Bhatia on 2/10/18.
//
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 84.0/255.0, green: 144.0/255.0, blue: 200.0/255.0, alpha:1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
