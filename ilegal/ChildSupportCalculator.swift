//
//  ChildSupportCalculator.swift
//  ilegal
//
//  Created by Prateek Bhatia on 3/16/18.
//

import UIKit

class ChildSupportCalculator: UIViewController {

    fileprivate var questions = [String]()

    @IBOutlet weak var oneAnswerField: UITextField!
    @IBOutlet weak var twoAnswerField: UITextField!
    @IBOutlet weak var threeAnswerField: UITextField!
    @IBOutlet weak var fourAnswerField: UITextField!
    @IBOutlet weak var fiveAnswerField: UITextField!
    @IBOutlet weak var sixAnswerField: UITextField!
    @IBOutlet weak var sevenAnswerField: UITextField!
    @IBOutlet weak var eightAnswerField: UITextField!




    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Child Support Calculator"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(calculateChildSupport))

    }

    @objc func calculateChildSupport() {

        if oneAnswerField.hasText, twoAnswerField.hasText, threeAnswerField.hasText, fourAnswerField.hasText, fiveAnswerField.hasText, sixAnswerField.hasText, sevenAnswerField.hasText, eightAnswerField.hasText {

            Backend.calculateChildSupport(withChildrenCount: oneAnswerField.text, non_custodial_income: twoAnswerField.text, non_custodial_support: threeAnswerField.text, non_custodial_insurance: fourAnswerField.text, non_custodial_time: fiveAnswerField.text, custodial_income: sixAnswerField.text, custodial_support: sevenAnswerField.text, custodial_insurance: eightAnswerField.text, completion: { (value, error) in
                if let value = value {
                    let alertController = UIAlertController(title: "\(value)", message: "Under this scenario, your monthly child support payment would be \(value)", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated:true, completion:nil)
                } else {
                    let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated:true, completion:nil)
                }
            })

        } else {
            let alertController = UIAlertController(title: "Error", message: "Incomplete fields", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated:true, completion:nil)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
