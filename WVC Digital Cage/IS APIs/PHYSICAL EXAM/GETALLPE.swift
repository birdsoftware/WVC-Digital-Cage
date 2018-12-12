//
//  GETALLPE.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/11/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension GETAll {
    
    func getPhysicalExams(aview: UIView, dispachInstance: DispatchGroup){
        
        var physicalExams = [Dictionary<String,String>]()
        var physicalExamId = 0; var patientID =  0; var patientName =  ""; var generalAppearance =  ""; var skinFeetHair = "";
        var musculoskeletal = ""; var nose = ""; var digestiveTeeth = ""; var respiratory = ""; var ears = "";
        var nervousSystem = ""; var lymphNodes = ""; var eyes = ""; var urogenital = ""; var bodyConditionScore = ""; var comments = ""
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: Constants.instantShare.PhysicalExams.getAllPhysicalExams)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 4.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
                                        completionHandler: { (data, response, error) -> Void in
                                            if (error != nil) {
                                                print("GET All PE Error:\n\(String(describing: error))")
                                                aview.makeToast("Connect to cloud error: \n Error when Attempting to get all Physical Exams:\n\(String(describing: error!))", duration: 2.1, position: .center)
                                                dispachInstance.leave() // API Responded
                                                return
                                            } else {
                                                
                                                do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                                                    if let data = data,  //go from Data? type (optional Data) to non-optional Data
                                                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                                        let type = json["type"] as? Bool{
                                                        if(type == true){
                                                            //we have DATA
                                                            let dictArray = json["data"] as? [[String: Any]]
                                                            for dict in dictArray! {
                                                                physicalExamId = dict["physicalExamId"] as? Int ?? 0; let vid = String(physicalExamId)
                                                                patientID = dict["patientID"] as? Int ?? 0; let pid = String(patientID)
                                                                patientName = dict["patientName"] as? String ?? "" //used as patientID in the app
                                                                generalAppearance =  dict["generalAppearance"] as? String ?? ""
                                                                skinFeetHair =  dict["skinFeetHair"] as? String ?? ""
                                                                musculoskeletal = dict["musculoskeletal"] as? String ?? ""
                                                                nose =  dict["nose"] as? String ?? ""
                                                                digestiveTeeth =  dict["digestiveTeeth"] as? String ?? ""
                                                                respiratory = dict["respiratory"] as? String ?? ""
                                                                ears = dict["ears"] as? String ?? ""
                                                                nervousSystem = dict["nervousSystem"] as? String ?? ""
                                                                lymphNodes = dict["lymphNodes"] as? String ?? ""
                                                                eyes = dict["eyes"] as? String ?? ""
                                                                urogenital = dict["urogenital"] as? String ?? ""
                                                                bodyConditionScore = dict["bodyConditionScore"] as? String ?? ""
                                                                comments = dict["comments"] as? String ?? ""
                                                                
                                                                physicalExams.append(["physicalExamId": vid, "patientID": patientName, "cloudPatientID": pid, "generalAppearance": generalAppearance,
                                                                               "skinFeetHair": skinFeetHair, "musculoskeletal": musculoskeletal, "nose": nose, "digestiveTeeth": digestiveTeeth,
                                                                               "respiratory": respiratory, "ears": ears, "nervousSystem": nervousSystem, "lymphNodes": lymphNodes, "eyes": eyes,
                                                                               "urogenital":urogenital, "bodyConditionScore":bodyConditionScore, "comments":comments])
                                                            }
                                                        }
                                                        
                                                        UserDefaults.standard.set(physicalExams, forKey: Constants.instantShare.PhysicalExams.getALLPhysicalExamsKey)
                                                        UserDefaults.standard.synchronize()
                                                        print("finished GET PhysicalExams")
                                                        dispachInstance.leave() // API Responded
                                                    } //ct came back empty?
                                                } catch {
                                                    print("Error deserializing PhysicalExams JSON: \(error)")
                                                    dispachInstance.leave() // API Responded
                                                }
                                            }
        })
        dataTask.resume()
    }
}
