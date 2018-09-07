//
//  Backend.swift
//  ilegal
//
//  Created by Matthew Rigdon on 2/7/17.
//  Copyright © 2017 Jordan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Stripe
import SwiftSoup

struct Customer {
    static var customerContext: STPCustomerContext!
}

class Backend: NSObject {
    
    // MARK: - Inner definitions
    
    private enum ServerError: Int {
        case noError = 0
        case badSQLConnection = 1
        case sqlUpdateFailed = 2
    }
    
    // MARK: - Properties
    
    static let basicErrorMessage = "Something went wrong, please try again later."
    
    private static let rootURL = "http://159.203.67.188:8080/Dev"
    
    // MARK: - Functions
    
    static func login(username: String, password: String, completion: @escaping (_ error: String?) -> Void) {
        //FIX THIS

        APIClient.sharedClient.retrieveCustomer(withEmail: User.currentUser.email, completion: {json,error in

            if error == nil {
                User.currentUser.customer_id = json!["id"] as! String
            } else {
                print(error?.localizedDescription)
            }
        })

        Alamofire.request("\(rootURL)/SignIn?Username=\(username)&Password=\(password)").responseJSON { response in
            switch response.result {
            case .success(let value):
                let outcome = JSON(value)
                if(outcome["Success"].intValue == 1){
                    //Log-In and go to CategoriesViewController
                    User.currentUser.firstName = outcome["FirstName"].stringValue
                    if(!outcome["MiddleInitial"].stringValue.isEmpty){
                        User.currentUser.middleInitial = outcome["MiddleInitial"].stringValue
                    } else{
                        User.currentUser.middleInitial = ""
                    }
                    User.currentUser.lastName = outcome["LastName"].stringValue
                    User.currentUser.email = outcome["EmailAddress"].stringValue
                    User.currentUser.password = outcome["Password"].stringValue
                    User.currentUser.addressOne = outcome["Address1"].stringValue
                    if(!outcome["Address2"].stringValue.isEmpty){
                        User.currentUser.addressTwo = outcome["Address2"].stringValue
                    } else {
                        User.currentUser.addressTwo = ""
                    }
                    User.currentUser.city = outcome["City"].stringValue
                    User.currentUser.state = outcome["State"].stringValue
                    User.currentUser.zipcode = outcome["PostalCode"].stringValue
                    User.currentUser.phone = outcome["PhoneNumber"].stringValue
                    User.currentUser.license = outcome["LicenseNumber"].stringValue
                    User.currentUser.DOB = outcome["DOB"].stringValue
                    User.currentUser.id = outcome["UserId"].stringValue
                    
                    //pull User's Saved Files
                    Backend.getSavedFiles()

                    completion(nil)
                } else{
                    // Password/Username is incorrect
                    completion("The Username and/or Password does not match our records, or you are not registered. Please try again.")
                }
            case .failure:
                // Password/Username is incorrect
                completion("The Username and/or Password does not match our records, or you are not registered. Please try again.")
            }
            
        }
    }
    
    static func saveUserLocal() {
        
        UserDefaults.standard.set(User.currentUser.dictionaryValue, forKey: "user")
        UserDefaults.standard.synchronize()

        //Initialize customer context for Stripe
        Customer.customerContext = STPCustomerContext(keyProvider: APIClient.sharedClient)
    }
    
    static func clearUserLocal() {
        User.currentUser = User()
        UserDefaults.standard.set(nil, forKey: "user")
        UserDefaults.standard.synchronize()
    }
    
