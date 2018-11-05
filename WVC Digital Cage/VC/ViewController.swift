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
 //incisions
 "patientID": "323",
 "date": "11/08/17 02:49 PM",
 "initials": "B.B. "
*/

//treatmentsAndNotes
/*
 "date", "lVT", "patientID",
 "sex", "age", "shelter",
 "breed", "dVM", "dX", "notes"
 */

//collectionTxVitals
/*
 [ "date", "temperature", "heartRate", "respirations", "mm/Crt", "diet", "v/D/C/S", "weightKgs", "initials" , "monitorDays", "checkComplete", "patientID", "monitorFrequency", "monitored", "group"]
 */

//collectionTreatments
/*
"treatmentNine, "treatmentTen", "treatmentFour", "date": "04/04/18 PM", "treatmentOne", "monitorDays": "3", "treatmentThree": "", "containsTreatmentLabels": "true", "checkComplete": "true", "patientID": "test2", "monitorFrequency": "daily", "treatmentEight": "", "treatmentSix": "", "monitored": "1", "treatmentFive": "", "treatmentTwo": "", "treatmentSeven": ""]
 */

import UIKit
//import UXCam

class ViewController: UIViewController {
    
    @IBOutlet weak var patientsBadge: UILabel!
    @IBOutlet weak var notificationsBadge: UILabel!
    @IBOutlet weak var syncBadge: UILabel!
    
    /*1*/ var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    /*2*/ let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
    /*3*/ let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
    /*4*/ var myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
    /*5*/ let myDemographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
    /*6*/ var myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
    /*7*/ let incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
    /*8*/ let procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
    /*9*/ let collectionPhotos = UserDefaults.standard.object(forKey: "collectionPhotos") as? Array<Dictionary<String,String>> ?? []
    /*10*/ let badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
    /*11*/ let collectionTxVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
    /*12*/ let collectionTreatments = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
    /*13*/ let treatmentsAndNotes = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []

    //view
    @IBOutlet weak var syncView: RoundedImageView!
    //image
    @IBOutlet weak var syncImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UXCam.tagUsersName("brian")//"\(name), \(title), \(role)")
        
        //segueclear(arrayDicName: "collectionTxVitals")
        //clear(arrayDicName: "collectionTreatments")
        
        //for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
        //    print("\(key) = \(value) \n")
        //}
        
        //deleteImage(imageName: "good _1.png")
        
        let app = UIApplication.shared
        
        //Register for the applicationWillResignActive anywhere in your app.
        //swift 4.1
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationWillEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: app)
        //swift 4.2
        //NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        printDictionaries(records: patientRecords, vitals: patientVitals, pe: patientPhysicalExam, notifications: myNotifications, myDemographics: myDemographics, myAmpms: myAmpms, incisions: incisions, procedures: procedures, collectionPhotos: collectionPhotos, badges: badges, collectionTxVitals: collectionTxVitals, collectionTreatments: collectionTreatments, treatmentsAndNotes: treatmentsAndNotes)

        //getNotifications(records: patientRecords)
    }//PieChart (with selection, ...)
    
    @objc func applicationWillEnterForeground(notification: NSNotification) {
        setupUI()
    }
    
    func switchKey<T, U>(_ myDict: inout [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValue(forKey: fromKey) {
            myDict[toKey] = entry
        }
    }
    
     override func viewWillAppear(_ animated: Bool) {
        setupUI()
        updateMissingAMPMRecords()
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
        getNotifications(records: patientRecords)
        createBadgeFrom(UIlabel:patientsBadge, text: " \(patientRecords.count) ")
        createBadgeFrom(UIlabel:notificationsBadge, text: " \(myNotifications.count) ")
        createBadgeFrom(UIlabel: syncBadge, text: " \(getArchivePatientRecordsCount()) ")
        if patientRecords.count == 0{
            patientsBadge.isHidden = true} else {
            patientsBadge.isHidden = false
        }
        if myNotifications.count == 0{
            notificationsBadge.isHidden = true} else {
            notificationsBadge.isHidden = false
        }
        if getArchivePatientRecordsCount() == 0 {
            syncBadge.isHidden = true} else {
            syncBadge.isHidden = false
        }
    }
    
    //Button Actions
    @IBAction func syncAction(_ sender: Any) {
        if Reachability.isConnectedToNetwork() == true
        {
            print("Internet Connection Available!")
            self.performSegue(withIdentifier: "segueToSync", sender: self)
        } else {
            simpleAlert(title: "Internet connection not found", message: "Enable internet connection to continue with cloud backups.", buttonTitle: "OK")
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
                           badges: Array<Dictionary<String,String>>,
                           collectionTxVitals: Array<Dictionary<String,String>>,
                           collectionTreatments: Array<Dictionary<String,String>>,
                           treatmentsAndNotes: Array<Dictionary<String,String>>){
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
        print("collectionTxVitals \(collectionTxVitals.count):\n\(collectionTxVitals)")
        print("collectionTreatments \(collectionTreatments.count):\n\(collectionTreatments)")
        print("treatmentsAndNotes \(treatmentsAndNotes.count):\n\(treatmentsAndNotes)")
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
        //print("missingPatientIDs \(missingPatientIDs.count):\n\(missingPatientIDs)")
    }
}
extension ViewController{
//    func createBadgeFrom(UIlabel:UILabel, text: String) {
//        UIlabel.clipsToBounds = true
//        UIlabel.layer.cornerRadius = UIlabel.font.pointSize * 1.2 / 2
//        UIlabel.backgroundColor = .white//.bostonBlue()
//        UIlabel.textColor = .DarkRed()
//        UIlabel.text = text
//    }
    func getArchivePatientRecordsCount() -> Int{
        var theCount = 0
        for array in patientRecords {
            if array["status"] == "Archive" {
                theCount += 1
            }
        }
        return theCount
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

extension ViewController {
    func setupUI(){
        if Reachability.isConnectedToNetwork() == true
        {
            //"Internet Connection Available!"
            syncView.alpha = 1.0
            
        } else {
            //"Internet connection not found"
            syncView.alpha = 0.5
        }
    }
}
