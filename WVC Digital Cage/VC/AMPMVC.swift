//
//  AMPMVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/3/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class AMPMVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {

    //class view
    @IBOutlet var ampmView: UIView!
    //slider
    @IBOutlet weak var appetiteSlider: UISlider!
    //label
    @IBOutlet weak var dateNow: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    //text fields TF
    @IBOutlet weak var attitudeTF: UITextField!
    @IBOutlet weak var fecesTF: UITextField!
    @IBOutlet weak var urineTF: UITextField!
    @IBOutlet weak var appetiteTF: UITextField!
    @IBOutlet weak var vdcsTF: UITextField!
    @IBOutlet weak var initialsTF: UITextField!
    //table
    @IBOutlet weak var ampmTable: UITableView!
    //switch
    @IBOutlet weak var ampmSwitch: UISwitch!
    //segments
    @IBOutlet weak var fecesSegment: UISegmentedControl!
    @IBOutlet weak var urineSegment: UISegmentedControl!
    //buttons
    @IBOutlet weak var vButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var sButton: UIButton!
    
    //constraints
    @IBOutlet weak var AMPMTextFieldsViewBottomLayoutConstraint: NSLayoutConstraint!//not used
    @IBOutlet weak var AMPMTextFieldsViewTopLayoutConstraint: NSLayoutConstraint!
    
    var myAmpms = Array<Dictionary<String,String>>()
    var filteredAMPM = Array<Dictionary<String,String>>()
    //var selectedAmpmFromTable = ""
    
    var newAMPM:Dictionary<String,String> =
        [
            "patientID":"",
            "filterID":"",
            "date":"",
            "attitude":"",
            "feces":"",
            "urine":"",
            "appetite":"",
            "vDCS":"",
            "initials":""
        ]
    let clear:Dictionary<String,String> =
    [
    "patientID":"",
    "filterID":"",
    "date":"",
    "attitude":"",
    "feces":"",
    "urine":"",
    "appetite":"",
    "vDCS":"",
    "initials":""
    ]
    var toggleV = false
    var toggleD = false
    var toggleC = false
    var toggleS = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegation
        ampmTable.delegate = self
        ampmTable.dataSource = self
        setupUI()
        textFieldsDelegates()
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(showAmpm),
                                               name: NSNotification.Name(rawValue: "showAmpm"),
                                               object: nil)
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardWillShowAMPM),
                           name: .UIKeyboardWillShow,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(keyboardWillHideAMPM),
                           name: .UIKeyboardWillHide,
                           object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        //myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        showAmpm()
    }
    //
    // Button Actions
    //
    @IBAction func updateNowAction(_ sender: Any) {
        saveAMPMObject()
        //myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        showAmpm()
        ampmTable.reloadData()
        updateMissingAMPMRecords()
        //REFRESH PATIENTS TABLE VIEW
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshPatientsTable"), object: nil)
        //TOGGLE AMPM VIEW
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveAMPMDown"), object: nil)
        //close keyboard
        view.endEditing(true)
        resetAMPM()
    }
    @IBAction func switchAction(_ sender: Any) {
        if ampmSwitch.isOn {
            emojiLabel.text = "🌞"
            let truncated = String(dateNow.text!.dropLast(2))
            dateNow.text = truncated + "PM"
        } else { //AM
            emojiLabel.text = "☾"
            let truncated = String(dateNow.text!.dropLast(2))
            dateNow.text = truncated + "AM"
        }
    }
    @IBAction func changeDateAction(_ sender: Any) {
        changeDateTime(dateLabel: dateNow, title: "AM/PM Date")
    }
    @IBAction func changeAppetiteAction(_ sender: UISlider) {
        let roundedNearestHalf = round(sender.value)//*2)/2 //0, 0.5,...
        let currentValue = String(roundedNearestHalf)
        appetiteTF.text = "\(currentValue)"
    }
    @IBAction func fecesSegmentAction(_ sender: Any) {
        updateFecesORUrineTFGiven(index: fecesSegment.selectedSegmentIndex, textField: fecesTF)
    }
    @IBAction func urineSegmentAction(_ sender: Any) {
        updateFecesORUrineTFGiven(index: urineSegment.selectedSegmentIndex, textField: urineTF)
    }
    //VDCS Button Actions
    @IBAction func vButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleV, value: "V")
        toggleCheckBox(isChecked: &toggleV, checkButton: vButton)
    }
    @IBAction func dButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleD, value: "D")
        toggleCheckBox(isChecked: &toggleD, checkButton: dButton)
    }
    @IBAction func cButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleC, value: "C")
        toggleCheckBox(isChecked: &toggleC, checkButton: cButton)
    }
    @IBAction func sButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleS, value: "S")
        toggleCheckBox(isChecked: &toggleS, checkButton: sButton)
    }
    
    func updateFecesORUrineTFGiven(index: Int, textField: UITextField){
        switch index
        {
        case 0://NA
            textField.text = ""
        case 1://+
            textField.text = "+"
        case 2://-
            textField.text = "-"
        default:
            break;
        }
    }
    
}
extension AMPMVC {
    //
    // #MARK: - VDCS buttons
    //
    func updateTextField(isChecked: Bool, value: String){
        let textFieldString = vdcsTF.text
        let slashValue = "/" + value
        
        if isChecked == false {//add Value
            if textFieldString == "" || textFieldString == "na" {
                vdcsTF.text = value
            } else {
                vdcsTF.text = textFieldString! + slashValue
            }
        } else if isChecked {//remove Value
            let replacedValue = textFieldString?.replacingOccurrences(of: slashValue, with: "")
            var replacedSlashValue = replacedValue?.replacingOccurrences(of: value, with: "")
            let fistCharIndex = replacedSlashValue?.index((replacedSlashValue?.startIndex)!, offsetBy: 0)
            if replacedSlashValue?.isEmpty == false {
                if replacedSlashValue![fistCharIndex!] == "/"{
                    let noFirstSlash = replacedSlashValue?.dropFirst()
                    replacedSlashValue = String(describing: noFirstSlash!)
                }
            }
            if textFieldString == "" || replacedSlashValue! == ""{
                vdcsTF.text = "na"//does nothing
            } else { vdcsTF.text = replacedSlashValue! }
        }
    }
    func resetAMPM(){
        fecesSegment.selectedSegmentIndex = 0//UISegmentedControlNoSegment
        urineSegment.selectedSegmentIndex = 0//UISegmentedControlNoSegment
        vButton.setImage(UIImage(named: "box"), for: .normal)
        dButton.setImage(UIImage(named: "box"), for: .normal)
        cButton.setImage(UIImage(named: "box"), for: .normal)
        sButton.setImage(UIImage(named: "box"), for: .normal)
        toggleV = false; toggleD = false; toggleC = false; toggleS = false
    }
}
extension AMPMVC {
    // #MARK: - When Keyboard hides DO: Move text view up
    @objc func keyboardWillShowAMPM(sender: NSNotification){
        //AMPMTextFieldsViewTopLayoutConstraint.constant = -300
        //TOGGLE AMPM VIEW
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveAMPMUp"), object: nil)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }// #MARK: - When Keyboard shws DO: Move text view down
    @objc func keyboardWillHideAMPM(sender: NSNotification){
        AMPMTextFieldsViewTopLayoutConstraint.constant = 0
        //TOGGLE AMPM VIEW
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveAMPMDown"), object: nil)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
extension AMPMVC {
    // #MARK: - Setup UI
    func textFieldsDelegates(){
        attitudeTF.delegate = self
        attitudeTF.returnKeyType = UIReturnKeyType.next
        attitudeTF.tag = 0
        fecesTF.delegate = self
        fecesTF.returnKeyType = UIReturnKeyType.next
        fecesTF.tag = 1
        urineTF.delegate = self
        urineTF.returnKeyType = UIReturnKeyType.next
        urineTF.tag = 2
        appetiteTF.delegate = self
        appetiteTF.returnKeyType = UIReturnKeyType.next
        appetiteTF.tag = 3
        vdcsTF.delegate = self
        vdcsTF.returnKeyType = UIReturnKeyType.next
        vdcsTF.tag = 4
        initialsTF.delegate = self
        initialsTF.returnKeyType = UIReturnKeyType.go
        initialsTF.tag = 5
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag >= 0 && textField.tag <= 6{
            //AMPMTextFieldsViewTopLayoutConstraint.constant = -300
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
    func setupUI(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy  a"
        let nowString = formatter.string(from: Date()) // "1/27/10, 1:00 PM"
        dateNow.text = nowString
        emojiLabel.text = returnEmojiFrom(dateString: nowString)
        //Move switch state based on date
        var isTrue = "false"
        let last2 = nowString.suffix(2)
        if last2 == "PM" { isTrue = "true"}
        moveSwitchState(switchName: ampmSwitch, isTrue: isTrue)
        fecesSegment.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)], for: .normal)
        urineSegment.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)], for: .normal)
    }
    func returnEmojiFrom(dateString: String) -> String{
        let last2 = dateString.suffix(2)//Swift 4
        //print("last2 \(last2)")
        if last2 == "PM" {     // U+263E - moon, sun U+263C sun face U+1F31E
            return "🌞"
        } else if last2 == "AM" {
            return "☾"
        } else {
            return ""
        }
    }
    func moveSwitchState(switchName: UISwitch, isTrue:String){
        if isTrue == "true" {
            switchName.setOn(true, animated: false)
        } else {
            switchName.setOn(false, animated: false)
        }
    }
    @objc func showAmpm(){
        //filter myAmpms
        self.myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        let pid = returnSelectedPatientID()
        var scopePredicate:NSPredicate
        
        scopePredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", pid)
        let arr=(myAmpms as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            filteredAMPM=arr as! Array<Dictionary<String,String>>
        } else {
            filteredAMPM=[clear]
        }
        //filteredAMPM.sort { $0["date"]! > $1["date"]! }//sort array in place
        
        
        //BUG 1
        filteredAMPM = sortArrayDictDesc(dict: filteredAMPM, dateFormat: "MM/dd/yy a")
        
        ampmTable.reloadData()
        
        //clear Text Fields
        attitudeTF.text = "bar"
        fecesTF.text = ""
        urineTF.text = ""
        appetiteTF.text = ""
        vdcsTF.text = "na"
        initialsTF.text = ""
        setupUI()
        resetAMPM()
    }
}
extension AMPMVC {
    //
    // #MARK: - Table View
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAMPM.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: AMPMTableView = tableView.dequeueReusableCell(withIdentifier: "ampmCell") as! AMPMTableView
        let this = filteredAMPM[IndexPath.row]
        let isAnyAMPMBlank = Bool(
                this["attitude"] == "" || this["feces"] == "" ||
                this["urine"] == "" || this["appetite"] == "" ||
                this["vDCS"] == "" || this["initials"] == ""
        )
        
