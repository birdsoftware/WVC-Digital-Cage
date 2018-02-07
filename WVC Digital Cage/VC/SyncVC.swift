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
    
    /*1*/ let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    /*2*/ let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
    /*3*/ let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
    /*4*/ let myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
    /*5*/ let myDemographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
    /*6*/ let myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
    /*7*/ let incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
    /*8*/ let procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
    /*9*/ //let collectionPhotos = UserDefaults.standard.object(forKey: "collectionPhotos") as? Array<Dictionary<String,String>> ?? []
    /*10*/ let badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
    /*11*/ let collectionTxVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
    /*12*/ let collectionTreatments = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
    /*13*/ let treatmentsAndNotes = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []
    
    var completedPatientTablesQueue = UserDefaults.standard.object(forKey: "completedPatientTablesQueue") as? Array<Dictionary<String,String>> ?? []
    
    var archivePatients = Array<Dictionary<String,String>>()
    
    var tempPatientId = Array<Dictionary<String,Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getArchivePatientRecords()
        putArchiveCountInTitle()
        
        let clear = Array<Dictionary<String,Any>>()
        UserDefaults.standard.set(clear, forKey: "dataBasePatientId")
        UserDefaults.standard.synchronize()
        
//        if let index = patientRecords.index(where: {$0["patientID"] == "snowball"}) {
//            print("1 exists in patients")
//        }
//        if let index = patientVitals.index(where: {$0["patientID"] == "snowball"}) {
//            print("2 exists in patientVitals")
//        }
//        if let index = patientPhysicalExam.index(where: {$0["patientID"] == "snowball"}) {
//            print("3 exists in patientPhysicalExam")
//        }
//        if let index = myNotifications.index(where: {$0["patientID"] == "snowball"}) {
//            print("4 exists in myNotifications")
//        }
//        if let index = myDemographics.index(where: {$0["patientID"] == "snowball"}) {
//            print("5 exists in myDemographics")
//        }
//        if let index = myAmpms.index(where: {$0["patientID"] == "snowball"}) {
//            print("6 exists in myAmpms")
//        }
//        if let index = incisions.index(where: {$0["patientID"] == "snowball"}) {
//            print("7 exists in incisions")
//        }
//        if let index = procedures.index(where: {$0["patientID"] == "snowball"}) {
//            print("8 exists in procedures")
//        }
//        if let index = badges.index(where: {$0["patientID"] == "snowball"}) {
//            print("9 exists in badges")
//        }
//        if let index = collectionTxVitals.index(where: {$0["patientID"] == "snowball"}) {
//            print("10 exists in collectionTxVitals")
//        }
//        if let index = collectionTreatments.index(where: {$0["patientID"] == "snowball"}) {
//            print("11 exists in collectionTreatments")
//        }
//        if let index = treatmentsAndNotes.index(where: {$0["patientID"] == "snowball"}) {
//            print("12 exists in treatmentsAndNotes")
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkDatabaseIsReachable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //
    //#MARK: - Button Actions
    //
    @IBAction func startSyncAction(_ sender: Any) {
        
        checkDatabaseConnection()
//        for patient in self.archivePatients {
//            //Save myDemographics
//            if let index = self.myDemographics.index(where: {$0["patientID"] == patient["patientID"]!}){
//                let dRecord = self.myDemographics[index]
//                print("\(patient["patientID"]!) exists in myDemographics")
//                let dFlag = DispatchGroup()
//                dFlag.enter()
//
//                let parameters = params().demographicParamaters(update: dRecord, databasePID: 11)
//                POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postDemog, dispachInstance: dFlag)
//            }
//        }

    }
    

}

