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
    
    /// the next suhur or iftar date
    var nextAlarm: Alarm
    
    /// timer to update next alarm date
    private var updateTimer: Timer!
    
    init() {
        nextAlarm = AlarmManager.nextAlarm()
        updateTimer = Timer(fireAt: nextAlarm.date, interval: 0, target: self, selector: #selector(update), userInfo: nil, repeats: false)
        RunLoop.main.add(updateTimer, forMode: .common)
    }
    
    @objc func update() {
        nextAlarm = AlarmManager.nextAlarm()
        scheduleAllNotificationsIfNeeded()
        updateTimer = Timer(fireAt: nextAlarm.date, interval: 0, target: self, selector: #selector(update), userInfo: nil, repeats: false)
        RunLoop.main.add(updateTimer, forMode: .common)
    }
    
    /// Returns array of suhur timings for next 6 days
    func suhurDates() -> [Date] {
        var dates = [Date]()
        let calculator = SuhurAndIftarCalculator()
        let today = Date()
        
        for i in 0...6 {
            let date = Date(timeIntervalSinceNow: Double(i * 86400 + 1))
            calculator.date = date
            
            let suhurTime = dateFrom(day: dayOfYearFrom(date: date), year: yearFromDate(date: date), hours: calculator.suhurTime())!
            // Check that date has not already passed, then add into array
            if suhurTime.timeIntervalSince(today) > 0 {
                dates.append(suhurTime)
            }
        }
        return dates
    }
    
    /// Returns array of iftar timings for next 6 days
    func iftarDates() -> [Date] {
        var dates = [Date]()
        let calculator = SuhurAndIftarCalculator()
        let today = Date()
        
        for i in 0...6 {
            let date = Date(timeIntervalSinceNow: Double(i * 86400 + 1))
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
    class func nextAlarm() -> Alarm {
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
                var requests = [UNNotificationRequest]()
                // schedule iftar notifications
                for date in self.iftarDates() {
                    // thirty minutes left
                    if UserSettings.shared.timeIntervalsForIftar.contains(0) {
                        let thirtyMinutesDate = Date(timeInterval: -1800, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Thirty minutes left.", sound: "thirtyminutesleft.mp3", date: thirtyMinutesDate) {
                            requests.append(request)
                        }
                    }
                    
                    // twenty minutes left
                    if UserSettings.shared.timeIntervalsForIftar.contains(1) {
                        let twentyMinutesDate = Date(timeInterval: -1200, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Twenty minutes left.", sound: "twentyminutesleft.mp3", date: twentyMinutesDate) {
                            requests.append(request)
                        }
                    }
                    // ten minutes left
                    if UserSettings.shared.timeIntervalsForIftar.contains(2) {
                        let tenMinutesDate = Date(timeInterval: -600, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Ten minutes left.", sound: "tenminutesleft.mp3", date: tenMinutesDate) {
                            requests.append(request)
                        }
                    }
                    // five minutes left
                    if UserSettings.shared.timeIntervalsForIftar.contains(3) {
                        let fiveMinutesDate = Date(timeInterval: -300, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Five minutes left.", sound: "fiveminutesleft.mp3", date: fiveMinutesDate) {
                            requests.append(request)
                        }
                    }
                    // one minute left
                    if UserSettings.shared.timeIntervalsForIftar.contains(4) {
                        let oneMinuteDate = Date(timeInterval: -60, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "One minute left.", sound: "oneminuteleft.mp3", date: oneMinuteDate) {
                            requests.append(request)
                        }
                    }
                    // iftar time
                    if let iftarRequest = self.appDelegate.createNotificationRequest(title: "It's time to break your fast.", sound: "breakfast.mp3", date: date) {
                        requests.append(iftarRequest)
                    }
                }
                
                // schedule suhur notifications
                for date in self.suhurDates() {
                    // thirty minutes left
                    if UserSettings.shared.timeIntervalsForSuhur.contains(0) {
                        let thirtyMinutesDate = Date(timeInterval: -1800, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Thirty minutes left.", sound: "thirtyminutesleft.mp3", date: thirtyMinutesDate) {
                            requests.append(request)
                        }
                    }
                    // twenty minutes left
                    if UserSettings.shared.timeIntervalsForSuhur.contains(1) {
                        let twentyMinutesDate = Date(timeInterval: -1200, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Twenty minutes left.", sound: "twentyminutesleft.mp3", date: twentyMinutesDate) {
                            requests.append(request)
                        }
                    }
                    // ten minutes left
                    if UserSettings.shared.timeIntervalsForSuhur.contains(2) {
                        let tenMinutesDate = Date(timeInterval: -600, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Ten minutes left.", sound: "tenminutesleft.mp3", date: tenMinutesDate) {
                            requests.append(request)
                        }
                    }
                    // five minutes left
                    if UserSettings.shared.timeIntervalsForSuhur.contains(3) {
                        let fiveMinutesDate = Date(timeInterval: -300, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "Five minutes left.", sound: "fiveminutesleft.mp3", date: fiveMinutesDate) {
                            requests.append(request)
                        }
                    }
                    // one minute left
                    if UserSettings.shared.timeIntervalsForSuhur.contains(4) {
                        let oneMinuteDate = Date(timeInterval: -60, since: date)
                        if let request = self.appDelegate.createNotificationRequest(title: "One minute left.", sound: "oneminuteleft.mp3", date: oneMinuteDate) {
                            requests.append(request)
                        }
                    }
                    // suhur time
                    if let suhurRequest = self.appDelegate.createNotificationRequest(title: "It's time to stop eating.", sound: "stopeating.mp3", date: date) {
                        requests.append(suhurRequest)
                    }
                }
                self.appDelegate.scheduleNotifications(requests: requests)
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
