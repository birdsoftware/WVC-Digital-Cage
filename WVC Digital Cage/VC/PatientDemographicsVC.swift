//
//  PatientDemographicsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/24/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientDemographicsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {

    //pickers
    @IBOutlet weak var ownerPicker: UIPickerView!
    @IBOutlet weak var kennelPicker: UIPickerView!
    //text fields
    @IBOutlet weak var ownerTF: UITextField!
    @IBOutlet weak var kennelTF: UITextField!
    //label
    @IBOutlet weak var intakeDateLabel: UILabel!
    //constraints
    @IBOutlet weak var intakeDateViewTopConstraint: NSLayoutConstraint!
    
    //Demographics paramaters---------------
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var patientIDTF: UITextField!
    @IBOutlet weak var breedTF: UITextField!
    //switches
    @IBOutlet weak var switchSex: UISwitch!
    @IBOutlet weak var npo: UIButton!
    @IBOutlet weak var cation: UIButton!
    @IBOutlet weak var feed: UISegmentedControl!
    @IBOutlet weak var feedType: UISegmentedControl!
    //---------------
    var toggleNPO = false
    var toggleCation = false
    var newDemographics:Dictionary<String,String> =
        [
            "patientID":"",
            "age":"",
            "breed":"",
            "sex":""
        ]
    var kennelIntArray = ["S1","S2","S3","S4","S5","S6","S7","S8","S9","S10",
                              "D1","D2","D3","D4","D5","D6","D7","D8","D9","D10",
                              "D11","D12","D13","D14","D15","D16",
                              "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10",
                              "T11","T12","T13",
                              "I1","I2","I3","I4",
                              "Cage Banks", "Cat room"]
    var ownerList = ["The Animal Foundation (TAF)","Henderson Shelter (HS)","Desert Haven Animal Society (DHAS)",
                     "Home for Spot (HFS)","Riverside Shelter (RS)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        setupUI()
        textFieldsDelegates()
        //call func showPhysicalExam from PatientsVC.swift
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(showDemographics),
                                               name: NSNotification.Name(rawValue: "showDemographics"),
                                               object: nil)
    }
    @IBAction func sexSwitchAction(_ sender: Any) {
        saveDemographics()
    }
    @IBAction func npoAction(_ sender: Any) {
        toggleCheckBox(isChecked: &toggleNPO, checkButton: npo)
        saveBadgeToDefaults(); updateBadgeUI()
    }
    @IBAction func cationAction(_ sender: Any) {
        toggleCheckBox(isChecked: &toggleCation, checkButton: cation)
        saveBadgeToDefaults(); updateBadgeUI()
    }
    @IBAction func feedFrequencyAction(_ sender: Any) {
        saveBadgeToDefaults(); updateBadgeUI()
    }
    @IBAction func feedTypeAction(_ sender: Any) {
        saveBadgeToDefaults(); updateBadgeUI()
    }
//    func toggleCheckBox( isChecked: inout Bool, checkButton: UIButton){
//        if (isChecked) {
//            checkButton.setImage(UIImage.init(named: "box"), for: .normal)
//        } else {
//            checkButton.setImage(UIImage.init(named: "boxCheck"), for: .normal) }
//        isChecked = !isChecked
//    }
    func updateBadgeUI(){
        //REFRESH BADGE IN PATIENTS VIEW
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBadge"), object: nil)
    }
    func saveBadgeToDefaults(){
        //save badge to defaults
        let pid = returnSelectedPatientID()
        var feedHalf=false; var feedTwice=false;
        var feedWet=false; var feedDry=false;
        switch feed.selectedSegmentIndex {
            case 1:
                feedHalf=true
            case 2:
                feedTwice=true
            default:
                break;
        }
        switch feedType.selectedSegmentIndex {
            case 1:
                feedWet=true
            case 2:
                feedDry=true
            default:
                break;
        }
        var newBadge =
        [
            "patientID":pid,
            "isNpo":String(toggleNPO),
            "isHalf":String(feedHalf),
            "isTwice":String(feedTwice),
            "isWet":String(feedWet),
            "isDry":String(feedDry),
            "isCaution":String(toggleCation)
        ]
        var badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
        var found = false
        if badges.isEmpty {
            UserDefaults.standard.set([newBadge], forKey: "badges")
            UserDefaults.standard.synchronize()
        } else {
            for index in 0..<badges.count {
                if badges[index]["patientID"] == newBadge["patientID"]{
                    found = true
                    for item in newBadge {
                        badges[index][item.key] = item.value
                    }
                    UserDefaults.standard.set(badges, forKey: "badges")
                    UserDefaults.standard.synchronize()
                    return
                }
            }
            if found == false {//APPEND NEW
                badges.append(newBadge)
                UserDefaults.standard.set(badges, forKey: "badges")
                UserDefaults.standard.synchronize()
            }
        }
    }
}

