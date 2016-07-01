//
//  MainPageTableViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 5/20/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import Firebase

extension BTNavigationDropdownMenu {
    func dropDownMenuDefaults (menuView: BTNavigationDropdownMenu) {
        menuView.cellSelectionColor = UIColor(red: 50/255.0, green:53/255.0, blue:60/255.0, alpha: 1.0)
        menuView.keepSelectedCellColor = true
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 14)
        menuView.checkMarkImage = nil;
        menuView.animationDuration = 0.25
    }
}

extension UIViewController {
    func navBarDefaults() {
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 60/255.0, green:65/255.0, blue:71/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func viewControllerSwitch(indexPath: Int) {
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var homeViewController = UIViewController()
        if (indexPath == 0) {
            homeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainPageTableViewController") as! MainPageTableViewController
        } else if (indexPath == 1 ) {
            homeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CurrencyViewController") as! CurrencyViewController
        } 
        let nav = UINavigationController(rootViewController: homeViewController)
        appdelegate.window!.rootViewController = nav
    }
    
    func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

class MainPageTableViewController: UITableViewController {
    var menuView: BTNavigationDropdownMenu!
    let currentIndex = 0
    var favoritesList: [FDataSnapshot] = []
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        ref.childByAppendingPath("users").childByAppendingPath(Constants.authID).childByAppendingPath("favoritesList").observeEventType(.Value) { (snapshot: FDataSnapshot!) in
            var favoritesDataItems = [FDataSnapshot]()
            
            // loop through the children and append them to the new array
            for favoritesDataItem in snapshot.children {
                favoritesDataItems.append(favoritesDataItem as! FDataSnapshot)
            }
            
            // replace the old array
            self.favoritesList = favoritesDataItems
            // reload the UITableView
            if self.favoritesList.count != 0 {
                self.tableView.reloadData()
            } else {
                /* If the user has yet to add a favorite, we will display a blank screen saying so. */
                if self.tableView.numberOfRowsInSection(0) == 0 {
                    let noFavoritesYet = self.createNoFavoritesView()
                    self.view.addSubview(noFavoritesYet)
                }
            }
        }
        
        self.navigationItem.titleView = menuView
       
        /* Removes the additional separator lines after the last cell*/
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))

