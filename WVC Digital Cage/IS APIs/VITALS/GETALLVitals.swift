//
//  GETALLVitals.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/6/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension GETAll {
    
    func getVitals(aview: UIView, dispachInstance: DispatchGroup){
        
        
        var vitals = [Dictionary<String,String>]()
        
        //for loop
        var vitalId = 0; var patientID =  0; var patientName =  ""; var temperature =  ""
        var pulse = ""; var weight = ""; var exitWeight = ""; var cRT_MM = ""; var respiration = ""; var initialsVitals = ""
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Vitals.getAllVitals)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 4.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        //print("got here bb")
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                print("GET All Vitals Error:\n\(String(describing: error))")
                                                aview.makeToast("Connect to cloud error: \n Error when Attempting to get all vitals:\n\(String(describing: error!))", duration: 2.1, position: .center)
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
                                                                vitalId = dict["vitalId"] as? Int ?? 0
                                                                let vid = String(vitalId)
                                                                patientID = dict["patientID"] as? Int ?? 0
                                                                let pid = String(patientID)
                                                                patientName = dict["patientName"] as? String ?? ""
                                                                temperature =  dict["temperature"] as? String ?? "" //used as patientID in the app
                                                                pulse =  dict["pulse"] as? String ?? ""
                                                                weight = dict["weight"] as? String ?? ""
                                                                exitWeight =  dict["exitWeight"] as? String ?? ""
                                                                cRT_MM =  dict["cRT_MM"] as? String ?? ""
                                                                respiration = dict["respiration"] as? String ?? ""
                                                                initialsVitals = dict["initialsVitals"] as? String ?? ""
                                                                
                                                                
                                                                vitals.append(["vitalId": vid, "patientID": patientName, "cloudPatientID": pid, "temperature": temperature,
                                                                               "pulse": pulse, "weight": weight, "exitWeight": exitWeight, "cRT_MM": cRT_MM,
                                                                               "respiration": respiration, "initialsVitals": initialsVitals])
                                                            }
                                                        }
                                                        
                                                        UserDefaults.standard.set(vitals, forKey: Constants.instantShare.Vitals.getAllVitalsKey)
                                                        UserDefaults.standard.synchronize()
                                                        print("finished GET vitals")
                                                        dispachInstance.leave() // API Responded
                                                    } //ct came back empty?
                                                } catch {
                                                    print("Error deserializing vitals JSON: \(error)")
                                                    dispachInstance.leave() // API Responded
                                                }
                                            }
        })
        dataTask.resume()
    }
}
