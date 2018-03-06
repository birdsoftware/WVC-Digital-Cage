//  Created by Brian Bird on 1/29/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

class GETdoesDB {
    
    func haveTable(dispachInstance: DispatchGroup){
        var isTrue = false
        let url = "http://ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/tableExist"
        let headers = [ "Content-Type": "application/json", "Cache-Control": "no-cache" ]
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest,
            completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    if error.debugDescription.contains("-1005"){//https://forums.developer.apple.com/thread/67606
                        print("ignore -1005")
                        self.saveAndQuit(isTrue: true, di: dispachInstance)
                    } else {
                    print("FALSE could not reach database: \(error!)")
                    self.saveAndQuit(isTrue: false, di: dispachInstance)
                    return
                    }
                } else {//let httpResponse = response as? HTTPURLResponse print(httpResponse!)
                    do {//http://roadfiresoftware.com/2016/12/how-to-parse-json-with-swift-3/
                        if let data = data,  //go from Data? type (optional Data) to non-optional Data
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let type = json["type"] as? Bool {
                            
                                if(type == true) {
                                    print("TRUE datbase exists")
                                    isTrue = true
                                }
                                else {
                                    print("FALSE no database :(")
                                    isTrue = false
                            }
                            self.saveAndQuit(isTrue: isTrue, di: dispachInstance)
                        }
                    } catch {
                        print("Error deserializing reach DB JSON: \(error)")
                        self.saveAndQuit(isTrue: false, di: dispachInstance)
                    }
                  }
                })
        dataTask.resume()
    }
    func saveAndQuit(isTrue: Bool, di: DispatchGroup){
        UserDefaults.standard.set(isTrue, forKey: "isDataBaseReachable")
        UserDefaults.standard.synchronize()
        di.leave() // API Responded
    }
}
