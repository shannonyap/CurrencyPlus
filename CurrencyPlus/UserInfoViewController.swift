//
//  UserInfoViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 4/15/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase

class UserInfoViewController: UIViewController, UITextFieldDelegate {
    
    var userInfo = ["userName": "", "password": ""]
    
    @IBOutlet weak var firstNameLabelError: UILabel!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var lastNameLabelError: UILabel!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var phoneNumberError: UILabel!
    
    @IBAction func ToMainPage(sender: UIButton) {
        firstNameLabelError.text = ""
        lastNameLabelError.text = ""
        phoneNumberError.text = ""
        
        if firstNameLabel.text == "" {
            firstNameLabelError.text = "Please enter your first name."
        } 
        if lastNameLabel.text == "" {
            lastNameLabelError.text = "Please enter your last name."
        }
        if !isValidPhoneNumber(phoneNumberLabel.text!) {
            phoneNumberError.text = "Please enter a valid phone number."
        }
        if isValidPhoneNumber(phoneNumberLabel.text!) && lastNameLabel.text != "" && firstNameLabel.text != "" {
            ref.authUser(userInfo["userName"], password: userInfo["password"]) {
                error, authData in
                if error != nil {
                    // Something went wrong. :(
                    print(error)
                } else {
                    print("success")
                    // Authentication just completed successfully :)
                    // The logged in user's unique identifier
             //       println(authData.uid)
                    
                    // Create a new user dictionary accessing the user's info
                    // provided by the authData parameter
                    let newUser = [
                        "firstName": self.firstNameLabel.text!,
                        "lastName": self.lastNameLabel.text!,
                        "phoneNumber": self.phoneNumberLabel.text!
                    ]
                    
                    // Create a child path with a key set to the uid underneath the "users" node
                    // This creates a URL path like the following:
                    //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                    ref.childByAppendingPath("users")
                        .childByAppendingPath(authData.uid).setValue(newUser)
                }
            }
        }
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
    
    func isValidPhoneNumber (value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluateWithObject(value)
        return result
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
