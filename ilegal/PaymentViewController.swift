//
//  PaymentViewController.swift
//  ilegal
//
//  Created by Prateek Bhatia on 2/10/18.
//
//

import UIKit
import Stripe

class PaymentViewController: UIViewController, STPPaymentContextDelegate, UITextFieldDelegate {

    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var cardNameButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var makePaymentButton: UIButton!
    
    @IBOutlet weak var descriptionTextView: UITextView!

    var paymentContext: STPPaymentContext!

    @IBOutlet weak var bottomLayout: NSLayoutConstraint!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.amountTextField.layer.borderWidth = 0

        self.stackView.layer.cornerRadius = 2
        self.stackView.layer.borderWidth = 1
        self.stackView.layer.borderColor = UIColor.lightGray.cgColor


        self.navigationController?.navigationBar.barTintColor = UIColor(red: 84.0/255.0, green: 144.0/255.0, blue: 200.0/255.0, alpha:1.0)



        //self.navigationController?.navigationBar.barTintColor = UIColor(red: 113.0/255.0, green: 158.0/255.0, blue: 255.0/255.0, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]

        self.paymentContext = STPPaymentContext(customerContext: Customer.customerContext)

        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification: )), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: NSNotification)
    {

        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                bottomLayout.constant = keyboardSize.height
                view.setNeedsLayout()
            }
        }

    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
        bottomLayout.constant = 0
        view.setNeedsLayout()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeCard(_ sender: UIButton) {
        self.paymentContext?.presentPaymentMethodsViewController()
    }

    @IBAction func makePaymentClicked(_ sender: Any) {

        self.paymentContext?.requestPayment()

//        let alert = UIAlertController(title: "Transaction", message:
//"Successful", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
//            switch action.style{
//            case .default:
//                print("default")
//
//            case .cancel:
//                print("cancel")
//
//            case .destructive:
//                print("destructive")
//
//
//            }}))
//
//        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {

        self.makePaymentButton.isEnabled = paymentContext.selectedPaymentMethod != nil
        self.cardNameButton.setTitle(paymentContext.selectedPaymentMethod?.label ?? "Add Card", for: UIControlState.normal)
        if let image = paymentContext.selectedPaymentMethod?.image {
            self.cardImageView.image = image
        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext,
                        didCreatePaymentResult paymentResult: STPPaymentResult,
                        completion: @escaping STPErrorBlock) {

        APIClient.sharedClient.completeCharge(paymentResult, amount: 500, description: descriptionTextView.text, completion: { (error: Error?) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }

    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFailToLoadWithError error: Error) {
        //Temporary commented out
        self.navigationController?.popViewController(animated: true)
        // Show the error to your user, etc.
        print ("HERE \(error.localizedDescription)")
    }

    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFinishWith status: STPPaymentStatus,
                        error: Error?) {

        switch status {
        case .error:
            self.showError(error: error)
//            print(error?.localizedDescription)
        case .success:
            self.showReceipt()
//            print("receipt")
        case .userCancellation:
            return // Do nothing
        }
    }

    func showError(error: Error?) {
        let alert = UIAlertController(title: "Error", message:
            error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")


            }}))

        self.present(alert, animated: true, completion: nil)
    }

    func showReceipt() {
        let alert = UIAlertController(title: "Transaction", message:
          "Successful", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")


            }}))

        self.present(alert, animated: true, completion: nil)
    }
//
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let fedEx = PKShippingMethod()
        fedEx.amount = 5.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"

        if address.country == "US" {
            completion(.valid, nil, [upsGround, fedEx], upsGround)
        }
        else {
            completion(.invalid, nil, nil, nil)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        var text = textField.text!

        if text.starts(with: "$") {
            text = text.substring(from: 1)
        } else if text.isEmpty {
            text = "0.00"
        }

        text = "$" + text

        textField.text = text

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        var text = textField.text!

        if !text.contains(".") && !text.isEmpty {
            text.append(".00")
        }
        textField.text = text
    }

}
