//
//  LoginViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 4/11/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase

struct Constants {
    static let firebaseUrl = "https://currencyplus.firebaseio.com/"
}

class LoginViewController: UIViewController {
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
                            self.performSegueWithIdentifier("SegueToMainPage", sender: sender)
                        }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
