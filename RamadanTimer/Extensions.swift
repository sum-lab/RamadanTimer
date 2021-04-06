//
//  Extensions.swift
//  RamadanTimer
//
//  Created by Sumayyah on 04/05/20.
//  Copyright © 2020 Sumayyah. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIViewController Extension
extension UIViewController {
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Table View controller extension
extension UITableViewController {
    
    /// check cell and decheck all other cells
    func checkCellAtIndexPath(_ indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        for i in 0..<tableView.numberOfRows(inSection: 0) {
            if i != indexPath.row {
                tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .none
            }
        }
    }
}

// MARK: - Double extension
extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
