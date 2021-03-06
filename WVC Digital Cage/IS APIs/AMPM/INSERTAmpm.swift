//
//  INSERTAmpm.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/1/19.
//  Copyright © 2019 Brian Bird. All rights reserved.
//

import UIKit

extension INSERT {
    
    func newAmpm(aview: UIView, parameters: [String : Any], dispachInstance: DispatchGroup){
        let messgTitle = "Ampm"
        let headers = [
            "content-type": "application/json"
        ]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Ampm.insertAmpm)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                print("Error when Attempting to POST new " + messgTitle  + ":\n\(String(describing: error))")
                                                aview.makeToast("Connect to cloud error: \n Error when Attempting to insert " + messgTitle + ":\n\(String(describing: error!))", duration: 2.1, position: .center)
                                                dispachInstance.leave() // API Responded
                                                return
                                            } else {
                                                do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                                                    if let data = data,  //go from Data? type (optional Data) to non-optional Data
                                                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                                        let type = json["type"] as? Bool{
                                                        if(type == true){
                                                            print("finished POST new " + messgTitle)
                                                        }
                                                        dispachInstance.leave() // API Responded
                                                    }
                                                } catch {
                                                    print("Error deserializing new " + messgTitle + " JSON: \(error)")
                                                    dispachInstance.leave() // API Responded
                                                }
                                            }
        })
        dataTask.resume()
    }
}
