//
//  GET.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 5/2/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

class GET {
    
    func recordFor(id: String, idName: String, tableName: String, dispachInstance: DispatchGroup){
        
        // ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/getRecordFor/168/idName/patientID/tableName/ampms
        // forever start --minUptime 600000 --spinSleepTime 3600000 tester.js
        // forever stop --minUptime 600000 --spinSleepTime 3600000 tester.js
        
        let url = "http://ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/getRecordFor/"
            + id + "/idName/" + idName + "/tableName/" + tableName
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
            completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print("GET Error:\n\(String(describing: error))")
                    dispachInstance.leave() // API Responded
                    return
                } else {
                    //let httpResponse = response as? HTTPURLResponse
                    //print(httpResponse!)
                    do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                        if let data = data,  //go from Data? type (optional Data) to non-optional Data
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let type = json["type"] as? Bool {
                            
                            if(type == true) {
                                let data = json["data"] as? [[String: Any]]
                                
                                UserDefaults.standard.set(data, forKey: "getData")
                                UserDefaults.standard.synchronize()
                                print("finished GET data")
                            }
                            else {
                                //error?
                            }
                            dispachInstance.leave() // API Responded
                        }
                    } catch {
                        print("Error deserializing JSON: \(error)")
                        dispachInstance.leave() // API Responded
                    }
                }
})
        dataTask.resume()
    }
}
