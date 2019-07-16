//
//  AlarmManager.swift
//  RamadanTimer
//
//  Created by Sumayyah on 15/06/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import Foundation
import UIKit

class AlarmManager {
    
    /// app delegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// shared instance
    static let shared = AlarmManager()
    
    ///  whether notifications already scheduled
    var scheduledNotifs = false
    
    /// Returns array of suhur timings for next 5 days
    func suhurDates() -> [Date] {
        var dates = [Date]()
        let calculator = SuhurAndIftarCalculator()
        let today = Date()
        
        for i in 0...5 {
            let date = Date(timeIntervalSinceNow: Double(i * 86400))
            calculator.date = date
            
            let suhurTime = dateFrom(day: dayOfYearFrom(date: date), year: yearFromDate(date: date), hours: calculator.suhurTime())!
            // Check that date has not already passed, then add into array
            if suhurTime.timeIntervalSince(today) > 0 {
                dates.append(suhurTime)
            }
        }
        return dates
    }
    
    /// Returns array of iftar timings for next 5 days
    func iftarDates() -> [Date] {
        var dates = [Date]()
        let calculator = SuhurAndIftarCalculator()
        let today = Date()
        
        for i in 0...5 {
            let date = Date(timeIntervalSinceNow: Double(i * 86400))
            calculator.date = date
            
            let iftarTime = dateFrom(day: dayOfYearFrom(date: date), year: yearFromDate(date: date), hours: calculator.iftarTime())!
            // Check that date has not already passed, then add into array
            if iftarTime.timeIntervalSince(today) > 0 {
                dates.append(iftarTime)
            }
        }
        return dates
    }
    
    /// Get next alarm date
    func nextAlarm() -> Alarm {
        let today = Date()
        let calculator = SuhurAndIftarCalculator()
        calculator.date = today
        let suhur = dateFrom(day: dayOfYearFrom(date: today), year: yearFromDate(date: today), hours: calculator.suhurTime())!
        let iftar = dateFrom(day: dayOfYearFrom(date: today), year: yearFromDate(date: today), hours: calculator.iftarTime())!
        
        if suhur < today && iftar < today {
            calculator.date = Date(timeIntervalSinceNow: 86400)
            let nextDaySuhur = dateFrom(day: dayOfYearFrom(date: calculator.date), year: yearFromDate(date: calculator.date), hours: calculator.suhurTime())!
            return Alarm(date: nextDaySuhur, type: .suhur)
        }
        
        if suhur > today {
            return Alarm(date: suhur, type: .suhur)
        }
        return Alarm(date: iftar, type: .iftar)
    }
    
    // MARK: Notifications
    
    /// Schedule notifications
    func scheduleAllNotificationsIfNeeded() {
        if LocationUtil.shared.locationSet && UserSettings.shared.notifications == true {
            DispatchQueue.global(qos: .background).async {
                self.appDelegate.center.removeAllPendingNotificationRequests()
                // schedule iftar notifications
                for date in self.iftarDates() {
                    // ten minutes left
                    let tenMinutesDate = Date(timeInterval: -600, since: date)
                    self.appDelegate.scheduleNotification(title: "Ten minutes left.", sound: "tenminutesleft.mp3", date: tenMinutesDate)
                    // five minutes left
                    let fiveMinutesDate = Date(timeInterval: -300, since: date)
                    self.appDelegate.scheduleNotification(title: "Five minutes left.", sound: "fiveminutesleft.mp3", date: fiveMinutesDate)
                    // one minute left
                    let oneMinuteDate = Date(timeInterval: -60, since: date)
                    self.appDelegate.scheduleNotification(title: "One minute left.", sound: "oneminuteleft.mp3", date: oneMinuteDate)
                    // iftar time
                    self.appDelegate.scheduleNotification(title: "It's time to break your fast.", sound: "breakfast.mp3", date: date)
                }
                
                // schedule suhur notifications
                for date in self.suhurDates() {
                    // thirty minutes left
                    let thirtyMinutesDate = Date(timeInterval: -1800, since: date)
                    self.appDelegate.scheduleNotification(title: "Thirty minutes left.", sound: "thirtyminutesleft.mp3", date: thirtyMinutesDate)
                    // twenty minutes left
                    let twentyMinutesDate = Date(timeInterval: -1200, since: date)
                    self.appDelegate.scheduleNotification(title: "Twenty minutes left.", sound: "twentyminutesleft.mp3", date: twentyMinutesDate)
                    // ten minutes left
                    let tenMinutesDate = Date(timeInterval: -600, since: date)
                    self.appDelegate.scheduleNotification(title: "Ten minutes left.", sound: "tenminutesleft.mp3", date: tenMinutesDate)
                    // five minutes left
                    let fiveMinutesDate = Date(timeInterval: -300, since: date)
                    self.appDelegate.scheduleNotification(title: "Five minutes left.", sound: "fiveminutesleft.mp3", date: fiveMinutesDate)
                    // one minute left
                    let oneMinuteDate = Date(timeInterval: -60, since: date)
                    self.appDelegate.scheduleNotification(title: "One minute left.", sound: "oneminuteleft.mp3", date: oneMinuteDate)
                    // suhur time
                    self.appDelegate.scheduleNotification(title: "It's time to stop eating.", sound: "stopeating.mp3", date: date)
                }
            }
            scheduledNotifs = true
        }
    }
    
    func alarmSwitchChanged(state: Bool) {
        if state == true {
            scheduleAllNotificationsIfNeeded()
        }
        else {
            self.appDelegate.center.removeAllPendingNotificationRequests()
            scheduledNotifs = false
        }
    }
}