extension PatientDemographicsVC{
    // #MARK: - Picker View
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // returns the number of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == kennelPicker {
            return kennelIntArray.count
        } else {
            return ownerList.count
        }
    }
    // returns data to display in care team picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        if pickerView == kennelPicker {
            return String(kennelIntArray[row])
        } else {
            return ownerList[row]
        }
    }
    // picker value selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == kennelPicker {
            //kennelTF.text = String(kennelIntArray[row])
            //flashGreenTextField(textField: kennelTF, displayText: String(kennelIntArray[row]))
            askToChange(selectedStringToChange: String(kennelIntArray[row]), textField: kennelTF, whatIsChanging: "Kennel#", dictDefaultsKey: "patientRecords", dictKey: "kennelID")
        } else {
            //ownerTF.text = ownerList[row]
            //flashGreenTextField(textField: ownerTF, displayText: ownerList[row])
            askToChange(selectedStringToChange: String(ownerList[row]), textField: ownerTF, whatIsChanging: "Owner", dictDefaultsKey: "patientRecords", dictKey: "owner")
        }
    }
}
extension PatientDemographicsVC{
    // #MARK: - Animations
    func flashGreenTextField(textField: UITextField, displayText: String){
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            //textField.alpha = 0.0
            textField.backgroundColor = UIColor.WVCActionBlue()
        }, completion: {
            finished in
            if finished {
                //Once the label is completely invisible, set the text and fade it back in
                textField.text = displayText
                // Fade in
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                    //textField.alpha = 1.0
                    textField.backgroundColor = UIColor.textFieldBlue()
                }, completion: nil)
            }
        })
    }
}
extension PatientDemographicsVC {
    // #MARK: - UI
    func setupUI(){
        ownerPicker.delegate = self
        ownerPicker.dataSource = self
        kennelPicker.delegate = self
        kennelPicker.dataSource = self
    }
}
extension PatientDemographicsVC {
    // #MARK: - Show Demographics
    @objc func showDemographics(){
        //get defaults
        let selectedPatientID = UserDefaults.standard.string(forKey: "selectedPatientID") ?? ""
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        let myDemographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
        let badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
        
        //update UI Selected Badges
        var foundB = false
        for badge in badges {
            if badge["patientID"] == selectedPatientID {
                foundB = true
                if badge["isCaution"]! == "true"{
                    toggleCation = false
                    toggleCheckBox( isChecked: &toggleCation, checkButton: cation)
                } else {
                    toggleCation = true
                    toggleCheckBox( isChecked: &toggleCation, checkButton: cation)
                }
                if badge["isNpo"]! == "true"{
                    toggleNPO = false
                    toggleCheckBox( isChecked: &toggleNPO, checkButton: npo)
                } else {
                    toggleNPO = true
                    toggleCheckBox( isChecked: &toggleNPO, checkButton: npo)
                }
                if badge["isHalf"]! == "true" {
                    feed.selectedSegmentIndex = 1
                } else if badge["isTwice"] == "true" {
                    feed.selectedSegmentIndex = 2
                } else {
                    feed.selectedSegmentIndex = 0
                }
                if badge["isWet"]! == "true" {
                    feedType.selectedSegmentIndex = 1
                } else if badge["isDry"]! == "true" {
                    feedType.selectedSegmentIndex = 2
                } else {
                    feedType.selectedSegmentIndex = 0
                }
            }
        }
        //Update UI not selected badges
        if foundB == false {
            toggleCation = true
            toggleCheckBox( isChecked: &toggleCation, checkButton: cation)
            toggleNPO = true
            toggleCheckBox( isChecked: &toggleNPO, checkButton: npo)
            feed.selectedSegmentIndex = 0
            feedType.selectedSegmentIndex = 0
        }
        patientIDTF.text = selectedPatientID
        var found = false
        for patient in patientRecords {
            if patient["patientID"] == selectedPatientID {
                ownerTF.text = patient["owner"]
                kennelTF.text = patient["kennelID"]
                intakeDateLabel.text = patient["intakeDate"]
                //moveSwitchState(switchName: switchStatus, isTrue: patient["status"]!)
                found = true
            }
        }
        if found == false{
            ownerTF.text = ""
            kennelTF.text = ""
        }
        found = false
        for patient in myDemographics {
            if patient["patientID"] == selectedPatientID {
                moveSwitchState(switchName: switchSex, isTrue: patient["sex"]!)
                ageTF.text = patient["age"]
                breedTF.text = patient["breed"]
                found = true
            }
        }
        if found == false{
            moveSwitchState(switchName: switchSex, isTrue: "false")
            ageTF.text = ""
            breedTF.text = ""
        }
    }
    func moveSwitchState(switchName: UISwitch, isTrue:String){//sex? Male Female
        if isTrue == "true" || isTrue == "Archive"{
            switchName.setOn(true, animated: false)
        } else {
            switchName.setOn(false, animated: false)
        }
    }
}
extension PatientDemographicsVC {
    //make changes to owner and kennel#
    func askToChange(selectedStringToChange: String,
                     textField: UITextField,
                     whatIsChanging: String,
                     dictDefaultsKey: String,
                     dictKey: String){
        let selectedPatientID = UserDefaults.standard.string(forKey: "selectedPatientID") ?? ""
        changeRecordAlert(title: "Change \(whatIsChanging) \(textField.text!)",
            message: "\(selectedStringToChange) will replace \(textField.text!) for \(whatIsChanging).",
            buttonTitle: "Save",
            cancelButtonTitle: "Cancel",
            selectedPatientID: selectedPatientID,
            selectedStringToChange: selectedStringToChange,
            textField: textField,
            dictDefaultsKey: dictDefaultsKey,
            dictKey: dictKey)
    }
    func changeButtonTapped(selectedPatientID: String, selectedStringToChange: String, textField: UITextField,dictDefaultsKey: String,dictKey: String){
        flashGreenTextField(textField: textField, displayText: selectedStringToChange)
        var dictArray = UserDefaults.standard.object(forKey: dictDefaultsKey) as? Array<Dictionary<String,String>> ?? []
        for index in 0..<dictArray.count {
            if dictArray[index]["patientID"] == selectedPatientID {
                //print("selectedPatientID \(selectedPatientID) dictDefaultsKey \(dictDefaultsKey) dictKey \(dictKey)")
                dictArray[index][dictKey] = selectedStringToChange
                UserDefaults.standard.set(dictArray, forKey: dictDefaultsKey)
                UserDefaults.standard.synchronize()
            }
        }
        //REFRESH PATIENTS TABLE VIEW 
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshPatientsTable"), object: nil)
    }
    func changeRecordAlert(title:String, message:String,
                           buttonTitle:String,
                           cancelButtonTitle: String,
                           selectedPatientID: String,
                           selectedStringToChange: String,
                           textField: UITextField,
                           dictDefaultsKey: String,
                           dictKey: String) {
        
        let myAlert = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        myAlert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {
            alert -> Void in
            //DO:
            self.changeButtonTapped(selectedPatientID: selectedPatientID, selectedStringToChange: selectedStringToChange, textField: textField, dictDefaultsKey: dictDefaultsKey, dictKey: dictKey)
        }))
        
        myAlert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in })
        
        present(myAlert, animated: true){}
    }
}
extension PatientDemographicsVC {
    //add update save create Demographics: Age, Breed, Sex
    func updateDemographicsObject(){
        let pid = returnSelectedPatientID()
        newDemographics =
            [
                "patientID":pid,
                "age":ageTF.text!,
                "breed":breedTF.text!,
                "sex":String(switchSex.isOn)//true = Male
        ]
    }
    func saveDemographics(){
        var demographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
        updateDemographicsObject()
        var found = false
        if demographics.isEmpty {
            UserDefaults.standard.set([newDemographics], forKey: "demographics")
            UserDefaults.standard.synchronize()
        } else {
            for index in 0..<demographics.count{
                if demographics[index]["patientID"] == newDemographics["patientID"]{
                    found = true
                    for item in newDemographics {
                        demographics[index][item.key] = item.value
                    }
                    UserDefaults.standard.set(demographics, forKey: "demographics")
                    UserDefaults.standard.synchronize()
                    return
                }
            }
            if found == false {//APPEND NEW
                demographics.append(newDemographics)
                UserDefaults.standard.set(demographics, forKey: "demographics")
                UserDefaults.standard.synchronize()
            }
        }
    }
}
extension PatientDemographicsVC {
    // #MARK: - Setup Text Field Delegates
    //make sure + UITextFieldDelegate and textFieldsDelegates() viewDidLoad
    func textFieldsDelegates(){
        ageTF.delegate = self
        ageTF.returnKeyType = UIReturnKeyType.next
        ageTF.tag = 0
        breedTF.delegate = self
        breedTF.returnKeyType = UIReturnKeyType.go
        breedTF.tag = 1
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        intakeDateViewTopConstraint.constant = -100
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= 0 && textField.tag <= 1{
            saveDemographics()
            intakeDateViewTopConstraint.constant = 0
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

