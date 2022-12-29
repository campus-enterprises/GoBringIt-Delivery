//
//  CheckPhoneVerificationVC.swift
//  BringIt
//
//  Created by Joshua Young on 5/18/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import RealmSwift
import Moya

class CheckNetIDVerificationVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    var user = User()
    
    let defaultButtonText = "I clicked the link!"

    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        // Setup UI
        setupUI()
        setupRealm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Get current User
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = realm.objects(User.self).filter(predicate).first!
    }
    
    func setupUI() {
        
        // Set title
        self.title = "Verify NetID"
        
        // Setup text field and button UI
        continueButton.layer.cornerRadius = Constants.cornerRadius
        
        // Set up custom back button
        setCustomBackButton()
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    @IBAction func signOutUser(_ sender: UIButton) {
        
        let realm = try! Realm() // Initialize Realm
        
        // Update UserDefaults' "loggedIn" property to false
        self.defaults.set(false, forKey: "loggedIn")
        self.defaults.set(false, forKey: "netIdVerified")
        
        // Set current Realm user's active property to false
        try! realm.write {
            user.isCurrent = false
        }
        
        self.performSegue(withIdentifier: "exitSegue", sender: self)
    }
    
    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        print("Button tapped")
        // Check that all fields are filled and correctly formatted, else return
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.checkNetIDVerificationCode(uid: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    print("Did a request")
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Check Verification Response: \(response)")
                    
                    // Check response from backend
                    let successResponse = response["success"] as? Int
                    if successResponse == 1 {
                        // Successfully received server response
                        print("Successfully received server response")
                        self.defaults.set(true, forKey: "netIdVerified")
                        self.performSegue(withIdentifier: "unwindNetIdSegue", sender: self)
                    } else {
                        // User already exists
                        self.showError(button: self.continueButton, error: .invalidNetIDVerification)
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                            self.hideErrorWhite(button: self.continueButton, defaultButtonText: self.defaultButtonText)
                        }
                    }
                } catch {
                    // Miscellaneous network error
                    self.showError(button: self.continueButton, error: .networkError)
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                        self.hideErrorWhite(button: self.continueButton, defaultButtonText: self.defaultButtonText)
                    }
                }
            case .failure(_):
                // Connection failed
                self.showError(button: self.continueButton, error: .connectionFailed)
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                    self.hideErrorWhite(button: self.continueButton, defaultButtonText: self.defaultButtonText)
                }
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
    
}
