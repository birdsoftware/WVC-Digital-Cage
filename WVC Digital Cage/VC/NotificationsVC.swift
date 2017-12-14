//
//  NotificationsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController , UITableViewDelegate, UITableViewDataSource{

    //table view
    @IBOutlet weak var notificationsTable: UITableView!
    
    //var patientRecords = Array<Dictionary<String,String>>()
    var myNotifications = Array<Dictionary<String,String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsTable.delegate = self
        notificationsTable.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
        notificationsTable.reloadData()
    }
    //NotificationsTableView: UITableViewCell {
    //identifier: notificationCell
//    "type":"walk",//"suture,treatment,custom"
//    "code":code,
//    "patientID":patientID,
//    "dateLong":nowString,
//    "message":message,
//    "image":""
}
extension NotificationsVC {
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myNotifications.count//patientRecords.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: NotificationsTableView = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationsTableView
        let this = myNotifications[IndexPath.row]
        //cell.imageType.image =
        cell.dateTime.text = this["dateLong"]
        cell.patientID.text = this["patientID"]
        cell.message.text = this["message"]
        if this["type"] == "walk"{
            cell.imageType.image = UIImage(named: "walk dog")
        } else if this["type"] == "custom"{
            cell.imageType.image = UIImage(named: "custom notification")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueNotificationsToPatients", sender: self)
        //        if let cell = tableView.cellForRow(at: indexPath) {
        //            cell.accessoryType = .checkmark
        //        }

    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("Delete button tapped")
            //self.deleteButtonTapped(indexPath: indexPath)
            //self.deleteRecordAlert(title:"Are you sure you want to remove this Notification?", message:"This will forever remove it.", buttonTitle:"OK", cancelButtonTitle: "Cancel", indexPath: indexPath)
            self.deleteButtonTapped(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }

    func deleteButtonTapped(indexPath: IndexPath){
        
        self.myNotifications.remove(at: indexPath.row)
        UserDefaults.standard.set(self.myNotifications, forKey: "notifications")
        UserDefaults.standard.synchronize()
        self.notificationsTable.deleteRows(at: [indexPath], with: .fade)
    }

    func deleteRecordAlert(title:String, message:String,
                           buttonTitle:String,
                           cancelButtonTitle: String,
                           indexPath: IndexPath) {
        
        let myAlert = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        myAlert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {
            alert -> Void in
            //DO:
            self.deleteButtonTapped(indexPath: indexPath)
        }))
        
        myAlert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in })
        
        present(myAlert, animated: true){}
    }
}
extension NotificationsVC {
    //
    // MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAddNotification" {
            //let selectedRow = ((inboxTable.indexPathForSelectedRow as NSIndexPath?)?.row)! //returns int
            //var Data = Dictionary<String,String>()//restInbox[selectedRow]
            
            if let toViewController = segue.destination as? customNotifVC {
                toViewController.segueWhereThisViewWasLanchedFrom = "notificationsVC"//"patientsVC"
                toViewController.seguePatientID = ""
            }
        } else if segue.identifier == "segueNotificationsToPatients" {
            if let toViewController = segue.destination as? PatientsVC {
                let selectedRow = ((notificationsTable.indexPathForSelectedRow as NSIndexPath?)?.row)! //returns int
                let thisPatientID = myNotifications[selectedRow]["patientID"]
                if doesPatientExist(patientID: thisPatientID!) {
                    toViewController.seguePatientID = thisPatientID
                }
            }
        }
    }
}
extension NotificationsVC {
    //CONTAINS
    func doesPatientExist(patientID: String) -> Bool{
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        //var missingPatientIDs = Set<String>()
        for things in patientRecords {
            if things["patientID"] == patientID {
                return true
            }
        }
        return false
    }
}
