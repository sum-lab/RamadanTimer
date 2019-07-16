//
//  LocationDetailViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 01/07/18.
//  Copyright © 2018 Sumayyah. All rights reserved.
//

import UIKit

/// Shows location detail, including latitude and longitude
class LocationDetailViewController: UIViewController {

    /// selected location
    var location: City!
    
    // outlets
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        latitudeLabel.text = "Latitude: \(location.latitude!.doubleValue)"
        longitudeLabel.text = "Longitude: \(location.longitude!.doubleValue)"
    }
    
    /// set new location action
    @IBAction func setLocation() {
        LocationUtil.shared.location.lat = location.latitude!.doubleValue
        LocationUtil.shared.location.long = location.longitude!.doubleValue
        LocationUtil.shared.locationName = "\(location.name!), \(location.country!)"
        LocationUtil.shared.saveNewLocation()
        LocationUtil.shared.delegate.locationUpdated()
        navigationController?.popToRootViewController(animated: true)
    }
}
