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
    @IBOutlet weak var navBar: UILabel!
    
    @IBAction func closeButton(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var baseCurr: String!
    var convertedCurr: String!
    var convertFromUSDRate: Double = 0.0
    var sortedGraphValues: [(String, Double)] = []
    
    var dateSelectorLabel: UILabel = UILabel()
    var rateSelectorLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        navBar.font = UIFont(name: "Vegur-Light", size: 40.0)
        navBar.text = "\(baseCurr) - \(convertedCurr)"
        self.view.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
        // line chart setup
        lineChart.backgroundColor = self.view.backgroundColor
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.reloadData()
        lineChart.setState(.Collapsed, animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let dateLastYear = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -365, toDate: NSDate(), options: [])
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateToday = dateFormatter.stringFromDate(NSDate())
        
        let lastYearDate = (String(dateLastYear!).componentsSeparatedByString(" "))[0]
        
        if (baseCurr == "USD") {
            getChartData(lastYearDate, endDate: dateToday, currency: convertedCurr, completionHandler: {
                dictValues, error in
                self.sortedGraphValues = dictValues.sort({ $0.0 < $1.0 })
                self.drawGraph()
            })
        } else if (convertedCurr == "USD") {
            getChartData(lastYearDate, endDate: dateToday, currency: baseCurr, completionHandler: {
                dictValues, error in
                var inverseValuesDict: Dictionary<String, Double> = [:]
                for (key, value) in dictValues {
                    inverseValuesDict[key] = 1 / value
                }
                self.sortedGraphValues = inverseValuesDict.sort({ $0.0 < $1.0})
                self.drawGraph()
            })
        } else if (baseCurr != "USD" && convertedCurr != "USD") {
            getChartData(lastYearDate, endDate: dateToday, currency: baseCurr, completionHandler: { dictValues, error in
                let baseDataDict: Dictionary<String, Double> = dictValues
                self.getChartData(lastYearDate, endDate: dateToday, currency: self.convertedCurr, completionHandler: {
                    chosenDataDict, error in
                    if baseDataDict.count > chosenDataDict.count || baseDataDict.count == chosenDataDict.count {
                        self.sortedGraphValues = self.getFilteredAndSortedGraphValues(false, baseDataDict: baseDataDict, chosenDataDict: chosenDataDict)
                    } else if baseDataDict.count < chosenDataDict.count {
                        self.sortedGraphValues = self.getFilteredAndSortedGraphValues(true, baseDataDict: chosenDataDict, chosenDataDict: baseDataDict)
                    }
                    self.drawGraph()
                })
            })
        }
        
        let dateLabel = createLabels("Date", customFrame: CGRect(x: lineChart.frame.origin.x, y: lineChart.frame.origin.y + lineChart.bounds.size.height, width: lineChart.bounds.size.width / 2, height: 20), font: UIFont(name: "Quicksand-Regular", size: 15.0)!)
        let rateLabel = createLabels("Rate", customFrame: CGRect(x: dateLabel.frame.origin.x + dateLabel.bounds.size.width, y: dateLabel.frame.origin.y, width: dateLabel.bounds.size.width, height: 20), font: UIFont(name: "Quicksand-Regular", size: 15.0)!)
        
        self.dateSelectorLabel = createLabels("", customFrame: CGRect(x: dateLabel.frame.origin.x, y: dateLabel.frame.origin.y + dateLabel.bounds.size.height, width: dateLabel.bounds.size.width, height: 50), font: UIFont(name: "BebasNeueRegular", size: 30.0)!)
        self.rateSelectorLabel = createLabels("", customFrame: CGRect(x: rateLabel.frame.origin.x, y: rateLabel.frame.origin.y + rateLabel.bounds.size.height, width: rateLabel.bounds.size.width, height: 50), font: UIFont(name: "BebasNeueRegular", size: 30.0)!)
        
        let borderLine = UIView(frame: CGRect(x: rateLabel.frame.origin.x, y: dateLabel.frame.origin.y, width: 1, height: dateLabel.bounds.size.height + self.dateSelectorLabel.bounds.size.height))
        borderLine.backgroundColor = UIColor(red: 175/255.0, green: 175/255.0, blue: 175/255.0, alpha: 1.0)
        borderLine.layer.cornerRadius = 2
        
        self.view.addSubview(dateLabel)
        self.view.addSubview(rateLabel)
        self.view.addSubview(self.dateSelectorLabel)
        self.view.addSubview(self.rateSelectorLabel)
        self.view.addSubview(borderLine)
        
        lineChart.reloadData()
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: #selector(GraphViewController.showChart), userInfo: nil, repeats: false)
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
            return UInt(self.sortedGraphValues.count)
        }
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        if (lineIndex == 0) {
            return CGFloat(self.sortedGraphValues[Int(horizontalIndex)].1)
        }
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(red: 77/255.0, green: 77/255.0, blue: 77/255.0, alpha: 1.0)
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
            let data = self.sortedGraphValues[Int(horizontalIndex)].1
            let date = self.sortedGraphValues[Int(horizontalIndex)].0
            self.dateSelectorLabel.text = date
            self.rateSelectorLabel.text = String(Double(round(10000*data)/10000))
        }
    }
    
    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        self.dateSelectorLabel.text = ""
        self.rateSelectorLabel.text = ""
    }
    
    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1.0)
    }
    
    func getChartData (startDate: String, endDate: String, currency: String, completionHandler: (Dictionary<String, Double>, NSError?) -> Void) -> NSURLSessionTask {
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22" + currency + "%3DX%22%20and%20startDate%20%3D%20%22" + startDate + "%22%20and%20endDate%20%3D%20%22" + endDate + "%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")!, completionHandler: { (data, response, error) -> Void in
            do{
                let dict: Dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                let currDataArr = dict["query"]!["results"]!!["quote"]!!
                var currDataDict: Dictionary<String, Double> = [:]
                
                for i in 0 ..< currDataArr.count - 1 {
                    let date = currDataArr[i]["Date"]
                    let currValue = currDataArr[i]["Adj_Close"]
                    currDataDict[date!! as! String] = Double(currValue!! as! String)
                }
                completionHandler(currDataDict, nil)
            }
            catch {
                print("json error: \(error)")
            }
        })
        task.resume()
        return task
    }
    
    func getFilteredAndSortedGraphValues (isBaseCurrBigger: Bool, baseDataDict: Dictionary<String, Double>, chosenDataDict: Dictionary<String, Double>) -> [(String, Double)] {
        var filteredDict: Dictionary<String, Double> = [:]
        for (key, value) in baseDataDict {
            if chosenDataDict[key] != nil {
                if !isBaseCurrBigger {
                    filteredDict[key] = chosenDataDict[key]! / value
                } else {
                    filteredDict[key] = value / chosenDataDict[key]!
                }
            }
        }
        return filteredDict.sort({ $0.0 < $1.0 })
    }
    
    func drawGraph () {
        let footerView = UIView(frame: CGRectMake(0, 0, self.lineChart.frame.width, 20))
        
        let footer1 = UILabel(frame: CGRectMake(0, 10, self.lineChart.frame.width/4, 10))
        footer1.font = UIFont(name: "BebasNeueRegular", size: 10.0)
        footer1.textColor = UIColor.blackColor()
        
        let footer2 = UILabel(frame: CGRectMake(self.lineChart.frame.width * 0.75, 10, footer1.bounds.size.width, footer1.bounds.size.height))
        footer2.textColor = footer1.textColor
        footer2.textAlignment = NSTextAlignment.Right
        footer2.font = footer1.font
        
        dispatch_async(dispatch_get_main_queue(), {
            footer1.text = "\(self.sortedGraphValues[0].0)"
            footer2.text = "\(self.sortedGraphValues[self.sortedGraphValues.count - 1].0)"
            footerView.addSubview(footer1)
            footerView.addSubview(footer2)
            self.lineChart.footerView = footerView
        })
    }
    
    func createLabels (text: String, customFrame: CGRect, font: UIFont) -> UILabel {
        let label = UILabel(frame: customFrame)
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.text = text
        
        return label
    }
}
