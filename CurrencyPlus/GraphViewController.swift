//
//  GraphViewController.swift
//  
//
//  Created by Shannon Yap on 6/13/16.
//
//

import UIKit
import JBChartView

class GraphViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource {
    
    @IBOutlet weak var lineChart: JBLineChartView!
    @IBOutlet weak var informationLabel: UILabel!

    
    var baseCurr: String!
    var convertedCurr: String!
    var convertFromUSDRate: Double = 0.0
    var graphDates: Array<String> = []
    var graphValues: Array<Double> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.darkGrayColor()
        
        // line chart setup
        lineChart.backgroundColor = UIColor.darkGrayColor()
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 10
        lineChart.maximumValue = 0
        
        lineChart.reloadData()
        
        lineChart.setState(.Collapsed, animated: false)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let dateLastYear = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -365, toDate: NSDate(), options: [])
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateToday = dateFormatter.stringFromDate(NSDate())
        
        let lastYearDate = (String(dateLastYear!).componentsSeparatedByString(" "))[0]
        
        getCurrencyConversionRates( { rate, error in
            self.convertFromUSDRate = Double(rate!)!
        })
        
        getChartData(lastYearDate, endDate: dateToday, completionHandler: { datesArr, valuesArr, error in
            self.graphDates = datesArr!.reverse()
            self.graphValues = valuesArr!.reverse()
        
        let footerView = UIView(frame: CGRectMake(0, 0, self.lineChart.frame.width, 16))
        
        print("viewDidLoad: \(self.lineChart.frame.width)")
        
        let footer1 = UILabel(frame: CGRectMake(0, 0, self.lineChart.frame.width/2 - 8, 16))
        footer1.textColor = UIColor.whiteColor()
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                footer1.text = "\(self.graphDates[0])"

            })
        let footer2 = UILabel(frame: CGRectMake(self.lineChart.frame.width/2 - 8, 0, self.lineChart.frame.width/2 - 8, 16))
        footer2.textColor = UIColor.whiteColor()
            dispatch_async(dispatch_get_main_queue(), {
        footer2.text = "\(self.graphDates[self.graphDates.count - 1])"
                })
        footer2.textAlignment = NSTextAlignment.Right
        
          dispatch_async(dispatch_get_main_queue(), {
        footerView.addSubview(footer1)
        footerView.addSubview(footer2)
            })
            
            dispatch_async(dispatch_get_main_queue(), {
        let header = UILabel(frame: CGRectMake(0, 0, self.lineChart.frame.width, 30))
        header.textColor = UIColor.whiteColor()
        header.font = UIFont.systemFontOfSize(15)
        header.text = "USD-MYR Graph"
        header.textAlignment = NSTextAlignment.Center
        
        self.lineChart.footerView = footerView
        self.lineChart.headerView = header
            })
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // our code
        lineChart.reloadData()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showChart"), userInfo: nil, repeats: false)
    }
   
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hideChart()
    }
    
    func hideChart() {
        lineChart.setState(.Collapsed, animated: true)
    }
    
    func showChart() {
        lineChart.setState(.Expanded, animated: true)
    }
    
    
    // MARK: JBlineChartView
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        if (lineIndex == 0) {
            return UInt(graphValues.count)
        }
        
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        if (lineIndex == 0) {
            return CGFloat(graphValues[Int(horizontalIndex)])
        }
        
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.lightGrayColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return false
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.lightGrayColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
        if (lineIndex == 0) {
            let data = graphValues[Int(horizontalIndex)]
            let key = graphDates[Int(horizontalIndex)]
            informationLabel.text = "USD-MYR on \(key): \(data)"
        }
    }
    
    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        informationLabel.text = ""
    }
    
    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
      
        return UIColor.clearColor()
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
    
    func getChartData (startDate: String, endDate: String, completionHandler: (Array<String>?, Array<Double>?, NSError?) -> Void) -> NSURLSessionTask {
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22MYR%3DX%22%20and%20startDate%20%3D%20%22" + startDate + "%22%20and%20endDate%20%3D%20%22" + endDate + "%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")!, completionHandler: { (data, response, error) -> Void in
            do{
                let dict: Dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                
                let currDataArr = dict["query"]!["results"]!!["quote"]!!
                var datesArr: Array<String> = [];
                var valuesArr: Array<Double> = [];
                
                for i in 0 ..< currDataArr.count - 1 {
                    let date = currDataArr[i]["Date"]
                    let currValue = currDataArr[i]["Adj_Close"]
                    datesArr.append(date!! as! String)
                    valuesArr.append(Double(currValue!! as! String)!)
                }

                completionHandler(datesArr, valuesArr, nil)
            }
            catch {
                print("json error: \(error)")
            }
        })
        task.resume()
        return task
    }
}
