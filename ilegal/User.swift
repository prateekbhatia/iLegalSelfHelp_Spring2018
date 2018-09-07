//
//  User.swift
//  ilegal
//
//  Created by ITP on 9/14/16.
//  Copyright © 2016 Jordan. All rights reserved.
//

import UIKit

open class User: NSObject {
    
    // MARK: - Properties
    
    static var currentUser = User()
    var email:String!
    var password:String!
    var firstName:String!
    var lastName:String!
    var middleInitial:String?
    var addressOne:String!
    var addressTwo:String!
    var city:String!
    var state:String!
    var zipcode:String!
    var phone:String!
    var license:String!
    var active:Bool!
    var DOB:String!
    var id:String!
    var myFiles = [Form]()
    var chat_id:String!
    var customer_id:String!
    
    var dictionaryValue: [String : Any] {
        return [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "middleInitial": middleInitial ?? "",
            "addressOne": addressOne,
            "addressTwo": addressTwo,
            "city": city,
            "state": state,
            "zipcode": zipcode,
            "phone": phone,
            "license": license,
            "active": active,
            "DOB": DOB,
            "id": id,
            "customer_id": customer_id,
        ]
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    // MARK: - Initializers
    
    override init() {
        email = ""
        password = ""
        firstName = ""
        lastName = ""
        middleInitial = ""
        addressOne = ""
        addressTwo = ""
        city = ""
        state = ""
        zipcode = ""
        phone = ""
        license = ""
        DOB = "0000-00-00"
        active = false;
        id = ""
        chat_id = ""
        customer_id = ""
    }
    
    init(dictionary: [String : Any]) {
        email = dictionary["email"] as! String
        password = dictionary["email"] as! String
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        middleInitial = dictionary["middleInitial"] as? String
        addressOne = dictionary["addressOne"] as! String
        addressTwo = dictionary["addressTwo"] as! String
        city = dictionary["city"] as! String
        state = dictionary["state"] as! String
        zipcode = dictionary["zipcode"] as! String
        phone = dictionary["phone"] as! String
        license = dictionary["license"] as! String
        active = dictionary["active"] as! Bool
        DOB = dictionary["DOB"] as! String
        id = dictionary["id"] as! String
        customer_id = dictionary["customer_id"] as! String
    }
    
    // MARK: - Methods
    
    func saveLocal() {
        UserDefaults.standard.set(dictionaryValue, forKey: "user")
        UserDefaults.standard.synchronize()
    }
    
    func setBirthday(_ month: String, day: String, year: String){
        self.DOB = year + "-" + month + "-" + day
    }
    
    func printUser()
    {
        print(self.firstName)
        print(self.lastName)
        print(self.middleInitial)
        print(self.email)
        print(self.password)
        print(self.addressOne)
        print(self.addressTwo)
        print(self.city)
        print(self.state)
        print(self.zipcode)
        print(self.phone)
        print(self.license)
        print(self.DOB)
    }
}


