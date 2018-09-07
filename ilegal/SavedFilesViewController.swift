//
//  SavedFilesViewController.swift
//  ilegal
//
//  Created by Tae Ha Lee on 10/16/16.
//  Copyright © 2016 Jordan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SavedFilesViewController: UITableViewController, UITabBarControllerDelegate{
    
    let dateEndIndex = 19
    
    var filteredSavedFiles = [Form]()
    var deleteFileIndex:IndexPath? = nil
    var deleteFile:Form? = nil
    
    let searchController = UISearchController(searchResultsController:  nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 84.0/255.0, green: 144.0/255.0, blue: 200.0/255.0, alpha:1.0)

        //self.navigationController?.navigationBar.barTintColor = UIColor(red: 113.0/255.0, green: 158.0/255.0, blue: 255.0/255.0, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.tabBarController?.delegate = self
        
        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "savedFileCell")

        //Set-Up searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredSavedFiles.count
        }
        return User.currentUser.myFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "savedFileCell"
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let form: Form
        if searchController.isActive && searchController.searchBar.text != "" {
            form = filteredSavedFiles[indexPath.row]
        } else {
            form = User.currentUser.myFiles[indexPath.row]
        }
        cell.textLabel?.text = form.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: form.subtitle.substring(to: dateEndIndex))
        dateFormatter.dateStyle = .short
        cell.detailTextLabel?.text = dateFormatter.string(from: date!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "ViewPDFViewController") as! ViewPDFViewController
        destination.title = User.currentUser.myFiles[(indexPath as NSIndexPath).item].title
        destination.currentForm = User.currentUser.myFiles[(indexPath as NSIndexPath).item]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        let editItem = UIBarButtonItem()
        editItem.title = "Edit"
        destination.navigationItem.backBarButtonItem = backItem
        destination.navigationItem.rightBarButtonItem = editItem
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredSavedFiles = User.currentUser.myFiles.filter {
            form in
            return form.title.lowercased().hasPrefix(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    //Add Delete when cell is swiped to the left
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            deleteFileIndex = indexPath
            if searchController.isActive && searchController.searchBar.text != "" {
                self.deleteFile = filteredSavedFiles[indexPath.row]
            } else {
                self.deleteFile = User.currentUser.myFiles[indexPath.row]
            }
            confirmDelete(fileToDelete: (self.deleteFile?.title!)!)
        }
    }
    
    func confirmDelete(fileToDelete: String) {
        let alert = UIAlertController(title: "Delete Saved File", message: "Are you sure you want to permanently delete \(fileToDelete)?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDelete)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDelete)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDelete(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteFileIndex {
            tableView.beginUpdates()
            
            //Delete on Server
            DispatchQueue.main.async{
                Alamofire.request("http://159.203.67.188:8080/Dev/DropPDF?PDFID=" + (self.deleteFile?.id)!).responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let outcome = JSON(value)
                        if outcome["SUCCESS"].boolValue == true {
                            let alertController = UIAlertController(title: "Deleted", message: (self.deleteFile?.title)! + " has been deleted successfully.", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated:true, completion:nil)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            User.currentUser.myFiles.remove(at: indexPath.row)

            
            // Note that indexPath is wrapped in an array:  [indexPath]
            self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            self.deleteFileIndex = nil
            
            self.tableView.endUpdates()
        }
    }
    
    func cancelDelete(alertAction: UIAlertAction!) {
        deleteFileIndex = nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 1 {
            DispatchQueue.main.async{
            Alamofire.request("http://159.203.67.188:8080/Dev/ListPDF?Type=4&UserUniqueID=" + User.currentUser.id).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let outcome = JSON(value)
                    if(outcome["Success"].boolValue == true){
                        User.currentUser.myFiles.removeAll()
                        let temp = outcome["UserDocs"].count
                        if(temp > 0){
                            for i in 0...temp-1 {
                                let tempForm:Form = Form()
                                tempForm.id = outcome["UserDocs"][i][0].string
                                tempForm.location = outcome["UserDocs"][i][1].string
                                tempForm.title = outcome["UserDocs"][i][2].string
                                tempForm.subtitle = outcome["UserDocs"][i][3].string
                                User.currentUser.myFiles.append(tempForm)
                            }
                        }
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
            self.tableView.reloadData()
            }
        }
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SavedFilesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
