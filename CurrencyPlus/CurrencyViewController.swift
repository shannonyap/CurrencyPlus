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
    
    class func getHighlightedButtonColor() -> UIColor {
        return UIColor(red: 65/255.0, green: 65/255.0, blue: 64/255.0, alpha: 0.3)
    }
    
    class func getBorderColor() -> UIColor {
        return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    }
}

struct TextFieldConstants {
    static let textFieldWidth: CGFloat = 125.0
    static let textFieldHeight: CGFloat = 50.0
}

class CurrencyViewController: UIViewController {

    var menuView: BTNavigationDropdownMenu!
    let currentIndex = 1
    let numPad = ["fav","1","2","3","4","5","6","7","8","9", ".", "0", "delete"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
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
        let dividerLine = makeCurrViews(UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0), customFrame: CGRect(x: 0, y: 2 * firstCurrView.bounds.height, width: firstCurrView.bounds.width, height: 2))
        
        let firstTextField = makeCurrTextFields(1, activeColor: UIColor.getTextFieldColor() ,customFrame: CGRect(x: firstCurrView.bounds.size.width/2 + (firstCurrView.bounds.size.width/2 - TextFieldConstants.textFieldWidth) / 2, y: firstCurrView.frame.origin.y + (firstCurrView.bounds.size.height - TextFieldConstants.textFieldHeight) / 2, width: TextFieldConstants.textFieldWidth, height: TextFieldConstants.textFieldHeight))
        
        let secondTextField = makeCurrTextFields(2, activeColor: UIColor.whiteColor() ,customFrame: CGRect(x: secondCurrView.bounds.size.width/2 + (secondCurrView.bounds.size.width/2 - TextFieldConstants.textFieldWidth) / 2, y: secondCurrView.frame.origin.y + (secondCurrView.bounds.size.height - TextFieldConstants.textFieldHeight) / 2, width: TextFieldConstants.textFieldWidth, height: TextFieldConstants.textFieldHeight))
        
        let xcoord: CGFloat = 0
        let ycoord = dividerLine.frame.origin.y + dividerLine.bounds.size.height
        let width = self.view.bounds.size.width / 3
        let height = (self.view.bounds.size.height - (self.navigationController?.navigationBar.bounds.size.height)! - UIApplication.sharedApplication().statusBarFrame.size.height - (dividerLine.frame.origin.y + dividerLine.bounds.size.height))/5
        var counter = 0
        for number in numPad {
            var button = UIView()
            if (Int)(numPad.indexOf(number)!) != 0 {
                    button = makeNumberPad(numPad.indexOf(number)!, buttonTitle: number, customFrame: CGRect(x: xcoord + width * (CGFloat)((numPad.indexOf(number)! % 3) - 1), y: ycoord + height * (CGFloat)(counter), width: width, height: height))
                if (Int)(numPad.indexOf(number)!) % 3  == 0 {
                    let borderLine = makeCurrViews(UIColor.getBorderColor(), customFrame: CGRect(x: 0, y: ycoord + height * (CGFloat)(counter), width: self.view.bounds.size.width, height: 0.5))
                    self.view.addSubview(borderLine)
                    button.frame.origin.x = xcoord + width * 2
                    counter += 1
                }
            } else {
                /* This is the favorite button */
                button = makeNumberPad(numPad.indexOf(number)!, buttonTitle: number, customFrame: CGRect(x: xcoord, y: ycoord, width: width * 3, height: height))
                counter += 1
            }
            self.view.addSubview(button)
        }
        
        self.view.addSubview(firstCurrView)
        self.view.addSubview(secondCurrView)
        self.view.addSubview(dividerLine)
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
    
    func makeCurrTextFields(textFieldId: Int, activeColor: UIColor, customFrame: CGRect) -> HoshiTextField {
        let theCurrTextField = HoshiTextField(frame: customFrame)
        theCurrTextField.textColor = activeColor
        theCurrTextField.borderActiveColor = activeColor
        if (textFieldId == 1) {
            theCurrTextField.borderInactiveColor = UIColor.grayColor()
        } else {
            theCurrTextField.borderInactiveColor = UIColor.whiteColor()
        }
        theCurrTextField.font = UIFont(name: "BebasNeueRegular", size: 30.0)
        theCurrTextField.inputView = UIView() /* Disable keyboard for text field */
        theCurrTextField.textAlignment = NSTextAlignment.Right
        
        return theCurrTextField
    }
    
    func makeNumberPad (buttonId: Int, buttonTitle: String, customFrame: CGRect) -> UIButton {
        var button = UIButton(frame: customFrame)
        if buttonId != 12 && buttonId != 0 {
            button.setTitleColor(UIColor.getTextFieldColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.getHighlightedButtonColor(), forState: UIControlState.Highlighted)
            button.setTitle(buttonTitle, forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont(name: "BebasNeueRegular", size: 30.0)
            button.addTarget(self, action: #selector(CurrencyViewController.appendNumber(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = buttonId
        } else if buttonId == 0 {
            button = customImageButtons(button, normalImage: "favorite", highlightedImage: "favoriteSelected", topAndBottomInsets: button.frame.size.height / 4.4, leftAndRightInsets: button.frame.size.width / 1.8)
        } else if buttonId == 12 {
            button = customImageButtons(button, normalImage: "delete", highlightedImage: "deleteHighlighted", topAndBottomInsets: button.frame.size.height / 3.342, leftAndRightInsets: button.frame.size.width / 2.5)
        }
        return button
    }
    
    func customImageButtons (button: UIButton, normalImage: String, highlightedImage: String, topAndBottomInsets: CGFloat, leftAndRightInsets: CGFloat) -> UIButton {
        var imageButton = button
        imageButton = UIButton(type: UIButtonType.Custom) as UIButton
        imageButton.frame = button.frame
        var image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(normalImage, ofType: "png", inDirectory: "Images")!)
        imageButton.setImage(image, forState: .Normal)
        image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(highlightedImage, ofType: "png", inDirectory: "Images")!)
        imageButton.setImage(image, forState: .Highlighted)
        imageButton.imageEdgeInsets = UIEdgeInsetsMake(topAndBottomInsets, leftAndRightInsets, topAndBottomInsets, leftAndRightInsets)
        
        return imageButton
    }
    
    func appendNumber(sender: UIButton!) {
        
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
