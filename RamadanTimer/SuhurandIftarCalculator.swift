//
//  SuhurAndIftarCalculator.swift
//  RamadanTimer
//
//  Created by Sumayyah on 24/09/16.
//  Copyright © 2016 Sumayyah. All rights reserved.
//

import Foundation

let D2R = Double.pi / 180
let R2D = 180 / Double.pi

class SuhurAndIftarCalculator {
    var date: Date
    
    /// Initialize with date
    init (date: Date = Date()) {
        self.date = date
    }
    
    /// Returns suhur time
    func suhurTime() -> Double {
        let location = LocationUtil.shared.location
        let day = Double(dayOfYearFrom(date: self.date))
        let lnHour = location.long / 15
        
        let angle = UserSettings.shared.fajrAngle!
        
        let zenith = 90 + angle;
        let t = day + ((6 - lnHour) / 24);
        
        //calculate the Sun's mean anomaly
        let M = (0.9856 * t) - 3.289;
        
        //calculate the Sun's true longitide
        let x = (0.020 * sin(2 * M*D2R))
        var L = M + (1.916 * sin(M*D2R)) + x + 282.634;
        if (L > 360) {
            L = L - 360;
        } else if (L < 0) {
            L = L + 360;
        }
        
        var RA = R2D*atan(0.91764 * tan(L*D2R));
        if (RA > 360) {
            RA = RA - 360;
        } else if (RA < 0) {
            RA = RA + 360;
        }
        //right ascension value needs to be in the same quadrant
        let Lquadrant  = (floor(L/(90))) * 90;
        let RAquadrant = (floor(RA/90)) * 90;
        RA = RA + (Lquadrant - RAquadrant);
        
        RA = RA / 15;
        
        //calculate the Sun's declination
        let sinDec = 0.39782 * sin(L*D2R);
        let cosDec = cos(asin(sinDec));
        
        let cosH = (cos(zenith*D2R) - (sinDec * sin(location.lat*D2R))) / (cosDec * cos(location.lat*D2R));
        
        var H = 360 - R2D * acos(cosH);
        H = H / 15;
        
        let T = H + RA - (0.06571 * t) - 6.622;
        
        var UT = T - lnHour;
        if (UT > 24) {
            UT = UT - 24;
        } else if (UT < 0) {
            UT = UT + 24;
        }
        
        var suhurLocalT =  UT  + localOffsetHours();
        
        // Use high latitude fajr methods if the normal is not working
        if suhurLocalT.isNaN {
            var previousDay: SuhurAndIftarCalculator
            // get year from date
            let year = yearFromDate(date: date)!
    
            if (day == 1){
                if ((year - 1) % 4 == 0){
                    // Doesn't matter which year it is
                    previousDay = SuhurAndIftarCalculator(date: dateFrom(day: 366, year: year - 1))
                }
                else {
                    previousDay = SuhurAndIftarCalculator(date: dateFrom(day: 365, year: year - 1))
                }
            }
            else {
                previousDay = SuhurAndIftarCalculator(date: dateFrom(day: Int(day) - 1, year: year))
            }
            let previousDaySunset = previousDay.iftarTime()
            let sunrise = self.sunriseTime()
            let nightlength = 24 - (previousDaySunset - sunrise);
            let hours: Double
            // Use selected calculating method for high latitude
            if UserSettings.shared.highLatitudeFajrMethod == midnight{
                hours = nightlength / 2;
                suhurLocalT = previousDaySunset + hours;
            }
            else if UserSettings.shared.highLatitudeFajrMethod == oneSeventhNight {
                hours = nightlength / 7;
                suhurLocalT = sunrise - hours;
            }
            else if UserSettings.shared.highLatitudeFajrMethod == angleBased {
                let t = angle / 60;
                hours  = nightlength * t;
                suhurLocalT = sunrise - hours;
            }
        }
        
        if (suhurLocalT > 24) {
            suhurLocalT = suhurLocalT - 24;
        } else if (suhurLocalT < 0) {
            suhurLocalT = suhurLocalT + 24;
        }
        let adjustment = Double(UserSettings.shared.suhurAdjustment) / 60
        return suhurLocalT + adjustment
    }
    
