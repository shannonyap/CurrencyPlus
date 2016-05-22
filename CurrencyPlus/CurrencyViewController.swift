//
//  CurrencyViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 5/21/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import TextFieldEffects

extension UIColor {
    class func getTextFieldColor() -> UIColor {
        return UIColor(red: 65/255.0, green: 65/255.0, blue: 64/255.0, alpha: 1.0)
    }
}

struct TextFieldConstants {
    static let textFieldWidth: CGFloat = 125.0
    static let textFieldHeight: CGFloat = 50.0
}

class CurrencyViewController: UIViewController {

    var menuView: BTNavigationDropdownMenu!
    let currentIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        addTapGesture()
        
        let items = DropDownMenuNavBarOptions.items
        navBarDefaults()
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[currentIndex], items: items)
        menuView.dropDownMenuDefaults(menuView)
        
        if (!menuView.isShown){
            menuView.show()
        }
        
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            if (self.currentIndex != indexPath) {
                self.viewControllerSwitch(indexPath)
            }
        }
        
        self.navigationItem.titleView = menuView
        
        /* Adding the UI objects to the screen */
        let firstCurrView = makeCurrViews(UIColor.whiteColor(), customFrame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.2))
        let secondCurrView = makeCurrViews(UIColor(red: 243/255.0, green: 66/255.0, blue: 64/255.0, alpha: 1.0), customFrame: CGRect(x: 0, y: firstCurrView.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height * 0.2))
        let borderLine = makeCurrViews(UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0), customFrame: CGRect(x: 0, y: 2 * firstCurrView.bounds.height, width: firstCurrView.bounds.width, height: 2))
        
        let firstTextField = makeCurrTextFields(UIColor.getTextFieldColor() ,customFrame: CGRect(x: firstCurrView.bounds.size.width/2 + (firstCurrView.bounds.size.width/2 - TextFieldConstants.textFieldWidth) / 2, y: firstCurrView.frame.origin.y + (firstCurrView.bounds.size.height - TextFieldConstants.textFieldHeight) / 2, width: TextFieldConstants.textFieldWidth, height: TextFieldConstants.textFieldHeight))
        let secondTextField = makeCurrTextFields(UIColor.getTextFieldColor() ,customFrame: CGRect(x: secondCurrView.bounds.size.width/2 + (secondCurrView.bounds.size.width/2 - TextFieldConstants.textFieldWidth) / 2, y: secondCurrView.frame.origin.y + (secondCurrView.bounds.size.height - TextFieldConstants.textFieldHeight) / 2, width: TextFieldConstants.textFieldWidth, height: TextFieldConstants.textFieldHeight))
        
        self.view.addSubview(firstCurrView)
        self.view.addSubview(secondCurrView)
        self.view.addSubview(borderLine)
        self.view.addSubview(firstTextField)
        self.view.addSubview(secondTextField)
    }
    
    override func viewWillAppear(animated: Bool) {
        menuView.hide()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeCurrViews (color: UIColor, customFrame: CGRect) -> UIView {
        let theCurrView = UIView(frame: customFrame)
        theCurrView.backgroundColor = color
        return theCurrView;
    }
    
    func makeCurrTextFields(activeColor: UIColor, customFrame: CGRect) -> HoshiTextField {
        let theCurrTextField = HoshiTextField(frame: customFrame)
        theCurrTextField.textColor = activeColor
        theCurrTextField.borderActiveColor = activeColor
        theCurrTextField.borderInactiveColor = UIColor.grayColor()
        theCurrTextField.font = UIFont(name: "BebasNeueLight", size: 30.0)
        
        return theCurrTextField
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
