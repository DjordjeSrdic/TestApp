//
//  SensorManager.swift
//  CurrentlyRunningApps
//
//  Created by 30hills on 11/2/17.
//  Copyright © 2017 30Hills. All rights reserved.
//

import UIKit
import Foundation
import CoreMotion

protocol SensorDataGatheringProtocol {
    func gyroscopeDataGathering(xAxisValue : String, yAxisValue : String, zAxisValue : String)
    func accelerometerDataGathering(xAxisValue : String, yAxisValue : String, zAxisValue : String)
    func magnetometerDataGathering(xAxisValue : String, yAxisValue : String, zAxisValue : String)
}


class SensorManager: NSObject {

    var sensorManager : CMMotionManager?
    
    private var gyroscopeSensorSelected : Bool = false
    private var accelometerSensorSelected : Bool = false
    private var magnetnometerSensorSelected : Bool = false
    private var gatheringProtocolDelegate : SensorDataGatheringProtocol?
   
    private var gyroQueue : OperationQueue?
    private var acccelQueue : OperationQueue?
    private var magnoQueue : OperationQueue?
    
    private var sensorDataGathered : String = ""
    
    init(gyroscopeSensor : Bool, accelometerSensor : Bool, magnetnometerSensor : Bool) {
        
        self.sensorManager = CMMotionManager()
        
        if gyroscopeSensor {
            self.gyroQueue = OperationQueue()
            self.gyroscopeSensorSelected = gyroscopeSensor
            sensorManager?.gyroUpdateInterval = 0.333333
        }
        
        if accelometerSensor {
            self.acccelQueue = OperationQueue()
            self.accelometerSensorSelected = accelometerSensor
            self.sensorManager?.accelerometerUpdateInterval = 0.333333
        }
        
        if magnetnometerSensor {
            self.magnoQueue = OperationQueue()
            self.magnetnometerSensorSelected = accelometerSensor
            self.sensorManager?.magnetometerUpdateInterval = 0.333333
        }
    }
    
    func startSensorDataGathering() {
        (self.gyroscopeSensorSelected) ? self.startGyroscopeData() : nil
//        (self.accelometerSensorSelected) ? self.startAccelerometerData() : nil
//        (self.magnetnometerSensorSelected) ? self.startMagnetometerData() : nil
    }
    
    func stopSensorDataGathering() {
        (self.sensorManager?.isGyroActive)! ? self.sensorManager?.stopGyroUpdates() : nil
//        (self.sensorManager?.isAccelerometerActive)! ? self.sensorManager?.stopAccelerometerUpdates() : nil
//        (self.sensorManager?.isMagnetometerActive)! ? self.sensorManager?.stopMagnetometerUpdates() : nil
    }
    
    func setSensorDataGatheringProtocolDelegate(delegate : SensorDataGatheringProtocol) {
        self.gatheringProtocolDelegate = delegate
    }
    
    func startGyroscopeData() {
        self.sensorManager?.startGyroUpdates(to: .main, withHandler: {
            (gyroscopeData, error) in
                self.gatheringProtocolDelegate?.gyroscopeDataGathering(xAxisValue: self.convertValue(value: (gyroscopeData?.rotationRate.x)!), yAxisValue: self.convertValue(value: (gyroscopeData?.rotationRate.y)!), zAxisValue: self.convertValue(value: (gyroscopeData?.rotationRate.z)!))
        })
    }
    
    func startAccelerometerData() {
        self.sensorManager?.startAccelerometerUpdates(to: self.acccelQueue!, withHandler: {
            (accelerometerData, error) in
                self.gatheringProtocolDelegate?.accelerometerDataGathering(xAxisValue: self.convertValue(value: (accelerometerData?.acceleration.x)!), yAxisValue: self.convertValue(value: (accelerometerData?.acceleration.y)!), zAxisValue: self.convertValue(value: (accelerometerData?.acceleration.z)!))
            })
    }
    
    func startMagnetometerData() {
        self.sensorManager?.startMagnetometerUpdates(to: self.magnoQueue!, withHandler: {
            (magnetometerData, error) in
                self.gatheringProtocolDelegate?.magnetometerDataGathering(xAxisValue: self.convertValue(value: (magnetometerData?.magneticField.x)!), yAxisValue: self.convertValue(value: (magnetometerData?.magneticField.y)!), zAxisValue: self.convertValue(value: (magnetometerData?.magneticField.z)!))
        })

    }
    
    private func convertValue(value : Double) -> String {
        return String(format: "%.3f", value)
    }
    
}
