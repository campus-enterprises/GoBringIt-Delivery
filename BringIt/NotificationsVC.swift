//
//  NotificationsVC.swift
//  BringIt
//
//  Created by Joey Lane on 4/22/21.
//  Copyright © 2021 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Moya
import Alamofire
import OneSignal

class NotificationsVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    
    @IBOutlet weak var launchSettings: UIButton!
    @IBOutlet weak var deviceStateLabel: UILabel!
    
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    var switchChanged = false
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    var user = User()
    var subscribed = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        // Setup UI
        setupUI()
        
        // Setup Realm
        setupRealm()
        
        // Fetch account info from the database
        fetchAccountInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        deviceStateLabel.font = UIFont.boldSystemFont(ofSize: 17)
        if let deviceState = OneSignal.getDeviceState() {
            subscribed = deviceState.isSubscribed
          if subscribed {
            deviceStateLabel.text = "ON"
          }
            print(subscribed)
         }
        // Set title
        self.title = "Notifications"
        
        // Setup text field and button UI
        
        
        
        // Set up custom back button
        setCustomBackButton()
        
        // Setup auto Next and Done buttons for keyboard
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        let filteredUsers = realm.objects(User.self).filter("isCurrent = %@", NSNumber(booleanLiteral: true))
        user = filteredUsers.first!
    }
    
    func fetchAccountInfo() {
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchAccountInfo(uid: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("User ID: \(self.user.id)")
                    print("Retrieved Response: \(response)")
                    
                    
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
            }
        }
    }
    
    func updateAccountInfo() {
        
        
        
    }

    
    
    @IBAction func notificationsEnabledTapped(_ sender: UIButton) {
        
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        let subscribed = OneSignal.getDeviceState().isSubscribed
        if subscribed == false {
          OneSignal.addTrigger("prompt_ios", withValue: "true")
        } else {
            
        }
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        
    }
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        
        
        
        return true
    }
    
    
    // MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var result = true
        
        
        
        checkFields()
        return result
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
}
