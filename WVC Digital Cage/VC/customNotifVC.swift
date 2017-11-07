//
//  customNotifVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/6/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class customNotifVC: UIViewController {
    
    var segueWhereThisViewWasLanchedFrom:String!
    var seguePatientID:String!

    @IBOutlet weak var patientIDTF: UITextField!
    @IBOutlet weak var messageTF: UITextField!
    //label
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        patientIDTF.text = seguePatientID
        // Date now
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let nowString = formatter.string(from: Date())
        dateLabel.text = nowString
        
    }
    @IBAction func saveAction(_ sender: Any) {
        //save locally
        addNotification()
        segueGoBack(lanchedFrom:segueWhereThisViewWasLanchedFrom)
    }
    @IBAction func backAction(_ sender: Any) {
        segueGoBack(lanchedFrom:segueWhereThisViewWasLanchedFrom)
    }
    @IBAction func goBackAction(_ sender: Any) {
        segueGoBack(lanchedFrom:segueWhereThisViewWasLanchedFrom)
    }
    
}
extension customNotifVC{
    //Save Notification
    func addNotification(){
        var myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
        let newAlert:Dictionary<String,String> =
            [
                "type":"custom",//"walk 1-2,suture 3-4,treatment 5,custom 6"
                "code":"6",
                "patientID":patientIDTF.text!,
                "dateLong":dateLabel.text!,
                "message":messageTF.text!,
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
extension customNotifVC{
    // #custom segue:
    func segueGoBack(lanchedFrom:String){
        //self.navigationController?.popViewController(animated: true)
        if lanchedFrom == "notificationsVC"{
            self.performSegue(withIdentifier: "segueBackToNotifications", sender: self)
        } else if lanchedFrom == "patientsVC"{
            self.performSegue(withIdentifier: "segueBackToPatients", sender: self)
        }
    }
}
