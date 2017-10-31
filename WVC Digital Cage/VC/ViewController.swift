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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //UXCam.tagUsersName("brian")//"\(name), \(title), \(role)")
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        
        printDictionaries(records: patientRecords, vitals: patientVitals, pe: patientPhysicalExam)
        
        createBadgeFrom(UIlabel:patientsBadge, text: " \(patientRecords.count) ")

    }//PieChart (with selection, ...)

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
    
    //patientPhysicalExam
    /*
    ["urogenital": "false", "nervousSystem": "false", "respiratory": "true", "digestiveTeeth": "false", "ears": "false", "Musculoskeletal": "false", "patientID": "81231", "nose": "false", "generalAppearance": "true", "lymphNodes": "false", "skinFeetHair": "false", "eyes": "false", "comments": "\n1) hbhjblhj\n6) breathing good", "bodyConditionScore": "5"]

    ["generalAppearance","skinFeetHair","Musculoskeletal","nose","digestiveTeeth","respiratory","ears","nervousSystem","lymphNodes","eyes","urogenital","bodyConditionScore","comments"]
 */
}
extension ViewController{
    //Update UI
    func printDictionaries(records: Array<Dictionary<String,String>>, vitals: Array<Dictionary<String,String>>, pe: Array<Dictionary<String,String>>){
        print("patientRecords \(records.count):\n\(records)")
        print("patientVitals \(vitals.count):\n\(vitals)")
        print("patientPhysicalExam \(pe.count):\n\(pe)")
    }
}
extension ViewController{
    func createBadgeFrom(UIlabel:UILabel, text: String) {
        //if text == " 0 "{
        //    UIlabel.isHidden = true
        //} else {
        UIlabel.isHidden = false
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
        //If patient walkMe is not yet
        for record in records{
            if record["walkDate"] != "" {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let yourDateString = record["walkDate"]!
                if let lastWalkDate = formatter.date(from: yourDateString) {
                    if let diff = Calendar.current.dateComponents([.hour], from: lastWalkDate, to: Date()).hour, diff > 12 {
                        //do something
                        isNewAlert()
                        addNewAlert()
                    }
                }
            } else {
                //patient walkMe is "not yet"
                isNewAlert()
                addNewAlert()
            }
        }
        //If patient walkMe is > 12 hours
        
        //If Incision check is not yet
        
        //If Incision check is > 12 hours
        
        //Custom notification
    }
    func isNewAlert(){
        
    }
    func addNewAlert(){
        
    }
}

