//
//  PickerViewController.swift
//  RamadanTimer
//
//  Created by Sumayyah on 25/06/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import UIKit

/// types of pickers to display
enum PickerType: String {
    case fajrAngle = "fajrAngle"
    case iftarAdjustment = "iftarAdjustment"
    case suhurAdjustment = "suhurAdjustment"
    case hijriDateAdjustment = "hijriDateAdjustment"
}

/**
 View with picker for choosing fajr angle, adjustments
 */
class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var picker: UIPickerView!
    var type: PickerType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // select row
        var selectedRow = 0
        if type == .fajrAngle {
            selectedRow = Int(2 * UserSettings.shared.fajrAngle - 24)
        }
        else if type == .iftarAdjustment {
            selectedRow = Int(UserSettings.shared.iftarAdjustment + 10)
        }
        else if type == .suhurAdjustment {
            selectedRow = Int(UserSettings.shared.suhurAdjustment + 10)
        }
        else if type == .hijriDateAdjustment {
            selectedRow = Int(UserSettings.shared.hijriDateAdjustment + 10)
        }
        picker.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    // MARK: Picker data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 21
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch type {
        case .fajrAngle?:
            return "\(Double(row) + 12 - (0.5 * Double(row)))°"
        case .hijriDateAdjustment?:
            return stringFromAdjustment(row - 10) + " days"
        default:
            return stringFromAdjustment(row - 10) + " mins"
        }
    }
    
    // MARK: Picker Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if type == .fajrAngle {
            UserSettings.shared.calcMethod = customFajrAngleKey
            calcMethods[customFajrAngleKey] = Double(row) + 12 - (0.5 * Double(row))
            UserSettings.shared.fajrAngle = calcMethods[customFajrAngleKey]
        }
        else if type == .iftarAdjustment {
            UserSettings.shared.iftarAdjustment = row - 10
        }
        else if type == .suhurAdjustment {
            UserSettings.shared.suhurAdjustment = row - 10
        }
        else if type == .hijriDateAdjustment {
            UserSettings.shared.hijriDateAdjustment = row - 10
        }
        // schedule notifications again
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
