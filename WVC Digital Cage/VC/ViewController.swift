//
//  ViewController.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//
//patientRecords
/*
 "patientID":reviewPatientID.text!,
 "kennelID":reviewKennel.text!,
 "status":"Active",
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
 "urogenital": "false",
 "nervousSystem": "false",
 "respiratory": "true",
 "digestiveTeeth": "false",
 "ears": "false",
 "musculoskeletal": "false",
 "patientID": "81231",
 "nose": "false",
 "generalAppearance": "true",
 "lymphNodes": "false",
 "skinFeetHair": "false",
 "eyes":"false",
 "comments": "\n1) hbhjblhj\n6) breathing good",
 "bodyConditionScore": "5"
 
 ["generalAppearance","skinFeetHair","musculoskeletal","nose","digestiveTeeth","respiratory","ears","nervousSystem","lymphNodes","eyes","urogenital","bodyConditionScore","comments"]
 */
//ampms
/*
 "patientID":"123",
 "date":"10/22/2017 AM",
 "attitude":"happy",
 "feces":"feces 5",
 "urine":"u 12",
 "appetite%":"appetite",
 "v/D/C/S":"vdcs",
 "initials":"b.b."
 */

/*
 incisions 9
 "patientID": "323",
 "date": "11/08/17 02:49 PM",
 "initials": "B.B. "
*/
 
import UIKit
//import UXCam

class ViewController: UIViewController {
    
    @IBOutlet weak var patientsBadge: UILabel!
    @IBOutlet weak var notificationsBadge: UILabel!
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
    let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
    var myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
    var myDemographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
    var myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
    var incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
    var procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
    var collectionPhotos = UserDefaults.standard.object(forKey: "collectionPhotos") as? Array<Dictionary<String,String>> ?? []
    var badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UXCam.tagUsersName("brian")//"\(name), \(title), \(role)")
        //clear(arrayDicName: "procedures")
        //clear(arrayDicName: "demographics")
        
        printDictionaries(records: patientRecords, vitals: patientVitals, pe: patientPhysicalExam, notifications: myNotifications, myDemographics: myDemographics, myAmpms: myAmpms, incisions: incisions, procedures: procedures, collectionPhotos: collectionPhotos, badges: badges)

        //getNotifications(records: patientRecords)
    }//PieChart (with selection, ...)
    func switchKey<T, U>(_ myDict: inout [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValue(forKey: fromKey) {
            myDict[toKey] = entry
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        updateMissingAMPMRecords()
        
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
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
    
}
extension ViewController{
    //Update UI
    func printDictionaries(records: Array<Dictionary<String,String>>,
                           vitals: Array<Dictionary<String,String>>,
                           pe: Array<Dictionary<String,String>>,
                           notifications: Array<Dictionary<String,String>>,
                           myDemographics: Array<Dictionary<String,String>>,
                           myAmpms: Array<Dictionary<String,String>>,
                           incisions: Array<Dictionary<String,String>>,
                           procedures: Array<Dictionary<String,String>>,
                           collectionPhotos: Array<Dictionary<String,String>>,
                           badges: Array<Dictionary<String,String>>){
        print("patientRecords \(records.count):\n\(records)")
        print("patientVitals \(vitals.count):\n\(vitals)")
        print("patientPhysicalExam \(pe.count):\n\(pe)")
        print("notifications \(notifications.count):\n\(notifications)")
        print("demographics \(myDemographics.count):\n\(myDemographics)")
        print("ampms \(myAmpms.count):\n\(myAmpms)")
        print("incisions \(incisions.count):\n\(incisions)")
        print("procedures \(procedures.count):\n\(procedures)")
        print("collectionPhotos \(collectionPhotos.count):\n\(collectionPhotos)")
        print("badges \(badges.count):\n\(badges)")
    }
    func updateMissingAMPMRecords(){
        myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        var missingPatientIDs = Set<String>()
        for things in myAmpms {
            if (things.map{$0.value}).contains("") { missingPatientIDs.insert(things["patientID"]!) }
        }
        let arrayFromSet = Array(missingPatientIDs)
        UserDefaults.standard.set(arrayFromSet, forKey: "missingPatientIDs")
        UserDefaults.standard.synchronize()
        print("missingPatientIDs \(missingPatientIDs.count):\n\(missingPatientIDs)")
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
                                  dateString: record["walkDate"]!)
                { //check if patientID AND code == 2
                    let pid = record["patientID"]!
                    let pidPredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", pid)
                    let codePredicate = NSPredicate(format: "SELF.code MATCHES[cd] %@", "2")
                    let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [pidPredicate, codePredicate])
                    let filtertedNotificationsWithPatientID=(myNotifications as NSArray).filtered(using: andPredicate)
                    if filtertedNotificationsWithPatientID.count > 0{
                        //we have patientID and code 2
                    } else {
                        addNewAlert(code: "2", patientID: pid)
                        print("code 2 for patientID: \(pid)")
                    }
                }
            } else {
                //patient walkMe is "not yet" because record["walkDate"] == ""
                //check if patientID AND code == 2
                let pid = record["patientID"]!
                let pidPredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", pid)
                let codePredicate = NSPredicate(format: "SELF.code MATCHES[cd] %@", "1")
                let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [pidPredicate, codePredicate])
                let filtertedNotificationsWithPatientID=(myNotifications as NSArray).filtered(using: andPredicate)
                if filtertedNotificationsWithPatientID.count > 0{
                    //we have patientID and code 1
                } else {
                    addNewAlert(code: "1", patientID: record["patientID"]!)
                    print("code 1 for patientID: \(record["patientID"]!)")
                }
            }
        }
        
        //Code 3 - If Incision check is not yet
        
        //Code 4 - If Incision check is > 12 hours
        
        //Code 5 - Treatment
        
        //Code 6 - Custom notification
    }

    func addNewAlert(code: String, patientID: String){
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
            formatter.dateFormat = "MM/dd/yyyy hh:mm a"
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

//extension ViewController{
//    // #MARK: - Clear Records
//    func clear(arrayDicName: String){
//        let clear = Array<Dictionary<String,String>>()
//        UserDefaults.standard.set(clear, forKey: arrayDicName)
//        UserDefaults.standard.synchronize()
//    }
//    //clear(arrayDicName: "procedures")
//}

