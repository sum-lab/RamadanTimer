//
//  CalculationMethodsTableViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 24/06/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import UIKit

class CalculationMethodsTableViewController: UITableViewController {

    /// Calculation methods strings
    let keys = Array(calcMethods.keys)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calcMethods.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalcMethodCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = keys[indexPath.row]
        cell.detailTextLabel?.text = "Fajr Angle: \(calcMethods[keys[indexPath.row]]!)°"
        if indexPath.row == keys.index(of: UserSettings.shared.calcMethod) {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkCellAtIndexPath(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedValue = calcMethods[keys[indexPath.row]]!
        // save selected value
        UserSettings.shared.fajrAngle = selectedValue
        UserSettings.shared.calcMethod = keys[indexPath.row]
        AlarmManager.shared.scheduleAllNotificationsIfNeeded()
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
