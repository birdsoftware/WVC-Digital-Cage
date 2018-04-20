//
//  CustomAlertView.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/20/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

import UIKit

class CustomAlertView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    var delegate: CustomAlertViewDelegate?
    var selectedOption = "< 1 month"
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    let pickerDataYears = Array(0...100)
    let pickerDataMonths = Array(0...12)
    var stringYearsArray = [String]()
    var stringMonthsArray = [String]()
    var pickerOptions = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //alertTextField.becomeFirstResponder()
        stringYearsArray = pickerDataYears.map
            {
                String($0)+" years"
            }
        stringMonthsArray = pickerDataMonths.map
            {
                String($0)+" months"
        }
        pickerOptions.append(stringYearsArray)
        pickerOptions.append(stringMonthsArray)
        titleLabel.text = delegate?.setTitle()
        messageLabel.text = delegate?.setMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
        picker.dataSource = self
        picker.delegate = self
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
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        //alertTextField.resignFirstResponder()
        
        delegate?.okButtonTapped(selectedOption: selectedOption, textFieldValue: "none")//alertTextField.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    //required in class
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    // returns the number of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return pickerOptions[component].count
    }
    // returns data to display  picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerOptions[component][row]
    }
    // picker value selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        var year = pickerOptions[0][pickerView.selectedRow(inComponent: 0)]
        var month = pickerOptions[1][pickerView.selectedRow(inComponent: 1)]
        
        //remove plural for single case
        if year == "1 years"{ year = "1 year" }
        if month == "1 months"{ month = "1 month" }
        
        //remove 0 cases
        if year == "0 years" && month == "0 months"{
           selectedOption = "< 1 month"
        } else if year == "0 years"{
            selectedOption = month
        } else if month == "0 months"{
            selectedOption = year
        } else {
            selectedOption = year + ", " + month
        }
        //print("\(selectedOption)")
    }
    
}
