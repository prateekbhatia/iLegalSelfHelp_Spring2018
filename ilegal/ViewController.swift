//
//  ViewController.swift
//  ilegal
//
//  Created by Jordan Banafsheha on 9/12/16.
//  Copyright © 2016 Jordan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import CryptoSwift

class ViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        
        if(usernameTF.text!.isEmpty || passwordTF.text!.isEmpty)
        {
            //If Password/Username is empty, display alert
            let alertController = UIAlertController(title: "Sorry", message: "Please enter the Username and/or Password. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated:true, completion:nil)
        } else{
            // Attempt login
            let username = usernameTF.text!.utf8.description
            let password = passwordTF.text!.sha1().utf8.description
            Backend.login(username: username, password: password) { error in
                if let error = error {

                    Backend.saveUserLocal()
                    self.performSegue(withIdentifier: "mainSegue", sender: self)

//                    // the request failed
//                    self.passwordTF.text = ""
//                    let alertController = UIAlertController(title: "Sorry", message: error, preferredStyle: UIAlertControllerStyle.alert)
//                    alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
//                    self.present(alertController, animated:true, completion:nil)
                } else {
                    Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
                        //...
                    }
                    // the request succeeded
                    Backend.saveUserLocal()
                    self.performSegue(withIdentifier: "mainSegue", sender: self)
                }
            }
        }
    }


}

