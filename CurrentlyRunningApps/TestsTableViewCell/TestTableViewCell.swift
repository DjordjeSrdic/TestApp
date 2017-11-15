//
//  TestTableViewCell.swift
//  CurrentlyRunningApps
//
//  Created by 30hills on 10/25/17.
//  Copyright © 2017 30Hills. All rights reserved.
//

import UIKit

protocol SelectedCellProtocol {
    func exportGyroData(gyroData : String, gyroFileName : String)
    func exportAccelData(accelData : String, accelFileName : String)
    func exportMagneData(magneData : String, magneFileName : String)
}

class TestTableViewCell: UITableViewCell {

    @IBOutlet var testDataLbl: UILabel!
    var cellProtocolDelegate : SelectedCellProtocol?
    
    private var gyroData : String?
    private var accelData : String?
    private var magnetData : String?
    private var gyroFileName : String?
    private var accelFileName : String?
    private var magneFileName : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWith(delegate : SelectedCellProtocol, test : TestModel) {
        cellProtocolDelegate = delegate
        self.gyroData = test.gyroData
        self.accelData = test.accelData
        self.magnetData = test.magneData
        self.gyroFileName = test.gyroFileName
        self.accelFileName = test.accelFileName
        self.magneFileName = test.magneFileName
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        self.testDataLbl.text = dateFormatter.string(from: test.currentDate as Date)
        
    }
    
    @IBAction func gyroDataCellExportBtnAction(_ sender: Any) {
        if let _ = self.gyroData {
            cellProtocolDelegate?.exportGyroData(gyroData: self.gyroData!, gyroFileName: self.gyroFileName!)
        }
        
    }
    
    @IBAction func magneDataCellExportBtnAction(_ sender: Any) {
        if let _ = self.magnetData {
            cellProtocolDelegate?.exportMagneData(magneData: self.magnetData!, magneFileName: self.magneFileName!)
        }
    }
    
    @IBAction func accelDataCellExportBtnAction(_ sender: Any) {
        if let _ = self.accelData {
             cellProtocolDelegate?.exportAccelData(accelData: self.accelData!, accelFileName: self.accelFileName!)
        }
    }

}
