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
    @IBOutlet weak var moreLessButton: RoundedButton!
    //label
    @IBOutlet weak var viewTitle: UILabel!
    //text field
    @IBOutlet weak var groupItemDetails: UITextView!
    //constraints

    @IBOutlet weak var syncButtonRightConstraint: NSLayoutConstraint!
    
    
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
    
    var moreLessBool = true
    
    var patientItemsSaved = [[String]]()//Array<Dictionary<String,String>>()
    var patientItemsToSave = [[String]]()
    
    var lastItemPopedOnStack = String()
    
    var stackOfStrings = Stack<[String]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getArchivePatientRecords()
        putArchiveCountInTitle()
        showItemsToSave(show: "less")
        
        let dataBasePatientId = UserDefaults.standard.object(forKey: "dataBasePatientId") as? Array<Dictionary<String,Any>> ?? []
        print("dataBasePatientId: \(dataBasePatientId)")
        
        //delete old sync db patient ID info before new sync
        let clear = Array<Dictionary<String,Any>>()
        UserDefaults.standard.set(clear, forKey: "dataBasePatientId")
        UserDefaults.standard.synchronize()
        
        createStack()
        
        NotificationCenter.default.addObserver(self,
                           selector: #selector(refreshSyncTable),
                           name: NSNotification.Name(rawValue: "refreshSyncTable"),
                           object: nil)
        hideSaveButtonIfArchiveIsEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkDatabaseIsReachable()
    }
    
    //
    //#MARK: - Button Actions
    //
    @IBAction func moreLessAction(_ sender: Any) {//TOGGLE MORE / LESS BUTTON
        groupItemDetails.text = ""
        if moreLessBool {
            //show more
            showItemsToSave(show: "more")
            moreLessButton.setTitle("less", for: .normal)
        } else {
            //show less
            showItemsToSave(show: "less")
            moreLessButton.setTitle("more", for: .normal)
        }
        moreLessBool.toggle()
    }
    
    @IBAction func startSyncAction(_ sender: Any) {
        groupItemDetails.text = ""
        moreLessButton.isHidden = true
        checkDatabaseConnection()
        processStack()
        
        // SHOW ACTIVITY INDICATOR, call the function from your view controller
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        // HIDE ACTIVITY INDICATOR, call the function from your view controller
        // ViewControllerUtils().hideActivityIndicator(uiView: self.view)
        // self.view.viewWithTag(1)?.removeFromSuperview()
        
        //---
        // TESTING Single API
        //---
        //testSingleAPI()
        //testSingleLoopAPI()

    }
}
extension SyncVC {
    //stack
    func showItemsToSave(show: String){
        let tables = [
            /*0*/patientRecords,
            /*1*/patientVitals,
            /*2*/patientPhysicalExam,
            /*3*/myNotifications,
            /*4*/myDemographics,
            /*5*/myAmpms,
            /*6*/incisions,
            /*7*/procedures,
            /*8*/badges, collectionTxVitals, collectionTreatments, treatmentsAndNotes
        ]
        let tableNames = [
            /*0*/"Patient Records",
            /*1*/"Vitals",
            /*2*/"Physical Exams",
            /*3*/"Notifications Repeating",
            /*4*/"Demographics",
            /*5*/"AMPM checks Repeating",
            /*6*/"Incisions Repeating",
            /*7*/"Procedures",
            /*8*/"Badges", "Treatment Vitals Repeating", "Treatments Repeating", "Treatment Notes Repeating"
        ]

        groupItemDetails.text = ""

        for patient in archivePatients{
 
            var countTableNames = 0
            
            let patientID = patient["patientID"]!
            for table in tables{
                if let index = table.index(where: {$0["patientID"] == patientID}){
   
                    if show == "more" {
                        syncButtonRightConstraint.constant = 10
                        print("countTableNames \(countTableNames)")
                        for item in tables[countTableNames]{
                            if item["patientID"] == patientID{
                                groupItemDetails.text = groupItemDetails.text + "🔁 \(patientID): \(tableNames[countTableNames]): \(item)\n"
                            }
                        }
                    } else {
                        syncButtonRightConstraint.constant = 150
                        print("countTableNames \(countTableNames)")
                        groupItemDetails.text = groupItemDetails.text + "🔁 \(patientID): \(tableNames[countTableNames])\n"
                    }
                }
                countTableNames += 1
            }
        }
    }
    func createStack(){
        let tables = [patientRecords, patientVitals, patientPhysicalExam, myNotifications, myDemographics, myAmpms, incisions, procedures, badges, collectionTxVitals, collectionTreatments, treatmentsAndNotes]
        let tableNames = ["Patient Records", "Vitals", "Physical Exams", "Notifications Repeating", "Demographics", "AMPM checks Repeating", "Incisions Repeating", "Procedures", "Badges", "Treatment Vitals Repeating", "Treatments Repeating", "Treatment Notes Repeating"]
        
        for patient in archivePatients{
            let patientID = patient["patientID"]!
            
            //var countTables = 0
            var countTableNames = 0
            var endString = [String]()
            
            for table in tables{

                if let index = table.index(where: {$0["patientID"] == patientID}){
                    
                    endString = [patientID,tableNames[countTableNames],String(index)]
                    stackOfStrings.pushFirst(endString)
                }
                countTableNames += 1
            }
        }
    }
    func processStack(){
        
        if stackOfStrings.items.count == 0{
            
            hideActivityIndicator()
            
            syncButton.isHidden = true
            
            simpleAlert(title: "Save To Cloud Completed", message: "", buttonTitle: "OK")
            
            for index in 0..<patientItemsToSave.count {
                let patientToSave = patientItemsToSave[index] //[patientName, itemCount]
                
                for index2 in 0..<patientItemsSaved.count{
                    let patientSaved = patientItemsSaved[index2]
                    
                    if patientToSave[0] == patientSaved[0]{
                        if patientToSave[1] == patientSaved[1]{
                            //Verify all items saved for patient
                            //DELETE
                            removeAllDataAndPicturesFor(patientID:patientToSave[0])
                            print(" <> DELETE \(patientToSave[0]) \(patientToSave[1]) <>")
                        }
                    }
                }
            }
            print("  >> Patient items saved: \(patientItemsSaved)")
            print("  << Patient items to save: \(patientItemsToSave)")
            
        } else {
            
                let topItem = stackOfStrings.peek()
                let groupType = topItem[1]
                
                print("PID,tableName,indexPIDInTable \(topItem)")
                savePatientRecords(topItem: topItem, saveType: groupType)
            
        }
    }

