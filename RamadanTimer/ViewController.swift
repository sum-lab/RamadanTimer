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
    private var dateTimer: Timer!
    
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
        
        // set up location
        LocationUtil.shared.delegate = self
        LocationUtil.shared.setUpLocation()
        
        // display date
        updateDates()
        updateLabels()
                
        // start timer
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
        dateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateDates), userInfo: nil, repeats: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // update dates
        hideSlideshowIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        hideSlideshowIfNeeded()
    }
    
    @objc func updateLabels() {
        if !locationSet {
            return
        }
        let alarm = AlarmManager.shared.nextAlarm
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
    
    @objc private func updateDates() {
        dateLabel.text = stringFromDate(formatString: "EEEE, MMM d, yyyy", date: Date())
        hijriDateLabel.text = currentHijriDateString()
    }
    
    // MARK: - Location manager delegate
    func locationUpdated() {
        locationSet = true
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.waitingForLocation.isHidden = true
            self.locationLabel.text = LocationUtil.shared.locationName
            self.startSlideshow()
            self.hideSlideshowIfNeeded()
        }
        // show alert if location access not granted
        if !LocationUtil.shared.locationAuthorized() && !UserDefaults.standard.bool(forKey: "locationDenied"){
            showErrorAlert(title: "Location Access Denied!", message:
            "Your location is set to Makkah, Saudi Arabia. To use your current location, go to Settings->Privacy->Location Services and turn on location access for this app. Or manually choose a location by going to the Settings tab->Change Location")
            UserDefaults.standard.set(true, forKey: "locationDenied")
        }
        // schedule notifications
        AlarmManager.shared.update()
    }
    
    // MARK: - Slideshow
    func startSlideshow() {
        slideshowView.images = [UIImage(named:"sunrise")!, UIImage(named:"waterfall")!, UIImage(named:"sunset")!, UIImage(named:"mountains")!, UIImage(named:"moonrise")!]
        slideshowView.imageDuration = 10.0
        slideshowView.startSlideshow()
    }
    
    /// hides or shows slideshow according to screen height
    func hideSlideshowIfNeeded() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIApplication.shared.statusBarOrientation.isLandscape && UIDevice.current.userInterfaceIdiom == .pad{
                slideshowView.isHidden = true
            }
            else {
                slideshowView.isHidden = false
            }
        }
        else if screenHeight() <= 680 {
            slideshowView.isHidden = true
        }
    }
    
}

