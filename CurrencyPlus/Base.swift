//
//  Base.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 4/11/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import Foundation
import Firebase

let baseUrl = "https://currencyplus.firebaseio.com"

let ref = Firebase(url: baseUrl)

var currUser: Firebase
{
    let userId = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
    
    let currentUser = Firebase(url: "\(ref)").childByAppendingPath("users").childByAppendingPath(userId)
    
    return currentUser!
}