//
//  ViewController.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit
import UXCam

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UXCam.tagUsersName("brian")//"\(name), \(title), \(role)")
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        
        print("patientRecords \(patientRecords.count):\n\(patientRecords)")
        print("patientVitals \(patientVitals.count):\n\(patientVitals)")
        print("patientPhysicalExam \(patientPhysicalExam.count):\n\(patientPhysicalExam)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

