//
//  Alarm.swift
//  RamadanTimer
//
//  Created by Sumayyah on 15/06/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import Foundation

enum AlarmType : String {
    case suhur = "Suhur"
    case iftar = "Iftar"
}

class Alarm {
    var type: AlarmType
    var date: Date
    
    init(date: Date, type: AlarmType) {
        self.type = type
        self.date = date
    }
}
