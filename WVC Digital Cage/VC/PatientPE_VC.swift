//
//  PatientPE_VC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/17/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientPE_VC: UIViewController, UITextViewDelegate{

    //this view
    @IBOutlet var physicalExamView: UIView!
    
    //text view
    @IBOutlet weak var textViewPE: UITextView!
    
    //segment
    @IBOutlet weak var bodyConditionScoreSegmentControl: UISegmentedControl!
    
    //slider
    //@IBOutlet weak var sliderPE: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    //Layout Constraint
    @IBOutlet weak var commentsTopLayoutConstraint: NSLayoutConstraint!
    
    //switches
    @IBOutlet weak var switchOne: UISwitch!
    @IBOutlet weak var switchTwo: UISwitch!
    @IBOutlet weak var switchThree: UISwitch!
    @IBOutlet weak var switchFour: UISwitch!
    @IBOutlet weak var switchFive: UISwitch!
    @IBOutlet weak var switchSix: UISwitch!
    @IBOutlet weak var switchSeven: UISwitch!
    @IBOutlet weak var switchEaight: UISwitch!
    @IBOutlet weak var switchNine: UISwitch!
    @IBOutlet weak var switchTen: UISwitch!
    @IBOutlet weak var switchEleven: UISwitch!
    
    var newPE:[String: Any] = //Dictionary<String,String> =
        [
            "patientID":"",
            "comments":"",
            "generalAppearance":"",
            "skinFeetHair":"",
            "musculoskeletal":"",
            "nose":"",
            "digestiveTeeth":"",
            "respiratory":"",
            "ears":"",
            "nervousSystem":"",
            "lymphNodes":"",
            "eyes":"",
            "urogenital":""
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegateFor(textView: textViewPE)
        tapDismissKeyboard()
        //keyboard notification for push fields up/down
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardWillShow),
                           name: .UIKeyboardWillShow,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(keyboardWillHide),
                           name: .UIKeyboardWillHide,
                           object: nil)
        //call func showPhysicalExam from PatientsVC.swift
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(showPhysicalExam),
                                               name: NSNotification.Name(rawValue: "showPhysicalExam"),
                                               object: nil)
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        //boolArray[sender.tag-1] = !boolArray[sender.tag-1]
        switch sender.tag {
        case 1:
            showAlertUpdateComments(message: "1 General Appearance", senderTag: sender.tag)
            break
        case 2:
            showAlertUpdateComments(message: "2 Skin / Feet / Hair", senderTag: sender.tag)
            break
        case 3:
            showAlertUpdateComments(message: "3 Musculoskeletal", senderTag: sender.tag)
            break
        case 4:
            showAlertUpdateComments(message: "4 Nose", senderTag: sender.tag)
            break
        case 5:
            showAlertUpdateComments(message: "5 Digestive / Teeth", senderTag: sender.tag)
            break
        case 6:
            showAlertUpdateComments(message: "6 Respiratory", senderTag: sender.tag)
            break
        case 7:
            showAlertUpdateComments(message: "7 Ears", senderTag: sender.tag)
            break
        case 8:
            showAlertUpdateComments(message: "8 Nervous System", senderTag: sender.tag)
            break
        case 9:
            showAlertUpdateComments(message: "9 Lymph Nodes", senderTag: sender.tag)
            break
        case 10:
            showAlertUpdateComments(message: "10 Eyes", senderTag: sender.tag)
            break
        case 11:
            showAlertUpdateComments(message: "11 Urogenital", senderTag: sender.tag)
            break
        default: ()
            break;
        }
    }
    @IBAction func segmentAction(_ sender: Any) {
        let segmentIndex = bodyConditionScoreSegmentControl.selectedSegmentIndex
        let title = bodyConditionScoreSegmentControl.titleForSegment(at: segmentIndex)
        sliderValueLabel.text = "\(title!)"
        updateDCCISCloud()//BodyConditionScore: sliderValueLabel.text!)
    }

}
extension PatientPE_VC{
    //switch action
    func showAlertUpdateComments(message: String, senderTag: Int){
        let isThisSwitchON = isThisSwitchOpen(switchNumber: senderTag-1)
        if isThisSwitchON == true {
            //print("selectedPatientID \(returnSelectedPatientID())")
            
            let showAlert = DispatchGroup()
            showAlert.enter()
            simpleTFAlert(title: "Add Comments:", message: message, buttonTitle: "OK", outputTextView:textViewPE, senderTag: senderTag, dispachInstance: showAlert)
            
            showAlert.notify(queue: DispatchQueue.main) {
                // user closed showAlert TODO:
                self.savePhysicalExamSwitchValue(senderTag:senderTag-1, isSwitchOpen: isThisSwitchON)
            }
        } else {
            self.savePhysicalExamSwitchValue(senderTag:senderTag-1, isSwitchOpen: isThisSwitchON)
        }
        
    }
    func isThisSwitchOpen(switchNumber: Int) -> Bool{
        var switchArray = [switchOne, switchTwo, switchThree, switchFour, switchFive, switchSix, switchSeven, switchEaight, switchNine, switchTen, switchEleven]
        return (switchArray[switchNumber]?.isOn)!
    }
}
extension PatientPE_VC {
    //
    // #MARK: - Hide Keyboard
    //
    func tapDismissKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PatientPE_VC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
        
