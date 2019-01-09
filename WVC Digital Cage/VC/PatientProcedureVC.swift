//
//  PatientProcedureVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/27/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientProcedureVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var patientProcedureView: UIView!
    
    //table
    @IBOutlet weak var incisionTable: UITableView!
    //text fields
    @IBOutlet weak var initialsTF: UITextField!
    @IBOutlet weak var sutureTF: UITextField!
    @IBOutlet weak var radiographTF: UITextField!
    @IBOutlet weak var labTF: UITextField!
    //labels
    @IBOutlet weak var incisionDate: UILabel!
    @IBOutlet weak var surgeryDate: UILabel!
    @IBOutlet weak var incisionLastChecked: UILabel!
    //button
    @IBOutlet weak var bloodWorkButton: UIButton!
    //constraints
    @IBOutlet weak var aMPMTopConstraint: NSLayoutConstraint!
    
    var toggleBloodWork = false
    var incisions = Array<Dictionary<String,String>>()
    var filteredIncisions = Array<Dictionary<String,String>>()
    var procedures = Array<Dictionary<String,String>>()
    var newProcedure:Dictionary<String,String> =
        [
            "patientID":"",
            "bloodWork":"",
            "surgeryDate":"",
            "suture":"",
            "radiographs":"",
            "lab":""
        ]
    var newIncision:/*[String:Any] =*/Dictionary<String,String> =
        [
            "patientID":"",
            "patientName":"",
            "initials":"",
            "date":""
        ]
    let clear:Dictionary<String,String> =
        [
            "patientID":"",
            "initials":"",
            "date":""
    ]
    
    //
    // #MARK: - Button Actions
    //
    @IBAction func bloodWorkAction(_ sender: Any) {
        if (toggleBloodWork) {
            bloodWorkButton.setImage(UIImage.init(named: "box"), for: .normal)
            toggleBloodWork = false
        } else {
            bloodWorkButton.setImage(UIImage.init(named: "boxCheck"), for: .normal)
            toggleBloodWork = true }
        saveProcedureObject()
    }
    @IBAction func changeIncisionDateAction(_ sender: Any) {
        changeDateTime(dateLabel: incisionDate, title: "Incision Date")
    }
    @IBAction func changeSurgeryDateAction(_ sender: Any) {
        changeDateTime(dateLabel: surgeryDate, title: "Surgery Date")
        saveProcedureObject()
    }
    @IBAction func updateNowAction(_ sender: Any) {
        if initialsTF.text?.isEmpty ?? true {
            simpleAlert(title: "Initials are missing", message: "Enter your initials before update.", buttonTitle: "OK")
        } else{
            saveIncisionObject()
            initialsTF.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate
        incisionTable.delegate = self
        incisionTable.dataSource = self
        setupUI()
        textFieldsDelegates()
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(showProcedure),
                                               name: NSNotification.Name(rawValue: "showProcedure"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                           selector: #selector(keyboardWillHideProcedure),
                           name: .UIKeyboardWillHide,
                           object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowProcedure),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
    }
    override func viewWillAppear(_ animated: Bool){
        incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
        procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
        showProcedure()
    }
}
extension PatientProcedureVC {
    //
    // #MARK: - Keboard
    //
    @objc func keyboardWillShowProcedure(sender: NSNotification){
        //AMPMTextFieldsViewTopLayoutConstraint.constant = -300
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    @objc func keyboardWillHideProcedure(sender: NSNotification){
        aMPMTopConstraint.constant = 2
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
extension PatientProcedureVC {
    //
    // #MARK: - Table View
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return filteredIncisions.count
        }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: ProcedureIncisionCheck = tableView.dequeueReusableCell(withIdentifier: "incisionCell") as! ProcedureIncisionCheck
        let this = filteredIncisions[IndexPath.row]//patientRecords[IndexPath.row]
        cell.date.text = this["date"]
        cell.initials.text = this["initials"]
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("Delete button tapped - incisions")
            let this = self.filteredIncisions[indexPath.row]
            let pIDThis = this["patientID"]
            let dateThis = this["date"]
            self.deleteButtonTapped(pid: pIDThis!, date: dateThis!)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    func deleteButtonTapped(pid: String, date: String){
        incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
        
        for index in 0..<incisions.count{
            if incisions[index]["patientID"] == pid && incisions[index]["date"] == date {

                //incisions.remove(at: index)
                
                //UserDefaults.standard.set(incisions, forKey: "incisions")
                //UserDefaults.standard.synchronize()
                
                //showIncisions()
                
                if let incisionsId = incisions[index]["incisionsId"] {
                print("removed for incisionsId: \(incisionsId)")
                    deleteIncision(incisionsId: Int(incisionsId)!) }
                
                break
            }
        }
    }
}
extension PatientProcedureVC {
    //
    // #MARK: - UI
    //
    func setupUI(){
        // Date now
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy hh:mm a"
        let nowString = formatter.string(from: Date())
        incisionDate.text = nowString
    }
}
extension PatientProcedureVC{
    //
    //#MARK - Date Picker Alert
    //
    func changeDateTime(dateLabel: UILabel, title: String){
        DatePickerDialog().show(title, doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .dateAndTime) {
            (date) -> Void in
            if date != nil {
                let dateFormat = DateFormatter()
                //dateFormat.dateStyle = DateFormatter.Style.short // --NO TIME .short
                dateFormat.dateFormat = "MM/dd/yy hh:mm a"
                let strDate = dateFormat.string(for: date!)!
                /* Uncomment for TIME use:
                 * let formatterTime = DateFormatter()
                 * formatterTime.timeStyle = .short
                 * let strTime =  formatterTime.string(from: date!)
                 */
                //----- UPDATE UI LABEL BY DATE SELECTED ---------
                //self.appointmentDate.text = "Appointment Date: \(strDate) \(strTime)"
                dateLabel.text = strDate
                self.saveProcedureObject()
            }
        }
    }
}
extension PatientProcedureVC {
    //
    // #MARK: - API
    //
    func getAllIncisions(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getIncisions(aview: patientProcedureView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            self.showIncisions()
        }
    }
    func insertIncisions(thisIncision:[String:Any]) {
        let insertDG = DispatchGroup()
        insertDG.enter()
        INSERT().newIncision(aview: patientProcedureView, parameters: thisIncision, dispachInstance: insertDG)
        
        insertDG.notify(queue: DispatchQueue.main) {
            print("insert new incision success")
            self.getAllIncisions()
        }
    }
    func deleteIncision(incisionsId: Int) {
        /* {
         *  "incisionsId": "6"
         *  } */
        let removeDG = DispatchGroup()
        removeDG.enter()
        DeleteInstantShare().Incision(aview: patientProcedureView, parameters: ["incisionsId":incisionsId], dispatchInstance: removeDG)
        
        removeDG.notify(queue: DispatchQueue.main) {
            print("deleted \(incisionsId)")
            self.getAllIncisions()
        }
    }
    
    //procedures
    func getAllProcedures(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getProcedures(aview: patientProcedureView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            self.showIncisions()
        }
    }
    func insertProcedure(thisProcedure:[String:Any]){
        let insertDG = DispatchGroup()
        insertDG.enter()
        INSERT().newProcedure(aview: patientProcedureView, parameters: thisProcedure, dispachInstance: insertDG)
        
        insertDG.notify(queue: DispatchQueue.main) {
            print("insert new procedure success")
            self.getAllProcedures()
        }
    }
    func updateProcedure(thisProcedure:[String:Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().Procedure(aview: patientProcedureView, parameters: thisProcedure, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update procedure success")
            self.getAllProcedures()
        }
    }
    func deleteProcedures(proceduresId: Int){
        
    }
}
extension PatientProcedureVC{
    //
    // #MARK: - Save Incision
    //
    func updateIncisionObject(){
        let pid = returnSelectedPatientID()
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? [] //might be slow
        let cpid = returnCloudPatientIDFor(dictArray: patientRecords, patientID: pid)
        newIncision =
            [
                "patientID":cpid,
                "patientName":pid,
                "initials":initialsTF.text!,
                "date":incisionDate.text!
            ]
    }
    
    func saveIncisionObject(){
        updateIncisionObject()
        insertIncisions(thisIncision:newIncision)
    }
}
extension PatientProcedureVC{
    //
    // #MARK: - Save Procedure
    //
    func updateProcedureObject(){
        let pid = returnSelectedPatientID()
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? [] //might be slow
        let cpid = returnCloudPatientIDFor(dictArray: patientRecords, patientID: pid)
        newProcedure =
        [
            "patientID":cpid,
            "patientName":pid,
            "bloodWork":String(toggleBloodWork),
            "surgeryDate":surgeryDate.text!,
            "suture":sutureTF.text!,
            "radiographs":radiographTF.text!,
            "lab":labTF.text!
        ]
    }
    func saveProcedureObject(){
        updateProcedureObject()
        procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
        var found = false
        if procedures.isEmpty {//CREATE NEW
            insertProcedure(thisProcedure: newProcedure)
            //UserDefaults.standard.set([newProcedure], forKey: "procedures")
            //UserDefaults.standard.synchronize()
        }
        else {
            for index in 0..<procedures.count {
                if procedures[index]["patientID"] == newProcedure["patientName"] {//UPDATE by PID
                    found = true
                    if let proceduresId = procedures[index]["proceduresId"] as String?{
                        newProcedure["proceduresId"] = proceduresId
                        found = true
                        print("UPDATE procedure \(newProcedure)")
                        updateProcedure(thisProcedure: newProcedure)
                        return
                    }
                    //for item in newProcedure {
                    //    procedures[index][item.key] = item.value
                    //}
                    //UserDefaults.standard.set(procedures, forKey: "procedures")
                    //UserDefaults.standard.synchronize()
                    
                }
            }
            if found == false {//APPEND NEW
                insertProcedure(thisProcedure: newProcedure)
                //procedures.append(newProcedure)
                //UserDefaults.standard.set(procedures, forKey: "procedures")
                //UserDefaults.standard.synchronize()
            }
        }
    }
}
extension PatientProcedureVC {
    // #MARK: - Setup Text Field Delegates
    func textFieldsDelegates(){
        sutureTF.delegate = self
        sutureTF.returnKeyType = UIReturnKeyType.next
        sutureTF.tag = 0
        radiographTF.delegate = self
        radiographTF.returnKeyType = UIReturnKeyType.next
        radiographTF.tag = 1
        labTF.delegate = self
        labTF.returnKeyType = UIReturnKeyType.go
        labTF.tag = 2
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag >= 0 && textField.tag <= 2{
            aMPMTopConstraint.constant = -350
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= 0 && textField.tag <= 2{
            saveProcedureObject()
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            return true;
        }
        return false
    }
}
extension PatientProcedureVC {
    // #MARK: - Show Procedure and Incisions
    @objc func showProcedure(){
        showIncisions()
        
        let pid = returnSelectedPatientID()
        var procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
        var found = false
        if procedures.isEmpty {
            return
        } else {
            for index in 0..<procedures.count {
                if procedures[index]["patientID"] == pid {//UPDATE UI by PID
                    if (procedures[index]["bloodWork"]! == "false") {
                        bloodWorkButton.setImage(UIImage.init(named: "box"), for: .normal)
                        toggleBloodWork = false
                    } else {
                        bloodWorkButton.setImage(UIImage.init(named: "boxCheck"), for: .normal)
                        toggleBloodWork = true }
                    surgeryDate.text = procedures[index]["surgeryDate"]!
                    sutureTF.text = procedures[index]["suture"]!
                    radiographTF.text = procedures[index]["radiographs"]!
                    labTF.text = procedures[index]["lab"]!
                    found = true
                    //print("showPhysicalExam found by PID")
                }
            }
        }
        if found == false {
            //print("NOT found by PID")
            bloodWorkButton.setImage(UIImage.init(named: "box"), for: .normal)
            toggleBloodWork = false
            surgeryDate.text = ""
            sutureTF.text = ""
            radiographTF.text = ""
            labTF.text = ""
        }
    }
    func showIncisions(){
        //incisionLastChecked
        let pid = returnSelectedPatientID()
        let incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
        var scopePredicate:NSPredicate
        
        scopePredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", pid)
        let arr=(incisions as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            filteredIncisions=arr as! Array<Dictionary<String,String>>
        } else {
            filteredIncisions=[clear]
        }
        //let sorted = filteredIncisions.sorted { $0["date"]! < $1["date"]! }//sort array in place
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
//        let sortedArray = filteredIncisions.sorted{[dateFormatter] one, two in
//            return dateFormatter.date(from: one["date"]! )! > dateFormatter.date(from: two["date"]! )! }
        
        //BUG 1
        filteredIncisions = sortArrayDictDesc(dict: filteredIncisions, dateFormat: "MM/dd/yy hh:mm a")
        
        if let firstDate = filteredIncisions.first{
            if firstDate["date"]?.isEmpty == false {//} != ""{
                incisionLastChecked.text = firstDate["date"]
            } else {
                incisionLastChecked.text = "not yet"
            }
        }
        incisionTable.reloadData()
    }
}

