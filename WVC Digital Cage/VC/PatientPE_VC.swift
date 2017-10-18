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
    
    var boolArray = [Bool](repeating: false, count: 11)
    
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
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        boolArray[sender.tag-1] = !boolArray[sender.tag-1]
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
        let currentValue = Int(sender.value)
        //print("\(currentValue)")
        sliderValueLabel.text = "\(currentValue)"
    }
}

extension PatientPE_VC{
    //switch action
    func showAlertUpdateComments(message: String, senderTag: Int){
        if boolArray[senderTag-1] == true {
            simpleTFAlert(title: "Add Comments:", message: message, buttonTitle: "OK", outputTextView:textViewPE, senderTag: senderTag)
        }
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
