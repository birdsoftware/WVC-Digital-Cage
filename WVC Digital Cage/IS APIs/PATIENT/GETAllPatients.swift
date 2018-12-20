//
//  GETAllPatients.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/30/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

class GETAll {
    
    func getPatients(aview: UIView, dispachInstance: DispatchGroup){
        
        var patients = [Dictionary<String,String>]()
        
        //for loop
        var intakeDate = ""
        var patientName =  ""
        var owner =  ""
        var kennelId =  ""
        var groupString = ""
        var status = ""
        var patientId = 0
        var photoName = ""
        var walkDate = ""
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Patient.getAllPatients)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 4.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        //print("got here bb")
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                print("GET All Patients Error:\n\(String(describing: error))")
                                                aview.makeToast("Connect to cloud error: \n Error when Attempting to get all patients:\n\(String(describing: error!))", duration: 2.1, position: .center)
                                                dispachInstance.leave() // API Responded
                                                return
                                            } else {
                                                
                                                do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                                                    if let data = data,  //go from Data? type (optional Data) to non-optional Data
                                                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                                        let type = json["type"] as? Bool{
                                                        if(type == true){
                                                            //we have DATA
                                                            let patientsIS = json["data"] as? [[String: Any]]
                                                            for dict in patientsIS! {
                                                                status = dict["status"] as? String ?? "" //Active or Archive
                                                                intakeDate = dict["intakeDate"] as? String ?? ""
                                                                patientName =  dict["patientName"] as? String ?? "" //used as patientID in the app
                                                                walkDate =  dict["walkDate"] as? String ?? ""
                                                                photoName = dict["photoName"] as? String ?? ""
                                                                kennelId =  dict["kennelId"] as? String ?? ""
                                                                owner =  dict["owner"] as? String ?? ""
                                                                groupString = dict["groupString"] as? String ?? ""
                                                                
                                                                patientId = dict["patientId"] as? Int ?? 0
                                                                let pid = String(patientId)
                                                                
                                                                patients.append(["status": status, "intakeDate": intakeDate, "patientID": patientName,
                                                                                 "cloudPatientID": pid, "walkDate": walkDate, "photo": photoName,
                                                                                 "kennelID": kennelId, "owner": owner, "group": groupString])
                                                            }
                                                        }
                                                        //                            for dic in json {
                                                        //                                if let number = dic["patientId"] as? Int {
                                                        //                                    // access individual value in dictionary
                                                        //                                    print("patientId \(number)")
                                                        //                                    patient = String(number)
                                                        //                                }
                                                        //                                /*
                                                        //                                 for (key, value) in dic {
                                                        //                                 // access all key / value pairs in dictionary
                                                        //                                 print("\(key) : \(value)")
                                                        //                                 }
                                                        //
                                                        //                                 if let nestedDictionary = dictionary["anotherKey"] as? [String: Any] {
                                                        //                                 // access nested dictionary values by key
                                                        //                                 }
                                                        //                                 */
                                                        //                            }
                                                        //print(patients)
                                                        
                                                        UserDefaults.standard.set(patients, forKey: "patientRecords")
                                                        UserDefaults.standard.synchronize()
                                                        print("finished GET patients")
                                                        dispachInstance.leave() // API Responded
                                                    }
                                                    //ct came back empty?
                                                } catch {
                                                    print("Error deserializing Patients JSON: \(error)")
                                                    dispachInstance.leave() // API Responded
                                                }
                                            }
        })
        dataTask.resume()
    }
}
