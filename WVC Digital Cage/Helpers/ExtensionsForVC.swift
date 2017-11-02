//
//  ExtensionsForVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/19/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation
import UIKit
import MessageUI //send email

extension UIViewController {
    
    //func isKeyPresentInUserDefaults(key: String) -> Bool {
    //    return UserDefaults.standard.object(forKey: key) != nil
    //}
    
//    public func updateToSavedImage(Userimage: UIImageView){
//        // UPDATE User Photo
//        if isKeyPresentInUserDefaults(key: "imageNeedsUpdate") {
//
//            if isKeyPresentInUserDefaults(key: "imagePathKey") {
//                // 4 --get encoded image saved above to user defaults
//                let imagePather = UserDefaults.standard.value(forKey: "imagePathKey")as! String
//                // 5 --get UIImage from imagePath
//                let dataer = FileManager.default.contents(atPath: imagePather)
//
//                if dataer != nil {
//                    let imageer = UIImage(data: dataer!)//unexpectedly found nil while unwrapping an Optional value
//
//                    Userimage.image = imageer
//                    // 8 --rotate image by 90 degrees M_PI_2 "if image is taken from camera"
//                    let angle =  CGFloat(Double.pi/2)
//                    let tr = CGAffineTransform.identity.rotated(by: angle)
//                    Userimage.transform = tr
//                } else { print("found nil while unwrapping") }
//            }
//        }
//
//    }
    
    public func isDateMoreThan(hours: Int,
                               dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let yourDateString = dateString//record["walkDate"]!
        if let lastWalkDate = formatter.date(from: yourDateString) {
            if let diff = Calendar.current.dateComponents([.hour], from: lastWalkDate, to: Date()).hour, diff >= hours {
                return true
            }
        }
        return false
    }
    
    public func removeNotification(code: String, patientID: String) {
        var myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
        print("patientID \(patientID) code \(code)")
        if patientID != "" && code != "" {
            for index in 0..<myNotifications.count {
                if myNotifications[index]["patientID"] == patientID &&
                    myNotifications[index]["code"] == code
                {
                    myNotifications.remove(at: index)
                    UserDefaults.standard.set(myNotifications, forKey: "notifications")
                    UserDefaults.standard.synchronize()
                    break
                }
            }
        }
    }
    
    
}
