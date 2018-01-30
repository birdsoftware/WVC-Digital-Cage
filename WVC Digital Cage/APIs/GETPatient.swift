//
//  GETPatient.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

//
//  RESTPUTVitals.swift
//  CarePointe
//
//  Created by Brian Bird on 5/3/17.
//  Copyright © 2017 Mogul Pro Media. All rights reserved.
//

import Foundation

class GETPatient {
    
    func getPatient(patientID: String, dispachInstance: DispatchGroup){
        
        var patient = String()
        
        let onePatient = Constants.Patient.patient + patientID
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: onePatient)! as URL,
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
                                            if let number = dic["patientId"] as? Int {
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
                                        UserDefaults.standard.set(patient, forKey: "dataBasePatientId")
                                        UserDefaults.standard.synchronize()
                                        print("finished GET patient ID")
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
