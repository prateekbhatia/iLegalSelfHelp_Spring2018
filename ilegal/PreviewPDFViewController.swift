//
//  PreviewPDFViewController.swift
//  ilegal
//
//  Created by ITP on 9/15/16.
//  Copyright © 2016 Jordan. All rights reserved.
//

import UIKit

class PreviewPDFViewController: UIViewController {

    @IBOutlet weak var pdfWebView: UIWebView!
    @IBOutlet weak var fillOutButton: UIButton!
    var destination:EditPDFViewController! = nil
    var currentForm:Form? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfWebView.loadRequest(URLRequest(url: URL(string: "http://159.203.67.188/pdfs/\(currentForm!.location!)")!))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Fill Out", style: .plain, target: self, action: #selector(FillOutButtonTapped))
    }

    func FillOutButtonTapped() {
        performSegue(withIdentifier: "fillOutSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fillOutSegue" {
            // for scroll view
            let destination = segue.destination as! EditPDFViewController
            destination.title = self.title
            let backItem = UIBarButtonItem()
            backItem.title = ""
            destination.currentForm = self.currentForm
            destination.navigationItem.backBarButtonItem = backItem
            
            // for progress bar
            // (segue.destination as! EditPDFViewController2).form = currentForm
        }
    }

}
