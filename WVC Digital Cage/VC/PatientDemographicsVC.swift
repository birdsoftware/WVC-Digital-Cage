//
//  PatientDemographicsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/24/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientDemographicsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //pickers
    @IBOutlet weak var ownerPicker: UIPickerView!
    @IBOutlet weak var kennelPicker: UIPickerView!
    //text fields
    @IBOutlet weak var ownerTF: UITextField!
    @IBOutlet weak var kennelTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var patientIDTF: UITextField!
    @IBOutlet weak var breedTF: UITextField!
    //switches
    @IBOutlet weak var switchSex: UISwitch!
    
    
    var kennelIntArray = Array(1...45)
    var ownerList = ["The Animal Foundation (TAF)","Henderson Shelter (HS)","Desert Haven Animal Society (DHAS)",
                     "Home for Spot (HFS)","Riverside Shelter (RS)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        ownerPicker.delegate = self
        ownerPicker.dataSource = self
        kennelPicker.delegate = self
        kennelPicker.dataSource = self
        //call func showPhysicalExam from PatientsVC.swift
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(showDemographics),
                                               name: NSNotification.Name(rawValue: "showDemographics"),
                                               object: nil)
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
            textField.backgroundColor = UIColor.candyGreen()
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
    // #MARK: - UI Set Up
    @objc func showDemographics(){
        //get defaults
        let selectedPatientID = UserDefaults.standard.string(forKey: "selectedPatientID") ?? ""
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        
        //update UI
        patientIDTF.text = selectedPatientID
        //ownerTF.text = "here"
        //kennelTF.text = "here"
        for patient in patientRecords {
            if patient["patientID"] == selectedPatientID {
                ownerTF.text = patient["owner"]
                kennelTF.text = patient["kennelID"]
                //moveSwitchState(switchName: switchStatus, isTrue: patient["Status"]!)
                print("here")
            }
        }
    }
    func moveSwitchState(switchName: UISwitch, isTrue:String){
        if isTrue == "true" || isTrue == "Archive"{
            switchName.setOn(true, animated: false)
        } else {
            switchName.setOn(false, animated: false)
        }
    }
}
extension PatientDemographicsVC {
    //make changes
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
                //REFRESH VIEW TODO:::
            }
        }
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

