//
//  DELETEAmpm.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/1/19.
//  Copyright © 2019 Brian Bird. All rights reserved.
//

import UIKit

extension DeleteInstantShare {
    
    func Ampm(aview: UIView, parameters: [String : Any], dispatchInstance: DispatchGroup) {
        /*{
         "incisionsId"   : "10"
         }*/
        let messgTitle = "Ampm"
        let headers = [
            "content-type": "application/json"
        ]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Ampm.deleteAmpm)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("Error when Attempting to DELETE " + messgTitle + ": \(error!)")
                aview.makeToast("Connect to cloud error: \n Error when Attempting to DELETE " + messgTitle + ": \n\(String(describing: error!))", duration: 2.1, position: .center)
                dispatchInstance.leave()
            } else {
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let type = json["type"] as? Bool{
                        if(type == true){
                            print("finished DELETE " + messgTitle + "")
                        }
                        dispatchInstance.leave()
                    }
                } catch {
                    print("Error deserializing DELETE " + messgTitle + ": \(error)")
                    dispatchInstance.leave()
                }
            }
        })
        dataTask.resume()
    }
}

