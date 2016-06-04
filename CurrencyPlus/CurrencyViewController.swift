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
import Firebase
import AutocompleteField

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

class CurrencyViewController: UIViewController, UITextFieldDelegate {
    var activeTextField = UITextField()
    var searchTerms: [String] = []
    var menuView: BTNavigationDropdownMenu!
    let currentIndex = 1
    let numPad = ["fav","1","2","3","4","5","6","7","8","9", ".", "0", "delete", "graph"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addTapGesture()
        
        addJSONtoFirebaseDB()
        toDB()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let items = Constants.items
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
        
        let firstTextField = makeCurrTextFields(1, activeColor: UIColor.getTextFieldColor() ,customFrame: CGRect(x: firstCurrView.bounds.size.width / 2 + (firstCurrView.bounds.size.width / 2 - Constants.textFieldWidth) / 2, y: firstCurrView.frame.origin.y + (firstCurrView.bounds.size.height - Constants.textFieldHeight) / 2, width: Constants.textFieldWidth, height: Constants.textFieldHeight))
        
        let secondTextField = makeCurrTextFields(2, activeColor: UIColor.whiteColor() ,customFrame: CGRect(x: secondCurrView.bounds.size.width / 2 + (secondCurrView.bounds.size.width/2 - Constants.textFieldWidth) / 2, y: secondCurrView.frame.origin.y + (secondCurrView.bounds.size.height - Constants.textFieldHeight) / 2, width: Constants.textFieldWidth, height: Constants.textFieldHeight))
        
        let BaseCurrencySearch = makeCurrencySearchFields(1, suggestions: self.searchTerms, customFrame: CGRectMake(firstCurrView.bounds.size.width/4 - Constants.textFieldWidth / 2 , firstTextField.frame.origin.y, Constants.textFieldWidth, Constants.textFieldHeight), placeHolderText: "Base Currency")
        
        let SelectedCurrencySearch = makeCurrencySearchFields(2, suggestions: self.searchTerms, customFrame: CGRectMake(secondCurrView.bounds.size.width / 4 - Constants.textFieldWidth / 2, secondTextField.frame.origin.y, Constants.textFieldWidth, Constants.textFieldHeight), placeHolderText: "Target Currency")

        let xcoord: CGFloat = 0
        let ycoord = dividerLine.frame.origin.y + dividerLine.bounds.size.height
        let width = self.view.bounds.size.width / 3
        let height = (self.view.bounds.size.height - (self.navigationController?.navigationBar.bounds.size.height)! - UIApplication.sharedApplication().statusBarFrame.size.height - (dividerLine.frame.origin.y + dividerLine.bounds.size.height))/5
        var counter = 0
        for number in numPad {
            var button = UIView()
            if (Int)(numPad.indexOf(number)!) != 0 &&  (Int)(numPad.indexOf(number)!) != 13 {
                    button = makeNumberPad(numPad.indexOf(number)!, buttonTitle: number, customFrame: CGRect(x: xcoord + width * (CGFloat)((numPad.indexOf(number)! % 3) - 1), y: ycoord + height * (CGFloat)(counter), width: width, height: height))
                if (Int)(numPad.indexOf(number)!) % 3  == 0 {
                    let borderLine = makeCurrViews(UIColor.getBorderColor(), customFrame: CGRect(x: 0, y: ycoord + height * (CGFloat)(counter), width: self.view.bounds.size.width, height: 0.5))
                    self.view.addSubview(borderLine)
                    button.frame.origin.x = xcoord + width * 2
                    counter += 1
                }
            } else {
                /* This is the favorite button */
                if (Int)(numPad.indexOf(number)!) == 0 {
                    button = makeNumberPad(numPad.indexOf(number)!, buttonTitle: number, customFrame: CGRect(x: xcoord, y: ycoord, width: width * 1.5, height: height))
                    counter += 1
                } else if (Int)(numPad.indexOf(number)!) == 13 {
                    /* Graph button */
                    button = makeNumberPad(numPad.indexOf(number)!, buttonTitle: number, customFrame: CGRect(x: width * 1.5, y: ycoord, width: width * 1.5, height: height))
                    
                    /* Add a dividing line between the favorite and graph button */
                    let middleLine = makeCurrViews(UIColor.getBorderColor(), customFrame: CGRect(x: width * 1.5, y: ycoord, width: 0.75, height: height))
                    self.view.addSubview(middleLine)
                }
            }
            self.view.addSubview(button)
        }
        
        self.view.addSubview(firstCurrView)
        self.view.addSubview(secondCurrView)
        self.view.addSubview(dividerLine)
        self.view.addSubview(firstTextField)
        self.view.addSubview(secondTextField)
        self.view.addSubview(BaseCurrencySearch)
        self.view.addSubview(SelectedCurrencySearch)
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
        theCurrTextField.font = UIFont(name: "BebasNeueRegular", size: 25.0)
        theCurrTextField.inputView = UIView() /* Disable keyboard for text field */
        theCurrTextField.textAlignment = NSTextAlignment.Right
        theCurrTextField.addTarget(self, action: #selector(CurrencyViewController.ifSelected(_:)), forControlEvents: UIControlEvents.AllTouchEvents)
        theCurrTextField.tag = textFieldId
        
        return theCurrTextField
    }
    
    func makeCurrencySearchFields (searchFieldId: Int, suggestions: NSArray, customFrame: CGRect, placeHolderText: String) -> AutocompleteField {
        let currSearchField = AutocompleteField(frame: customFrame, suggestions: suggestions as! [String])
        currSearchField.placeholder = placeHolderText
        currSearchField.font = UIFont(name: "OpenSans-Light", size: 20.0)
        currSearchField.minimumFontSize = 8;
        currSearchField.adjustsFontSizeToFitWidth = true
        currSearchField.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
        currSearchField.delegate = self
        currSearchField.tag = searchFieldId
        
        return currSearchField
    }
    
    func makeNumberPad (buttonId: Int, buttonTitle: String, customFrame: CGRect) -> UIButton {
        var button = UIButton(frame: customFrame)
        if buttonId != 12 && buttonId != 0  && buttonId != 13{
            button.setTitleColor(UIColor.getTextFieldColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.getHighlightedButtonColor(), forState: UIControlState.Highlighted)
            button.setTitle(buttonTitle, forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont(name: "BebasNeueRegular", size: 30.0)
            button.addTarget(self, action: #selector(CurrencyViewController.appendNumber(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        } else if buttonId == 0 {
            button = customImageButtons(button, normalImage: "favorite", highlightedImage: "favoriteSelected", topAndBottomInsets: button.frame.size.height / 4, leftAndRightInsets: button.frame.size.width / 1.65)
        } else if buttonId == 12 {
            button = customImageButtons(button, normalImage: "delete", highlightedImage: "deleteHighlighted", topAndBottomInsets: button.frame.size.height / 3.342, leftAndRightInsets: button.frame.size.width / 2.5)
            button.addTarget(self, action: #selector(CurrencyViewController.deleteNumber(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        } else if buttonId == 13 {
            button = customImageButtons(button, normalImage: "graph", highlightedImage: "graphHighlighted", topAndBottomInsets: button.frame.size.height / 3.5, leftAndRightInsets: button.frame.size.width / 1.7)
        }
        button.tag = buttonId
        
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
        if sender.tag != 10 && sender.tag != 11 {
            self.activeTextField.text!.appendContentsOf(String(sender.tag))
        } else if sender.tag == 10 {
            if !self.activeTextField.text!.containsString("."){
                self.activeTextField.text!.appendContentsOf(".")
            }
        } else if sender.tag == 11 {
            self.activeTextField.text!.appendContentsOf("0")
        }
    }
    
    func deleteNumber (sender: UIButton!) {
        if self.activeTextField.text!.isNotEmpty {
            self.activeTextField.text!.removeAtIndex(self.activeTextField.text!.endIndex.predecessor())
        }
    }
    
    func ifSelected (sender: HoshiTextField) {
        self.activeTextField = sender
    }

    /* Used to get the dictionary of currency information */
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func addJSONtoFirebaseDB () {
        let url = NSURL(string: Constants.jsonUrl)
        let request = NSURLRequest(URL: url!)
        
        /* Adds the json Currencies into firebase if it doesn't have it already. */
        ref.observeEventType(.Value, withBlock: { snapshot in
            if !(snapshot.exists()) {
                /* GET HTTP response. */
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                    let datastring = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
                    let firebaseDictionary: Dictionary? = self.convertStringToDictionary(datastring)
                    ref.childByAppendingPath("jsonCurrencies").setValue(firebaseDictionary)
                    ref.childByAppendingPath("jsonCurrencies").observeEventType(.ChildAdded, withBlock: { snapshot in
                        var searchTerm = ["searchTerm1": String(snapshot.value.objectForKey("name")!) + ", " + (String(snapshot.value.objectForKey("code")!))]
                        ref.childByAppendingPath("jsonCurrencies").childByAppendingPath(String(snapshot.value.objectForKey("code")!)).updateChildValues(searchTerm)
                        
                        searchTerm = ["searchTerm2": (String(snapshot.value.objectForKey("code")!)) + ", " + String(snapshot.value.objectForKey("name")!)]
                        ref.childByAppendingPath("jsonCurrencies").childByAppendingPath(String(snapshot.value.objectForKey("code")!)).updateChildValues(searchTerm)
                    })
                }
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }

    func toDB() {
        ref.childByAppendingPath("jsonCurrencies").observeEventType(.ChildAdded, withBlock:  { snapshot in
            self.searchTerms.append(String(snapshot.value.objectForKey("searchTerm1")!))
            self.searchTerms.append(String(snapshot.value.objectForKey("searchTerm2")!))
        })
    }

    // MARK: - UITextField delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // set field text to the suggestion text on return
        if let field = textField as? AutocompleteField
        {
            field.text = field.suggestion
        }
        
        return true
    }
    
    /* Function to add the searchTerms to the textField. */
    func textFieldShouldBeginEditing(state: UITextField) -> Bool {
        if let textField = state as? AutocompleteField {
            if textField.text!.isNotEmpty {
                textField.textAlignment = NSTextAlignment.Natural
            }
            textField.suggestions = self.searchTerms
        }
        
        return true
    }
    
    /* Autocompletes partial typing and then shows the currency code. */
    func textFieldDidEndEditing(textField: UITextField) {
        if let autoCompleteField = textField as? AutocompleteField {
            autoCompleteField.text = autoCompleteField.suggestion
            ref.childByAppendingPath("jsonCurrencies").observeEventType(.ChildAdded, withBlock: { snapshot in
                let text: String = autoCompleteField.text!
                let currencyCode: String = snapshot.value.objectForKey("code")! as! String
                if text.containsString(currencyCode) {
                    autoCompleteField.textAlignment = NSTextAlignment.Right
                    autoCompleteField.text = currencyCode
                }
            })

            /* Find the textFields for the amount. */
            var amountTextFieldArray: [HoshiTextField] = []
            for case let amountTextField as HoshiTextField in self.view.subviews {
                amountTextFieldArray.append(amountTextField)
            }
            if (amountTextFieldArray[1].tag == autoCompleteField.tag) && amountTextFieldArray[0].text!.isEmpty {
                amountTextFieldArray[1].text = "1"
            } else if (amountTextFieldArray[0].tag == autoCompleteField.tag) && amountTextFieldArray[1].text!.isEmpty {
                amountTextFieldArray[0].text = "1"
            }
            if amountTextFieldArray[autoCompleteField.tag - 1].text!.isEmpty {
                // here is where we convert
            }
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

}
