//
//  PUTPatients.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

class POSTPatientUpdates {
    
    func updatePatientUpdates(parameters: [String : Any]/*update:Dictionary<String,String>*/, endPoint: String, dispachInstance: DispatchGroup){
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: endPoint)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
    completionHandler: { (data, response, error) -> Void in
        if (error != nil) {
            print("Error when Attempting to POST/send patient updates: \(error!)") //The Internet connection appears to be offline. -1009
            dispachInstance.leave() // API Responded
        } else {
            
            let httpResponse = response as? HTTPURLResponse //print("\(httpResponse)")
            let statusCode = httpResponse!.statusCode
            print("Status Code : \(statusCode)") //TODO check if 200 display message sent o.w. message not sent try later?
            UserDefaults.standard.set(statusCode, forKey: "statusCode")
            UserDefaults.standard.synchronize()
            //let httpData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let authData = json["data"] as? [String: Any] {
                let insertId = authData["insertId"]! as? Int ?? 0 //TODO nill found and crashes here
                print("insertId: \(insertId)")
                
                self.savePatientIdFromSQLTable(parameters: parameters, insertId: insertId, endPoint: endPoint)
                
                dispachInstance.leave()
                }
            } catch {
                print("Error when JSONSerialization )")
                dispachInstance.leave()
            }
        }
})
        dataTask.resume()
    }
    func savePatientIdFromSQLTable(parameters: [String : Any], insertId: Int, endPoint: String){
        if endPoint == Constants.Patient.postPatient{
            let pName = parameters["patientName"]!
            var dataBasePatientId = UserDefaults.standard.object(forKey: "dataBasePatientId") as? Array<Dictionary<String,Any>> ?? []
            dataBasePatientId.insert(["patientID":pName,"dataBasePatientId":insertId], at: 0)
            
            UserDefaults.standard.set(dataBasePatientId, forKey: "dataBasePatientId")
            UserDefaults.standard.synchronize()
        }
    }
}

