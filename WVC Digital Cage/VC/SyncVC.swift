//
//  SyncVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import UIKit

class SyncVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //table
    @IBOutlet weak var syncTable: UITableView!
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    var archivePatients = Array<Dictionary<String,String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        // Do any additional setup after loading the view.
        for array in patientRecords {
            if array["status"] == "Archive" {
                archivePatients.append(array)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //button actions
    @IBAction func startSyncAction(_ sender: Any) {
        let patientFlag = DispatchGroup()
        patientFlag.enter()
        GETPatient().getPatient(patientID: "Suzy", dispachInstance: patientFlag)
        patientFlag.notify(queue: DispatchQueue.main){
            let returnedPatientId = UserDefaults.standard.object(forKey: "lastAPIPatientId") as? String ?? ""
            print("patientID: \(returnedPatientId) returned")
        }
        let patientPostFlag = DispatchGroup()
        let testDic = ["status":"Active", "intakeDate":"12/16/2017", "patientName":"Testerson", "walkDate":"2017-12-17 10:00:21", "photoName":"Testerson.png", "kennelId":"S7", "owner":"The Animal Foundation (TAF)", "groupString":"Canine"]
        //POSTPatientUpdates().updatePatientUpdates(update: testDic, dispachInstance: patientPostFlag)
    }
    

}
extension SyncVC {
    //UI
    func setupUI(){
        syncTable.delegate = self
        syncTable.dataSource = self
    }
}
extension SyncVC {
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivePatients.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: syncTableView = tableView.dequeueReusableCell(withIdentifier: "syncCell") as! syncTableView
        let this = archivePatients[IndexPath.row]
        //cell.imageType.image =
        cell.photo.image = returnImage(imageName: this["patientID"]! + ".png")
        cell.name.text = this["patientID"]!
        
        return cell
    }
}
