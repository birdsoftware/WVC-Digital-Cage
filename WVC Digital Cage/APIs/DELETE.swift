//
//  DELETE.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 2/9/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
// //http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/

import Foundation

class DeleteRow {
    
    func anAllergy(stringId: String, endPoint: String, dispachInstance: DispatchGroup) {
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: endPoint)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("Error when Attempting to DELETE row: \(error!)") //The Internet connection offline. -1009
                //UserDefaults.standard.set(false, forKey: "APIdeleteCurAllergySuccess")
                //UserDefaults.standard.synchronize()
                dispachInstance.leave()
                
            } else {
                
                let httpResponse = response as? HTTPURLResponse //print("\(httpResponse)")
                let statusCode = httpResponse!.statusCode
                print("Status Code : \(statusCode)") //TODO check if 200 display message sent o.w. message not sent try later?
                UserDefaults.standard.set(statusCode, forKey: "statusCode")
                UserDefaults.standard.synchronize()
                //let httpData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                //print("Response String :\(httpData)")
                
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let type = json["data"] as? Bool{
                        if(type == true){
                            
                            UserDefaults.standard.set(true, forKey: "APIdeleteCurAllergySuccess")
                            UserDefaults.standard.synchronize()
                            
                            print("finished DELETE current allergy")
                        }
                        dispachInstance.leave() // API Responded
                    }
                } catch {
                    print("Error deserializing DELETE current allergy: \(error)")
                    UserDefaults.standard.set(false, forKey: "APIdeleteCurAllergySuccess")
                    UserDefaults.standard.synchronize()
                    
                    dispachInstance.leave() // API Responded
                }
                //DispatchQueue.main.async {
                //}
            }
        })
        dataTask.resume()
    }
}