        commentsTopLayoutConstraint.constant = 320 //move text view back
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    // #MARK: - When Keyboard hides DO: Move text view up
    @objc func keyboardWillShow(sender: NSNotification){
        commentsTopLayoutConstraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }// #MARK: - When Keyboard shws DO: Move text view down
    @objc func keyboardWillHide(sender: NSNotification){
        
        commentsTopLayoutConstraint.constant = 320
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
extension PatientPE_VC {
    //
    // #MARK: - Text View
    //
    func setUpDelegateFor(textView: UITextView){
        textView.delegate = self
        textView.tag = 10
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 10 {
            print("keyboardWillHide")
            updateDCCISCloud()
        }
    }
}
extension PatientPE_VC{
    //
    // #MARK - Reset Physical Exam
    //
    func setPhysicalExamToNormalState(){
        let pid = returnSelectedPatientID()
        
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? [] //might be slow
        let cpid = returnCloudPatientIDFor(dictArray: patientRecords, patientID: pid)
       
        newPE =
            [
                "patientID":cpid,
                "patientName":pid,//patientName
                "comments":textViewPE.text!,
                "generalAppearance":"false",//Normal/Abnormal - false/true
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
                "bodyConditionScore":sliderValueLabel.text!
        ]
    }
}

extension PatientPE_VC{
    //
    // #MARK: - Save New or Update Physical Exam
    //
    func savePhysicalExamSwitchValue(senderTag:Int, isSwitchOpen: Bool){
        var patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        
        var found = false
        setPhysicalExamToNormalState()
        
        //update selected toggle switch
        let toggleSwitchs = ["generalAppearance","skinFeetHair","musculoskeletal","nose","digestiveTeeth","respiratory","ears","nervousSystem","lymphNodes","eyes","urogenital"]
        newPE.updateValue(String(isSwitchOpen), forKey: toggleSwitchs[senderTag])
        
        //INSERT NEW CLOUD
        if patientPhysicalExam.isEmpty {
            
            insertPhysicalExamInDCCISCloud(thisPhysicalExam:newPE)
            print("EMPTY, INSERT NEW P E \n \(newPE)")
            
        } else {
            
            //make sure we have right patient
            for index in 0..<patientPhysicalExam.count {
                
                let patientName = newPE["patientName"] as? String
                if patientPhysicalExam[index]["patientID"] == patientName {
                    
                    //UPDATE CLOUD
                    //If this patient already has a physical exam record then update it here
                    if let physicalExamId = patientPhysicalExam[index]["physicalExamId"] as? String {
                        
                        for item in toggleSwitchs {
                            newPE[item] = patientPhysicalExam[index][item]
                        }
                        newPE["physicalExamId"] = physicalExamId
                        //newPE["comments"] = textViewPE.text!
                        //newPE["bodyConditionScore"] = sliderValueLabel.text!
                        newPE.updateValue(String(isSwitchOpen), forKey: toggleSwitchs[senderTag])
                        
                        found = true
                        print("UPDATE PE \(patientPhysicalExam)")
                        updatePhysicalExamInDCCISCloud(thisPhysicalExam: newPE)
                        return
                    }
                }
            }
            if found == false {
                
                //INSERT NEW
                insertPhysicalExamInDCCISCloud(thisPhysicalExam:newPE)
                print("INSERT NEW P E \n \(newPE)")
                
            }
        }
    }
    
    //
    // #MARK: - Show Physical Exam
    //
    @objc func showPhysicalExam(){
        let pid = returnSelectedPatientID()
        var patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        var found = false
        if patientPhysicalExam.isEmpty {
            return
        } else {
            for index in 0..<patientPhysicalExam.count {
                if patientPhysicalExam[index]["patientID"] == pid {//UPDATE UI by PID
                    moveSwitchState(switchName: switchOne, isTrue: patientPhysicalExam[index]["generalAppearance"]!)
                    moveSwitchState(switchName: switchTwo, isTrue: patientPhysicalExam[index]["skinFeetHair"]!)
                    moveSwitchState(switchName: switchThree, isTrue: patientPhysicalExam[index]["musculoskeletal"]!)
                    moveSwitchState(switchName: switchFour, isTrue: patientPhysicalExam[index]["nose"]!)
                    moveSwitchState(switchName: switchFive, isTrue: patientPhysicalExam[index]["digestiveTeeth"]!)
                    moveSwitchState(switchName: switchSix, isTrue: patientPhysicalExam[index]["respiratory"]!)
                    moveSwitchState(switchName: switchSeven, isTrue: patientPhysicalExam[index]["ears"]!)
                    moveSwitchState(switchName: switchEaight, isTrue: patientPhysicalExam[index]["nervousSystem"]!)
                    moveSwitchState(switchName: switchNine, isTrue: patientPhysicalExam[index]["lymphNodes"]!)
                    moveSwitchState(switchName: switchTen, isTrue: patientPhysicalExam[index]["eyes"]!)
                    moveSwitchState(switchName: switchEleven, isTrue: patientPhysicalExam[index]["urogenital"]!)
                    textViewPE.text = patientPhysicalExam[index]["comments"]!
                    let sliderScore = patientPhysicalExam[index]["bodyConditionScore"]!
                    sliderValueLabel.text = sliderScore
                    print("sliderScore: \(sliderScore)")
                    updateSlider(sliderScore: sliderScore)
                    found = true
                }
            }
        }
        if found == false {
            //print("NOT found by PID")
            moveSwitchState(switchName: switchOne, isTrue: "")
            moveSwitchState(switchName: switchTwo, isTrue: "")
            moveSwitchState(switchName: switchThree, isTrue: "")
            moveSwitchState(switchName: switchFour, isTrue: "")
            moveSwitchState(switchName: switchFive, isTrue: "")
            moveSwitchState(switchName: switchSix, isTrue: "")
            moveSwitchState(switchName: switchSeven, isTrue: "")
            moveSwitchState(switchName: switchEaight, isTrue: "")
            moveSwitchState(switchName: switchNine, isTrue: "")
            moveSwitchState(switchName: switchTen, isTrue: "")
            moveSwitchState(switchName: switchEleven, isTrue: "")
            textViewPE.text = ""
            sliderValueLabel.text = "3"
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 4
            //sliderPE.setValue(3.0, animated: false)
        }
    }
    func moveSwitchState(switchName: UISwitch, isTrue:String){
        if isTrue == "true" {
            switchName.setOn(true, animated: false)
        } else {
            switchName.setOn(false, animated: false)
        }
    }
    func updateSlider(sliderScore: String){
        switch sliderScore {
        case "1":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 0
        case "1.5":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 1
        case "2":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 2
        case "2.5":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 3
        case "3":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 4
        case "3.5":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 5
        case "4":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 6
        case "4.5":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 7
        case "5":
            bodyConditionScoreSegmentControl.selectedSegmentIndex = 8
        default: ()
        break;
        }
    }
    
}

extension PatientPE_VC{
    //
    // #MARK: - UPDATE SLIDER for Body Condition Score and comments
    //
    func updateDCCISCloud(){
        var patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        
        var found = false
        setPhysicalExamToNormalState()
        
        //INSERT NEW CLOUD
        if patientPhysicalExam.isEmpty {
            
            insertPhysicalExamInDCCISCloud(thisPhysicalExam:newPE)
            print("EMPTY, INSERT NEW body condition score \n \(newPE)")
            
        } else {
            
            let toggleSwitchs = ["generalAppearance","skinFeetHair","musculoskeletal","nose","digestiveTeeth","respiratory","ears","nervousSystem","lymphNodes","eyes","urogenital"]
            //make sure we are update or saving for the right patient
            for index in 0..<patientPhysicalExam.count {
                
                let patientName = newPE["patientName"] as? String
                if patientPhysicalExam[index]["patientID"] == patientName {
                    
                    //UPDATE CLOUD
                    //If this patient already has a physical exam record then update it here
                    if let physicalExamId = patientPhysicalExam[index]["physicalExamId"] as? String {
                        
                        for item in toggleSwitchs {
                            newPE[item] = patientPhysicalExam[index][item]
                        }
                        newPE["physicalExamId"] = physicalExamId
                        found = true
                        print("UPDATE body condition score \(newPE)")
                        updatePhysicalExamInDCCISCloud(thisPhysicalExam: newPE)
                        return
                    }
                }
            }
            if found == false {
                //INSERT NEW
                insertPhysicalExamInDCCISCloud(thisPhysicalExam:newPE)
                print("INSERT NEW body condition score \n \(newPE)")
            }
        }
    }
}

extension PatientPE_VC{
    //
    // #MARK: - API
    //
    func getPhysicalExamsFromDCCISCloud(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getPhysicalExams(aview: physicalExamView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            //let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
            print("got cloud PhysicalExams")
        }
    }
    
    func updatePhysicalExamInDCCISCloud(thisPhysicalExam:[String : Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().physicalExam(aview: physicalExamView, parameters: thisPhysicalExam, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update Physical Exam success")
            self.getPhysicalExamsFromDCCISCloud()
        }
    }
    
    func insertPhysicalExamInDCCISCloud(thisPhysicalExam:[String : Any]){
        let insertDG = DispatchGroup()
        insertDG.enter()
        INSERT().newPhysicalExam(aview: physicalExamView, parameters: thisPhysicalExam, dispachInstance: insertDG)
        
        insertDG.notify(queue: DispatchQueue.main) {
            print("insert new Physical Exam success")
            self.getPhysicalExamsFromDCCISCloud()
        }
    }
}
