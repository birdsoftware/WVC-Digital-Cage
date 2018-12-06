//
//  INSERTPatient.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/30/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

class INSERTPatient {
    
    func newPatient(aview: UIView, parameters: [String : Any]/*update:Dictionary<String,String>*/, dispachInstance: DispatchGroup){
        let headers = [
            "content-type": "application/json"
        ]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Patient.insertPatient)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                print("Error when Attempting to POST newPatient:\n\(String(describing: error))")
                                                aview.makeToast("Connect to cloud error: \n Error when Attempting to insert patient:\n\(String(describing: error!))", duration: 2.1, position: .center)
                                                dispachInstance.leave() // API Responded
                                                return
                                            } else {
                                                do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                                                    if let data = data,  //go from Data? type (optional Data) to non-optional Data
                                                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                                        let type = json["type"] as? Bool{
                                                        if(type == true){
                                                            //we insert new user OK and have DATA
                                                            //                                {
                                                            //                                    "type": true,
                                                            //                                    "data": {
                                                            //                                        "fieldCount": 0,
                                                            //                                        "affectedRows": 1,
                                                            //                                        "insertId": 42,
                                                            //                                        "serverStatus": 2,
                                                            //                                        "warningCount": 0,
                                                            //                                        "message": "",
                                                            //                                        "protocol41": true,
                                                            //                                        "changedRows": 0
                                                            //                                    }
                                                        }
                                                        print("finished POST newPatient")
                                                        dispachInstance.leave() // API Responded
                                                    }
                                                    //ct came back empty?
                                                } catch {
                                                    print("Error deserializing POST newPatient JSON: \(error)")
                                                    dispachInstance.leave() // API Responded
                                                }
                                            }
        })
        dataTask.resume()
    }
}
