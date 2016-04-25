//
//  CreateAccountViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 4/11/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(sender: UIButton) {
        emailError.text = ""
        passwordError.text = ""
        let ref = Firebase(url: Constants.firebaseUrl)
        if (isValidEmail(email.text!)){
            ref.createUser(email.text, password: password.text,
                           withValueCompletionBlock: { error, result in
                            if error != nil {
                                // There was an error creating the account
                               // print(error)
                                if (error.code == -9) {
                                    self.emailError.text = "Email has already been used."
                                } else if (error.code == -6) {
                                    self.passwordError.text = "Please enter a valid password."
                                }
                            } else {
                                /*
                                let uid = result["uid"] as? String
                                print("Successfully created user account with uid: \(uid)")
                                print(result)
                                */
                                self.performSegueWithIdentifier("createAccount", sender: self)
                            }
            })
        } else {
            emailError.text = "Invalid email. Please try again."
        }
    }

    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }
    
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


