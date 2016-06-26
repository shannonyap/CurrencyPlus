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
        } else if (indexPath == 2) {
            homeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
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
        
        ref.childByAppendingPath("favoritesList").observeEventType(.Value) { (snapshot: FDataSnapshot!) in
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
        /* Makes the separator lines go edge to edge */
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        /* Draws a separator line for the tableviewcell */
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
        
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
        cell.textLabel?.text = self.favoritesList[indexPath.row].key
        
        return cell
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
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            ref.childByAppendingPath("favoritesList").childByAppendingPath(self.favoritesList[indexPath.row].key).removeValue()
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
