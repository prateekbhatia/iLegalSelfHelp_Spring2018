//
//  AccountViewController.swift
//  ilegal
//
//  Created by Matthew Rigdon on 2/7/17.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit
import SafariServices

class AccountViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var userProperties = [UserProperty]()
    private var contactLoaded = false
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 84.0/255.0, green: 144.0/255.0, blue: 200.0/255.0, alpha:1.0)
    
        
        
        //self.navigationController?.navigationBar.barTintColor = UIColor(red: 113.0/255.0, green: 158.0/255.0, blue: 255.0/255.0, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]

        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? userProperties.count : 6
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseID = ""
        if (indexPath.section == 0){
            reuseID = "userPropertyCell"
        }
        else{
            if indexPath.row == 0 {
                reuseID = "chatCell"
            }
            else if indexPath.row == 1{
                reuseID = "generalInformationCell"
            }
            else if indexPath.row == 2{
                reuseID = "paymentCell"
            }
            else if indexPath.row == 3{
                reuseID = "childCalculatorCell"
            }
            else if indexPath.row == 4{
                reuseID = "contactUsCell"
            }
            else {
                reuseID = "logoutCell"
            }
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        cell.backgroundColor = UIColor(white: 1, alpha: 0.4);

        
        if indexPath.section == 0 {
            (cell as! UserPropertyCell).userProperty = userProperties[indexPath.row]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            if User.currentUser.email == "peterjlu@usc.edu" {
                self.performSegue(withIdentifier: "chatListSegue", sender: indexPath);
            }
            else {
                self.performSegue(withIdentifier: "chatSegue", sender: indexPath);
            }
        }

        else if indexPath.section == 1 && indexPath.row == 1 {
            let url = URL(string: "http://www.lacourt.org/selfhelp/selfhelp.aspx")
            let vc = SFSafariViewController(url: url!)
            present(vc, animated: true, completion: nil)
        }

        else if indexPath.section == 1 && indexPath.row == 2 {
            self.performSegue(withIdentifier: "paymentSegue", sender: indexPath);
        }
        else if indexPath.section == 1 && indexPath.row == 3 {

            self.performSegue(withIdentifier: "childSupportSegue", sender: indexPath)
        }
    }
    
    
     // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutSegue" {
            Backend.clearUserLocal()
        }
        else if segue.identifier == "updateUserSegue" {
            let indexPath = tableView.indexPathForSelectedRow
            (segue.destination as! UpdateUserViewController).userProperty = userProperties[indexPath!.row]
        }
//        else if segue.identifier == "chatSegue" {
//            self.tabBarController?.tabBar.isHidden = true
//        }
//        else if segue.identifier == "chatListSegue" {
//            self.tabBarController?.tabBar.isHidden = true
//        }
     }
    
    //

    // MARK: - Methods
    
    private func reloadData() {
        userProperties = [
            UserProperty(displayName: "First Name", value: User.currentUser.firstName, sqlName: "FirstName"),
            UserProperty(displayName: "Last Name", value: User.currentUser.lastName, sqlName: "LastName"),
            UserProperty(displayName: "Email", value: User.currentUser.email, sqlName: "Email"),
            UserProperty(displayName: "Driver's License", value: User.currentUser.license, sqlName: "DLNumber"),
            UserProperty(displayName: "Address", value: User.currentUser.addressOne, sqlName: "Address1"),
            UserProperty(displayName: "City", value: User.currentUser.city, sqlName: "City"),
            UserProperty(displayName: "State", value: User.currentUser.state, sqlName: "State"),
            UserProperty(displayName: "Zip", value: User.currentUser.zipcode, sqlName: "ZipCode"),
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
