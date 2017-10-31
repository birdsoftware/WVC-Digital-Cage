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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //UXCam.tagUsersName("brian")//"\(name), \(title), \(role)")
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        
        print("patientRecords \(patientRecords.count):\n\(patientRecords)")
        print("patientVitals \(patientVitals.count):\n\(patientVitals)")
        print("patientPhysicalExam \(patientPhysicalExam.count):\n\(patientPhysicalExam)")
        

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

