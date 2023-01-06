//
//  EnterPinPopUpVC.swift
//  BringIt
//
//  Created by Young, Joshua on 7/6/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import Moya

class PromoCodeVC: UIViewController {
    

    @IBOutlet var popupView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var promoField: UITextField!
    var order = Order()
    var user = User()
    let realm = try! Realm() // Initialize Realm
    let defaultButtonText = "Submit"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        promoField.text! = order.promoCode

        promoField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
//
//
    @IBAction func pinSubmitTouched(_ sender: Any) {
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        if (promoField.text! == "") {
            print("Cleared promo code")
            try! realm.write {
                order.promoCode = ""
                order.discount = 0.0
            }
            promoField.text = ""
            self.performSegue(withIdentifier: "unwindPromoCodeSegue", sender: self)
            return
        }
        
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.checkPromoCode(uid: String(user.id), restaurantID: order.restaurantID, paymentType: String(order.paymentMethod?.paymentMethodID ?? -1), amount: String(order.subtotal), promoCode: promoField.text!)) { [self] result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    print(moyaResponse)
                    
                    print("unwrapping")
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Check Promo Code Response: \(response)")
                    
                    // Check response from backend
                    let successResponse = response["status"] as? String
                    if successResponse == "success" && response["discount"] as? Double != 0.0 {
                        // Successfully received server response
                        print("Successfully added promo code")
                        print(response["discount"])
                        try! realm.write {
                            order.discount = response["discount"] as! Double
                            order.promoCode = promoField.text!
                        }
                        promoField.text = ""
                        self.performSegue(withIdentifier: "unwindPromoCodeSegue", sender: self)
                    } else {
                        // User already exists
                        self.showError(button: self.submitButton, error: .invalidPromoCode)
                    }
                } catch {
                    // Miscellaneous network error
                    self.showError(button: self.submitButton, error: .networkError, defaultButtonText: self.defaultButtonText)
                }
            case .failure(_):
                // Connection failed
                self.showError(button: self.submitButton, error: .connectionFailed, defaultButtonText: self.defaultButtonText)
            }
        }
    }
//
    func checkFields() -> Bool {

//        // Check for empty fields
//        if (pinTextField.text?.isBlank)! {
//            showError(button: submitButton, error: .fieldEmpty)
//            return false
//        }
//
//        // Check for correct input type
//        if pinTextField.text?.isNumber == false {
//            showError(button: submitButton, error: .nonNumerical)
//            return false
//        }
//
//        // Check for correct input lengths
//        if pinTextField.text?.count != 4 {
//            showError(button: submitButton, error: .invalidInput)
//            return false
//        }
//
        hideError(button: submitButton, defaultButtonText: self.defaultButtonText)
//
        return true
    }
//
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
//
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
//

}