    // SAVE FUNCTIONS
    // 1. Check DB reachable
    // 2. Check Is patient duplicate
    // 3. Save
    // 4. O.W. Put back
    func savePatientRecords(topItem: [String], saveType: String){
        // POP - parent loop can continue
        _ = stackOfStrings.pop()
        lastItemPopedOnStack = topItem[0]
        
        // Is Data Base Reachable?
        let checkDBFlag = DispatchGroup()
        checkDBFlag.enter()
        GETdoesDB().haveTable(dispachInstance: checkDBFlag)
        checkDBFlag.notify(queue: DispatchQueue.main){
            let isReachable = UserDefaults.standard.bool(forKey: "isDataBaseReachable") //as? Bool ?? false
            if isReachable == true{
                
        //Is patient Duplicate?
                let patientID = topItem[0]
                let patient = self.archivePatients.first(where: {$0["patientID"] == patientID})!
//                let patientFlag = DispatchGroup()
//                patientFlag.enter()
//                let intakeDate = patient["intakeDate"]
//                let intakeDateNoEscapeChars = intakeDate?.replacingOccurrences(of: "/", with: "%2F", options: .literal, range: nil)/*"12%2F15%2F2017"*/
//                GETPatientIntake().exists(patientID: patient["patientID"]!, intakeDate: intakeDateNoEscapeChars!, dispachInstance: patientFlag)
//                patientFlag.notify(queue: DispatchQueue.main){
//                    if UserDefaults.standard.bool(forKey: "patientIsInDatabase") == true{
//                        print("patient Is In Database duplicate? or update? or crash halfway through save other tables")
//                        self.putItemBackOnStackExistInMySQLDB(topItem: topItem, msg: "Duplicate?")
//                    } else {
//                        print("patient Not In Database - save now ")
                
        //SAVE
                        switch (saveType){
                        case "Patient Records":
                            self.savePatientRecordsNow(patient: patient, topItem: topItem, patientID: patientID)
                        case "Vitals":
                            self.saveVitals(patient: patient, topItem: topItem, patientID: patientID)
                        case "Physical Exams":
                            self.savePhysicalExams(patient: patient, topItem: topItem, patientID: patientID)
                        case "Notifications Repeating":
                            self.saveNotificationsRepeating(patient: patient, topItem: topItem, patientID: patientID)
                        case "Demographics":
                            self.saveDemographics(patient: patient, topItem: topItem, patientID: patientID)
                        case "AMPM checks Repeating":
                            self.saveAMPMChecksRepeating(patient: patient, topItem: topItem, patientID: patientID)
                        case "Incisions Repeating":
                            self.saveIncisionsRepeating(patient: patient, topItem: topItem, patientID: patientID)
                        case "Procedures":
                            self.saveProcedures(patient: patient, topItem: topItem, patientID: patientID)
                        case "Badges":
                            self.saveBadges(patient: patient, topItem: topItem, patientID: patientID)
                        case "Treatment Vitals Repeating":
                            self.saveTreatmentVitalsRepeating(patient: patient, topItem: topItem, patientID: patientID)
                        case "Treatments Repeating":
                            self.saveTreatmentsRepeating(patient: patient, topItem: topItem, patientID: patientID)
                        case "Treatment Notes Repeating":
                            self.saveTreatmentNotesRepeating(patient: patient, topItem: topItem, patientID: patientID)
                        default:
                            print("Some other case")
                        }
                    //}
                //}
            }
            else {
        //PUT BACK
                self.putItemBackTryLater(topItem: topItem)
            }
        }
    }
    func savePatientRecordsNow(patient: [String : String], topItem: [String], patientID: String){
        let postPatientFlag = DispatchGroup(); postPatientFlag.enter()
        let parameters = params().patientParameters(update: patient)
        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postPatient, dispachInstance: postPatientFlag)
        
