//
//  LoginViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 4/11/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

struct Constants {
    static let firebaseUrl = "https://currencyplus.firebaseio.com/"
    static var items = ["Favorites", "Currency Converter"]
    static let textFieldWidth: CGFloat = 125.0
    static let textFieldHeight: CGFloat = 50.0
    static let jsonUrl = "http://www.localeplanet.com/api/auto/currencymap.json?name=Y"
    static var authID = ""
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    var authUID = ""
    var showNotification = 0
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var loginEmailError: UILabel!
    @IBOutlet weak var loginPasswordError: UILabel!
    
    @IBAction func loginPress(sender: UIButton) {
        loginEmailError.text = ""
        loginPasswordError.text = ""
        
        let ref = Firebase(url: Constants.firebaseUrl)
        ref.authUser(loginEmail.text, password: loginPassword.text,
                     withCompletionBlock: { error, authData in
                        if error != nil {
                            // There was an error logging in to this account
                            print(error)
                            if (error.code == -8) {
                                self.loginEmailError.text = "Email does not have an account associated with it."
                            } else if (error.code == -6) {
                                self.loginPasswordError.text = "Incorrect Password."
                            } else if (error.code == -5) {
                                self.loginEmailError.text = "Invalid email."
                            }
                        } else {
                            // We are now logged in
                            Constants.authID = authData.uid
                            self.performSegueWithIdentifier("SegueToMainPage", sender: sender)
                        }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        titleLabel.font = UIFont(name: "Alcubierre", size: 40.0)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        if showNotification == 1 {
            let alert = SCLAlertView()
            alert.showSuccess("", subTitle: "User Info added.")
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
