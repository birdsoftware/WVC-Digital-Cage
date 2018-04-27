//
//  GETPatientCount.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

class GETPatientCount {
    
    func pCount(dispachInstance: DispatchGroup){
        
        var patient = String()
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/patientCount")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
            completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print("GET Patient Error:\n\(String(describing: error))")
                    dispachInstance.leave() // API Responded
                    return
                } else {
                    //let httpResponse = response as? HTTPURLResponse
                    //print(httpResponse!)
                    do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                        if let data = data,  //go from Data? type (optional Data) to non-optional Data
                            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                            for dic in json {
                                if let number = dic["COUNT(*)"] as? Int {
                                    // access individual value in dictionary
                                    print("patientId \(number)")
                                    patient = String(number)
                                }
                                /*
                                 for (key, value) in dic {
                                 // access all key / value pairs in dictionary
                                 print("\(key) : \(value)")
                                 }
                                 
                                 if let nestedDictionary = dictionary["anotherKey"] as? [String: Any] {
                                 // access nested dictionary values by key
                                 }
                                 */
                            }
                            UserDefaults.standard.set(patient, forKey: "dataBaseCount")
                            UserDefaults.standard.synchronize()
                            print("finished GET patient Count")
                            dispachInstance.leave() // API Responded
                        }
                        //ct came back empty?
                    } catch {
                        print("Error deserializing Patient JSON: \(error)")
                        dispachInstance.leave() // API Responded
                    }
                }
})
        dataTask.resume()
    }
}
