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

class DeleteAccountVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var deletionButton: UIButton!
    let defaults = UserDefaults.standard // Initialize UserDefaults
    var user = User()
    
    let defaultButtonText = "Delete Account"

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
        self.title = "Delete Account"
        
        // Setup text field and button UI
        deletionButton.layer.cornerRadius = Constants.cornerRadius
        
        // Set up custom back button
        setCustomBackButton()
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    @IBAction func deleteUser(_ sender: UIButton) {
        
        let realm = try! Realm() // Initialize Realm
        
        // Update UserDefaults' "loggedIn" property to false
        self.defaults.set(false, forKey: "loggedIn")
        self.defaults.set(false, forKey: "netIdVerified")
        
        // Set current Realm user's active property to false
        try! realm.write {
            user.isCurrent = false
        }
        
        let provider = MoyaProvider<APICalls>()
        provider.request(.deleteAccount(uid: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                print("Account deleted")
                self.performSegue(withIdentifier: "unwindDeletionSegue", sender: self)
            case .failure(_):
                // Connection failed
                self.showError(button: self.deletionButton, error: .connectionFailed)
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                    self.hideErrorWhite(button: self.deletionButton, defaultButtonText: self.defaultButtonText)
                }
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
    
}