        self.tableView.allowsMultipleSelectionDuringEditing = false;
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }

    override func viewWillAppear(animated: Bool) {
        self.menuView.hide()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (menuView.isShown) != nil {
            menuView.hide()   
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.favoritesList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        /* cell's separator lines will now be edge to edge*/
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
    
        let customContainer = UIView(frame: CGRect(x: self.tableView.bounds.size.width * 0.1 / 2, y: cell.bounds.size.height * 0.1 / 2 , width: self.tableView.bounds.size.width * 0.9, height: cell.bounds.size.height * 0.9))
        customContainer.layer.cornerRadius = customContainer.frame.origin.x * 0.4
        customContainer.layer.masksToBounds = true
        customContainer.backgroundColor = UIColor.whiteColor()
        
        let borderLine = UIView(frame: CGRect(x: customContainer.bounds.size.width * 0.5, y: 0, width: 0.75, height: customContainer.bounds.size.height))
        borderLine.backgroundColor = cell.backgroundColor
        
        let favoritesItem: Dictionary<String, String> = (self.favoritesList[indexPath.row].value as? Dictionary<String, String>)!

        let baseCurrLabel = createLabels(0, customFrame: CGRect(x: 0, y: 5, width: customContainer.bounds.size.width * 0.5, height: customContainer.bounds.size.height * 0.215), currencyCode: favoritesItem["baseCurrency"]!)
        
        let chosenCurrLabel = createLabels(0, customFrame: CGRect(x: customContainer.bounds.size.width * 0.5, y: baseCurrLabel.frame.origin.y, width: customContainer.bounds.size.width * 0.5, height: baseCurrLabel.bounds.size.height), currencyCode: favoritesItem["chosenCurrency"]!)
        
        getCurrNameFromDB(favoritesItem["baseCurrency"]!, completionHander: { currName in
            let baseFullCurrName = self.createLabels(1, customFrame: CGRect(x: baseCurrLabel.frame.origin.x, y: baseCurrLabel.bounds.size.height + 5, width: customContainer.bounds.size.width * 0.5, height: customContainer.bounds.size.height * 0.125), currencyCode: currName)
            customContainer.addSubview(baseFullCurrName)
        })
        
        getCurrNameFromDB(favoritesItem["chosenCurrency"]!, completionHander: { currName in
            let chosenFullCurrName = self.createLabels(1, customFrame: CGRect(x: customContainer.bounds.size.width * 0.5, y: baseCurrLabel.bounds.size.height + 5, width: customContainer.bounds.size.width * 0.5, height: customContainer.bounds.size.height * 0.125), currencyCode: currName)
            customContainer.addSubview(chosenFullCurrName)
        })
        
        let baseAmount = createLabels(2, customFrame: CGRect(x: 0, y: baseCurrLabel.bounds.size.height + 10 + customContainer.bounds.size.height * 0.125, width: baseCurrLabel.bounds.size.width, height: customContainer.bounds.size.height * 0.35), currencyCode: favoritesItem["baseCurrencyAmount"]!)
        
        getCurrencyConversionRates(favoritesItem["baseCurrency"]!, chosenCurrency: favoritesItem["chosenCurrency"]!, completionHandler: { amount, error in
            dispatch_async(dispatch_get_main_queue(), {
                let chosenAmount = self.createLabels(2, customFrame: CGRect(x: baseAmount.bounds.size.width, y: baseAmount.frame.origin.y, width: baseAmount.bounds.size.width, height: baseAmount.bounds.size.height), currencyCode: String(Double(favoritesItem["baseCurrencyAmount"]!)! * Double(amount!)!))
                
                let lastUpdatedTimeLabel = self.createLabels(3, customFrame: CGRect(x: 0, y: baseAmount.frame.origin.y + baseAmount.bounds.size.height, width: customContainer.bounds.size.width, height: customContainer.bounds.size.height - (baseAmount.frame.origin.y + baseAmount.bounds.size.height)), currencyCode: "The exchange rate is : \(amount!)")
                
                customContainer.addSubview(chosenAmount)
                customContainer.addSubview(lastUpdatedTimeLabel)
            })
        })
        
        
        cell.contentView.addSubview(customContainer)
        customContainer.addSubview(chosenCurrLabel)
        customContainer.addSubview(baseCurrLabel)
        customContainer.addSubview(borderLine)
        customContainer.addSubview(baseAmount)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.bounds.height * 0.2
    }
    
    func createNoFavoritesView () -> UILabel {
        let noFavoritesYet = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        noFavoritesYet.textColor = UIColor.whiteColor()
        noFavoritesYet.backgroundColor = UIColor(red: 65/255.0, green: 68/255.0, blue: 77/255.0, alpha: 1.0)
        noFavoritesYet.font = UIFont(name: "Quicksand-Regular", size: 40)
        noFavoritesYet.text = "You have no favorites yet."
        noFavoritesYet.numberOfLines = 2
        noFavoritesYet.textAlignment = NSTextAlignment.Center
        
        return noFavoritesYet
    }
    
    func createLabels (labelType: Int, customFrame: CGRect, currencyCode: String) -> UILabel {
        let currLabel = UILabel(frame: customFrame)
        currLabel.textColor = UIColor.blackColor()
        currLabel.textAlignment = NSTextAlignment.Center
        if labelType == 0 {
            currLabel.font = UIFont(name: "OpenSans-Light", size: customFrame.height * 0.8)
        } else if labelType == 1 {
            currLabel.font = UIFont(name: "OpenSans-Light", size: customFrame.height * 0.6)
        } else if labelType == 2 {
            currLabel.font = UIFont(name: "BebasNeueRegular", size: customFrame.height * 0.8)
        } else if labelType == 3 {
            currLabel.font = UIFont(name: "OpenSans-Light", size: customFrame.height * 0.5)
            currLabel.textColor = UIColor.whiteColor()
            currLabel.backgroundColor = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1)
        }
        currLabel.text = currencyCode
        currLabel.clipsToBounds = true
        
        return currLabel
    }
    
    func getCurrNameFromDB (currCode: String, completionHander: (String!) -> Void) {
        ref.childByAppendingPath("jsonCurrencies").observeEventType(.Value, withBlock: { snapshot in
            completionHander(snapshot.value.objectForKey(currCode)!["name"] as! String)
        })
    }
    
    func getCurrencyConversionRates (baseCurrency: String, chosenCurrency: String, completionHandler: (String?, NSError?) -> Void ) -> NSURLSessionTask {
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%3D%22" + baseCurrency + chosenCurrency + "%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")!, completionHandler: { (data, response, error) -> Void in
            do{
                let dict: Dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                print(dict)
                let amount: String = (dict["query"]!["results"]!!["rate"]!!["Rate"]!! as? String)!
                completionHandler(amount, nil)
            }
            catch {
                print("json error: \(error)")
            }
        })
        task.resume()
        return task
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            ref.childByAppendingPath("users").childByAppendingPath(Constants.authID).childByAppendingPath("favoritesList").childByAppendingPath(self.favoritesList[indexPath.row].key).removeValue()
            self.favoritesList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
