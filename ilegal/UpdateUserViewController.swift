//
//  UpdateUserViewController.swift
//  ilegal
//
//  Created by Matthew Rigdon on 2/14/17.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit
import MBProgressHUD

class UpdateUserViewController: UITableViewController {
    
    // MARK: - Inner defs
    
    private enum AlertType {
        case success, error
    }
    
    // MARK: - Properties
    
    var hasConfirmCell = false
    var userProperty: UserProperty!
    
    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private var hud = MBProgressHUD()
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Update \(userProperty.displayName)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 && hasConfirmCell ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = indexPath.section == 0 ? "valueCell" : "submitCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)

        if indexPath.section == 0 {
            (cell as! ValueCell).textField.text = userProperty.value
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return userProperty.displayName
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ValueCell
            hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.label.text = "Updating info..."
            Backend.updateUser(fieldToChange: userProperty.sqlName, withNewValue: cell.textField.text ?? "") { error in
                DispatchQueue.main.async {
                    self.hud.hide(animated: true)
                }
                if let error = error {
                    self.alert(withType: .error, withError: error)
                } else {
                    User.currentUser.saveLocal()
                    self.alert(withType: .success)
                }
            }
        }
    }

    // MARK: - Methods
    
    private func alert(withType type: AlertType, withError error: String? = nil) {
        switch type {
        case .success:
            alertController.title = "Success"
            alertController.message = "You've successfully updated your \(userProperty.displayName)"
        case .error:
            alertController.title = "Error"
            alertController.message = error ?? Backend.basicErrorMessage
        }
        alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }

}
