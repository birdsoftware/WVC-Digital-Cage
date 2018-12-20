//
//  PatientDemographicsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/24/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientDemographicsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {

    @IBOutlet var patientDemographicsView: UIView!
    
    //buttons
    //@IBOutlet weak var ageButton: UIButton!   // Custom Alert
    //@IBOutlet weak var breedButton: UIButton! // Custom Alert
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
    @IBOutlet weak var sexTF: UITextField!
    //switch
    //@IBOutlet weak var switchSex: UISwitch!
    
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
    var kennelIntArray = ["S1","S2","S3","S4","S5","S6","S7","S8",//"S9","S10",
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
    
    //
    // Button / Switch Actions
    //
    @IBAction func ageAction(_ sender: Any) {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! CustomAlertView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    @IBAction func breedAction(_ sender: Any) {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomBreedAlertID") as! CustomAlertBreedView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    @IBAction func sexAction(_ sender: Any) {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomSexAlertID") as! CustomAlertSexView
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
//    @IBAction func sexSwitchAction(_ sender: Any) {
//        saveDemographics()
//    }
    @IBAction func npoAction(_ sender: Any) {
        toggleCheckBox(isChecked: &toggleNPO, checkButton: npo)
        saveBadgeToDefaults(); //updateBadgeUI()
    }
    @IBAction func cationAction(_ sender: Any) {
        toggleCheckBox(isChecked: &toggleCation, checkButton: cation)
        saveBadgeToDefaults(); //updateBadgeUI()
    }
    @IBAction func feedFrequencyAction(_ sender: Any) {
        saveBadgeToDefaults(); //updateBadgeUI()
    }
    @IBAction func feedTypeAction(_ sender: Any) {
        saveBadgeToDefaults(); //updateBadgeUI()
    }

    func updateBadgeUI(){
        //REFRESH BADGE IN PATIENTS VIEW
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBadge"), object: nil)
    }
    func saveBadgeToDefaults(){
        //save badge to defaults
        let pid = returnSelectedPatientID()
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? [] //might be slow
        let cpid = returnCloudPatientIDFor(dictArray: patientRecords, patientID: pid)
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
            "patientID":cpid,
            "patientName":pid,
            "isNpo":String(toggleNPO),
            "isHalf":String(feedHalf),
            "isTwice":String(feedTwice),
            "isWet":String(feedWet),
            "isDry":String(feedDry),
            "isCaution":String(toggleCation)
        ]
        var badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
        var found = false
        if badges.isEmpty {//INSERT NEW
            insertBadgeInDCCISCloud(thisBadge: newBadge)
            print("EMPTY, INSERT NEW badge \n \(newBadge)")
        } else {
            for index in 0..<badges.count {
                if badges[index]["patientID"] == newBadge["patientName"]{
                    found = true
                    if let badgeId = badges[index]["badgesId"] as? String{//UPDATE
                        newBadge["badgesId"] = badgeId
                        found = true
                        print("UPDATE Badge \(newBadge)")
                        updateBadgeInDCCISCloud(thisBadge: newBadge)
                        return
                    }
                }
            }
            if found == false {//INSERT NEW
                insertBadgeInDCCISCloud(thisBadge: newBadge)
                print("EMPTY, INSERT NEW badge \n \(newBadge)")
            }
        }
    }
}

extension PatientDemographicsVC{
    //
    // #MARK: - Picker View
    //
    
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
                //moveSwitchState(switchName: switchSex, isTrue: patient["sex"]!)
                sexTF.text = patient["sex"]//false = Male
                
                //if patient["sex"] == "false" { sexTF.text = "Male" }
                //if patient["sex"] == "true" { sexTF.text = "Female" }
                
