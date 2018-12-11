//
//  UPDATEPatient.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/4/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

class UPDATE {
    
    func Patient(aview: UIView, parameters: [String : Any]/*update:Dictionary<String,String>*/, dispachInstance: DispatchGroup){
        let headers = [
            "content-type": "application/json"
        ]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Patient.updatePatient)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                    completionHandler: { (data, response, error) -> Void in
                        if (error != nil) {
                            print("Error when Attempting to PUT newPatient:\n\(String(describing: error))")
                            aview.makeToast("Connect to cloud error: \n Error when Attempting to update patient:\n\(String(describing: error!))", duration: 2.1, position: .center)
                            dispachInstance.leave() // API Responded
                            return
                        } else {
                            do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                                if let data = data,  //go from Data? type (optional Data) to non-optional Data
                                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                    let type = json["type"] as? Bool{
                                        if(type == true){
                                            print("finished PUT newPatient")
                                        }
                                    dispachInstance.leave() // API Responded
                                }
                                //ct came back empty?
                            } catch {
                                print("Error deserializing PUT newPatient JSON: \(error)")
                                dispachInstance.leave() // API Responded
                            }
                        }
})
        dataTask.resume()
    }
}
