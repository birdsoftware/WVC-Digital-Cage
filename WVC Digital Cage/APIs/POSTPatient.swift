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
        
        let parameters = [
            "status": update["status"]!,  //requires String
            "intakeDate": update["intakeDate"]!,
            "patientName": update["patientName"]!,         //requires "mobile app"
            "walkDate": update["walkDate"]!,
            "photoName": update["photoName"]!,
            "kennelId": update["kennelId"]!,
            "owner": update["owner"]!,
            "groupString": update["groupString"]!
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
                                                print("\(httpResponse)")
                                                print("Status Code : \(httpResponse!.statusCode)") //TODO check if 200 display message sent o.w. message not sent try later?
                                                
                                                let httpData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                                print("Response String :\(httpData)")
                                                
//                                                do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
//                                                    if let data = data,  //go from a Data? type (optional Data) to a non-optional Data
//                                                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                                                        let type = json["type"] as? Bool{
//                                                        if(type == true){
//
//                                                            UserDefaults.standard.set(true, forKey: "APIUpdatePatientUpdates")
//                                                            UserDefaults.standard.synchronize()
//
//                                                            print("finished POST/send patient updates")
//                                                        }
//                                                        dispachInstance.leave() // API Responded
//                                                    }
//                                                } catch {
//                                                    print("Error deserializing PUT/send messageInbox JSON: \(error)")
//                                                    UserDefaults.standard.set(false, forKey: "APIUpdatePatientUpdates")
//                                                    UserDefaults.standard.synchronize()
//
//                                                    dispachInstance.leave() // API Responded
//                                                }
                                                //DispatchQueue.main.async {
                                                //}
                                            }
        })
        dataTask.resume()
    }
}

