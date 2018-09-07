//
//  EditPDFViewController.swift
//  ilegal
//
//  Created by ITP on 10/13/16.
//  Copyright © 2016 Jordan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class EditPDFViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    var currentForm:Form? = nil
    var json:JSON = []
    var resultJSON:JSON = []
    
    //Store all fields in its corresponding type array
    var TFArray = [PDFTextField]()
    var YesNoArray = [YesNoButton]()
    var OptionArray = [CheckBoxGroup]()
    var ChArray = [DropdownPickerView]()
    var ChData = Dictionary<Int,Array<String>>()
    var ChTF = Dictionary<Int,UITextField>()
    var PVTAG:Int = 1;

    @IBOutlet weak var scrollView: UIScrollView!
    var textFieldDict:[String:UITextField] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        self.navigationItem.rightBarButtonItem = doneItem
        // Do any additional setup after loading the view.
        
        parseJSON()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func donePressed(sender: UIBarButtonItem){
        //Send POST Request to server
        updateJSON()

        let parameters:Parameters = [
            "PDFID":currentForm!.id.utf8.description,
            "USERID":User.currentUser.id.utf8.description,
            "pdfJsonResults":self.resultJSON
        ]
        
         Alamofire.request("http://159.203.67.188:8080/Dev/FinPDF?", method: .post, parameters: parameters).responseJSON { response in
            switch response.result{
            case .success(let value):
            let outcome = JSON(value)
            print("here matt")
            print(outcome)
            if(outcome["Success"].boolValue == true){
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let destination = storyboard.instantiateViewController(withIdentifier: "DonePDFViewController") as! DonePDFViewController
                destination.title = self.title
                destination.currentForm = self.currentForm
                destination.fileURL = outcome["FileURL"].string!
                let backItem = UIBarButtonItem()
                backItem.title = ""
                destination.navigationItem.backBarButtonItem = backItem
                self.navigationController?.pushViewController(destination, animated: true)

            } else{
                let alertController = UIAlertController(title: "Error", message: "Completed form could not be created. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated:true, completion:nil)
            }
            case .failure(let error):
                let alertController = UIAlertController(title: "Error", message: "Completed form could not be created. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated:true, completion:nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func parseJSON() {
        //Load json file in path
        
            var yAxis = -40;
            Alamofire.request("http://159.203.67.188:8080/Dev/FillPDF?PdfID=\(currentForm!.id!)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    self.json = JSON(value)
                    let fields = self.json["Fields"]
                    for (key,subJson):(String, JSON) in fields {
                        if(subJson["type"].exists()){
                            //Create Label
                            let tempLabel = UILabel(frame: CGRect(x: 20, y: yAxis, width: 350, height: 40))
                            tempLabel.font = UIFont.systemFont(ofSize:15)
                            tempLabel.text = subJson["name"].string
                            tempLabel.numberOfLines = 0
                            tempLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                            tempLabel.sizeToFit()
                            self.scrollView.addSubview(tempLabel)
                            yAxis = yAxis + Int(tempLabel.frame.height) + 10
                            
                            if subJson["type"] == "Tx" {
                                //Create TextField
                                let tempTF = PDFTextField(frame: CGRect(x: 40, y: yAxis, width: 300, height: 40))
                                tempTF.font = UIFont.systemFont(ofSize: 14)
                                tempTF.borderStyle = UITextBorderStyle.roundedRect
                                tempTF.text = subJson["value"].string
                                tempTF.title = subJson["name"].string!
                                tempTF.index = Int(key)!
                                self.textFieldDict[tempTF.title] = tempTF
                                self.scrollView.addSubview(tempTF)
                                self.TFArray.append(tempTF)
                                //Autofill User Information
                                if(subJson["name"] == "First Name"){
                                    tempTF.text = User.currentUser.firstName
                                } else if(subJson["name"] == "Last Name"){
                                    tempTF.text = User.currentUser.lastName
                                } else if(subJson["name"] == "Full Name" || subJson["name"] == "Your Name"){
                                    if(User.currentUser.middleInitial == ""){
                                        tempTF.text = User.currentUser.firstName + " " + User.currentUser.middleInitial! + " " + User.currentUser.lastName
                                    } else{
                                        tempTF.text = User.currentUser.firstName + " " + User.currentUser.lastName
                                    }
                                } else if(subJson["name"] == "Middle Initial"){
                                    tempTF.text = User.currentUser.middleInitial
                                } else if(subJson["name"] == "Address One"){
                                    tempTF.text = User.currentUser.addressOne
                                } else if(subJson["name"] == "Address Two"){
                                    tempTF.text = User.currentUser.addressTwo
                                } else if(subJson["name"] == "Email"){
                                    tempTF.text = User.currentUser.email
                                } else if(subJson["name"] == "City"){
                                    tempTF.text = User.currentUser.city
                                } else if(subJson["name"] == "State"){
                                    tempTF.text = User.currentUser.state
                                } else if(subJson["name"] == "Zip"){
                                    tempTF.text = User.currentUser.zipcode
                                } else if(subJson["name"] == "Phone Number"){
                                    tempTF.text = User.currentUser.phone
                                }
                                yAxis += 50
                            } else if subJson["type"] == "Btn" {
                                //Create List of Switch
                                let buttonTitle = subJson["value"].array
                                let buttonGroup = CheckBoxGroup()
                                for option in buttonTitle! {
                                    let checkBox = CheckBox(frame: CGRect(x: 40, y: yAxis, width: 70, height:40))
                                    checkBox.label = option.string!
                                    let checkBoxLabel = UILabel(frame: CGRect(x: 105, y: yAxis-5, width: 150, height: 40))
                                    checkBoxLabel.text = option.string!
                                    buttonGroup.buttons.append(checkBox)
                                    buttonGroup.title = subJson["name"].string!
                                    buttonGroup.index = Int(key)!
                                    self.scrollView.addSubview(checkBox)
                                    self.scrollView.addSubview(checkBoxLabel);
                                    
                                    yAxis += 40
                                }
                                
                                for i in 0...buttonGroup.buttons.count-1{
                                    for j in 0...buttonGroup.buttons.count-1{
                                        if (buttonGroup.buttons[i] != buttonGroup.buttons[j]){
                                            buttonGroup.buttons[i].alternateOptions.append(buttonGroup.buttons[j])
                                        }
                                    }
                                }
                                self.OptionArray.append(buttonGroup)
                                
                            } else if subJson["type"] == "Ch" {
                                let tempPicker = DropdownPickerView()
                                tempPicker.delegate = self
                                tempPicker.dataSource = self
                                tempPicker.tag = self.PVTAG
                                tempPicker.title = subJson["name"].string!
                                tempPicker.index = Int(key)!
                                self.PVTAG += 1
                                let tempTF = UITextField(frame: CGRect(x: 40, y: yAxis, width: 300, height: 40))
                                tempTF.inputView = tempPicker
                                tempTF.font = UIFont.systemFont(ofSize: 14)
                                tempTF.borderStyle = UITextBorderStyle.roundedRect
                                self.ChArray.append(tempPicker)
                                //Parse Values from subJson["value"]
                                let pValues = subJson["value"].array
                                var pickerValues = [String]()
                                pickerValues.append("")
                                for temp in pValues!{
                                    pickerValues.append(temp.string!)
                                }
                                //Add Done Button to UIPickerView
                                let toolBar = UIToolbar()
                                toolBar.barStyle = UIBarStyle.default
                                toolBar.isTranslucent = true
                                toolBar.tintColor = UIColor(red :76/255, green: 17/225, blue: 100/225, alpha: 1)
                                toolBar.sizeToFit()
                                
                                let doneButton = UIBarButtonItem(title:"Done", style:UIBarButtonItemStyle.plain, target:self, action:#selector(self.donePicker))
                                let flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
                                toolBar.setItems([flexibleSpaceLeft, doneButton],animated:false)
                                toolBar.isUserInteractionEnabled = true
                                tempTF.inputAccessoryView = toolBar
                                self.ChData[tempPicker.tag] = pickerValues
                                self.ChTF[tempPicker.tag] = tempTF
                                tempPicker.dataTF = tempTF
                                self.scrollView.addSubview(tempTF)
                                //Autofill User Information
                                if(subJson["name"].stringValue == "State"){
                                    tempTF.text = User.currentUser.state
                                } else if(subJson["name"].stringValue == "Birth Date"){
                                    
                                }
                                yAxis += 40
                            } else if subJson["type"] == "yesNo" {
                                let yesButton = YesNoButton(frame: CGRect(x: 40, y: yAxis, width: 150, height: 30))
                                let noButton = YesNoButton(frame: CGRect(x:200, y: yAxis, width:150, height: 30))
                                yesButton.backgroundColor = UIColor.lightGray
                                yesButton.setTitle("Yes", for: UIControlState.normal)
                                yesButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                                yesButton.addTarget(self, action: #selector(self.yesNoButtonSelected), for: .touchUpInside)
                                yesButton.title = subJson["name"].string!
                                yesButton.index = Int(key)!
                                noButton.backgroundColor = UIColor.lightGray
                                noButton.setTitle("No", for: UIControlState.normal)
                                noButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                                noButton.addTarget(self, action: #selector(self.yesNoButtonSelected), for: .touchUpInside)
                                noButton.title = subJson["name"].string!
                                noButton.index = Int(key)!
                                yesButton.alternateButton.append(noButton)
                                noButton.alternateButton.append(yesButton)
                                self.scrollView.addSubview(yesButton)
                                self.scrollView.addSubview(noButton)
                                yAxis += 40
                                self.YesNoArray.append(yesButton)
                            }
                        }
                        self.scrollView.contentSize = CGSize(width: self.view.intrinsicContentSize.width, height: CGFloat(yAxis+20))
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    //Create JSON with updated values
    func updateJSON(){
        
        //Nicky's Way
        var result = Dictionary<String, Any>()
        
        //Text Fields (Tx)
        for field:PDFTextField in self.TFArray {
            result[field.title.utf8.description] = ["type":"Tx".utf8.description,"value":field.text!.utf8.description]
        }
        
        //Check Box (Btn)
        for buttonGroup:CheckBoxGroup in self.OptionArray {
            var checkedButtons = [String]()
            for button:CheckBox in buttonGroup.buttons{
                if button.isOn {
                    checkedButtons.append(button.label.utf8.description)
                }
            }
             result[buttonGroup.title.utf8.description] = ["type":"Btn".utf8.description,"value":checkedButtons]
        }
        
        //Dropdown Menu (Ch)
        for picker in ChArray {
            var output = [String]()
            output.append((picker.dataTF?.text!)!.utf8.description)
           result[picker.title.utf8.description] = ["type":"Ch".utf8.description,"value":output]
        }
        
        //YesNo Button
        for button:YesNoButton in self.YesNoArray{
            result[button.title.utf8.description] = ["type":"yesNo".utf8.description,"value":button.value.utf8.description]
        }
        
        self.resultJSON = JSON(result)
        
    }
    
    @objc func yesNoButtonSelected(sender:YesNoButton){
        if(sender.value == "yes"){
            sender.value = "no"
            for i in 0...sender.alternateButton.count-1 {
                sender.alternateButton[i].value = "no"
            }
        } else {
            sender.value = "yes"
            for i in 0...sender.alternateButton.count-1 {
                sender.alternateButton[i].value = "yes"
            }
        }
        if(sender.backgroundColor == UIColor.blue){
            sender.backgroundColor = UIColor.lightGray
            for i in 0...sender.alternateButton.count-1 {
                sender.alternateButton[i].backgroundColor = UIColor.blue
            }
            sender.isSelected = false
            for i in 0...sender.alternateButton.count-1 {
                sender.alternateButton[i].isSelected = true
            }
        } else{
            sender.backgroundColor = UIColor.blue
            for i in 0...sender.alternateButton.count-1 {
                sender.alternateButton[i].backgroundColor = UIColor.lightGray
            }
            sender.isSelected = true
            for i in 0...sender.alternateButton.count-1 {
                sender.alternateButton[i].isSelected = false
            }
        }
    }

    
    //PICKER VIEW
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ChData[pickerView.tag]!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        ChTF[pickerView.tag]?.text = String(describing: (ChData[pickerView.tag]?[row])!)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ChData[pickerView.tag]?[row]
    }
    
    @objc func donePicker(){
        for picker in ChArray {
            picker.dataTF?.resignFirstResponder()
        }
    }

    func autofill(){
        
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