        if this["date"] != "" && isAnyAMPMBlank{
            cell.backgroundColor = UIColor.WVCActionBlue()
        } else { cell.backgroundColor = UIColor.white }
        
            cell.date.text = this["date"]
            cell.attitude.text = this["attitude"]
            cell.feces.text = this["feces"]
            cell.urine.text = this["urine"]
            cell.appetite.text = this["appetite"]
            cell.VDCS.text = this["vDCS"]
            cell.initials.text = this["initials"]
            cell.ampmEmoji.text = returnEmojiFrom(dateString: this["date"]!)
        
        return cell
    }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            var selectedData:Dictionary<String,String> = filteredAMPM[indexPath.row]
            dateNow.text! = selectedData["date"]!
            attitudeTF.text! = selectedData["attitude"]!
            fecesTF.text! = selectedData["feces"]!
            urineTF.text! = selectedData["urine"]!
            appetiteTF.text! = selectedData["appetite"]!
            vdcsTF.text! = selectedData["vDCS"]!
            initialsTF.text! = selectedData["initials"]!
            //Move switch state based on date
            var isTrue = "false"
            let last2 = selectedData["date"]!.suffix(2)
            if last2 == "PM" {
                isTrue = "true"
                emojiLabel.text = "🌞"
            } else { emojiLabel.text = "☾" }
            moveSwitchState(switchName: ampmSwitch, isTrue: isTrue)
            let FSV = Float(selectedData["appetite"]!) ?? 0.0
            appetiteSlider.value = FSV
            //selectedAmpmFromTable = selectedData["ampmsId"]!
        }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("Delete button tapped")
            self.deleteButtonTapped(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    func deleteButtonTapped(indexPath: IndexPath){
        let selectedDict = filteredAMPM[indexPath.row]
        let selectedAmpm = selectedDict["ampmsId"]!
        
        deleteAmpm(thisProcedure:["ampmsId":selectedAmpm])
//        if let index = dictIndexFrom(array: myAmpms, usingKey:"filterID", usingValue: selectedFilterID!) {
//                 myAmpms.remove(at: index)
//         }
//
//        //self.myAmpms.remove(at: indexPath.row)//not correct indexPath.rom is for filteredAMPM displayed NEED ID
//        UserDefaults.standard.set(self.myAmpms, forKey: "ampms")
//        UserDefaults.standard.synchronize()
//        //----------------filter it
//        let pid = returnSelectedPatientID()
//        var scopePredicate:NSPredicate
//
//        scopePredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", pid)
//        let arr=(myAmpms as NSArray).filtered(using: scopePredicate)
//        if arr.count > 0
//        {
//            filteredAMPM=arr as! Array<Dictionary<String,String>>
//        } else {
//            filteredAMPM=[clear]
//        }
//        //filteredAMPM.sort { $0["date"]! > $1["date"]! }//sort array in place
//
//
//        //BUG 1
//        filteredAMPM = sortArrayDictDesc(dict: filteredAMPM, dateFormat: "MM/dd/yy a")
//
//        ampmTable.reloadData()
        //self.ampmTable.deleteRows(at: [indexPath], with: .fade)
    }

}
extension AMPMVC {
    //
    // #MARK: - Save AMPM
    //
    func updateAMPMObject(){
        let pid = returnSelectedPatientID()
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? [] //might be slow
        let cpid = returnCloudPatientIDFor(dictArray: patientRecords, patientID: pid)
        var filterID = "0"
        if myAmpms.isEmpty == false {
            let lastFilerID = myAmpms.last!["filterID"]!
            filterID = String(Int(lastFilerID)! + 1)
        }
        newAMPM =
        [
        "patientID":cpid,
        "patientName":pid,
        "attitude":attitudeTF.text!,
        "filterID":filterID,
        "initials":initialsTF.text!,
        "vDCS":vdcsTF.text!,
        "date":dateNow.text!,
        "urine":urineTF.text!,
        "feces":fecesTF.text!,
        "appetite":appetiteTF.text!
        //"appetite%":appetiteTF.text!
        //"v/D/C/S":vdcsTF.text!
        
        ]
    }
    func saveAMPMObject(){
        updateAMPMObject()
        var found = false
        if myAmpms.isEmpty {//CREATE NEW
            insertAmpm(thisProcedure: newAMPM)
            print("myAmpms is Empty insert new ampm \(newAMPM)")
            return
//            UserDefaults.standard.set([newAMPM], forKey: "ampms")
//            UserDefaults.standard.synchronize()
//            print("create new ampm")
        }
        else {
            for index in 0..<myAmpms.count{
                if /*myAmpms[index]["ampmsId"] == selectedAmpmFromTable*/myAmpms[index]["date"] == newAMPM["date"] && myAmpms[index]["patientID"] == newAMPM["patientName"] {
                    //UPDATE
                    if let ampmsId = myAmpms[index]["ampmsId"] {
                        newAMPM["ampmsId"] = ampmsId
                        found = true
                        print("UPDATE ampm newAMPM:\(newAMPM)")
                        print("UPDATE ampm myAmpms:\(myAmpms[index])")
                        updateAmpm(thisProcedure: newAMPM)
                        return
                    }
                }
            }
        }
            if found == false {//APPEND NEW
                insertAmpm(thisProcedure: newAMPM)
                print("insert ampm \(newAMPM)")
            }
    }
    func updateMissingAMPMRecords(){
        myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        var missingPatientIDs = Set<String>()
        for things in myAmpms {
            if (things.map{$0.value}).contains("") { missingPatientIDs.insert(things["patientID"]!) }
        }
        let arrayFromSet = Array(missingPatientIDs)
        UserDefaults.standard.set(arrayFromSet, forKey: "missingPatientIDs")
        UserDefaults.standard.synchronize()
        print("missingPatientIDs \(missingPatientIDs.count):\n\(missingPatientIDs)")
    }
}
extension AMPMVC {
    //
    // #MARK: - Date Picker Alert
    //
    func changeDateTime(dateLabel: UILabel, title: String){
        DatePickerDialog().show(title, doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .dateAndTime) {
            (date) -> Void in
            if date != nil {
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MM/dd/yy a"
                let strDate = dateFormat.string(for: date!)!
                dateLabel.text = strDate
                self.emojiLabel.text = self.returnEmojiFrom(dateString: strDate)
            }
        }
    }
}

extension AMPMVC {
    //
    //  #MARK: - API
    //
    func getAllAmpms(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getAmpms(aview: ampmView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            //self.myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
            self.showAmpm()
        }
    }
    func insertAmpm(thisProcedure:[String:Any]){
        let insertDG = DispatchGroup()
        insertDG.enter()
        INSERT().newAmpm(aview: ampmView, parameters: thisProcedure, dispachInstance: insertDG)
        
        insertDG.notify(queue: DispatchQueue.main) {
            print("insert new ampm success")
            self.getAllAmpms()
        }
    }
    func updateAmpm(thisProcedure:[String:Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().Ampm(aview: ampmView, parameters: thisProcedure, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update ampm success")
            self.getAllAmpms()
        }
    }
    func deleteAmpm(thisProcedure:[String:Any]){
        let deleteDG = DispatchGroup()
        deleteDG.enter()
        DeleteInstantShare().Ampm(aview: ampmView, parameters: thisProcedure, dispatchInstance: deleteDG)
        deleteDG.notify(queue: DispatchQueue.main) {
            print("delete ampm success")
            self.getAllAmpms()
        }
    }
}
