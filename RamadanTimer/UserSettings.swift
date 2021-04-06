//
//  UserDefaults.swift
//  RamadanTimer
//
//  Created by Sumayyah on 28/05/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import Foundation

// Setting Strings
// Calculation Methods
let univOfIslamicSciencesKarachiKey = "Univ. of Islamic Sciences, Karachi"
let muslimWorldLeagueKey = "Muslim World League"
let ummulQuraUnivMakkahKey = "Ummul Qura Univ., Makkah"
let egyptianGeneralAuthorityOfSurveyKey = "Egyptian General Authority of Survey"
let universityOfTehranKey = "University of Tehran"
let uiofKey = "UIOF (France)"
let islamicSocietyOfNorthAmericaKey = "Islamic Society of North America"
let customFajrAngleKey = "Custom Fajr Angle"
// Keys
let calcMethodKey = "calcMethod"
let autoLocationKey = "autoLocation"
let iftarAdjustmentKey = "iftarAdjustment"
let suhurAdjustmentKey = "suhurAdjustment"
let fajrAngleKey = "selectedFajrAngle"
let highLatitudeFajrMethodKey = "fajrMethod"
let notificationsKey = "notifications"
let hijriDateAdjustmentKey = "hijriDateAdjustment"
let timeIntervalsSuhurKey = "timeIntervalsForSuhur"
let timeIntervalsIftarKey = "timeIntervalsForIftar"

var calcMethods = [univOfIslamicSciencesKarachiKey: 18.0, muslimWorldLeagueKey: 18.0, ummulQuraUnivMakkahKey: 19.0, islamicSocietyOfNorthAmericaKey: 15.0, egyptianGeneralAuthorityOfSurveyKey: 19.5, universityOfTehranKey: 17.7, uiofKey: 12, customFajrAngleKey: 18.0]

// High Latitude Fajr methods
let midnight = "Midnight"
let oneSeventhNight = "One-seventh night"
let angleBased = "Angle based"

/// Manages user settings
class UserSettings {
    
    /// shared instance
    static let shared = UserSettings()
    
    var calcMethod: String! {
        set {
           UserDefaults.standard.set(newValue, forKey: calcMethodKey)
        }
        get {
            return UserDefaults.standard.string(forKey: calcMethodKey)
        }
    }
    
    var fajrAngle: Double! {
        set {
            UserDefaults.standard.set(newValue, forKey: fajrAngleKey)
        }
        get {
            return UserDefaults.standard.double(forKey: fajrAngleKey)
        }
    }
    
    var autoLocation: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: autoLocationKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: autoLocationKey)
        }
    }
    
    var iftarAdjustment: Int! {
        set {
            UserDefaults.standard.set(newValue, forKey: iftarAdjustmentKey)
        }
        get {
            return UserDefaults.standard.integer(forKey: iftarAdjustmentKey)
        }
    }
    
    var suhurAdjustment: Int! {
        set {
            UserDefaults.standard.set(newValue, forKey: suhurAdjustmentKey)
        }
        get {
            return UserDefaults.standard.integer(forKey: suhurAdjustmentKey)
        }
    }
    
    var hijriDateAdjustment: Int! {
        set {
            UserDefaults.standard.set(newValue, forKey: hijriDateAdjustmentKey)
        }
        get {
            return UserDefaults.standard.integer(forKey: hijriDateAdjustmentKey)
        }
    }
    
    var notifications: Bool! {
        set {
            UserDefaults.standard.set(newValue, forKey: notificationsKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: notificationsKey)
        }
    }
    
    var highLatitudeFajrMethod: String! {
        set {
            UserDefaults.standard.set(newValue, forKey: highLatitudeFajrMethodKey)
        }
        get {
            return UserDefaults.standard.string(forKey: highLatitudeFajrMethodKey)
        }
    }
    
    var timeIntervalsForSuhur: [Int]! {
        set {
            UserDefaults.standard.set(newValue, forKey: timeIntervalsSuhurKey)
        }
        get {
            return UserDefaults.standard.array(forKey: timeIntervalsSuhurKey) as? [Int]
        }
    }
    
    var timeIntervalsForIftar: [Int]! {
        set {
            UserDefaults.standard.set(newValue, forKey: timeIntervalsIftarKey)
        }
        get {
            return UserDefaults.standard.array(forKey: timeIntervalsIftarKey) as? [Int]
        }
    }
    
    /// sets default settings
    func setDefaults() {
        calcMethod = univOfIslamicSciencesKarachiKey
        fajrAngle = calcMethods[univOfIslamicSciencesKarachiKey]
        autoLocation = true
        suhurAdjustment = 0
        iftarAdjustment = 0
        highLatitudeFajrMethod = midnight
        notifications = true
        hijriDateAdjustment = 0
        timeIntervalsForSuhur = [0, 1, 2, 3, 4]
        timeIntervalsForIftar = [2, 3, 4]
    }
}
