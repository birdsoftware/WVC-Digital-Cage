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
//        selectedData = SearchData[indexPath.row]
//        hideHideView()
//        //UPDATE UI VALUES
//        shareButton.isHidden = false
//        pdfLabel.isHidden = false
//        screenShareButton.isHidden = false
//        patientID = selectedData["patientID"]!
//        UserDefaults.standard.set(patientID, forKey: "selectedPatientID")
//        UserDefaults.standard.synchronize()
//        print("patientID: \(patientID)")
//        showVitals(pid:patientID)
//        //showPhysicalExam(pid:patientID)
//        patientIDLabel.text = patientID
//        let kennelID = selectedData["kennelID"]!
//        kennelNumberButton.setTitle(kennelID, for: .normal)
//        if selectedData["walkDate"]! != ""{
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            let yourDateString = selectedData["walkDate"]!
//            let lastWalkDate = formatter.date(from: yourDateString)
//            walkMeLabel.text = lastWalkDate!.timeAgo()
//        } else {
//            walkMeLabel.text = "not yet"
//        }
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPhysicalExam"), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showDemographics"), object: nil)
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
                toViewController.segueWhereThisViewWasLanchedFrom = "notificationsVC"
                toViewController.seguePatientID = ""
            }
        }
    }
}
