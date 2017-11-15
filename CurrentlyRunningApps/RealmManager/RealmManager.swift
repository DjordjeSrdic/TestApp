//
//  RealmManager.swift
//  CurrentlyRunningApps
//
//  Created by 30hills on 10/25/17.
//  Copyright © 2017 30Hills. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class DatabaseManager {
    static let sharedManager : DatabaseManager = DatabaseManager()
    
    var realm : Realm
    var dataResults : Results<TestModel>
    
    init() {
        realm = try! Realm()
        dataResults = realm.objects(TestModel.self)
    }
    
    func writeDataToRealm(data : TestModel, success : @escaping () -> (), failiure : @escaping (Error) -> ()) {
        do {
            try realm.write({
                realm.add(data)
            })
        }
        catch {
            failiure(error)
            return
            }
        success()
        }
    
    func getDataFromRealm() -> [TestModel] {
        dataResults = realm.objects(TestModel.self)
        var tests : [TestModel] = [TestModel]()
        for test in dataResults {
            tests.append(test)
        }
        return tests
    }
    
    
}
