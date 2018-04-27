//
//  GETPatients.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

class GETPatients {
    
    func getPatients(dispachInstance: DispatchGroup){
        
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
        
        let urlString = "http://ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/patients"
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                print("GET Patients Error:\n\(String(describing: error))")
                                                dispachInstance.leave() // API Responded
                                                return
                } else {
                                                
                    do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                        if let data = data,  //go from Data? type (optional Data) to non-optional Data
                            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                            if json.isEmpty == false {
                                for dict in json {
                                    intakeDate = dict["intakeDate"] as? String ?? ""
                                    patientName =  dict["patientName"] as? String ?? ""
                                    owner =  dict["owner"] as? String ?? ""
                                    kennelId =  dict["kennelId"] as? String ?? ""
                                    groupString = dict["groupString"] as? String ?? ""
                                    status = dict["status"] as? String ?? ""
                                    photoName = dict["photoName"] as? String ?? ""
                                    
                                    patientId = dict["patientId"] as? Int ?? 0
                                    let pid = String(patientId)
                                    
                                    patients.append(["status": status, "intakeDate": intakeDate, "patientID": patientName,
                                                     "cloudPatientID": pid, "walkDate": "", "photo": photoName,
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
                            
                            UserDefaults.standard.set(patients, forKey: "dataBasePatients")
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
