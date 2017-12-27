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
    @IBOutlet weak var monitoredList: UITextField!
    
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
    //@IBOutlet weak var initialButton: UIButton!
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
    var newTxVital = [String:String]()
    var groupNumber = 0
    
    //segue vars
    var seguePatientID: String!
    var segueShelterName: String!
    var seguePatientSex: String!
    var seguePatientAge: String!
    var seguePatientBreed: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        groupNumber = getLastGroupNumber()
        if collectionTxVitals.isEmpty {
            groupNumber = 1
        } else {
            groupNumber = groupNumber + 1
        }
    }
    //
    // #MARK: - Actions
    //
    @IBAction func saveAction(_ sender: Any) {
        let isDataMissing = checkForMissingData()
        if isDataMissing == false{
            saveTreatmentVitalsLocally()
            self.performSegue(withIdentifier: "segueaddTxVitalToTxVC", sender: self)
        }
    }
    @IBAction func closeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueaddTxVitalToTxVC", sender: self)
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
        updateTextField(isChecked: tToggle, value: "T", slashString: ",", outputTextField: monitoredList)
        toggleCheckBox(isChecked: &tToggle, checkButton: tempButton)
    }
    @IBAction func hrButtonAction(_ sender: Any) {
        updateTextField(isChecked: hrToggle, value: "H", slashString: ",", outputTextField: monitoredList)
        toggleCheckBox(isChecked: &hrToggle, checkButton: hrButton)
    }
    @IBAction func respButtonAction(_ sender: Any) {
        updateTextField(isChecked: respToggle, value: "R", slashString: ",", outputTextField: monitoredList)
        toggleCheckBox(isChecked: &respToggle, checkButton: respButton)
    }
    @IBAction func mmCrtButtonAction(_ sender: Any) {
        updateTextField(isChecked: mmCrtToggle, value: "M", slashString: ",", outputTextField: monitoredList)
        toggleCheckBox(isChecked: &mmCrtToggle, checkButton: mmCrtButton)
    }
    @IBAction func dietButtonAction(_ sender: Any) {
        updateTextField(isChecked: dietToggle, value: "D", slashString: ",", outputTextField: monitoredList)
        toggleCheckBox(isChecked: &dietToggle, checkButton: dietButton)
    }
    @IBAction func csvdButtonAction(_ sender: Any) {
        updateTextField(isChecked: csvdToggle, value: "C", slashString: ",", outputTextField: monitoredList)
        toggleCheckBox(isChecked: &csvdToggle, checkButton: csvdButton)
    }
    @IBAction func wtButtonAction(_ sender: Any) {
        updateTextField(isChecked: wtToggle, value: "W", slashString: ",", outputTextField: monitoredList)
        toggleCheckBox(isChecked: &wtToggle, checkButton: wtButton)
    }