extension SyncVC {
    // #MARK: - UI
    func setupUI(){
        syncTable.delegate = self
        syncTable.dataSource = self
    }
    func getArchivePatientRecords(){
        for array in patientRecords {
            if array["status"] == "Archive" {
                archivePatients.append(array)
            }
        }
    }
    func putArchiveCountInTitle(){
        var plural = "s"
        if archivePatients.count < 2 { plural = ""}
        viewTitle.text = "Sync \(archivePatients.count) record" + plural
    }
    func checkDatabaseIsReachable(){
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
    // #MARK: - UI Helper Functions
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
    // #MARK: - API Helper Functions
    func checkDatabaseConnection(){
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
                
                self.backUpNow()
                
            }
        }
    }
    func backUpNow(){
        
        for patient in self.archivePatients {
            
            isPatientInMySQLDB(patient: patient)
            
            //checkForDuplicatePatientRecord
            // check last saved mySQLGeneratedPatientID and patientID [5, Bob] to this patient mySQLGeneratedPatientID and patientID
            // if empty or not the same continue, if same 5 = 5 & Bob = Bob dont save patient record but check other tables to save
            
            // for item in completedPatientTablesQueue
            
            // if item != mySQLGeneratedPatientID
            //    backUpItemOnMySQL
            //    update completedPatientTablesQueue
            //    check item exists in mySQL
            //    remove item from tableInLocalStorage
            //    updateUI
            
        }//end for
    }
    func isPatientInMySQLDB(patient: [String : String]) {

        let patientFlag = DispatchGroup()
        patientFlag.enter()
        let intakeDate = patient["intakeDate"]!

        let intakeDateNoEscapeChars = intakeDate.replacingOccurrences(of: "/", with: "%2F", options: .literal, range: nil)
        GETPatientIntake().exists(patientID: /*"Bob2"*/patient["patientID"]!, intakeDate: intakeDateNoEscapeChars/*"12%2F15%2F2017"*/, dispachInstance: patientFlag)
        patientFlag.notify(queue: DispatchQueue.main){
            if UserDefaults.standard.bool(forKey: "patientIsInDatabase") == true{
                print("patient Is In Database duplicate? or update? or crash halfway through save other tables")
            } else {
                print("patient Not In Database - save now ")
                
                self.addPatientDataToMySQLDB(patient: patient)
                
            }
            
        }
    }
    func findDatabasePatientIdFor(patientID: String) -> Int{
        var mYSQLpID = 0
        let dbPatientIdArray = UserDefaults.standard.object(forKey: "dataBasePatientId") as? Array<Dictionary<String,Any>> ?? []
        for item in dbPatientIdArray{
            let stringPID = item["patientID"]! as! String
            if stringPID == patientID {
                mYSQLpID = item["dataBasePatientId"] as! Int
            }
        }
        return mYSQLpID
    }
    func addPatientDataToMySQLDB(patient: [String : String]){
        //Save patientRecords & Get dataBasePatientId UserDefaults
        let postPatientFlag = DispatchGroup()
        postPatientFlag.enter()
        let parameters = params().patientParameters(update: patient)
        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postPatient, dispachInstance: postPatientFlag)
        
        postPatientFlag.notify(queue: DispatchQueue.main){
            let statusCode: Int = UserDefaults.standard.integer(forKey: "statusCode")
            if statusCode == 200{//http://www.restapitutorial.com/httpstatuscodes.html
                print("Save successful \(patient["patientID"]!)")
                
                let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
                
                //Save patientVitals if exist
                if let index = self.patientVitals.index(where: {$0["patientID"] == patient["patientID"]!}) {
                    let vitalRecord = self.patientVitals[index]
                    print("\(patient["patientID"]!) exists in patientVitals")
                    let postVitalFlag = DispatchGroup()
                    postVitalFlag.enter()
                    
                    let parameters = params().vitalParameters(update: vitalRecord, databasePID: dBPID)
                    
                    POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postVitals, dispachInstance: postVitalFlag)
                }
                //Save patientPhysicalExam
                if let index = self.patientPhysicalExam.index(where: {$0["patientID"] == patient["patientID"]!}) {
                    let peRecord = self.patientPhysicalExam[index]
                    print("\(patient["patientID"]!) exists in patientPhysicalExam")
                    let peFlag = DispatchGroup()
                    peFlag.enter()
                    
                    let parameters = params().peParameters(update: peRecord, databasePID: dBPID)
                    
                    POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postPE, dispachInstance: peFlag)
                
                }
                //Save myNotifications
                if let index = self.myNotifications.index(where: {$0["patientID"] == patient["patientID"]!}){
                    let nRecord = self.myNotifications[index]
                    print("\(patient["patientID"]!) exists in myNotifications")
                    let notificationsFlag = DispatchGroup()
                    notificationsFlag.enter()
                    
                    let parameters = params().myNotifiParameters(update: nRecord, databasePID: dBPID)
                    POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postNotificat, dispachInstance: notificationsFlag)
                }
                
                //Save myDemographics
                if let index = self.myDemographics.index(where: {$0["patientID"] == patient["patientID"]!}){
                    let dRecord = self.myDemographics[index]
                    print("\(patient["patientID"]!) exists in myDemographics")
                    let dFlag = DispatchGroup()
                    dFlag.enter()
                    
                    let parameters = params().demographicParamaters(update: dRecord, databasePID: dBPID)
                    POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postDemog, dispachInstance: dFlag)
                }
                
                //Save myAmpms
                
//                if let index = myAmpms.index(where: {$0["patientID"] == "snowball"}) {
//                    print("6 exists in myAmpms")
//                }
//                if let index = incisions.index(where: {$0["patientID"] == "snowball"}) {
//                    print("7 exists in incisions")
//                }
//                if let index = procedures.index(where: {$0["patientID"] == "snowball"}) {
//                    print("8 exists in procedures")
//                }
//                if let index = badges.index(where: {$0["patientID"] == "snowball"}) {
//                    print("9 exists in badges")
//                }
//                if let index = collectionTxVitals.index(where: {$0["patientID"] == "snowball"}) {
//                    print("10 exists in collectionTxVitals")
//                }
//                if let index = collectionTreatments.index(where: {$0["patientID"] == "snowball"}) {
//                    print("11 exists in collectionTreatments")
//                }
//                if let index = treatmentsAndNotes.index(where: {$0["patientID"] == "snowball"}) {
//                    print("12 exists in treatmentsAndNotes")
//                }
                
            } else {
                print("error in save try again. Status Code: \(statusCode)")
                self.simpleAlert(title: "Error saving try again", message: "Error Status Code: \(statusCode)", buttonTitle: "OK")
            }
        }
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
        let numItems = returnTotalItemsToSave(patientID:this["patientID"]!)
        cell.message.text = "O out of " + numItems + " items saved."
        return cell
    }
    func returnTotalItemsToSave(patientID: String) -> String{
        var countItems = 0
        let tables = [patientRecords, patientVitals, patientPhysicalExam, myNotifications, myDemographics, myAmpms, incisions, procedures, badges, collectionTxVitals, collectionTreatments, treatmentsAndNotes]
        //let tableNames = ["Rec", "Vit", "PEx", "Not", "Dem", "Amp", "Inc", "Pro", "Bad", "TVi", "Tre", "TNo"]
        //var iterator = 0
        //var endString = ""
        for table in tables{
            
            if let index = table.index(where: {$0["patientID"] == patientID}){
                countItems += 1
                //endString += " \(tableNames[iterator])"
            }
            //iterator += 1
        }


        return String(countItems)// + endString
    }
}
