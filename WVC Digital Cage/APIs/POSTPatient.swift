//
//  PUTPatients.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

class POSTPatientUpdates {
    
    func updatePatientUpdates(update:Dictionary<String,String>, dispachInstance: DispatchGroup){
        
        let nsurlAlerts = Constants.Patient.postPatient
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]
        //print("update: \(update)") //["status": "Archive", "intakeDate": "12/14/2017", "patientID": "Wolfe", "walkDate": "2018-01-04 15:13:00", "photo": "Wolfe.png", "kennelID": "D3", "owner": "Henderson Shelter (HS)", "group": "Canine"]
        let parameters = [
            "status": update["status"]!,
            "intakeDate": update["intakeDate"]!,
            "patientName": update["patientID"]!,
            "walkDate": update["walkDate"]!,
            "photoName": update["photo"]!,
            "kennelId": update["kennelID"]!,
            "owner": update["owner"]!,
            "groupString": update["group"]!
            ] as [String : Any]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: nsurlAlerts)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                
                                                print("Error when Attempting to POST/send patient updates: \(error!)") //The Internet connection appears to be offline. -1009
                                                //UserDefaults.standard.set(false, forKey: "APIUpdatePatientUpdates")
                                                //UserDefaults.standard.synchronize()
                                                
                                                dispachInstance.leave() // API Responded
                                                
                                            } else {
                                                
                                                let httpResponse = response as? HTTPURLResponse
                                                //print("\(httpResponse)")
                                                let statusCode = httpResponse!.statusCode
                                                print("Status Code : \(statusCode)") //TODO check if 200 display message sent o.w. message not sent try later?
                                                UserDefaults.standard.set(statusCode, forKey: "statusCode")
                                                UserDefaults.standard.synchronize()
                                                //let httpData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                                //print("Response String :\(httpData)")
                                                dispachInstance.leave()

                                                DispatchQueue.main.async {
                                                }
                                            }
        })
        dataTask.resume()
    }
}

