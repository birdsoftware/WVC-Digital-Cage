//
//  GETALLIncisions.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/21/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension GETAll {
    
    func getIncisions(aview: UIView, dispachInstance: DispatchGroup){
        let messgTitle = "Incisions"
        
        var Demographic = [Dictionary<String,String>]()
        var incisionsId = 0; var patientID =  0; var patientName =  "";
        var date =  ""; var initials = "";
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Incisions.getAllIncisions)! as URL,
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
                                    incisionsId = dict["incisionsId"] as? Int ?? 0
                                    let iid = String(incisionsId)
                                    patientID = dict["patientID"] as? Int ?? 0
                                    let pid = String(patientID)
                                    patientName = dict["patientName"] as? String ?? ""
                                    date =  dict["date"] as? String ?? "" //used as patientID in the app
                                    initials =  dict["initials"] as? String ?? ""
                                    
                                    Demographic.append(["incisionsId": iid, "patientID": patientName, "cloudPatientID": pid, "date": date, "initials": initials])
                                }
                            }
                            
                            UserDefaults.standard.set(Demographic, forKey: Constants.instantShare.Incisions.getAllIncisionsKey)
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
