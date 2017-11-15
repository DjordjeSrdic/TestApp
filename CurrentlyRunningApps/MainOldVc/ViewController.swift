//
//  ViewController.swift
//  CurrentlyRunningApps
//
//  Created by 30hills on 10/10/17.
//  Copyright © 2017 30Hills. All rights reserved.
//

import UIKit
import CoreFoundation
import CoreMotion
import Realm
import RealmSwift

typealias AlertControllerInfo = (alertControllerTitle : String, alertControllerMessage : String, alertActionYesTitle : String?, alertActionNoTitle : String?)

class ViewController: UIViewController, UITextViewDelegate, SensorDataGatheringProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBOutlet var switchDrv: UISwitch!
    @IBOutlet var xAxisLbl: UILabel!
    @IBOutlet var yAxis: UILabel!
    @IBOutlet var zAxis: UILabel!
    @IBOutlet var btnPressLbl: UILabel!
    @IBOutlet var driverLbl: UILabel!
    @IBOutlet var coDriverLbl: UILabel!
    @IBOutlet var collectedDataTextView: UITextView!
    @IBOutlet var clickMeBtn: UIButton!
    
    var coreMotion = CMMotionManager()
    var buttonPress : Int?
    var device : UIDevice?
    var collectedData : String = " GyroX\t\tGyroY\t\tGyroZ\t\t\tbtn\t drv\tcoDrv\t rowNumb\n"
    let tmpCollectedData : String = " GyroX\t\tGyroY\t\tGyroZ\t\t\tbtn\t drv\tcoDrv\t rowNumb\n"
    var dataWithAccelemeterAndMagnetometer : String = " GyroX\t\tGyroY\t\tGyroZ\tAccelX\tAccelY\tAccelZ\tMagnoX\tMagnoY\tMagnoZ \tbtn\t drv\tcoDrv\t rowNumb\n"
    
    var gyroValues = String()
    var accelValues : String = "Accelerometer :    x       y       z       battery :\tbtn\t drv\tcoDrv\t rowNumb\n"
    var magnometerValues : String = "Magnometer :    x       y       z       battery :\tbtn\t drv\tcoDrv\t rowNumb\n"
    
    var collectedGyroData : String = gyroTextTemplate
    var collectedAccelData : String = accelTextTemplate
    var collectedMagneData : String = magneTextTemplate
    var collectedBtnPressedData : String = btnPressedTemplate
    
    var sensorCoreMotionManager : SensorManager?
    
    var batteryStatus : String?
    var driver : String?
    var coDriver : String?

    var btnPress : Bool = false

    var gyroDataGatheredTime : TimeInterval?
    var accelDataGatheredTime : TimeInterval?
    var magnoDataGatheredTime : TimeInterval?
    
    var gyroDataGatheredDate : String?
    var accelDataGatheredDate : String?
    var magnoDataGatheredDate : String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString)
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLife : Double = Double(UIDevice.current.batteryLevel)
        print(batteryLife)
        print(String(format: "OVO JE STANJE BATERIJE %.2f", batteryLife))
        self.buttonPress = 0
        collectedDataTextView.delegate = self
        self.clickMeBtn.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.clickMeBtn.addTarget(self, action: #selector(touchDown(sender:)), for: .touchDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func setProximitySensorEnabled(_ enabled: Bool) {
        self.device = UIDevice.current
        device!.isProximityMonitoringEnabled = enabled
        if device!.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: .UIDeviceProximityStateDidChange, object: device)
        } else {
            NotificationCenter.default.removeObserver(self, name: .UIDeviceProximityStateDidChange, object: nil)
        }
    }
    
    @objc func proximityChanged(_ notification: Notification) {
        if let device = notification.object as? UIDevice {
            self.view.backgroundColor = UIColor(red: CGFloat(arc4random()) / CGFloat(UInt32.max), green: CGFloat(arc4random()) / CGFloat(UInt32.max), blue: CGFloat(arc4random()) / CGFloat(UInt32.max), alpha: 1)
        }
    }

    @IBAction func pressBtnAction(_ sender: Any) {
        if collectedGyroData != gyroTextTemplate {
            self.collectedBtnPressedData.append("\nButton pressed at :" + dateFormating(date: Date()))
        }
    }
    
    @IBAction func switchAction(_ sender: Any) {
        if switchDrv.isOn {
            self.driverLbl.text = "1"
            self.coDriverLbl.text = "0"
        } else {
            self.driverLbl.text = "0"
            self.coDriverLbl.text = "1"
        }
    }
    
    @IBAction func stopGyroBtnAction(_ sender: Any) {
        coreMotion.stopGyroUpdates()
        coreMotion.stopAccelerometerUpdates()
        coreMotion.stopMagnetometerUpdates()
        self.sensorCoreMotionManager?.stopSensorDataGathering()
    }
    
    @IBAction func playGyroBtnAction(_ sender: Any) {
       
//        self.sensorCoreMotionManager = SensorManager.init(gyroscopeSensor: true, accelometerSensor: true, magnetnometerSensor: true)
//        self.sensorCoreMotionManager?.setSensorDataGatheringProtocolDelegate(delegate: self)
//        self.sensorCoreMotionManager?.startSensorDataGathering()

        self.oldSensorRun()
    }
    
    func timeInSecondsBetweenDates(endDate : Date, startDate : Date) -> TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }
    
    func changeTimeIntervalType(timeInterval : TimeInterval) -> String {
        return String(format: "%.5f", timeInterval)
    }
    
    func dateFormating(date : Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:m:ss.SSS"
        return dateFormatter.string(from:date)
    }
    
    func buttonData() {
        self.driverLbl.text = (self.switchDrv.isOn) ? "1" : "0"
        self.coDriverLbl.text = (self.switchDrv.isOn) ? "0" : "1"
    }
    
    @IBAction func exportDataBtnAction(_ sender: Any) {
        coreMotion.stopDeviceMotionUpdates()
        coreMotion.stopGyroUpdates()
        coreMotion.stopMagnetometerUpdates()
        coreMotion.stopAccelerometerUpdates()
        //self.collectedGyroData.append("\n\n" + collectedBtnPressedData)
        performSegue(withIdentifier: "exportData", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exportData" {
            let vc : ExportViewController = segue.destination as! ExportViewController
            vc.setUpGatheredData(gyroData: self.collectedGyroData, accelData: self.collectedAccelData, magneData: self.collectedMagneData)
            self.resetValues()
        }
    }
    
    @IBAction func resetBtnAction(_ sender: Any) {
        collectedData = tmpCollectedData
        self.resetValues()
    }
    
    func resetValues() {
        
        self.xAxisLbl.text = ""
        self.yAxis.text = ""
        self.zAxis.text = ""
        self.collectedGyroData = gyroTextTemplate
        self.collectedAccelData = accelTextTemplate
        self.collectedMagneData = magneTextTemplate
        self.collectedBtnPressedData = btnPressedTemplate
        collectedDataTextView.text = ""
    }
    
    func gyroscopeDataGathering(xAxisValue: String, yAxisValue: String, zAxisValue: String) {
      //  OperationQueue.main.addOperation {
            self.buttonData()
            self.xAxisLbl.text = xAxisValue
            self.yAxis.text = yAxisValue
            self.zAxis.text = zAxisValue
            self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
            self.gyroDataGatheredDate = self.dateFormating(date: Date())
            self.collectedGyroData.append("\t\t\(xAxisValue)\t\(yAxisValue)\t\(zAxisValue)\t\(self.batteryStatus!)\t\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t \(self.gyroDataGatheredDate!)\t\t\(self.btnPress)\n")
            self.collectedDataTextView.text = self.collectedGyroData
    //    }
    }
    
    func accelerometerDataGathering(xAxisValue: String, yAxisValue: String, zAxisValue: String) {
        OperationQueue.main.addOperation {
            self.buttonData()
            self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
            self.accelDataGatheredDate = self.dateFormating(date: Date())
            self.collectedAccelData.append("\t\t\(xAxisValue)\t\(yAxisValue)\t\(zAxisValue)\t\(self.batteryStatus!)\t\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t\(self.accelDataGatheredDate!)\t\t\(self.clickMeBtn.isSelected)\n")
        }
    }
    
    func magnetometerDataGathering(xAxisValue: String, yAxisValue: String, zAxisValue: String) {
        OperationQueue.main.addOperation {
            self.buttonData()
            self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
            self.magnoDataGatheredDate = self.dateFormating(date: Date())
            self.collectedMagneData.append("\t\t\(xAxisValue)\t\(yAxisValue)\t\(zAxisValue)\t\(self.batteryStatus!)\t\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t\(self.magnoDataGatheredDate!)\t\t\(self.clickMeBtn.isSelected)\n")
        }
    }
    
    
    func oldSensorRun() {
        coreMotion.gyroUpdateInterval = 0.4
        coreMotion.accelerometerUpdateInterval = 0.4
        coreMotion.magnetometerUpdateInterval = 0.4
        
        let queueGyro : OperationQueue = OperationQueue()
        let queueAccel : OperationQueue = OperationQueue()
        let queueMagno : OperationQueue = OperationQueue()
        
        coreMotion.startGyroUpdates(to: queueGyro) { (data, error) in
            
            let xVal : String = String(format: "%.3f", (data?.rotationRate.x)!)
            let yVal : String = String(format: "%.3f", (data?.rotationRate.y)!)
            let zVal : String = String(format: "%.3f", (data?.rotationRate.z)!)
            self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
            self.gyroDataGatheredDate = self.dateFormating(date: Date())
            
            OperationQueue.main.addOperation {
                self.buttonData()
                self.xAxisLbl.text = xVal
                self.yAxis.text = yVal
                self.zAxis.text = zVal
                self.btnPressLbl.text = String(describing : self.buttonPress!)
                self.collectedGyroData.append("\t\t\(xVal)\t\(yVal)\t\(zVal)\t\(self.batteryStatus!)\t\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t \(self.gyroDataGatheredDate!)\t\t\(self.btnPress)\n")
                self.collectedDataTextView.text = self.collectedGyroData
            }
        }
        
        coreMotion.startAccelerometerUpdates(to: queueAccel) { (accelerometerData, error) in
            let xVal : String = String(format: "%.3f", (accelerometerData?.acceleration.x)!)
            let yVal : String = String(format: "%.3f", (accelerometerData?.acceleration.y)!)
            let zVal : String = String(format: "%.3f", (accelerometerData?.acceleration.z)!)
            self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
            self.accelDataGatheredDate = self.dateFormating(date: Date())
            
            OperationQueue.main.addOperation {
                self.buttonData()
                self.btnPressLbl.text = String(describing : self.buttonPress!)
                self.collectedAccelData.append("\t\t\(xVal)\t\(yVal)\t\(zVal)\t\(self.batteryStatus!)\t\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t\(self.accelDataGatheredDate!)\t\t\n")
            }
        }
        
        coreMotion.startMagnetometerUpdates(to: queueMagno) { (magnometerData, error) in
            let xVal : String = String(format: "%.3f", (magnometerData?.magneticField.x)!)
            let yVal : String = String(format: "%.3f", (magnometerData?.magneticField.y)!)
            let zVal : String = String(format: "%.3f", (magnometerData?.magneticField.z)!)
            self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
            self.magnoDataGatheredDate = self.dateFormating(date: Date())
            
            OperationQueue.main.addOperation {
                self.buttonData()
                self.btnPressLbl.text = String(describing : self.buttonPress!)
                self.collectedMagneData.append("\t\t\(xVal)\t\(yVal)\t\(zVal)\t\(self.batteryStatus!)\t\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t\(self.magnoDataGatheredDate!)\t\t\n")
            }
        }
    }
    
    func newSensorRunningTasks()  {
        DispatchQueue.main.async {

            if let gyroData = self.coreMotion.gyroData {
                self.xAxisLbl.text = String(format : "%.3f", (gyroData.rotationRate.x))
                self.yAxis.text = String(format : "%.3f", (gyroData.rotationRate.y))
                self.zAxis.text = String(format : "%.3f", (gyroData.rotationRate.z))
                self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
                self.buttonData()
                self.collectedGyroData.append("\t\t\(self.xAxisLbl.text!)\t\(self.yAxis.text!)\t\(self.zAxis.text!)\t\(self.batteryStatus!)\t\t\(self.btnPressLbl.text!)\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t\n")
                self.btnPressLbl.text = String(describing : self.buttonPress!)
                //self.buttonPress = 0
                self.collectedDataTextView.text = self.collectedGyroData
                
            }
            if let accelData = self.coreMotion.accelerometerData {
                let xAccelVal : String = String(format: "%.3f", (accelData.acceleration.x))
                let yAccelVal : String = String(format: "%.3f", (accelData.acceleration.y))
                let zAccelVal : String = String(format: "%.3f", (accelData.acceleration.z))
                self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
                self.buttonData()
                self.collectedAccelData.append("\t\t\(xAccelVal)\t\(yAccelVal)\t\(zAccelVal)\t\(self.batteryStatus!)\t\t\(self.btnPressLbl.text!)\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t\n")
                self.btnPressLbl.text = String(describing : self.buttonPress!)
            }
            
            if let magnoData = self.coreMotion.magnetometerData {
                let xMagnoVal : String = String(format: "%.3f", (magnoData.magneticField.x))
                let yMagnoVal : String = String(format: "%.3f", (magnoData.magneticField.y))
                let zMagnoVal : String = String(format: "%.3f", (magnoData.magneticField.z))
                self.batteryStatus = String(format: "%.3f", UIDevice.current.batteryLevel)
                self.buttonData()
                self.collectedMagneData.append("\t\t\(xMagnoVal)\t\(yMagnoVal)\t\(zMagnoVal)\t\(self.batteryStatus!)\t\t\(self.btnPressLbl.text!)\t\(self.driverLbl.text!)\t\(self.coDriverLbl.text!)\t\n")
                self.btnPressLbl.text = String(describing : self.buttonPress!)
            }
            
            if self.coreMotion.isGyroActive, self.coreMotion.isAccelerometerActive, self.coreMotion.isMagnetometerActive {
                self.newSensorRunningTasks()
            }
        }
    }
    
    @objc func touchDown(sender : Any)  {
        btnPress = true
    }
    @objc func touchUp()  {
        btnPress = false
    }
}

