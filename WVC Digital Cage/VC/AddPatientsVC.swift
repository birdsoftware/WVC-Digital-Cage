//
//  AddPatientsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/18/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class AddPatientsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    //label
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewPatientID: UILabel!
    @IBOutlet weak var reviewGroup: UILabel!
    @IBOutlet weak var reviewOwner: UILabel!
    @IBOutlet weak var reviewKennel: UILabel!
    //segment
    @IBOutlet weak var segmentControl: UISegmentedControl!
    //pickers
    @IBOutlet weak var ownerPicker: UIPickerView!
    @IBOutlet weak var kennelPicker: UIPickerView!
    //text fields
    @IBOutlet weak var patientIDTF: UITextField!
    @IBOutlet weak var ownerTF: UITextField!
    @IBOutlet weak var kennelTF: UITextField!
    var kennelIntArray = ["S1","S2","S3","S4","S5","S6","S7","S8",
                          "D1","D2","D3","D4","D5","D6","D7","D8","D9","D10",
                          "D11","D12","D13","D14","D15","D16",
                          "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10",
                          "T11","T12","T13",
                          "I1","I2","I3","I4",
                          "Cage Banks", "Cat room"]//Array(1...45)
    
    var ownerList = ["The Animal Foundation (TAF)","Henderson Shelter (HS)","Desert Haven Animal Society (DHAS)",
                     "Home for Spot (HFS)","Riverside Shelter (RS)"]
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDateNow()
        // Delegates
        ownerPicker.delegate = self
        ownerPicker.dataSource = self
        kennelPicker.delegate = self
        kennelPicker.dataSource = self
        patientIDTF.delegate = self
        ownerTF.delegate = self
        kennelTF.delegate = self
    }
    
    // #MARK: - ACTIONS
    @IBAction func changeDateAction(_ sender: Any) {
        changeDateTime(title: "Intake Date")
    }
    @IBAction func segmentControlAction(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            reviewGroup.text = "Canine"
        case 1:
            reviewGroup.text = "Feline"
        case 2:
            reviewGroup.text = "Other"
        default:
            break;
        }
    }
    @IBAction func saveAction(_ sender: Any) {
        saveNewPatientLocally()
        self.performSegue(withIdentifier: "segueToPatientsDB", sender: self)
    }
    @IBAction func closeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToPatientsDB", sender: self)
    }
    
}
extension AddPatientsVC{
    //#MARK - UI Setup
    func setDateNow(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let nowString = formatter.string(from: Date())
        dateLabel.text = nowString
        reviewDateLabel.text = nowString
    }
}
extension AddPatientsVC{
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
            kennelTF.text = String(kennelIntArray[row])
            reviewKennel.text = String(kennelIntArray[row])
        } else {
            ownerTF.text = ownerList[row]
            reviewOwner.text = ownerList[row]
        }
    }
}
extension AddPatientsVC{
    //#MARK - Date Picker Alert
    func changeDateTime(title: String){
        DatePickerDialog().show(title, doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date/*.dateAndTime*/) {
            (date) -> Void in
            if date != nil {
                let dateFormat = DateFormatter()
                dateFormat.dateStyle = DateFormatter.Style.short // --NO TIME .short
                let strDate = dateFormat.string(for: date!)!
                
                /* Uncomment for TIME use:
                 * let formatterTime = DateFormatter()
                 * formatterTime.timeStyle = .short
                 * let strTime =  formatterTime.string(from: date!)
                 */
                
                //----- UPDATE UI LABEL BY DATE SELECTED ---------
                //self.appointmentDate.text = "Appointment Date: \(strDate) \(strTime)"
                self.dateLabel.text = strDate
                self.reviewDateLabel.text = strDate
                //self.timeUpToDate = strTime
            }
        }
        //Save new date to user defaults
        //UserDefaults.standard.set(true, forKey: "didUpdateCalendarDate") //need check to display a date if no date selected
    }
}
extension AddPatientsVC{
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Your app can do something when textField finishes editing
        switch textField {
        case patientIDTF:
            reviewPatientID.text = patientIDTF.text
        case ownerTF:
            reviewOwner.text = ownerTF.text
        case kennelTF:
            reviewKennel.text = kennelTF.text
        default:
            return
        }

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}
extension AddPatientsVC{
// MARK: local storage
    func saveNewPatientLocally(){
        //get what user entered
        var newPatientData = [String]()
        newPatientData.append(reviewDateLabel.text!)
        newPatientData.append(reviewPatientID.text!)
        newPatientData.append(reviewGroup.text!)
        newPatientData.append(reviewOwner.text!)
        newPatientData.append(reviewKennel.text!)
        //check for missing data
        var missingData = false
        for index in 0..<newPatientData.count{
            if newPatientData[index].isEmpty {
                missingData = true
                let p = patientDataConversion(indexV:index)
                simpleAlert(title: p + " is missing", message: "enter value and try again before Saving.", buttonTitle: "OK")
            }
        }
        //check if name already taken
        for item in patientRecords {
            if item["patientID"] == reviewPatientID.text!{
                missingData = true
                simpleAlert(title: "Patient ID " + reviewPatientID.text! + " already in use", message: "Enter a unique Patient ID before saving.", buttonTitle: "OK")
            }
        }
        //save locally if no missing data
        if missingData == false{
            let newP:Dictionary<String,String> =
                    ["patientID":reviewPatientID.text!,
                     "kennelID":reviewKennel.text!,
                     "status":"Active",
                     "intakeDate":reviewDateLabel.text!,
                     "owner":reviewOwner.text!,
                     "group":reviewGroup.text!,
                     "walkDate":"",
                     "photo":""
                    ]
            
            if patientRecords.isEmpty == false
            {
                patientRecords.append(newP)
                UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
                UserDefaults.standard.synchronize()
            }
            else {
                UserDefaults.standard.set([newP], forKey: "patientRecords")
                UserDefaults.standard.synchronize()
            }
            
            var patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
            
            let newPE =
                [
                    "patientID":reviewPatientID.text!,
                    "comments":"",
                    "generalAppearance":"false",
                    "skinFeetHair":"false",
                    "musculoskeletal":"false",
                    "nose":"false",
                    "digestiveTeeth":"false",
                    "respiratory":"false",
                    "ears":"false",
                    "nervousSystem":"false",
                    "lymphNodes":"false",
                    "eyes":"false",
                    "urogenital":"false",
                    "bodyConditionScore":"3.0"
            ]

            patientPhysicalExam.append(newPE)
            UserDefaults.standard.set(patientPhysicalExam, forKey: "patientPhysicalExam")
            UserDefaults.standard.synchronize()
            
        }
    }
    func patientDataConversion(indexV:Int) -> String{
        switch indexV {
        case 1:
            return "Patient ID"
        case 2:
            return "Group"
        case 3:
            return "Owner"
        case 4:
            return "Kennel"
        default:
            return "Patient Field"
        }
    }
}
