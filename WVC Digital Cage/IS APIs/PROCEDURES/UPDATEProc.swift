//
//  UPDATEProc.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/31/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import UIKit

extension UPDATE {
    
    func Procedure(aview: UIView, parameters: [String : Any], dispachInstance: DispatchGroup){
        let messgTitle = "Procedures"
        let headers = [ "content-type": "application/json" ]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.Procedures.updateProcedure)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                
                                                print("Error when Attempting to PUT new " + messgTitle + ":\n\(String(describing: error))")
                                                aview.makeToast("Connect to cloud error: \n Error when Attempting to update " + messgTitle + ":\n\(String(describing: error!))", duration: 2.1, position: .center)
                                                dispachInstance.leave() // API Responded
                                                return
                                                
                                            } else {
                                                do {
                                                    if let data = data,  //go from Data? type (optional Data) to non-optional Data
                                                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                                        let type = json["type"] as? Bool{
                                                        
                                                        if(type == true){
                                                            print("finished PUT new " + messgTitle)
                                                        }
                                                        dispachInstance.leave() // API Responded
                                                    }
                                                } catch {
                                                    print("Error deserializing PUT new " + messgTitle + " JSON: \(error)")
                                                    dispachInstance.leave() // API Responded
                                                }
                                            }
        })
        dataTask.resume()
    }
}