                ageTF.text = patient["age"]
                breedTF.text = patient["breed"]
                found = true
            }
        }
        if found == false{
            //moveSwitchState(switchName: switchSex, isTrue: "false")
            sexTF.text = ""
            ageTF.text = ""
            breedTF.text = ""
        }
    }
}
extension PatientDemographicsVC {
    //
    // #MARK: OWNER & KENNEL# Picker funcs for Save, Update & Create
    //
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
        var dictArray = UserDefaults.standard.object(forKey: dictDefaultsKey) as? Array<Dictionary<String,String>> ?? [] //"patientRecords"
        for index in 0..<dictArray.count {
            if dictArray[index]["patientID"] == selectedPatientID {
                //print("selectedPatientID \(selectedPatientID) dictDefaultsKey \(dictDefaultsKey) dictKey \(dictKey)")
                dictArray[index][dictKey] = selectedStringToChange
                UserDefaults.standard.set(dictArray, forKey: dictDefaultsKey)
                UserDefaults.standard.synchronize()
                
                var kennelId = ""
                if dictKey == "kennelID" {
                    kennelId = selectedStringToChange
                } else {
                    kennelId = dictArray[index]["kennelID"]!
                }
                var owner = ""
                if dictKey == "owner" {
                    owner = selectedStringToChange
                } else {
                    owner = dictArray[index]["owner"]!
                }
                
                let updateDCCISPatient:Dictionary<String,String> =
                    [
                        "patientId": dictArray[index]["cloudPatientID"]!,//cloudPatientID
                        "status": dictArray[index]["status"]!,
                        "intakeDate": dictArray[index]["intakeDate"]!,
                        "patientName": dictArray[index]["patientID"]!,
                        "walkDate": dictArray[index]["walkDate"]!,
                        "photoName": dictArray[index]["photo"]!,
                        "kennelId": kennelId,
                        "owner": owner,
                        "groupString": dictArray[index]["group"]!
                ]
                //print("\(updateDCCISPatient)")
                updateInDCCISCloud(thisPatient:updateDCCISPatient)
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
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? [] //might be slow
        let cpid = returnCloudPatientIDFor(dictArray: patientRecords, patientID: pid)
        newDemographics =
            [
                "patientID":cpid,
                "patientName":pid,
                "age":ageTF.text!,
                "breed":breedTF.text!,
                "sex":sexTF.text!//String(switchSex.isOn)//true = female
        ]
    }
    func saveDemographics(){
        var demographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
        updateDemographicsObject()
        var found = false
        //INSERT NEW CLOUD
        if demographics.isEmpty {
            insertDemographicInDCCISCloud(thisDemographic: newDemographics)
            print("EMPTY, INSERT NEW Demographics \n \(newDemographics)")
        } else {
            //make sure we have right patient
            for index in 0..<demographics.count{
                if demographics[index]["patientID"] == newDemographics["patientName"]{
                    found = true
                    if let demographicsId = demographics[index]["demographicsId"] as? String {
                        newDemographics["demographicsId"] = demographicsId
                        found = true
                        print("UPDATE Demographics \(newDemographics)")
                        updateDemographicInDCCISCloud(thisDemographic: newDemographics)
                        return
                    }
                }
            }
            if found == false {
                insertDemographicInDCCISCloud(thisDemographic: newDemographics)
                print("INSERT NEW Demographics \n \(newDemographics)")
                //INSERT NEW
            }
        }
    }
}
extension PatientDemographicsVC {
    //
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

extension PatientDemographicsVC: CustomAlertViewDelegate {
    // #MARK: - Setup Custom Alert View
    func okButtonTapped(selectedOption: String, textFieldValue: String) {
        //print("ok Button Tapped with \(selectedOption) option selected")
        //print("TextField has value: \(textFieldValue)")
        ageTF.text = selectedOption
        saveDemographics()
        print("selectedOption \(selectedOption)")
    }
    func cancelButtonTapped() {
        print("cancel Button Tapped")
    }
    func setTitle() -> String{
        return "Age"
    }
    func setMessage() -> String{
        return "Choose age in years and months"
    }
}

extension PatientDemographicsVC: CustomAlertViewDelegateBreed {
    // #MARK: - Setup Custom Alert View
    func okButtonTappedBreed(selectedOption: String, textFieldValue: String) {
        //print("ok Button Tapped with \(selectedOption) option selected")
        //print("TextField has value: \(textFieldValue)")
        breedTF.text = selectedOption
        saveDemographics()
        print("selectedOption \(selectedOption)")
    }
    func cancelButtonTappedBreed() {
        print("cancel Button Tapped")
    }
}

extension PatientDemographicsVC: CustomAlertViewDelegateSex {
    // #MARK: - Setup Custom Alert View
    func okButtonTappedSex(selectedOption: String, textFieldValue: String) {
        //print("ok Button Tapped with \(selectedOption) option selected")
        //print("TextField has value: \(textFieldValue)")
        sexTF.text = selectedOption
        saveDemographics()
        print("selectedOption \(selectedOption)")
    }
    func cancelButtonTappedSex() {
        print("cancel Button Tapped")
    }
}

//patientDemographicsView
extension PatientDemographicsVC {
//
// #MARK: API
//

    // --- update Patients table ---
    func updateInDCCISCloud(thisPatient:[String : Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().Patient(aview: patientDemographicsView, parameters: thisPatient, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update this Patient success")
        }
    }
    
    // --- Demographics table ---
    func getDemographicsFromDCCISCloud(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getDemographic(aview: patientDemographicsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            //let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
            print("got cloud Demographics")
        }
    }
    
    func updateDemographicInDCCISCloud(thisDemographic:[String : Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().Demographic(aview: patientDemographicsView, parameters: thisDemographic, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update Demographic success")
            self.getDemographicsFromDCCISCloud()
        }
    }
    
    func insertDemographicInDCCISCloud(thisDemographic:[String : Any]){
        let insertDG = DispatchGroup()
        insertDG.enter()
        INSERT().newDemographic(aview: patientDemographicsView, parameters: thisDemographic, dispachInstance: insertDG)
        
        insertDG.notify(queue: DispatchQueue.main) {
            print("insert new Demographic success")
            self.getDemographicsFromDCCISCloud()
        }
    }
    
    // --- badges table ---
    func getBadgesFromDCCISCloud(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getBadges(aview: patientDemographicsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            print("got cloud badges")
            self.updateBadgeUI()
        }
    }
    
    func updateBadgeInDCCISCloud(thisBadge:[String : Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().Badge(aview: patientDemographicsView, parameters: thisBadge, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update Badge success")
            self.getBadgesFromDCCISCloud()
        }
    }
    
    func insertBadgeInDCCISCloud(thisBadge:[String : Any]){
        let insertDG = DispatchGroup()
        insertDG.enter()
        INSERT().newBadge(aview: patientDemographicsView, parameters: thisBadge, dispachInstance: insertDG)
        
        insertDG.notify(queue: DispatchQueue.main) {
            print("insert new Badge success")
            self.getBadgesFromDCCISCloud()
        }
    }
}
