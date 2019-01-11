//
//  GETAllAmpm.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/1/19.
//  Copyright © 2019 Brian Bird. All rights reserved.
//

import UIKit

extension GETAll {
    
    func getAmpms(aview: UIView, dispachInstance: DispatchGroup){
        let messgTitle = "Ampm"
        
        var arrayDictionary = [Dictionary<String,String>]()
        var ampmsId = 0; var patientID =  0; var patientName = ""; var attitude =  "";
        var filterID =  ""; var initials = ""; var vDCS = ""; var date = "";
        var urine = ""; var feces = ""; var appetite = "";
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Ampm.getAllAmpm)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 4.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
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
                                                                ampmsId = dict["ampmsId"] as? Int ?? 0
                                                                let aid = String(ampmsId)
                                                                patientID = dict["patientID"] as? Int ?? 0
                                                                let pid = String(patientID)
                                                                patientName = dict["patientName"] as? String ?? ""
                                                                attitude = dict["attitude"] as? String ?? ""
                                                                filterID =  dict["filterID"] as? String ?? "" //used as patientID in the app
                                                                initials =  dict["initials"] as? String ?? ""
                                                                vDCS = dict["vDCS"] as? String ?? ""
                                                                date = dict["date"] as? String ?? ""
                                                                urine = dict["urine"] as? String ?? ""
                                                                feces = dict["feces"] as? String ?? ""
                                                                appetite = dict["appetite"] as? String ?? ""
                                                                
                                                                arrayDictionary.append(["ampmsId": aid, "patientID": patientName, "cloudPatientID": pid, "attitude": attitude,
                                                                                        "filterID": filterID, "initials":initials, "vDCS":vDCS, "date":date, "urine":urine, "feces":feces, "appetite":appetite])
                                                            }
                                                        }
                                                        
                                                        UserDefaults.standard.set(arrayDictionary, forKey: Constants.instantShare.Ampm.getAllAmpmKey)
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
