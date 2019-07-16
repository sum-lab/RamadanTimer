//
//  SettingsTableViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 19/06/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import UIKit

let blueColor = UIColor(red: 0, green: 0.13, blue: 0.56, alpha: 1.0)

/**
 View controller for displaying settings
 */
class SettingsTableViewController: UITableViewController {
    
    let alarmSwitch = UISwitch()
    let autoLocationSwitch = UISwitch()

    override func viewDidLoad() {
        // configure switches
        alarmSwitch.onTintColor = blueColor
        alarmSwitch.isOn = UserSettings.shared.notifications
        alarmSwitch.addTarget(self, action: #selector(self.switchChanged), for: .valueChanged)
        autoLocationSwitch.onTintColor = blueColor
        autoLocationSwitch.isOn = UserSettings.shared.autoLocation
        autoLocationSwitch.addTarget(self, action: #selector(self.switchChanged), for: .valueChanged)
    }
    
    /// reload cells
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    /// Alarm and Auto location switches on/off
    @objc func switchChanged(sender: UISwitch) {
        if sender == alarmSwitch {
            UserSettings.shared.notifications = sender.isOn
            AlarmManager.shared.alarmSwitchChanged(state: sender.isOn)
        }
        else if sender == autoLocationSwitch {
            UserSettings.shared.autoLocation = sender.isOn
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section){
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        case 3:
            return 3
        case 4:
            return 2
        case 5:
            return 1
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)

        // Configure the cell...
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
        cell.detailTextLabel?.text = ""
        if indexPath.section == 0 {
            cell.accessoryType = .none
            cell.textLabel?.text = "Alarm"
            cell.accessoryView = alarmSwitch
            cell.selectionStyle = .none
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Calculation Method"
                cell.detailTextLabel?.text = UserSettings.shared.calcMethod
            }
            else {
                cell.textLabel?.text = "Custom Fajr Angle"
                cell.detailTextLabel?.text = "\(UserSettings.shared.fajrAngle!)°"
                // disable cell if custom fajr angle method is not chosen
                let enabled = (UserSettings.shared.calcMethod == customFajrAngleKey)
                cell.isUserInteractionEnabled = enabled
                cell.textLabel?.isEnabled = enabled
                cell.detailTextLabel?.isEnabled = enabled
            }
        }
        else if indexPath.section == 2 {
            cell.textLabel?.text = "High Latitude Fajr Method"
            cell.detailTextLabel?.text = "\(UserSettings.shared.highLatitudeFajrMethod!)"
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Suhur"
                cell.detailTextLabel?.text = stringFromAdjustment(UserSettings.shared.suhurAdjustment!) + " mins"
            }
            else if indexPath.row == 1 {
                cell.textLabel?.text = "Iftar"
                cell.detailTextLabel?.text = stringFromAdjustment(UserSettings.shared.iftarAdjustment!) + " mins"
            }
            else {
                cell.textLabel?.text = "Hijri Date"
                cell.detailTextLabel?.text = stringFromAdjustment(UserSettings.shared.hijriDateAdjustment!) + " days"
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Automatic Location"
                cell.accessoryType = .none
                cell.selectionStyle = .none
                cell.accessoryView = autoLocationSwitch
            }
            else {
                cell.textLabel?.text = "Change Location"
                let enabled = !UserSettings.shared.autoLocation
                cell.isUserInteractionEnabled = enabled
                cell.textLabel?.isEnabled = enabled
            }
        }
        /*else if indexPath.section == 5 {
            cell.textLabel?.text = "Write a Review"
            cell.accessoryType = .none
        }*/

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = blueColor
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica-Bold", size: 16)
        if section == 2 {
            label.text = "  High Latitude"
        }
        if section == 3 {
            label.text = "  Adjustments"
        }
        if section == 4 {
            label.text = "  Location"
        }
        label.sizeToFit()
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 || section == 4 {
            return 35.0
        }
        return 0
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Navigate to selected setting
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "calcMethodsSegue", sender: nil)
            }
            else if indexPath.row == 1 {
                performSegue(withIdentifier: "pickerSegue", sender: PickerType.fajrAngle)
            }
        }
        else if indexPath.section == 2 {
            performSegue(withIdentifier: "highLatFajrMethodSegue", sender: nil)
        }
        else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "pickerSegue", sender: PickerType.suhurAdjustment)
            case 1:
                performSegue(withIdentifier: "pickerSegue", sender: PickerType.iftarAdjustment)
            default:
                performSegue(withIdentifier: "pickerSegue", sender: PickerType.hijriDateAdjustment)
            }
        }
        else if indexPath.section == 4 && indexPath.row == 1 {
            performSegue(withIdentifier: "locationSearchSegue", sender: nil)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickerSegue" {
            let pickerVC = segue.destination as! PickerViewController
            pickerVC.type = sender as? PickerType
        }
    }
    

}
