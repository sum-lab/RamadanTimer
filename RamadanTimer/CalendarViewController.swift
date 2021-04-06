//
//  MonthViewViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 31/05/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import UIKit
import CoreLocation

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var locationLabel: UILabel!
    
    let calendar = Calendar(identifier: .gregorian)
    let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
    
    /// date corresponding to first of displayed hijri month
    var date: Date!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // get first of current month
        var comps = hijriCalendar.dateComponents([.month, .year], from: Date())
        comps.day = 1
        date = hijriCalendar.date(from: comps)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // display location
        self.locationLabel.text = LocationUtil.shared.locationName
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // flash scroll indicators to indicate scrollable content
        collectionView.flashScrollIndicators()
    }
    
    /// the no. of days in current month
    func noOfDaysInMonth() -> Int {
        let range = hijriCalendar.range(of: .day, in: .month, for: date)
        return range!.count
    }
    
    /// returns header string for column
    func headerForColumn(_ column: Int) -> String {
        switch column {
        case 0:
            return "HIJRI DATE"
        case 1:
            return "DATE"
        case 2:
            return "SUHUR"
        default:
            return "IFTAR"
        }
    }

    /// returns date to display in given row
    func dateForRow(row: Int) -> Date {
        var comps = hijriCalendar.dateComponents([.month, .year], from: date)
        comps.day = row - UserSettings.shared.hijriDateAdjustment
        return hijriCalendar.date(from: comps)!
    }
    
    /// Return hijri date as string for given row
    func hijriDateStringForRow(row: Int) -> String {
        let formatter = DateFormatter()
        formatter.calendar = hijriCalendar
        formatter.dateFormat = "d MMMM yyyy"
        var comps = hijriCalendar.dateComponents([.month, .year], from: date)
        comps.day = row
        let dateString = formatter.string(from: hijriCalendar.date(from: comps)!)
        return dateString
    }
    
    /// show next month
    @IBAction func nextMonth() {
        var comps = hijriCalendar.dateComponents([.month, .year], from: date)
        comps.month = comps.month! + 1
        comps.day = 1
        date = hijriCalendar.date(from: comps)
        collectionView.reloadData()
    }
    
    /// show previous month
    @IBAction func previousMonth() {
        var comps = hijriCalendar.dateComponents([.month, .year], from: date)
        comps.month = comps.month! - 1
        comps.day = 1
        date = hijriCalendar.date(from: comps)
        collectionView.reloadData()
    }
    
    // MARK: Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return noOfDaysInMonth() + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "TextCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TextCell
        
        if indexPath.section % 2 != 0 {
            cell.backgroundColor = UIColor(white: 242/255.0, alpha: 1.0)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        cell.textLabel.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel.textColor = UIColor.black
        
        if indexPath.section == 0 {
            cell.textLabel.text = headerForColumn(indexPath.row)
            cell.textLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        }
        else {
            let rowDate = dateForRow(row: indexPath.section)
            if indexPath.row == 0 {
                cell.textLabel.text = hijriDateStringForRow(row: indexPath.section)
                
            } else {
                cell.textLabel.textColor = UIColor.darkGray
                let calculator = SuhurAndIftarCalculator(date: rowDate)
                if indexPath.row == 2 {
                    // show suhur time
                    let suhurTime = dateFrom(day: dayOfYearFrom(date: rowDate), year: yearFromDate(date: rowDate), hours: calculator.suhurTime())!
                    cell.textLabel.text = dateInHourMinuteFormat(date: suhurTime)
                }
                if indexPath.row == 3 {
                    // show iftar time
                    let iftarTime = dateFrom(day: dayOfYearFrom(date: rowDate), year: yearFromDate(date: rowDate), hours: calculator.iftarTime())!
                    cell.textLabel.text = dateInHourMinuteFormat(date: iftarTime)
                }
                else if indexPath.row == 1 {
                    cell.textLabel.text = stringFromDate(formatString: "MMM d, yyyy", date: rowDate)
                }
            }
        }
        return cell
    }

}
