//
//  ViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 24/09/16.
//  Copyright © 2016 Sumayyah. All rights reserved.
//

import UIKit
import CoreLocation

/**
 Main view controller
 */
class ViewController: UIViewController, LocationDelegate {
    
    var locationSet = false
    
    var timer = Timer()
    
    /// App Delegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: IBOutlets
    
    /// Location
    @IBOutlet var locationLabel: UILabel!
    
    /// Today's date
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var hijriDateLabel: UILabel!
    
    /// "Suhur/iftar time"
    @IBOutlet var titleLabel1: UILabel!
    
    /// Suhur/Iftar
    @IBOutlet var timeLabel: UILabel!
    
    /// "Time left for Suhur/Iftar"
    @IBOutlet var titleLabel2: UILabel!
    
    /// Time left for suhur/iftar
    @IBOutlet var timeLeftLabel: UILabel!
    
    // waiting for location information
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var waitingForLocation: UILabel!
    
    /// adhkar slideshow
    @IBOutlet var slideshowView: SimpleImageSlideshow!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set up location
        LocationUtil.shared.delegate = self
        LocationUtil.shared.setUpLocation()
        
        // display date
        dateLabel.text = stringFromDate(formatString: "EEEE, MMM d, yyyy", date: Date())
        hijriDateLabel.text = currentHijriDateString()
        updateLabels()
                
        // start timer
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
    }
    
    @objc func updateLabels() {
        if !locationSet {
            return
        }
        let alarm = AlarmManager.shared.nextAlarm()
        let string = alarm.type.rawValue
        let date = alarm.date
        
        // Set time labels
        titleLabel1.text = "\(string) time"
        timeLabel.text = dateInHourMinuteFormat(date: date)
        
        // set time left labels
        titleLabel2.text = "Time left for \(string)"
        let timeLeft = date.timeIntervalSinceNow
        timeLeftLabel.text = stringFromTimeInterval(interval: timeLeft)
    }
    
    
    // MARK: Location manager delegate
    func locationUpdated() {
        locationSet = true
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.waitingForLocation.isHidden = true
            self.locationLabel.text = LocationUtil.shared.locationName
            self.startSlideshow()
        }
        // schedule notifications
        AlarmManager.shared.scheduleAllNotificationsIfNeeded()
    }
    
    func startSlideshow() {
        slideshowView.images = [UIImage(named:"sunrise")!, UIImage(named:"waterfall")!, UIImage(named:"sunset")!, UIImage(named:"mountains")!, UIImage(named:"moonrise")!]
        slideshowView.imageDuration = 10.0
        slideshowView.startSlideshow()
    }

}