    /// Returns iftar time
    func iftarTime() -> Double {
        let location = LocationUtil.shared.location
        let day = Double(dayOfYearFrom(date: self.date))
        let lnHour = location.long / 15

        let zenith = 90 + 5/6.0;
        
        // convert the longitude to hour value and calculate an approximate time
        
        let t = day + ((18-lnHour)/24);
        
        
        //calculate the Sun's mean anomaly
        let M = (0.9856 * t) - 3.289;
        
        //calculate the Sun's true longitide
        let x = (0.020 * sin(2 * M * D2R))
        var L = M + (1.916 * sin(M*D2R)) + x + 282.634;
        if (L > 360) {
            L = L - 360;
        } else if (L < 0) {
            L = L + 360;
        }
        
        //calculate the Sun's right ascension
        var RA = R2D*atan(0.91764 * tan(L*D2R));
        if (RA > 360) {
            RA = RA - 360;
        } else if (RA < 0) {
            RA = RA + 360;
        }
        
        //right ascension value needs to be in the same quadrant
        let Lquadrant  = (floor(L/(90))) * 90;
        let RAquadrant = (floor(RA/90)) * 90;
        RA = RA + (Lquadrant - RAquadrant);
        
        //right ascension value needs to be converted into hours
        RA = RA / 15;
        
        //calculate the Sun's declination
        let sinDec = 0.39782 * sin(L*D2R);
        let cosDec = cos(asin(sinDec));
        
        //calculate the Sun's local hour angle
        let cosH = (cos(zenith*D2R) - (sinDec * sin(location.lat*D2R))) / (cosDec * cos(location.lat*D2R));
        var H: Double;
        
        H = R2D*acos(cosH);
        
        H = H / 15;
        
        //calculate local mean time of rising/setting
        let T = H + RA - (0.06571 * t) - 6.622;
        
        //adjust back to UTC
        var UT = T - lnHour;
        if (UT > 24) {
            UT = UT - 24;
        } else if (UT < 0) {
            UT = UT + 24;
        }
        // adjust to local time
        var iftarLocalT =  UT  + localOffsetHours();
        
        if (iftarLocalT > 24) {
            iftarLocalT = iftarLocalT - 24;
        } else if (iftarLocalT < 0) {
            iftarLocalT = iftarLocalT + 24;
        }
        let adjustment = Double(UserSettings.shared.iftarAdjustment) / 60
        return iftarLocalT + adjustment
    }
    
    /// Returns sunrise time
    private func sunriseTime() -> Double {
        let location = LocationUtil.shared.location
        let day = Double(dayOfYearFrom(date: self.date))
        let lnHour = location.long / 15
        
        let zenith = 90 + 5/6.0;
        let t = day + ((6 - lnHour) / 24);
        
        let M = (0.9856 * t) - 3.289;
        
        let x = (0.020 * sin(2 * M*D2R))
        var L = M + (1.916 * sin(M*D2R)) + x + 282.634;
        if (L > 360) {
            L = L - 360;
        } else if (L < 0) {
            L = L + 360;
        }
        
        var RA = R2D*atan(0.91764 * tan(L*D2R));
        if (RA > 360) {
            RA = RA - 360;
        } else if (RA < 0) {
            RA = RA + 360;
        }
        let Lquadrant  = (floor(L/(90))) * 90;
        let RAquadrant = (floor(RA/90)) * 90;
        RA = RA + (Lquadrant - RAquadrant);
        
        RA = RA / 15;
        
        let sinDec = 0.39782 * sin(L*D2R);
        let cosDec = cos(asin(sinDec));
        
        let cosH = (cos(zenith*D2R) - (sinDec * sin(location.lat*D2R))) / (cosDec * cos(location.lat*D2R));
        
        var H = 360 - R2D * acos(cosH);
        H = H / 15;
        
        //calculate local mean time of rising/setting
        let T = H + RA - (0.06571 * t) - 6.622;
        
        var UT = T - lnHour;
        if (UT > 24) {
            UT = UT - 24;
        } else if (UT < 0) {
            UT = UT + 24;
        }
        
        // Convert to local time
        var sunriseLocalT =  UT  + localOffsetHours();
        if (sunriseLocalT > 24) {
            sunriseLocalT = sunriseLocalT - 24;
        } else if (sunriseLocalT < 0) {
            sunriseLocalT = sunriseLocalT + 24;
        }
        return sunriseLocalT
    }
}
