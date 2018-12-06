//
//  DELETEPatient.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/30/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

class DeleteInstantShare {
    
    func patient(aview: UIView, parameters: [String : Any], dispatchInstance: DispatchGroup) {
        /*{
         "patientID"   : "10"
         }*/
        let headers = [
            "content-type": "application/json"
        ]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Patient.deletePatient)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("Error when Attempting to DELETE patient: \(error!)")
                aview.makeToast("Connect to cloud error: \n Error when Attempting to DELETE patient: \n\(String(describing: error!))", duration: 2.1, position: .center)
                dispatchInstance.leave()
            } else {
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let type = json["type"] as? Bool{
                        if(type == true){
                            print("finished DELETE patient")
                        }
                        dispatchInstance.leave()
                    }
                } catch {
                    print("Error deserializing DELETE patient: \(error)")
                    dispatchInstance.leave()
                }
            }
        })
        dataTask.resume()
    }
}
