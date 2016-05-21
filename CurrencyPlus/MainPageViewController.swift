//
//  MainPageViewController.swift
//  CurrencyPlus
//
//  Created by Shannon Yap on 5/18/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class MainPageViewController: UIViewController {
    
    @IBOutlet weak var selectedCellLabel: UILabel!
    var menuView: BTNavigationDropdownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        let items = ["Favorites", "Currency Converter", "Settings"]
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 60/255.0, green:65/255.0, blue:71/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[0], items: items)
        menuView.cellHeight = 40
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 50/255.0, green:53/255.0, blue:60/255.0, alpha: 1.0)
        menuView.keepSelectedCellColor = true
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 14)
        menuView.checkMarkImage = nil;
        menuView.animationDuration = 0.25
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
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