    static func getSavedFiles(completion: ((_ error: String?) -> Void)? = nil) {
        Alamofire.request("\(rootURL)/ListPDF?Type=4&UserUniqueID=\(User.currentUser.id)").responseJSON { response in
            switch response.result {
            case .success(let value):
                var outcome = JSON(value)
                if(outcome["Success"].boolValue == true){
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
                        completion?(nil)
                    }
                }
            case .failure:
                completion?(basicErrorMessage)
            }
        }
    }
    
    static func getCategories(completion: @escaping (_ categories: [String]?) -> Void) {
        let path = Bundle.main.path(forResource: "Categories", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: url)
        let json = try! JSON(data: data)
        completion(json["Categories"].arrayObject as? [String])
    }
    
    static func getItems(fromCategory category: String, completion: @escaping (_ forms: [Form]?) -> Void) {
        Alamofire.request("\(rootURL)/ListPDF?Type=2&Category=\(category)").responseJSON { response in
            switch response.result {
            case .success(let value):
                let outcome = JSON(value)
                var list = outcome["PDFS"].arrayObject
                let pdfCount:Int = (list?.count)!
                var formList = [Form]()
                for i in 0..<pdfCount {
                    var current = list?[i] as! [String]
                    let tempPDF:Form = Form()
                    tempPDF.title = current[0]
                    tempPDF.location = current[1]
                    tempPDF.id = current[2]
                    formList.append(tempPDF)
                }
                formList.sort { $0.title < $1.title }
                completion(formList)
            case .failure:
                completion(nil)
            }
        }
    }
    
    static func updateUser(fieldToChange field: String, withNewValue value: String, completion: @escaping (_ error: String?) -> Void) {
        let parameters: Parameters = [
            "Id": User.currentUser.id,
            "FieldToChange": field,
            "NewValue": value
        ]
        Alamofire.request("\(rootURL)/UpdateUser?", method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                let data = JSON(value)
                let errorCode = ServerError(rawValue: data["ErrorCode"].intValue)
                if let errorCode = errorCode {
                    switch errorCode {
                    case .noError:
                        // success
                        let changedField = data["ChangedField"].stringValue
                        if changedField == "Email" {
                            User.currentUser.email = data["NewValue"].stringValue
                        } else if changedField == "FirstName" {
                            User.currentUser.firstName = data["NewValue"].stringValue
                        } else if changedField == "MiddleName" {
                            User.currentUser.middleInitial = data["NewValue"].stringValue
                        } else if changedField == "LastName" {
                            User.currentUser.lastName = data["NewValue"].stringValue
                        } else if changedField == "Address1" {
                            User.currentUser.addressOne = data["NewValue"].stringValue
                        } else if changedField == "City" {
                            User.currentUser.city = data["NewValue"].stringValue
                        } else if changedField == "State" {
                            User.currentUser.state = data["NewValue"].stringValue
                        } else if changedField == "ZipCode" {
                            User.currentUser.zipcode = data["NewValue"].stringValue
                        }
                        saveUserLocal()
                        completion(nil)
                    case .badSQLConnection:
                        completion("Unable to connect to database. Please try again later.")
                    case .sqlUpdateFailed:
                        completion("Unable to update information right now. Please try again later.")
                    }
                } else {
                    completion(basicErrorMessage)
                }
            case .failure:
                completion(basicErrorMessage)
            }
        }
    }
    
    static func getPDF(withID id: String, completion: @escaping (_ questions: [String]?, _ error: String?) -> Void) {
        let parameters: Parameters = [
            "PdfID": id
        ]
        Alamofire.request("\(rootURL)/FillPDF?", method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                let data = JSON(value)
                var questions = [String]()
                for (_, json): (String, JSON) in data["Fields"] {
                    if json["type"].exists() {
                        questions.append(json["name"].stringValue)
                    }
                }
                completion(questions, nil)
            case .failure:
                completion(nil, basicErrorMessage)
            }
        }
    }

    static func calculateChildSupport(withChildrenCount children_count: String!, non_custodial_income: String!,                                       non_custodial_support: String!,
        non_custodial_insurance: String!,
        non_custodial_time: String!,
        custodial_income: String!,
        custodial_support: String!,
        custodial_insurance: String!, completion: @escaping (_ value: String?, _ error: String?)->Void) {
        let parameters: Parameters = [
            "children_count": children_count,
            "non_custodial_income": non_custodial_income,
            "non_custodial_support": non_custodial_support,
            "non_custodial_insurance": non_custodial_insurance,
            "non_custodial_time": non_custodial_time,
            "custodial_income": custodial_income,
            "custodial_support": custodial_support,
            "custodial_insurance": custodial_insurance,
        ]

        Alamofire.request("http://www.alllaw.com/calculators/ChildSupport/california", method: .post, parameters: parameters).responseString { response in
            switch response.result {
            case .success(let value):
                let doc: Document = try! SwiftSoup.parse(value)

                //Handle error 
                let link: Element = try! doc.getElementById("calculator-result")!

                completion(try? link.text(), nil)

            case .failure:
                completion(nil, basicErrorMessage)

            }
        }
    }
    
}
