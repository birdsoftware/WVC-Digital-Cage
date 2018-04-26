//
//  CustomAlertSex.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

import UIKit

class CustomAlertSexView:UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    //Specific to This View Delegate
    var delegate: CustomAlertViewDelegateSex?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    //data
    var sex = ["Male", "Female", "Neutered Male", "Spayed Female"]
    var selectedOption = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
        picker.dataSource = self
        picker.delegate = self
        selectedOption = sex[0]
        titleLabel.text = "Sex of Animal"
        messageLable.text = ""//Pick \(groupString) Breed for \(patientID)"
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        //cancelButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        //cancelButton.addBorder(side: .Right, color: alertViewGrayColor, width: 1)
        //okButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        //alertTextField.resignFirstResponder()
        delegate?.cancelButtonTappedSex()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        //alertTextField.resignFirstResponder()
        delegate?.okButtonTappedSex(selectedOption: selectedOption, textFieldValue: "none")
        self.dismiss(animated: true, completion: nil)
    }
    
    //Picker setup
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // returns the number of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return sex.count
    }
    // returns data to display  picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sex[row]
    }
    //picker selected value
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
       selectedOption = sex[row]
    }
}
