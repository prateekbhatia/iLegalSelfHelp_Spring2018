//
//  DonePDFViewController.swift
//  ilegal
//
//  Created by Tae Ha Lee on 10/16/16.
//  Copyright © 2016 Jordan. All rights reserved.
//

import UIKit
import ILPDFKit

class DonePDFViewController: ILPDFViewController {


    @IBOutlet weak var webView: UIWebView!
    var currentForm:Form? = nil
    var fileURL:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Implement ILPDFKit
        fileURL = fileURL.replacingOccurrences(of: "/var/www/html", with: "http://159.203.67.188/")
        print(fileURL)

        webView.loadRequest(URLRequest(url: URL(string: (fileURL))!))
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePressed))
        self.navigationItem.rightBarButtonItem = saveButton
    }

    @objc func savePressed(sender: UIBarButtonItem){
        let alert = UIAlertController(title: "Save PDF", message: "Save " + (currentForm?.title)! + "?", preferredStyle: .actionSheet)
        
        let SaveAction = UIAlertAction(title: "Save", style: .default, handler: handleSave)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelSave)
        
        alert.addAction(SaveAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)

    }
    
    func handleSave(alertAction: UIAlertAction!) -> Void {
        //Save to Database
        
        let alertController = UIAlertController(title: "Saved", message: (currentForm?.title)! + " has been saved!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated:true, completion:nil)
        
    }
    
    func cancelSave(alertAction: UIAlertAction!) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func printPDF(sender:AnyObject?) {
        let data = self.document?.documentPath
        
        let savedVCDocument = ILPDFDocument(path: data!)
        
        let alert : UIAlertController = UIAlertController(title: "Save PDF", message: "The PDF file displayed next is a static version of the previous file, but with the form values added. The starting PDF has not been modified and this static pdf no longer contains forms.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Show Saved Static PDF", style: .default) { (_ : UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            self.document = savedVCDocument
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
        
        alert.addAction(action)
        self.present(alert, animated:true, completion:nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
