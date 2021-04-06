//
//  ChooseIntervalsTableViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 04/05/20.
//  Copyright © 2020 Sumayyah. All rights reserved.
//

import UIKit

class ChooseIntervalsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Suhur"
        }
        return "Iftar"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath)

        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "-30 minutes"
        case 1:
            cell.textLabel?.text = "-20 minutes"
        case 2:
            cell.textLabel?.text = "-10 minutes"
        case 3:
            cell.textLabel?.text = "-5 minutes"
        case 4:
            cell.textLabel?.text = "-1 minute"
        default:
            cell.textLabel?.text = ""
        }
        if indexPath.section == 0 {
            if UserSettings.shared.timeIntervalsForSuhur.contains(indexPath.row) {
               cell.accessoryType = .checkmark
            }
        }
        else {
            if UserSettings.shared.timeIntervalsForIftar.contains(indexPath.row) {
                cell.accessoryType = .checkmark
            }
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // check non-checked cell, decheck checked cell if selected
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        // update user settings
        var intervals = indexPath.section == 0 ? UserSettings.shared.timeIntervalsForSuhur! : UserSettings.shared.timeIntervalsForIftar!
        if intervals.contains(indexPath.row) {
            intervals.remove(at: intervals.firstIndex(of: indexPath.row)!)
        }
        else {
            intervals.append(indexPath.row)
        }
                
        if indexPath.section == 0 {
            UserSettings.shared.timeIntervalsForSuhur = intervals
        }
        else {
            UserSettings.shared.timeIntervalsForIftar = intervals
        }
        AlarmManager.shared.update()
        
    }

}
