//
//  testData.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 3/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

extension SettingsVC {
    
    func addTestData(){
        var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        var kennelIntArray = ["S1","S2","S3","S4","S5","S6","S7","S8",
                              "D1","D2","D3","D4","D5","D6","D7","D8","D9","D10",
                              "D11","D12","D13","D14","D15","D16",
                              "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10",
                              "T11","T12","T13",
                              "I1","I2","I3","I4",
                              "Cage Banks", "Cat room"]//Array(1...45)
        
        var ownerList = ["The Animal Foundation (TAF)","Henderson Shelter (HS)","Desert Haven Animal Society (DHAS)",
                         "Home for Spot (HFS)","Riverside Shelter (RS)"]
        
        var testNames = ["Bob_test","Sam_test","Stacy_test","Brandon_test","Ciearra_test"]
        
        let loop = 5
        var iter = 0
        let currentDate = setDateNow()
        var newP = Dictionary<String,String>()
        
        loop.times {
            
             newP =
                ["patientID":testNames[iter],
                 "kennelID":kennelIntArray[iter],
                 "status":"Active",
                 "intakeDate":currentDate,
                 "owner":ownerList[iter],
                 "group":"Canine",
                 "walkDate":"",
                 "photo":""
            ]
            patientRecords.append(newP)
            iter += 1
        }
        
        //save locally
        UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
        UserDefaults.standard.synchronize()

    }
    func setDateNow() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let nowString = formatter.string(from: Date())
        return nowString
    }
 
}
