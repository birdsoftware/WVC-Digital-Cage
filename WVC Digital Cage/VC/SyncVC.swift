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
    //image
    @IBOutlet weak var syncIndicator: UIImageView!
    //buttons
    @IBOutlet weak var syncButton: RoundedButton!
    //label
    @IBOutlet weak var viewTitle: UILabel!
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    var archivePatients = Array<Dictionary<String,String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        for array in patientRecords {
            if array["status"] == "Archive" {
                archivePatients.append(array)
            }
        }
        //Put count in Title
        var plural = "s"
        if archivePatients.count < 2 { plural = ""}
        viewTitle.text = "Sync \(archivePatients.count) record" + plural
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Check database connection
        let checkDBFlag = DispatchGroup()
        checkDBFlag.enter()
        GETdoesDB().haveTable(dispachInstance: checkDBFlag)
        checkDBFlag.notify(queue: DispatchQueue.main){
            let isReachable = UserDefaults.standard.bool(forKey: "isDataBaseReachable") //as? Bool ?? false
            if isReachable == false{
                self.syncUnavailable()
            }
            else {
                self.syncAvailable()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //button actions
    @IBAction func startSyncAction(_ sender: Any) {
        //Check database connection
            let checkDBFlag = DispatchGroup()
            checkDBFlag.enter()
            GETdoesDB().haveTable(dispachInstance: checkDBFlag)
            checkDBFlag.notify(queue: DispatchQueue.main){
                let isReachable = UserDefaults.standard.bool(forKey: "isDataBaseReachable") //as? Bool ?? false
                if isReachable == false{
                    self.simpleAlert(title: "Cloud Storage Unavailable", message: "Contact support and try again later.", buttonTitle: "OK")
                    self.syncUnavailable()
                }
                else {
                    self.syncAvailable()
                }
            }
        //POST Patient Table
        let patientPostFlag = DispatchGroup()
        let testDic = ["status":"Active", "intakeDate":"12/16/2017", "patientName":"Testerson", "walkDate":"2017-12-17 10:00:21", "photoName":"Testerson.png", "kennelId":"S7", "owner":"The Animal Foundation (TAF)", "groupString":"Canine"]
        //POSTPatientUpdates().updatePatientUpdates(update: testDic, dispachInstance: patientPostFlag)
        
        //GET MySQL patient ID
        //let patientFlag = DispatchGroup()
        //patientFlag.enter()
        //GETPatient().getPatient(patientID: "Suzy", dispachInstance: patientFlag)
        //patientFlag.notify(queue: DispatchQueue.main){
        //    let returnedPatientId = UserDefaults.standard.object(forKey: "dataBasePatientId") as? String ?? ""
        //    print("patientID: \(returnedPatientId) returned")
        //}
    }
    

}
extension SyncVC {
    //UI
    func setupUI(){
        syncTable.delegate = self
        syncTable.dataSource = self
    }
    //helper funcytions
    func syncUnavailable(){
        self.syncIndicator.image = UIImage(named: "synSlsh")
        self.syncButton.alpha = 0.5
    }
    func syncAvailable(){
        self.syncIndicator.image = UIImage(named: "syn")
        self.syncButton.alpha = 1
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
