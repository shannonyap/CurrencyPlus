//
//  CurrencyViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 5/21/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class CurrencyViewController: UIViewController {

    var menuView: BTNavigationDropdownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let items = DropDownMenuNavBarOptions.items
        navBarDefaults()

        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[1], items: items)
        menuView.cellHeight = 40
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 50/255.0, green:53/255.0, blue:60/255.0, alpha: 1.0)
        menuView.keepSelectedCellColor = true
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 14)
        menuView.checkMarkImage = nil;
        menuView.animationDuration = 0.25
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            if (indexPath == 0) {
                let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainPageTableViewController") as! MainPageTableViewController
                let nav = UINavigationController(rootViewController: homeViewController)
                appdelegate.window!.rootViewController = nav
            }
        }
        
        self.navigationItem.titleView = menuView
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
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
