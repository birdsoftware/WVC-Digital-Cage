//
//  GETPatientIntake.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/31/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

class GETPatientIntake {
    
    func exists(patientID: String, intakeDate: String,dispachInstance: DispatchGroup){

        let url = "http://ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/patients/"
            + patientID + "/intakeDate/" + intakeDate//12%2F15%2F2017"
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
            completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print("GET Patient Error:\n\(String(describing: error))")
                    dispachInstance.leave() // API Responded
                    return
                } else {
                    //let httpResponse = response as? HTTPURLResponse
                    //print(httpResponse!)
                    do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                        if let data = data,  //go from Data? type (optional Data) to non-optional Data
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let type = json["type"] as? Bool {
                            
                            if(type == true) {
                                let pData = json["data"] as? [[String: Any]]
                                
                                if (pData?.isEmpty)!{
                                    // FALSE NO RECORD FOR PATIENT AND INTAKE DATE
                                    UserDefaults.standard.set(false, forKey: "patientIsInDatabase")
                                    UserDefaults.standard.synchronize()
                                    //print("DNE: empty [] record for \(patientID)")
                                } else {
                                    // TRUE RECORD EXISTS
                                    UserDefaults.standard.set(true, forKey: "patientIsInDatabase")
                                    UserDefaults.standard.synchronize()
                                    //print("TRUE record exists for \(patientID)")
                                }
                                
                            }
                            else {//error?
                            }
                            dispachInstance.leave() // API Responded
                        }
                    } catch {
                        print("Error deserializing reach DB JSON: \(error)")
                        dispachInstance.leave() // API Responded
                    }
                }
    })
        dataTask.resume()
    }
}
