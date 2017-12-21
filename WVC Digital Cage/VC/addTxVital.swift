//
//  addTxVital.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/20/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class addTxVital: UIViewController {
    
    //text fields
    @IBOutlet weak var monitorDays: UITextField!
    @IBOutlet weak var monitorFrequency: UITextField!
    @IBOutlet weak var vdcsTF: UITextField!
    
    @IBOutlet weak var temperatureTF: UITextField!
    @IBOutlet weak var hearRateTF: UITextField!
    @IBOutlet weak var respirationsTF: UITextField!
    @IBOutlet weak var mmCrtTF: UITextField!
    
    @IBOutlet weak var dietTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var initialsTF: UITextField!
    
    //label
    @IBOutlet weak var dateLabel: UILabel!
    //buttons
    @IBOutlet weak var tempButton: UIButton!
    @IBOutlet weak var hrButton: UIButton!
    @IBOutlet weak var respButton: UIButton!
    @IBOutlet weak var mmCrtButton: UIButton!
    @IBOutlet weak var dietButton: UIButton!
    @IBOutlet weak var csvdButton: UIButton!
    @IBOutlet weak var wtButton: UIButton!
    @IBOutlet weak var initialButton: UIButton!
    //---VDCS buttons
    @IBOutlet weak var vButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var sButton: UIButton!
    //Monitor toggles
    var tToggle = false
    var hrToggle = false
    var respToggle = false
    var mmCrtToggle = false
    var dietToggle = false
    var csvdToggle = false
    var wtToggle = false
    var initialToggle = false
    //VDCS toggles
    var toggleV = false
    var toggleD = false
    var toggleC = false
    var toggleS = false
    
    var collectionTxVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
    var newTxVitalCollection = [
        "patientID":"",
        "photo":"",
        "note":"",
        "date":""
    ]
    //
    var seguePatientID: String!
    var segueShelterName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    //
    // #MARK: - Actions
    //
    @IBAction func saveAction(_ sender: Any) {
        checkForMissingData()
    }
    @IBAction func closeAction(_ sender: Any) {
        
    }
    @IBAction func mDaysSlider(_ sender: UISlider) {
        let currentValue = String(Int(sender.value))
        monitorDays.text = "\(currentValue)"
    }
    @IBAction func frequencyAction(_ sender: UISwitch) {
        if sender.isOn {
            monitorFrequency.text = "daily"
        } else {
            monitorFrequency.text = "2x daily"
        }
    }
    
    //toggle box
    @IBAction func tButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &tToggle, checkButton: tempButton)
    }
    @IBAction func hrButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &hrToggle, checkButton: hrButton)
    }
    @IBAction func respButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &respToggle, checkButton: respButton)
    }
    @IBAction func mmCrtButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &mmCrtToggle, checkButton: mmCrtButton)
    }
    @IBAction func dietButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &dietToggle, checkButton: dietButton)
    }
    @IBAction func csvdButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &csvdToggle, checkButton: csvdButton)
    }
    @IBAction func wtButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &wtToggle, checkButton: wtButton)
    }
    @IBAction func initalButtonAction(_ sender: Any) {
        toggleCheckBox(isChecked: &initialToggle, checkButton: initialButton)
    }
    //VDCS toggle box Button Actions
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
}
extension addTxVital {
    // #MARK: - UI
    func setupUI(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let nowString = formatter.string(from: Date())
        dateLabel.text = nowString
    }
}
extension addTxVital {
    //
    // #MARK: - VDCS buttons
    //
    func updateTextField(isChecked: Bool, value: String){
        let textFieldString = vdcsTF.text
        let slashValue = "/" + value
        if isChecked == false {//add Value
            if textFieldString == "" {
                vdcsTF.text = value
            } else { vdcsTF.text = textFieldString! + slashValue }
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
            if textFieldString == "" {
                vdcsTF.text = ""
            } else { vdcsTF.text = replacedSlashValue! }
        }
    }
    func checkForMissingData() {
        var newPatientData = [String]()
        newPatientData.append(monitorFrequency.text!)
        newPatientData.append(monitorDays.text!)
        for index in 0..<newPatientData.count{
            if newPatientData[index].isEmpty {
                let p = patientDataConversion(indexV:index)
                simpleAlert(title: p + " is missing", message: "enter value and try again before Saving.", buttonTitle: "OK")
            }
        }
    }
    func patientDataConversion(indexV:Int) -> String{
        switch indexV {
        case 0:
            return "2X Daily / Daily"
        case 1:
            return "Number of Days"
        default:
            return "Monitored Vitals Field"
        }
    }
}
extension addTxVital {
    //
    // #MARK: - Saving Locally
    //
    func updateInjuriesObject(name: String){
        // Date now
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let nowString = formatter.string(from: Date())
        newTxVitalCollection = [
            "patientID":seguePatientID,
            "date":nowString,
            "temperature":"noteTF.text!",
            "heartRate":"",
            "respirations":"",
            "mm/Crt":"",
            "diet":"",
            "v/D/C/S":"",
            "weightKgs":"",
            "initials":"",
            "monitorFrequency":"",
            "monitorDays":"",
            "monitored":""//temperature,heartRate,...initials
        ]
    }
}
extension addTxVital {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueaddTxVitalToTxVC" {
            if let toVC = segue.destination as? TxVC {//<-BACK
                toVC.seguePatientID = seguePatientID
                toVC.segueShelterName = segueShelterName
            }
        }
    }
}
