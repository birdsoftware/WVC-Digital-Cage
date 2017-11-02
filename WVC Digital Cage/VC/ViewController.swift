//
//  ViewController.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit
//import UXCam

class ViewController: UIViewController {
    
    @IBOutlet weak var patientsBadge: UILabel!
    @IBOutlet weak var notificationsBadge: UILabel!
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
    let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
    var myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UXCam.tagUsersName("brian")//"\(name), \(title), \(role)")
        
        printDictionaries(records: patientRecords, vitals: patientVitals, pe: patientPhysicalExam, notifications: myNotifications)

        //getNotifications(records: patientRecords)
    }//PieChart (with selection, ...)

    override func viewWillAppear(_ animated: Bool) {
        
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        //let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        //let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
        getNotifications(records: patientRecords)
        
        createBadgeFrom(UIlabel:patientsBadge, text: " \(patientRecords.count) ")
        createBadgeFrom(UIlabel:notificationsBadge, text: " \(myNotifications.count) ")
        
        if patientRecords.count == 0{
            patientsBadge.isHidden = true} else {
            patientsBadge.isHidden = false
        }
        if myNotifications.count == 0{
            notificationsBadge.isHidden = true} else {
            notificationsBadge.isHidden = false
        }

    }
    //patientRecords
    /*
     "patientID":reviewPatientID.text!,
     "kennelID":reviewKennel.text!,
     "Status":"Active",
     "intakeDate":reviewDateLabel.text!,
     "owner":reviewOwner.text!,
     "group":reviewGroup.text!,
     "walkDate":""
     */
    
    //patientVitals
    /*
    "patientID":patientID,
    "temperature":temperature.text!,
    "pulse":pulse.text!,
    "cRT_MM":cRT_MM.text!,
    "respiration":respiration.text!,
    "weight":weight.text!,
    "exitWeight":exitWeight.text!,
    "initialsVitals":initialsVitals.text!
    */
    
    //patientPhysicalExam
    /*
    ["urogenital": "false", "nervousSystem": "false", "respiratory": "true", "digestiveTeeth": "false", "ears": "false", "musculoskeletal": "false", "patientID": "81231", "nose": "false", "generalAppearance": "true", "lymphNodes": "false", "skinFeetHair": "false", "eyes": "false", "comments": "\n1) hbhjblhj\n6) breathing good", "bodyConditionScore": "5"]

    ["generalAppearance","skinFeetHair","musculoskeletal","nose","digestiveTeeth","respiratory","ears","nervousSystem","lymphNodes","eyes","urogenital","bodyConditionScore","comments"]
 */
}
extension ViewController{
    //Update UI
    func printDictionaries(records: Array<Dictionary<String,String>>, vitals: Array<Dictionary<String,String>>, pe: Array<Dictionary<String,String>>, notifications: Array<Dictionary<String,String>>){
        print("patientRecords \(records.count):\n\(records)")
        print("patientVitals \(vitals.count):\n\(vitals)")
        print("patientPhysicalExam \(pe.count):\n\(pe)")
        print("notifications \(notifications.count):\n\(notifications)")
    }
}
extension ViewController{
    func createBadgeFrom(UIlabel:UILabel, text: String) {
        //if text == " 0 "{
        //    UIlabel.isHidden = true
        //} else {
        //UIlabel.isHidden = false
        UIlabel.clipsToBounds = true
        UIlabel.layer.cornerRadius = UIlabel.font.pointSize * 1.2 / 2
        UIlabel.backgroundColor = .white//.bostonBlue()
        UIlabel.textColor = .DarkRed()
        UIlabel.text = text
        //}
    }
}
extension ViewController{
    func getNotifications(records: Array<Dictionary<String,String>>){
        //Code 1 - If patient walkMe is not yet
        //Code 2 - If patient walkMe is > 12 hours
        for record in records{
            if record["walkDate"] != "" {
                if isDateMoreThan(hours: 12,
                                  dateString: record["walkDate"]!) {
                    addNewAlert(code: "2", patientID: record["patientID"]!)
                    print("code 2 for patientID: \(record["patientID"]!)")
                }
            } else {
                //patient walkMe is "not yet"
                addNewAlert(code: "1", patientID: record["patientID"]!)
                print("code 1 for patientID: \(record["patientID"]!)")
            }
        }
        
        //Code 3 - If Incision check is not yet
        
        //Code 4 - If Incision check is > 12 hours
        
        //Code 5 - Treatment
        
        //Code 6 - Custom notification
    }

    func addNewAlert(code: String, patientID: String){
        var isUnique = false
        //isUnique same code, same patientID == not unique -> return
        if myNotifications.isEmpty {
            isUnique = true
        } else { //NOT EMPTY
            if arrayContains(array: myNotifications, value: patientID) {
                //see if it also contains code
                for notification in myNotifications {
                    if (notification["patientID"] == patientID &&
                        notification["code"] != code) {
                        isUnique = true
                        print("patientID \(patientID) match code \(code) not match")
                        break
                    } else {
                        isUnique = false
                        print("had patientID \(patientID) but code  \(code) matched - dont add")
                    }
                }
            } else {print("no patientID \(patientID)")
                isUnique = true
            }
        }
        
        if isUnique {
            print("isUnique")
            myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
            var message = ""
            switch code {
            case "1":
                message = "Hasn't been walked yet."
            case "2":
                message = "Hasn't been walked for over 12 hours."
            case "3":
                message = "Incision hasn't been checked yet."
            case "4":
                message = "Incision hasn't been checked for over 12 hours."
            case "5":
                message = "Treatment."
            case "6":
                message = "Custom."
            default:
                return
            }
            // Date now
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let nowString = formatter.string(from: Date())
            
            let newAlert:Dictionary<String,String> =
                [
                    "type":"walk",//"suture,treatment,custom"
                    "code":code,
                    "patientID":patientID,
                    "dateLong":nowString,
                    "message":message,
                    "image":""
            ]
            //add new notification
            if myNotifications.isEmpty {
                UserDefaults.standard.set([newAlert], forKey: "notifications")
                UserDefaults.standard.synchronize()
            } else {
                myNotifications.append(newAlert)
                UserDefaults.standard.set(myNotifications, forKey: "notifications")
                UserDefaults.standard.synchronize()
            }
        }
    }
}

