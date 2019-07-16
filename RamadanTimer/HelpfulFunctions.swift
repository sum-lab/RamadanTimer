//
//  HelpfulFunctions.swift
//  RamadanTimer
//
//  Created by Sumayyah on 24/09/16.
//  Copyright © 2016 Sumayyah. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

let calendar = Calendar(identifier: .gregorian)

// MARK: Dates
func dateFrom(day: Int, year: Int, hours: Double = 0) -> Date! {
    var comps = DateComponents()
    comps.year = year
    comps.day = day
    let seconds = Int(hours * 3600)
    comps.second = seconds
    return calendar.date(from: comps)
}

func dayOfYearFrom(date: Date) -> Int! {
    let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)
    return dayOfYear
}

func yearFromDate(date:Date) -> Int! {
    let year = calendar.component(.year, from: date)
    return year
}

func localOffsetHours() -> Double {
    let localOffset = NSTimeZone.system.secondsFromGMT()
    return Double(localOffset) / 3600
}

func stringFromDate(formatString: String, date: Date) -> String! {
    let formatter = DateFormatter()
    formatter.dateFormat = formatString
    let dateString = formatter.string(from: date)
    return dateString
}

/// return today's Hijri date in d MMMM yyyy format
func currentHijriDateString() -> String {
    let hijriCalender = Calendar(identifier: .islamicUmmAlQura)
    let formatter = DateFormatter()
    formatter.calendar = hijriCalender
    formatter.dateFormat = "d MMMM yyyy"
    var comps = hijriCalender.dateComponents([.day,.month, .year], from: Date())
    comps.day! += UserSettings.shared.hijriDateAdjustment
    let dateString = formatter.string(from: hijriCalender.date(from: comps)!)
    return dateString
}

/// Converts seconds to "HH:mm:ss" format
func stringFromTimeInterval(interval: TimeInterval) -> String {
    
    let seconds = Int(interval);
    return String(format: "%02u : %02u : %02u",
                  seconds / 3600, (seconds / 60) % 60, seconds % 60)
}

/// Returns string in "HH:mm" format or am/pm format
func dateInHourMinuteFormat(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter.string(from: date)
}

// MARK: Location
/// Returns address string from given location coordinates in the format "City, Country"
func locationNameFromCoordinates(location: CLLocation, completion: @escaping (String) -> Void) {
    let geocoder = CLGeocoder()
    // timeout after 5 secs
    let _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {_ in
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }})
    
    geocoder.reverseGeocodeLocation(location, completionHandler: {
        placemarks, error in
        
        if error == nil && (placemarks?.count)! > 0 {
            let placeMark = placemarks?.last
            let address = "\(placeMark!.locality!), \(placeMark!.country!)"
            completion(address)
        }
        else {
            // return coordinates if reverse geocoding fails
            completion("\(location.coordinate.latitude.truncate(places: 2))°, \(location.coordinate.longitude.truncate(places: 2))°")
        }
    })
}

func stringFromAdjustment(_ adjustment: Int) -> String {
    return adjustment > 0 ? "+\(adjustment)" : "\(adjustment)"
}

// MARK: - Table View controller extension
extension UITableViewController {
    
    /// check cell and decheck all other cells
    func checkCellAtIndexPath(_ indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        for i in 0..<tableView.numberOfRows(inSection: 0) {
            if i != indexPath.row {
                tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .none
            }
        }
    }
}

// MARK: - Double extension
extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
