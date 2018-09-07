//
//  ViewPDFViewController.swift
//  ilegal
//
//  Created by Tae Ha Lee on 10/16/16.
//  Copyright © 2016 Jordan. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire

class ViewPDFViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var webView: UIWebView!
    var currentForm:Form? = nil
    var formData:NSData!
    var formURL:NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currentForm?.location = currentForm?.location.replacingOccurrences(of: "/var/www/html/", with: "http://159.203.67.188/")
        webView.loadRequest(URLRequest(url: URL(string: (currentForm?.location)!)!))

        do {
            formURL = NSURL(string: (currentForm?.location)!)
            formData = try NSData(contentsOf: formURL as URL, options: NSData.ReadingOptions())
        } catch {
            print(error)
        }
        let optionItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(optionsPressed))

        self.navigationItem.rightBarButtonItem = optionItem
    }
    
    @objc func optionsPressed(sender:UIBarButtonItem){
        /*
        let alert = UIAlertController(title: "Options", message: "Download or Email " + (currentForm?.title)! + "?", preferredStyle: .actionSheet)
        
        let DownloadAction = UIAlertAction(title: "Download", style: .default, handler: downloadPressed)
        let EmailAction = UIAlertAction(title: "Email", style: .default, handler: emailPressed)
        let CancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(DownloadAction)
        alert.addAction(EmailAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
 */
        let activityVC = UIActivityViewController(activityItems:[formData], applicationActivities:nil)
        if let popoverPresentationController = activityVC.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        present(activityVC, animated: true, completion: nil)
        
    }
    
    func downloadPressed(alertAction: UIAlertAction!) -> Void {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download("http://www.courts.ca.gov/documents/sc100.pdf", to: destination)
            .responseData { response in
                print("RESPONSE: \(response)")
                if response.result.value != nil {
                    let alertController = UIAlertController(title: "Download Completed", message: "Download of \(self.currentForm?.title) has been completed.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated:true, completion:nil)
                }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        //mailComposerVC.setToRecipients([contactEmail])
        //mailComposerVC.setSubject(subjectTF.text!)
        //mailComposerVC.setMessageBody(messageBodyTF.text!, isHTML: false)
        if(formData != nil){
            mailComposerVC.addAttachmentData(formData as Data, mimeType: "\(currentForm?.location)", fileName: (currentForm?.title)! as String)
        }
        return mailComposerVC
    }
    
    func emailPressed(alertAction: UIAlertAction!) -> Void {
        
        //Download file and store in formData
        //TESTING - DELETE LATER
        let path = Bundle.main.path(forResource: "SmallClaims", ofType: "pdf")
        let url = URL(string: path!)
        print(url!.absoluteString)
        do {
            self.formData = try Data(contentsOf: url!) as NSData!
        } catch {
            print(error)
        }
        /*
        Alamofire.download(url!.absoluteString).responseData { response in
            if let data = response.result.value {
                print("HERE")
                self.formData = Data(contentsOf: url)
            }
        }
 */
        //Launch email view controller
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else
        {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert(){
        let sendMailErrorAlert = UIAlertController(title: "Email Could Not Be Sent", message: "Your device could not send email. Please check email and/or network configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        sendMailErrorAlert.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(sendMailErrorAlert, animated:true, completion:nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
