//
//  TestModel.swift
//  CurrentlyRunningApps
//
//  Created by 30hills on 10/25/17.
//  Copyright © 2017 30Hills. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class TestModel : Object {
    
    @objc dynamic var gyroData : String = ""
    @objc dynamic var accelData : String = ""
    @objc dynamic var magneData : String = ""
    @objc dynamic var currentDate : NSDate = NSDate()
    @objc dynamic var gyroFileName : String = ""
    @objc dynamic var accelFileName : String = ""
    @objc dynamic var magneFileName : String = ""
    
    convenience init?(gyroData : String, accelData : String, magneData : String, gyroFileName : String, accelFileName : String, magneFileName : String) {
        self.init()
        self.gyroData = gyroData
        self.accelData = accelData
        self.magneData = magneData
        self.currentDate = NSDate()
        self.gyroFileName = gyroFileName
        self.accelFileName = accelFileName
        self.magneFileName = magneFileName
    }
    
   
    
}
