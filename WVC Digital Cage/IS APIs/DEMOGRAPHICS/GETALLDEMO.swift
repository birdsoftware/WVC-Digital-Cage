//
//  GETALLDEMO.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/17/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension GETAll {
    
    func getDemographic(aview: UIView, dispachInstance: DispatchGroup){
        let messgTitle = "Demographic"
        
        var Demographic = [Dictionary<String,String>]()
        var demographicId = 0; var patientID =  0; var patientName =  "";
        var age =  ""; var breed = ""; var sex = "";
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Demographics.getAllDemographics)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 4.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        //print("got here bb")
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                completionHandler: { (data, response, error) -> Void in
                    if (error != nil) {
                        print("GET All " + messgTitle + " Error:\n\(String(describing: error))")
                        aview.makeToast("Connect to cloud error: \n Error when Attempting to get all " + messgTitle + ":\n\(String(describing: error!))", duration: 2.1, position: .center)
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
                                        demographicId = dict["demographicId"] as? Int ?? 0
                                        let did = String(demographicId)
                                        patientID = dict["patientID"] as? Int ?? 0
                                        let pid = String(patientID)
                                        patientName = dict["patientName"] as? String ?? ""
                                        age =  dict["age"] as? String ?? "" //used as patientID in the app
                                        breed =  dict["breed"] as? String ?? ""
                                        sex = dict["sex"] as? String ?? ""
                                        
                                        Demographic.append(["demographicId": did, "patientID": patientName, "cloudPatientID": pid, "age": age,
                                                       "breed": breed, "sex": sex])
                                    }
                                }
                                
                                UserDefaults.standard.set(Demographic, forKey: Constants.instantShare.Demographics.getAllDemographicsKey)
                                UserDefaults.standard.synchronize()
                                print("finished GET " + messgTitle)
                                dispachInstance.leave() // API Responded
                            }
                        } catch {
                            print("Error deserializing " + messgTitle + " JSON: \(error)")
                            dispachInstance.leave() // API Responded
                        }
                    }
})
        dataTask.resume()
    }
}

