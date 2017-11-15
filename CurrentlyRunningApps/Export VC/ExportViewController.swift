//
//  ExportViewController.swift
//  CurrentlyRunningApps
//
//  Created by 30hills on 10/25/17.
//  Copyright © 2017 30Hills. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectedCellProtocol {

  
    @IBOutlet var testsTableView: UITableView!
    
    private var gyroData : String?
    private var accelData : String?
    private var magneData : String?
    
    private var testData = TestModel()
    
    private var tests : [TestModel]?
    private var defaultFileNameExport : AlertControllerInfo?
    private var saveDataToDBAlert : AlertControllerInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
    }
    
    func setUpDelegates() {
        testsTableView.delegate = self
        testsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataValidation()
        tests = DatabaseManager.sharedManager.getDataFromRealm().reversed()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setUpGatheredData(gyroData : String , accelData : String, magneData : String) {
        self.gyroData = gyroData
        self.accelData = accelData
        self.magneData = magneData
    }
    
    func dataValidation() {
        if self.gyroData! != gyroTextTemplate, self.accelData! != accelTextTemplate, self.magneData! != magneTextTemplate {
            let gyroFileName = "GyroscopeData" + self.currentDate()+".csv"
            let accelFileName = "AccelerometerData" + self.currentDate()+".csv"
            let magneFileName = "MagnetometerData" + self.currentDate()+".csv"
            
            let test : TestModel = TestModel(gyroData: self.gyroData!, accelData: self.accelData!, magneData: magneData!, gyroFileName: gyroFileName, accelFileName: accelFileName, magneFileName: magneFileName)!
            
            DatabaseManager.sharedManager.writeDataToRealm(data: test, success: {
                    self.testsTableView.reloadData()
                    self.gyroData = gyroTextTemplate
                
            }, failiure: { (error) in
                print(error)
                return
            })
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseManager.sharedManager.getDataFromRealm().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TestTableViewCell = tableView.dequeueReusableCell(withIdentifier: "testCell") as! TestTableViewCell
            cell.initCellWith(delegate: self, test: tests![indexPath.row])
        return cell
    }
  
    func exportGyroData(gyroData: String, gyroFileName : String) {
        self.exportData(data: gyroData, fileName: gyroFileName)
    }
    func exportAccelData(accelData: String, accelFileName : String) {
        self.exportData(data: accelData, fileName: accelFileName)
    }
    func exportMagneData(magneData: String, magneFileName : String) {
        self.exportData(data: magneData, fileName: magneFileName)
    }
    
    func exportData(data : String, fileName : String) {
        let accelerometerAlertInfo = AlertControllerInfo(alertControllerTitle : "Export", alertControllerMessage : "Export \(fileName)?", alertActionYesTitle : "Yes", alertActionNoTitle : "No")
        customAlert(alertControllerInfo: accelerometerAlertInfo, alertActionYes: {
            (action) in
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            let csvText = data
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivityType.mail,
                UIActivityType.copyToPasteboard,
                UIActivityType.openInIBooks,
                UIActivityType.print
            ]
            
            self.present(vc, animated: true, completion: nil)
        }) { (action) in
            
        }
    }
    
    func currentDate() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "-yyyy-MM-dd-hh-mm"
        return dateFormatter.string(from: Date())
    }
    
    
}