        postPatientFlag.notify(queue: DispatchQueue.main){
            self.updateUITextField(patient: patient, topItem: topItem)
            self.processStack()
        }
    }
    func saveVitals(patient: [String : String], topItem: [String], patientID: String){
        let index = Int(topItem[2])!
        let vitalRecord = self.patientVitals[index]
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        let postVitalFlag = DispatchGroup(); postVitalFlag.enter()
        let parameters = params().vitalParameters(update: vitalRecord, databasePID: dBPID)
        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postVitals, dispachInstance: postVitalFlag)
        
        postVitalFlag.notify(queue: DispatchQueue.main){
            self.updateUITextField(patient: patient, topItem: topItem)
            self.processStack()
        }
    }
    func savePhysicalExams(patient: [String : String], topItem: [String], patientID: String){
        let index = Int(topItem[2])!
        let peRecord = self.patientPhysicalExam[index]
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        let peFlag = DispatchGroup(); peFlag.enter()
        let parameters = params().peParameters(update: peRecord, databasePID: dBPID)
        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postPE, dispachInstance: peFlag)
        
        peFlag.notify(queue: DispatchQueue.main){
            self.updateUITextField(patient: patient, topItem: topItem)
            self.processStack()
        }
    }
    func saveNotificationsRepeating(patient: [String : String], topItem: [String], patientID: String){
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        var doOnce = 0
        for nrRecord in self.myNotifications{
            if nrRecord["patientID"] == patient["patientID"]!{
                let nrFlag = DispatchGroup(); nrFlag.enter()
                let parameters = params().myNotifiParameters(update: nrRecord, databasePID: dBPID)
                POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postNotificat, dispachInstance: nrFlag)
                nrFlag.notify(queue: DispatchQueue.main){
                    if doOnce == 0{
                        doOnce = 1
                        self.updateUITextField(patient: patient, topItem: topItem)
                        self.processStack()
                    }
                }
            }
        }
    }
    func saveDemographics(patient: [String : String], topItem: [String], patientID: String){
        let index = Int(topItem[2])!
        let dRecord = self.myDemographics[index]
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        let dFlag = DispatchGroup(); dFlag.enter()
        let parameters = params().demographicParameters(update: dRecord, databasePID: dBPID)
        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postDemog, dispachInstance: dFlag)
        
        dFlag.notify(queue: DispatchQueue.main){
            self.updateUITextField(patient: patient, topItem: topItem)
            self.processStack()
        }
    }
    func saveAMPMChecksRepeating(patient: [String : String], topItem: [String], patientID: String){
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        var doOnce = 0
        for aRecord in self.myAmpms{
            if aRecord["patientID"] == patient["patientID"]!{
                let aFlag = DispatchGroup(); aFlag.enter()
                let parameters = params().ampmParameters(update: aRecord, databasePID: dBPID)
                POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postAMPM, dispachInstance: aFlag)
                aFlag.notify(queue: DispatchQueue.main){
                    if doOnce == 0{
                        doOnce = 1
                        self.updateUITextField(patient: patient, topItem: topItem)
                        self.processStack()
                    }
                }
            }
        }
    }
    func saveIncisionsRepeating(patient: [String : String], topItem: [String], patientID: String){
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        var doOnce = 0
        for iRecord in self.incisions{
            if iRecord["patientID"] == patient["patientID"]!{
                let iFlag = DispatchGroup(); iFlag.enter()
                let parameters = params().incisionsParameters(update: iRecord, databasePID: dBPID)
                POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postIncisions, dispachInstance: iFlag)
                iFlag.notify(queue: DispatchQueue.main){
                    if doOnce == 0{
                        doOnce = 1
                        self.updateUITextField(patient: patient, topItem: topItem)
                        self.processStack()
                    }
                }
            }
        }
    }
    func saveProcedures(patient: [String : String], topItem: [String], patientID: String){
        let index = Int(topItem[2])!
        let pRecord = self.procedures[index]
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        let pFlag = DispatchGroup(); pFlag.enter()
        let parameters = params().proceduresParameters(update: pRecord, databasePID: dBPID)
        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postProcedure, dispachInstance: pFlag)
        
        pFlag.notify(queue: DispatchQueue.main){
            self.updateUITextField(patient: patient, topItem: topItem)
            self.processStack()
        }
    }
    func saveBadges(patient: [String : String], topItem: [String], patientID: String){
        let index = Int(topItem[2])!
        let bRecord = self.badges[index]
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        let bFlag = DispatchGroup(); bFlag.enter()
        let parameters = params().badgesParameters(update: bRecord, databasePID: dBPID)
        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postBadges, dispachInstance: bFlag)
        
        bFlag.notify(queue: DispatchQueue.main){
            self.updateUITextField(patient: patient, topItem: topItem)
            self.processStack()
        }
    }
    //TREATMENTS
    func saveTreatmentVitalsRepeating(patient: [String : String], topItem: [String], patientID: String){
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        var doOnce = 0
        for tvRecord in self.collectionTxVitals{//collectionTreatments treatmentsAndNotes
            if tvRecord["patientID"] == patient["patientID"]!{
                let tvFlag = DispatchGroup(); tvFlag.enter()
                let parameters = params().treatmentVitalsParameters(update: tvRecord, databasePID: dBPID)
                POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postTxVitals, dispachInstance: tvFlag)
                tvFlag.notify(queue: DispatchQueue.main){
                    if doOnce == 0{
                        doOnce = 1
                        self.updateUITextField(patient: patient, topItem: topItem)
                        self.processStack()
                    }
                }
            }
        }
    }
    func saveTreatmentsRepeating(patient: [String : String], topItem: [String], patientID: String){
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        var doOnce = 0
        for tRecord in self.collectionTreatments{//collectionTreatments treatmentsAndNotes
            if tRecord["patientID"] == patient["patientID"]!{
                let tFlag = DispatchGroup(); tFlag.enter()
                let parameters = params().treatmentsParameters(update: tRecord, databasePID: dBPID)
                POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postTx, dispachInstance: tFlag)
                tFlag.notify(queue: DispatchQueue.main){
                    if doOnce == 0{
                        doOnce = 1
                        self.updateUITextField(patient: patient, topItem: topItem)
                        self.processStack()
                    }
                }
            }
        }
    }
    func saveTreatmentNotesRepeating(patient: [String : String], topItem: [String], patientID: String){
        let dBPID:Int = self.findDatabasePatientIdFor(patientID: patient["patientID"]!)
        var doOnce = 0
        for tnRecord in self.treatmentsAndNotes{//collectionTreatments treatmentsAndNotes
            if tnRecord["patientID"] == patient["patientID"]!{
                let tnFlag = DispatchGroup(); tnFlag.enter()
                let parameters = params().treatmentNotesParameters(update: tnRecord, databasePID: dBPID)
                POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postTxNotes, dispachInstance: tnFlag)
                tnFlag.notify(queue: DispatchQueue.main){
                    if doOnce == 0{
                        doOnce = 1
                        self.updateUITextField(patient: patient, topItem: topItem)
                        self.processStack()
                    }
                }
            }
        }
    }
    func returnStatusCode() -> Int{ //http://www.restapitutorial.com/httpstatuscodes.html
        return UserDefaults.standard.integer(forKey: "statusCode")
    }
    //Called When save task complete
    func updateItemsSaved(topItem: [String]){
        
        let patientName = topItem[0]
        var countItems = 1
        var findPatientAndUpdateCount = false
        
        for index in 0..<patientItemsSaved.count {
            if patientItemsSaved[index][0] == patientName {
                countItems = Int(patientItemsSaved[index][1])! + 1
                patientItemsSaved[index][1] = String(countItems)
                findPatientAndUpdateCount = true
            }
        }
        
        if findPatientAndUpdateCount == false { patientItemsSaved.append([patientName,String(countItems)]) }
    }
    func updateUITextField(patient: [String : String], topItem: [String]){

        self.updateItemsSaved(topItem: topItem)
        
        if self.returnStatusCode() == 200{
            //let group = topItem[1]
            //print("\(patient["patientID"]!): \(group) Saved")
            self.successSavingItem(topItem: topItem)
            //REFRESH SYNC TABLE VIEW
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshSyncTable"), object: nil)
        }
        else {
            //error
            self.putItemBackOnStackExistInMySQLDB(topItem: topItem, msg: "cloud error")
        }
    }
    //Options: 1. ❌,✅,🔁⚠️,🔁
    func putItemBackTryLater(topItem: [String]){
        groupItemDetails.text = groupItemDetails.text + "⚠️🔁 \(topItem[0]): \(topItem[1])\n"
        print("No Internet Try Later")
        //put back
        stackOfStrings.pushFirst(topItem)
    }
    func putItemBackOnStackTryAgainLater(topItem: [String]){
        groupItemDetails.text = groupItemDetails.text + "🔁 \(topItem[0]): \(topItem[1])\n"
        print(" Try Later")
        //_ = stackOfStrings.pop()
        //put back
        stackOfStrings.pushFirst(topItem)
    }
    func putItemBackOnStackExistInMySQLDB(topItem: [String], msg: String){
        groupItemDetails.text = groupItemDetails.text + msg + "❌ \(topItem[0]): \(topItem[1])\n"
        print("Exists Try Later")
        //_ = stackOfStrings.pop()
        //put back
        stackOfStrings.pushFirst(topItem)
    }
    func successSavingItem(topItem: [String]){
        groupItemDetails.text = groupItemDetails.text + "✅ \(topItem[0]): \(topItem[1])\n"
    }
    
    func checkIfPatientInMySQLDB(_ patientID:String ){
//        let patientID = topItem[0]
//        let patient = archivePatients.first(where: {$0["patientID"] == patientID})
//        let patientFlag = DispatchGroup()
//        patientFlag.enter()
//        let intakeDate = patient!["intakeDate"]
//
//        let intakeDateNoEscapeChars = intakeDate?.replacingOccurrences(of: "/", with: "%2F", options: .literal, range: nil)
//        GETPatientIntake().exists(patientID: /*"Bob2"*/patient!["patientID"]!, intakeDate: intakeDateNoEscapeChars!/*"12%2F15%2F2017"*/, dispachInstance: patientFlag)
//        patientFlag.notify(queue: DispatchQueue.main){
//            if UserDefaults.standard.bool(forKey: "patientIsInDatabase") == true{
//                print("patient Is In Database duplicate? or update? or crash halfway through save other tables")
//                self.putItemBackOnStackExistInMySQLDB(topItem: topItem, msg: "Duplicate?")
//            } else {
//                print("patient Not In Database - save now ")

        //saveFunction
                //self.addPatientDataToMySQLDB(patient: patient!, topItem: topItem)
            //}
    
    }
}
extension SyncVC {
    // #MARK: - UI
    func setupUI(){
        syncTable.delegate = self
        syncTable.dataSource = self
    }
    @objc func refreshSyncTable(){          //only called if  200 OK back from server
        if stackOfStrings.items.count == 0{
            //print("count = \(stackOfStrings.items.count)")
            viewTitle.text = "Save complete"
            syncButton.isHidden = true
            for index in 0..<archivePatients.count{
                archivePatients[index]["status"] = "Saved"
            }
            syncTable.reloadData()
        }
    }
    func hideSaveButtonIfArchiveIsEmpty(){
        if archivePatients.isEmpty {
            syncButton.isHidden = true
        }
    }
    func hideActivityIndicator(){
        // HIDE ACTIVITY INDICATOR, call the function from your view controller
        ViewControllerUtils().hideActivityIndicator(uiView: self.view)
        self.view.viewWithTag(1)?.removeFromSuperview()
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
        viewTitle.text = "Save \(archivePatients.count) patient" + plural
    }
    func checkDatabaseIsReachable(){
        let checkDBFlag = DispatchGroup()
        checkDBFlag.enter()
        GETdoesDB().haveTable(dispachInstance: checkDBFlag)
        checkDBFlag.notify(queue: DispatchQueue.main){
            let isReachable = UserDefaults.standard.bool(forKey: "isDataBaseReachable") //as? Bool ?? false
            if isReachable == false{
                self.syncUnavailable()
                print("False reach: see checkDatabaseIsReachable()")
            }
            else {
                self.syncAvailable()
                print("True reach: see checkDatabaseIsReachable()")
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
                //self.backUpNow()
                
            }
        }
    }
    func findDatabasePatientIdFor(patientID: String) -> Int{
        var dBPID = 0
        let dbPatientIdArray = UserDefaults.standard.object(forKey: "dataBasePatientId") as? Array<Dictionary<String,Any>> ?? []
        for item in dbPatientIdArray{
            let stringPID = item["patientID"]! as! String
            if stringPID == patientID {
                dBPID = item["dataBasePatientId"] as! Int
            }
        }
        //print("dBPID \(dBPID)")
        return dBPID
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
        if this["status"] == "Archive"{
            cell.photo.image = returnImage(imageName: this["patientID"]! + ".png")
            cell.name.text = this["patientID"]!
            let numItems = returnTotalItemsToSave(patientID:this["patientID"]!)
            cell.message.text = " " + numItems + " Item groups found."
        }
        return cell
    }
    func returnTotalItemsToSave(patientID: String) -> String{
        var countItems = 0
        let tables = [patientRecords, patientVitals, patientPhysicalExam, myNotifications, myDemographics, myAmpms, incisions, procedures, badges, collectionTxVitals, collectionTreatments, treatmentsAndNotes]
        //let tableNames = ["Rec", "Vit", "PEx", "Not", "Dem", "Amp", "Inc", "Pro", "Bad", "TVi", "Tre", "TNo"]
        for table in tables{
            
            if let index = table.index(where: {$0["patientID"] == patientID}){
                countItems += 1
                
            }
        }

        patientItemsToSave.append([patientID,String(countItems)])
        
        return String(countItems)
    }
}
extension SyncVC {
    // #MARK: - API Testing
    func testSingleAPI(){
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
        
        
    }
    func testSingleLoopAPI() {
        //            //Save myAmpms
        //            if let index = self.myAmpms.index(where: {$0["patientID"] == patient["patientID"]!}){
        //
        //
        //                for aRecord in self.myAmpms{
        //                    if aRecord["patientID"] == patient["patientID"]!{
        //                        print("\(patient["patientID"]!) exists in myAmpms")
        //                        let aFlag = DispatchGroup()
        //                        aFlag.enter()
        //                        let parameters = params().ampmParamaters(update: aRecord, databasePID: 21)
        //                        POSTPatientUpdates().updatePatientUpdates(parameters: parameters, endPoint: Constants.Patient.postAMPM, dispachInstance: aFlag)
        //                    }
        //                }
        //                //let aRecord = self.myDemographics[index]
        //            }
        //        }
    }
}

//NOTES
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
