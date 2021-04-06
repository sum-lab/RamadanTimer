//
//  HighLatFajrMethodViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 22/06/18.
//  Copyright © 2018 Sumayyah. All rights reserved.
//

import UIKit

/**
 View for choosing high latitude fajr method
 */
class HighLatFajrMethodViewController: UITableViewController {

    let fajrMethods: [String] = [midnight, oneSeventhNight, angleBased]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fajrMethods.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UITextView(frame: CGRect.zero)
        // Configure text view
        footerView.font = UIFont.systemFont(ofSize: 16)
        footerView.backgroundColor = UIColor.clear
        footerView.isEditable = false
        footerView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        footerView.text = "At higher latitudes, twilight may persist throughout the  night in some months. Fajr is impossible to determine using the usual formula.\n\n• The Midnight method divides the time between sunrise and sunset into two halves, and Fajr is at the midnight point.\n• The One-seventh night method divides the time between sunrise and sunset into seven parts, with Fajr at the start of the seventh part.\n• The Angle-based method uses this formula to divide the time between sunrise and sunset: Number of parts = twilight angle for Fajr ÷ 60\nFajr is at the beginning of the last part."
        footerView.sizeToFit()
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FajrMethodCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = fajrMethods[indexPath.row]
        // check selected method
        if indexPath.row == fajrMethods.firstIndex(of: UserSettings.shared.highLatitudeFajrMethod) {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkCellAtIndexPath(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedValue = fajrMethods[indexPath.row]
        // save selected value
        UserSettings.shared.highLatitudeFajrMethod = selectedValue
        AlarmManager.shared.update()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
