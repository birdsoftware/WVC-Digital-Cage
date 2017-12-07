//
//  PatientPE_VC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/17/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientPE_VC: UIViewController {

    //text view
    @IBOutlet weak var textViewPE: UITextView!
    //slider
    @IBOutlet weak var sliderPE: UISlider!
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
    
    //var boolArray = [Bool](repeating: false, count: 11)
    
    //Saved selectedPatientID from PatientsVC.swift
    //var selectedPatientID = ""
    
    var newPE:Dictionary<String,String> =
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
    @IBAction func sliderAction(_ sender: UISlider) {
        let roundedNearestHalf = round(sender.value*2)/2 //0, 0.5,...
        let currentValue = String(roundedNearestHalf)
        sliderValueLabel.text = "\(currentValue)"
        updateSliderValueInpatientPhysicalExamDictionary(sliderNewValue: currentValue)
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
    // #MARK: - Hide Keyboard
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
extension PatientPE_VC{
    func updatePEDataObject(){
        let pid = returnSelectedPatientID()
        newPE =
            [
                "patientID":pid,
                "comments":textViewPE.text!,
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
                "bodyConditionScore":sliderValueLabel.text!
        ]
    }
    func savePhysicalExamSwitchValue(senderTag:Int, isSwitchOpen: Bool){
        var patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        let pid = returnSelectedPatientID()
        let switchStringNames = ["generalAppearance","skinFeetHair","musculoskeletal","nose","digestiveTeeth","respiratory","ears","nervousSystem","lymphNodes","eyes","urogenital"]
        var found = false
        updatePEDataObject()
        
        newPE.updateValue(String(isSwitchOpen), forKey: switchStringNames[senderTag])
        if patientPhysicalExam.isEmpty {//Create NEW record/TABLE if DNE
            UserDefaults.standard.set([newPE], forKey: "patientPhysicalExam")
            UserDefaults.standard.synchronize()
        } else {
            for index in 0..<patientPhysicalExam.count {
                if patientPhysicalExam[index]["patientID"] == pid {//UPDATE Existing PID
                    patientPhysicalExam[index][switchStringNames[senderTag]] = String(isSwitchOpen)
                    patientPhysicalExam[index]["comments"] = textViewPE.text!
                    patientPhysicalExam[index]["bodyConditionScore"] = sliderValueLabel.text!
                    UserDefaults.standard.set(patientPhysicalExam, forKey: "patientPhysicalExam")
                    UserDefaults.standard.synchronize()
                    found = true
                    //print("UPDATE PE \(patientPhysicalExam)")
                }
            }
            if found == false {
                patientPhysicalExam.append(newPE)
                UserDefaults.standard.set(patientPhysicalExam, forKey: "patientPhysicalExam")
                UserDefaults.standard.synchronize()
                //print("APPEND PE \(patientPhysicalExam)")
            }
        }
    }
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
                    sliderPE.setValue(Float(sliderScore)!, animated: false)
                    found = true
                    print("showPhysicalExam found by PID")
                }
            }
        }
        if found == false {
            print("NOT found by PID")
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
            sliderValueLabel.text = "3.0"
            sliderPE.setValue(3.0, animated: false)
        }
    }
    func moveSwitchState(switchName: UISwitch, isTrue:String){
        if isTrue == "true" {
            switchName.setOn(true, animated: false)
        } else {
            switchName.setOn(false, animated: false)
        }
    }
    func updateSliderValueInpatientPhysicalExamDictionary(sliderNewValue: String){
        //let pid = returnSelectedPatientID()
        var dic = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        if dic.isEmpty {
            updatePEDataObject()
            UserDefaults.standard.set([newPE], forKey: "patientPhysicalExam")
            UserDefaults.standard.synchronize()
        } else {
            var changesMade = false
            let result : [Any] = dic.map { dictionary in
                var dict = dictionary
                if let patientID = dict["patientID"], patientID == returnSelectedPatientID() {
                    dict["bodyConditionScore"] = sliderNewValue
                    changesMade = true
                }
                return dict
            }
            if changesMade {
                UserDefaults.standard.set(result, forKey: "patientPhysicalExam")
                UserDefaults.standard.synchronize()
            } else {
                updatePEDataObject()
                dic.append(newPE)
                UserDefaults.standard.set(dic, forKey: "patientPhysicalExam")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
}

