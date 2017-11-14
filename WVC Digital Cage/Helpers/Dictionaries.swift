//
//  Dictionaries.swift
//  Brian Bird
//
//  Created by Brian Bird on 10/25/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    //DELETE
    //using .index(where:) method which performs performs 0(n):
    //https://stackoverflow.com/questions/43675437/how-to-delete-object-in-array-of-dictionaries-using-key-value
    func dictIndexFrom(array: [[String:String]], usingKey: String, usingValue: String) -> Array<Any>.Index?{
        let index = array.index(where: { (dictionary) -> Bool in
            guard let value = dictionary[usingKey]
                else { return false }
            return value == usingValue//255024731588044
        })
        return index
        //USE:
        // if let index = dictIndexFrom(array: array, usingKey:"photo_id", usingValue: "4") {
        //     array.remove(at: index)
        // }
    }
    func arrayContainsPatientIDCode(array:[[String:String]], value:[String:String], code: String) -> Bool {
        for item in array {
            if item == value {//return true
                if item["code"] == code {
                    return false //DONT ADD
                } else {
                    return true //ADD
                }
            }
        }
        return false //DONT ADD
    }
    func arrayContains(array:[[String:String]], value:String) -> Bool {
        for item in array {
            if item["patientID"] == value {//
                return true
            }
        }
        return false
    }
    // #MARK: - Clear Records
    // clear(arrayDicName: "procedures")
    func clear(arrayDicName: String){
        let clear = Array<Dictionary<String,String>>()
        UserDefaults.standard.set(clear, forKey: arrayDicName)
        UserDefaults.standard.synchronize()
    }
    //need a count of selectedPatientIds
    func returnCountOfKeys(aDicts: [[String:String]], aKey: String, matchKey: String) -> Int{
        var count = 0
        for dict in aDicts{
            if dict[aKey] == matchKey {
                count += 1
            }
        }
        return count
    }
    
    //change all keys in DICT ARRRAY
    /*
    var dict = Dictionary<String,String>()
    for index in 0..<patientRecords.count {
     dict = patientRecords[index]
     switchKey(&dict, fromKey: "Status", toKey: "status")
     patientRecords[index] = dict
    }
    UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
    UserDefaults.standard.synchronize()
    patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
 */
    
}
