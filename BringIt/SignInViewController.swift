//
//  SignInViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(animated: Bool) {
        displayWalkthroughs()
    }
    
    func displayWalkthroughs() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let displayedWalkthrough = userDefaults.boolForKey("displayedWalkthrough")
        
        print("FIRST LAUNCH: \(displayedWalkthrough)")
        
        if !displayedWalkthrough {
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") {
                self.presentViewController(pageViewController, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
