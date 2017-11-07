//
//  AMPMVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/3/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class AMPMVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {

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
    
    @IBOutlet weak var AMPMTextFieldsViewBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var AMPMTextFieldsViewTopLayoutConstraint: NSLayoutConstraint!
    
    var myAmpms = Array<Dictionary<String,String>>()
    var filteredAMPM = Array<Dictionary<String,String>>()
    
    var newAMPM:Dictionary<String,String> =
        [
            "patientID":"",
            "filterID":"",
            "date":"",
            "attitude":"",
            "feces":"",
            "urine":"",
            "appetite%":"",
            "V/D/C/S":"",
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
    "appetite%":"",
    "V/D/C/S":"",
    "initials":""
    ]
    
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
        myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        //filteredAMPM = myAmpms
        showAmpm()
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
    //Button Action
    @IBAction func updateNowAction(_ sender: Any) {
        saveAMPMObject()
        myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        showAmpm()
        ampmTable.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideUpdateRecordView"), object: nil)
    }
    @IBAction func switchAction(_ sender: Any) {
        if ampmSwitch.isOn {
            emojiLabel.text = "🌞"
            let truncated = String(dateNow.text!.characters.dropLast(2))
            dateNow.text = truncated + "PM"
        } else { //AM
            emojiLabel.text = "☾"
            let truncated = String(dateNow.text!.characters.dropLast(2))
            dateNow.text = truncated + "AM"
        }
    }
}
extension AMPMVC {
    // #MARK: - When Keyboard hides DO: Move text view up
    @objc func keyboardWillShowAMPM(sender: NSNotification){
        AMPMTextFieldsViewTopLayoutConstraint.constant = -300
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }// #MARK: - When Keyboard shws DO: Move text view down
    @objc func keyboardWillHideAMPM(sender: NSNotification){
        AMPMTextFieldsViewTopLayoutConstraint.constant = 0
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
        ampmTable.reloadData()
        
        //clear Test Fields
        attitudeTF.text = ""
        fecesTF.text = ""
        urineTF.text = ""
        appetiteTF.text = ""
        vdcsTF.text = ""
        initialsTF.text = ""
    }
}
extension AMPMVC {
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAMPM.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: AMPMTableView = tableView.dequeueReusableCell(withIdentifier: "ampmCell") as! AMPMTableView
        let this = filteredAMPM[IndexPath.row]
            cell.date.text = this["date"]
            cell.attitude.text = this["attitude"]
            cell.feces.text = this["feces"]
            cell.urine.text = this["urine"]
            cell.appetite.text = this["appetite%"]
            cell.VDCS.text = this["V/D/C/S"]
            cell.initials.text = this["initials"]
            cell.ampmEmoji.text = returnEmojiFrom(dateString: this["date"]!)
        
        return cell
    }
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    }
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
        let selectedFilterID = selectedDict["filterID"]
        
        if let index = dictIndexFrom(array: myAmpms, usingKey:"filterID", usingValue: selectedFilterID!) {
                 myAmpms.remove(at: index)
         }
  
        //self.myAmpms.remove(at: indexPath.row)//not correct indexPath.rom is for filteredAMPM displayed NEED ID
        UserDefaults.standard.set(self.myAmpms, forKey: "ampms")
        UserDefaults.standard.synchronize()
        //----------------filter it
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
        ampmTable.reloadData()
        //self.ampmTable.deleteRows(at: [indexPath], with: .fade)
    }

}
extension AMPMVC {
// #MARK: - Save AMPM
    func updateAMPMObject(){
        let pid = returnSelectedPatientID()
        var filterID = "0"
        if myAmpms.isEmpty == false {
            let dict = myAmpms.last
            let lastFilerID = dict!["filterID"]!
            filterID = String(Int(lastFilerID)! + 1)
        }
        newAMPM =
        [
        "patientID":pid,
        "filterID":filterID,
        "date":dateNow.text!,
        "attitude":attitudeTF.text!,
        "feces":fecesTF.text!,
        "urine":urineTF.text!,
        "appetite%":appetiteTF.text!,
        "V/D/C/S":vdcsTF.text!,
        "initials":initialsTF.text!
        ]
    }
    func saveAMPMObject(){
        updateAMPMObject()
        if myAmpms.isEmpty {
            UserDefaults.standard.set([newAMPM], forKey: "ampms")
            UserDefaults.standard.synchronize()
        }
        else {
            //let dict = myAmpms.last
            //let lastFilerID = dict!["filterID"]!
            //let newFilerID = Int(lastFilerID)! + 1
            myAmpms.append(newAMPM)
            UserDefaults.standard.set(myAmpms, forKey: "ampms")
            UserDefaults.standard.synchronize()
        }
    }
}


