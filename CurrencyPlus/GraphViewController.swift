//
//  GraphViewController.swift
//  
//
//  Created by Shannon Yap on 6/13/16.
//
//

import UIKit
import JBChartView

class GraphViewController: UIViewController {
    
    var baseCurr: String!
    var convertedCurr: String!
    var convertFromUSDRate: Double = 0.0
    var currGraphData: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateLastYear = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -365, toDate: NSDate(), options: [])
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateToday = dateFormatter.stringFromDate(NSDate())

        let lastYearDate = (String(dateLastYear!).componentsSeparatedByString(" "))[0]
        
        getCurrencyConversionRates( { rate, error in
            self.convertFromUSDRate = Double(rate!)!
        })
        
        getChartData(lastYearDate, endDate: dateToday, completionHandler: { dataArr, error in
            print(dataArr!)
        })
        // Do any additional setup after loading the view.
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrencyConversionRates (completionHandler: (String?, NSError?) -> Void ) -> NSURLSessionTask {
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22USD" + "MYR" + "%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")!, completionHandler: { (data, response, error) -> Void in
            do{
                
                let dict: Dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]

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
    
    func getChartData (startDate: String, endDate: String, completionHandler: (Dictionary<String, String>?, NSError?) -> Void) -> NSURLSessionTask {
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22MYR%3DX%22%20and%20startDate%20%3D%20%22" + startDate + "%22%20and%20endDate%20%3D%20%22" + endDate + "%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")!, completionHandler: { (data, response, error) -> Void in
            do{
                let dict: Dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                
                let currDataArr = dict["query"]!["results"]!!["quote"]!!
                var graphData = [String: String]()
                for i in 0 ..< currDataArr.count - 1 {
                    let date = currDataArr[i]["Date"]
                    let currValue = currDataArr[i]["Adj_Close"]
                    graphData[date!! as! String] = currValue!! as? String
                }

                completionHandler(graphData, nil)
            }
            catch {
                print("json error: \(error)")
            }
        })
        task.resume()
        return task
    }
}