//    @IBAction func initalButtonAction(_ sender: Any) {
//        updateTextField(isChecked: initialToggle, value: "I", slashString: ",", outputTextField: monitoredList)
//        toggleCheckBox(isChecked: &initialToggle, checkButton: initialButton)
//    }
    //VDCS toggle box Button Actions
    @IBAction func vButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleV, value: "V", slashString: "/", outputTextField: vdcsTF)
        toggleCheckBox(isChecked: &toggleV, checkButton: vButton)
    }
    @IBAction func dButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleD, value: "D", slashString: "/", outputTextField: vdcsTF)
        toggleCheckBox(isChecked: &toggleD, checkButton: dButton)
    }
    @IBAction func cButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleC, value: "C", slashString: "/", outputTextField: vdcsTF)
        toggleCheckBox(isChecked: &toggleC, checkButton: cButton)
    }
    @IBAction func sButtonAction(_ sender: Any) {
        updateTextField(isChecked: toggleS, value: "S", slashString: "/", outputTextField: vdcsTF)
        toggleCheckBox(isChecked: &toggleS, checkButton: sButton)
    }
}
extension addTxVital {
    // #MARK: - UI
    func setupUI(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy a"
        let nowString = formatter.string(from: Date())
        dateLabel.text = nowString
    }
}
extension addTxVital {
    //
    // #MARK: - VDCS buttons
    //
    func updateTextField(isChecked: Bool, value: String, slashString: String, outputTextField: UITextField){
        let textFieldString = outputTextField.text
        let slashValue = slashString + value
        if isChecked == false {//add Value
            if textFieldString == "" {
                outputTextField.text = value
            } else { outputTextField.text = textFieldString! + slashValue }
        } else if isChecked {//remove Value
            let replacedValue = textFieldString?.replacingOccurrences(of: slashValue, with: "")
            var replacedSlashValue = replacedValue?.replacingOccurrences(of: value, with: "")
            let fistCharIndex = replacedSlashValue?.index((replacedSlashValue?.startIndex)!, offsetBy: 0)
            if replacedSlashValue?.isEmpty == false {
                if replacedSlashValue![fistCharIndex!] == Character(slashString){
                    let noFirstSlash = replacedSlashValue?.dropFirst()
                    replacedSlashValue = String(describing: noFirstSlash!)
                }
            }
            if textFieldString == "" {
                outputTextField.text = ""
            } else { outputTextField.text = replacedSlashValue! }
        }
    }
    func checkForMissingData() -> Bool{
        var isDataMissing = false
        var newPatientData = [String]()
        newPatientData.append(monitorFrequency.text!)
        newPatientData.append(monitorDays.text!)
        newPatientData.append(initialsTF.text!)
        for index in 0..<newPatientData.count{
            if newPatientData[index].isEmpty {
                isDataMissing = true
                let p = patientDataConversion(indexV:index)
                var preposition = "is"
                if index == 2 { preposition = "are"}
                simpleAlert(title: p + " "+preposition+" missing", message: "Enter this before saving.", buttonTitle: "OK")
            }
        }
        return isDataMissing
    }
    func patientDataConversion(indexV:Int) -> String{
        switch indexV {
        case 0:
            return "2X Daily / Daily"
        case 1:
            return "Number of days"
        case 2:
            return "Your Initials"
        default:
            return "Monitored Vitals Field"
        }
    }
}
extension addTxVital {
    //
    // #MARK: - Saving Locally
    //
    func getLastGroupNumber() -> Int{
        var maxGroupNumber = 1
        for vital in collectionTxVitals{
            if vital["patientID"] == seguePatientID {
            if Int(vital["group"]!)! > maxGroupNumber {
                maxGroupNumber = Int(vital["group"]!)!
            }
            }
        }
        return maxGroupNumber
    }
    func updateTV(){
        // Date now
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy a"
        let nowString = formatter.string(from: Date())
        newTxVital = [
            "patientID":seguePatientID,
            "date":nowString,
            "temperature":temperatureTF.text!,
            "heartRate":hearRateTF.text!,
            "respirations":respirationsTF.text!,
            "mm/Crt":mmCrtTF.text!,
            "diet":dietTF.text!,
            "v/D/C/S":vdcsTF.text!,
            "weightKgs":weightTF.text!,
            "initials":initialsTF.text!,
            "monitorFrequency":monitorFrequency.text!,//daily or 2x daily
            "monitorDays":monitorDays.text!,
            "monitored":monitoredList.text!,//T,H,R,M, D,C,W,I
            "group":String(groupNumber),//"1",//check and auto increment
            "checkComplete":"true"
        ]
    }
    func emptyTV(date: String){
        newTxVital = [
            "patientID":seguePatientID,
            "date":date,
            "temperature":"",
            "heartRate":"",
            "respirations":"",
            "mm/Crt":"",
            "diet":"",
            "v/D/C/S":"",
            "weightKgs":"",
            "initials":"",
            "monitorFrequency":monitorFrequency.text!,
            "monitorDays":monitorDays.text!,
            "monitored":monitoredList.text!,//T,H,R,M, D,C,W,I
            "group":String(groupNumber),//"1",//check and auto increment
            "checkComplete":"false"
        ]
    }
    func monitorTreatmentsFor(numberOfDays: Int, isTwiceDaily: String){
        var loopCount = numberOfDays
        var hours = 24
        if isTwiceDaily == "2x daily" {
            loopCount = numberOfDays * 2
            hours = 12
        }
        //var daysToAdd = 0
        var hoursToAdd = 0
        var dateComponent = DateComponents()
        let currentDate = Date()
        //if 2x selected 1) numberOfDays*2 2) hoursToAdd = 12 not 24
        loopCount.times {//LOOP # DAYS
            //daysToAdd = daysToAdd + 1
            //dateComponent.day = daysToAdd
            //
            hoursToAdd = hoursToAdd + hours
            dateComponent.hour = hoursToAdd
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy a"
            let nowString = formatter.string(from: futureDate!)
            emptyTV(date: nowString)
            collectionTxVitals.append(newTxVital)
        }
    }
    func saveTreatmentVitalsLocally(){
        updateTV()
        //if collectionTxVitals.isEmpty == false {
            collectionTxVitals.append(newTxVital)//Initial Vitals
            UserDefaults.standard.set(collectionTxVitals, forKey: "collectionTxVitals")
            UserDefaults.standard.synchronize()
        monitorTreatmentsFor(numberOfDays: Int(monitorDays.text!)!, isTwiceDaily: monitorFrequency.text!)
            UserDefaults.standard.set(collectionTxVitals, forKey: "collectionTxVitals")
            UserDefaults.standard.synchronize()
//        } else {
//            UserDefaults.standard.set([newTxVital], forKey: "collectionTxVitals")
//            UserDefaults.standard.synchronize()
//            monitorTreatmentsFor(numberOfDays: Int(monitorDays.text!)!)
//            UserDefaults.standard.set(collectionTxVitals, forKey: "collectionTxVitals")
//            UserDefaults.standard.synchronize()
//        }
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
                toVC.seguePatientSex = seguePatientSex
                toVC.seguePatientAge = seguePatientAge
                toVC.seguePatientBreed = seguePatientBreed
            }
        }
    }
}
