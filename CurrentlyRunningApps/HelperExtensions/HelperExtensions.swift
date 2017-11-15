//
//  HelperExtensions.swift
//  CurrentlyRunningApps
//
//  Created by 30hills on 10/26/17.
//  Copyright © 2017 30Hills. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func customAlert(alertControllerInfo : AlertControllerInfo, alertActionYes : @escaping (UIAlertAction) -> (), alertActionNo : @escaping (UIAlertAction) -> ()) {
        
        let alertController = UIAlertController.init(title: alertControllerInfo.alertControllerTitle, message: alertControllerInfo.alertControllerMessage, preferredStyle: .alert)
        
        if let _ = alertControllerInfo.alertActionYesTitle {
            let alertActionDelete = UIAlertAction.init(title: alertControllerInfo.alertActionYesTitle, style: .default, handler: alertActionYes)
            alertController.addAction(alertActionDelete)
        }
        
        if let _ = alertControllerInfo.alertActionNoTitle {
            let alertActionCancel = UIAlertAction.init(title: alertControllerInfo.alertActionNoTitle, style: .cancel, handler: alertActionNo)
            alertController.addAction(alertActionCancel)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
