//
//  addTx.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/27/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class addTx: UIViewController {

    //text fields
    @IBOutlet weak var oneTreatmentTF: UITextField!
    @IBOutlet weak var twoTreatmentTF: UITextField!
    @IBOutlet weak var threeTreatmentTF: UITextField!
    @IBOutlet weak var fourTreatmentTF: UITextField!
    @IBOutlet weak var fiveTreatmentTF: UITextField!
    
    @IBOutlet weak var sixTreatmentTF: UITextField!
    @IBOutlet weak var sevenTreatmentTF: UITextField!
    @IBOutlet weak var eightTreatmentTF: UITextField!
    @IBOutlet weak var nineTreatmentTF: UITextField!
    @IBOutlet weak var tenTreatmentTF: UITextField!
    
    @IBOutlet weak var monitorDays: UITextField!
    @IBOutlet weak var monitorFrequency: UITextField!
    
    //labels
    @IBOutlet weak var dateLabel: UILabel!
    
    var collectionTreatments = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
    var newTreatment = [String:String]()
    
    var filteredCollectionTreatments = Array<Dictionary<String,String>>()
    
    var monitoredList = ""
    
    //views - Hide -
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var dailyView: UIView!
    
    //segue vars
    var seguePatientID: String!
    var segueShelterName: String!
    var seguePatientSex: String!
    var seguePatientAge: String!
    var seguePatientBreed: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTreatmentsBy(selectedValue: seguePatientID)
        setupUI()
    }
    //
    // #MARK: - Actions
    //
    @IBAction func saveAction(_ sender: Any) {
        let isDataMissing = checkForMissingData()
        if isDataMissing == false{
            getMonitoredList()
            saveTreatmentsLocally()
            self.performSegue(withIdentifier: "segueaddTxToTxVC", sender: self)
        }
    }
    @IBAction func closeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueaddTxToTxVC", sender: self)
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
    
}
extension addTx {
    //
    // #MARK: - UI Supporting Functions
    //
    func setupUI(){// UPDATE Text Fields and Date Label
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy a"
        let nowString = formatter.string(from: Date())
        dateLabel.text = nowString
        if filteredCollectionTreatments.isEmpty == false {
            sliderView.isHidden = true
            dailyView.isHidden = true
            for treatment in filteredCollectionTreatments {
                if treatment["containsTreatmentLabels"] == "true" {
                    oneTreatmentTF.text = treatment["treatmentOne"]
                    twoTreatmentTF.text = treatment["treatmentTwo"]
                    threeTreatmentTF.text = treatment["treatmentThree"]
                    fourTreatmentTF.text = treatment["treatmentFour"]
                    fiveTreatmentTF.text = treatment["treatmentFive"]
                    sixTreatmentTF.text = treatment["treatmentSix"]
                    sevenTreatmentTF.text = treatment["treatmentSeven"]
                    eightTreatmentTF.text = treatment["treatmentEight"]
                    nineTreatmentTF.text = treatment["treatmentNine"]
                    tenTreatmentTF.text = treatment["treatmentTen"]
                    monitorFrequency.text = treatment["monitorFrequency"]
                    monitorDays.text = treatment["monitorDays"]
                    return
                }
            }
        }
    }
    func checkForMissingData() -> Bool{
        var isDataMissing = false
        var whatMissing = "Treatment field"
        if monitorFrequency.text!.isEmpty { whatMissing = "2X Daily / Daily"; isDataMissing = true }
        else if monitorDays.text!.isEmpty { whatMissing = "Number of days"; isDataMissing = true }
        else if oneTreatmentTF.text!.isEmpty &&
                twoTreatmentTF.text!.isEmpty &&
                threeTreatmentTF.text!.isEmpty &&
                fourTreatmentTF.text!.isEmpty &&
                fiveTreatmentTF.text!.isEmpty &&
                sixTreatmentTF.text!.isEmpty &&
                sevenTreatmentTF.text!.isEmpty &&
                eightTreatmentTF.text!.isEmpty &&
                nineTreatmentTF.text!.isEmpty &&
                tenTreatmentTF.text!.isEmpty
        { isDataMissing = true }
        if isDataMissing {
            simpleAlert(title: whatMissing + " is missing", message: "Enter this before saving.", buttonTitle: "OK")
        }
        return isDataMissing
    }
    func filterTreatmentsBy(selectedValue: String) {
        var scopePredicate:NSPredicate
        scopePredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", selectedValue)
        let arr=(collectionTreatments as NSArray).filtered(using: scopePredicate)
        if arr.isEmpty == false {
            filteredCollectionTreatments=arr as! Array<Dictionary<String,String>>
        } else {
            filteredCollectionTreatments=Array<Dictionary<String,String>>()
        }
    }
}
extension addTx {
    //
    // #MARK: - Saving Locally
    //
    func updateTreatment(){
        // Date now
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy a"
        let nowString = formatter.string(from: Date())
        newTreatment = [
            "patientID":seguePatientID,
            "date":nowString,
            "treatmentOne":oneTreatmentTF.text!,
            "treatmentTwo":twoTreatmentTF.text!,
            "treatmentThree":threeTreatmentTF.text!,
            "treatmentFour":fourTreatmentTF.text!,
            "treatmentFive":fiveTreatmentTF.text!,
            "treatmentSix":sixTreatmentTF.text!,
            "treatmentSeven":sevenTreatmentTF.text!,
            "treatmentEight":eightTreatmentTF.text!,
            "treatmentNine":nineTreatmentTF.text!,
            "treatmentTen":tenTreatmentTF.text!,
            "monitorFrequency":monitorFrequency.text!,//daily or 2x daily
            "monitorDays":monitorDays.text!,
            "monitored":monitoredList,//1,2,3,4,5,6,7,8,9,T
            "checkComplete":"true",
            "containsTreatmentLabels":"true"
        ]
    }
    func emptyTreatment(date: String){
        newTreatment = [
            "patientID":seguePatientID,
            "date":date,
            "treatmentOne":"",
            "treatmentTwo":"",
            "treatmentThree":"",
            "treatmentFour":"",
            "treatmentFive":"",
            "treatmentSix":"",
            "treatmentSeven":"",
            "treatmentEight":"",
            "treatmentNine":"",
            "treatmentTen":"",
            "monitorFrequency":monitorFrequency.text!,//daily or 2x daily
            "monitorDays":monitorDays.text!,
            "monitored":monitoredList,//1,2,3,4,5,6,7,8,9,T
            "checkComplete":"false",
            "containsTreatmentLabels":"false"
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
            hoursToAdd = hoursToAdd + hours
            dateComponent.hour = hoursToAdd
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy a"
            let nowString = formatter.string(from: futureDate!)
            emptyTreatment(date: nowString)
            collectionTreatments.append(newTreatment)
        }
    }
    func saveTreatmentsLocally(){
        
        if filteredCollectionTreatments.isEmpty {//if empty add new
            updateTreatment()
            collectionTreatments.append(newTreatment)// ADD 1
            UserDefaults.standard.set(collectionTreatments, forKey: "collectionTreatments")
            UserDefaults.standard.synchronize()
            //LOOP ADD treatments
            monitorTreatmentsFor(numberOfDays: Int(monitorDays.text!)!, isTwiceDaily: monitorFrequency.text!)
            UserDefaults.standard.set(collectionTreatments, forKey: "collectionTreatments")
            UserDefaults.standard.synchronize()
        } else {// UPDATE
            for index in 0..<collectionTreatments.count {
                if collectionTreatments[index]["patientID"] == seguePatientID &&
                collectionTreatments[index]["containsTreatmentLabels"] == "true" {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy a"
                    let nowString = formatter.string(from: Date())
                    collectionTreatments[index]["date"] = nowString
                    collectionTreatments[index]["treatmentOne"] = oneTreatmentTF.text!
                    collectionTreatments[index]["treatmentTwo"] = twoTreatmentTF.text!
                    collectionTreatments[index]["treatmentThree"] = threeTreatmentTF.text!
                    collectionTreatments[index]["treatmentFour"] = fourTreatmentTF.text!
                    collectionTreatments[index]["treatmentFive"] = fiveTreatmentTF.text!
                    collectionTreatments[index]["treatmentSix"] = sixTreatmentTF.text!
                    collectionTreatments[index]["treatmentSeven"] = sevenTreatmentTF.text!
                    collectionTreatments[index]["treatmentEight"] = eightTreatmentTF.text!
                    collectionTreatments[index]["treatmentNine"] = nineTreatmentTF.text!
                    collectionTreatments[index]["treatmentTen"] = tenTreatmentTF.text!
                    collectionTreatments[index]["monitored"] = monitoredList//1,2,3,4,5,6,7,8,9,T
                } else if collectionTreatments[index]["patientID"] == seguePatientID &&
                    collectionTreatments[index]["containsTreatmentLabels"] == "false"{
                    collectionTreatments[index]["monitored"] = monitoredList
                }
            }
            UserDefaults.standard.set(collectionTreatments, forKey: "collectionTreatments")
            UserDefaults.standard.synchronize()
        }
    }
    func getMonitoredList() {
        
        //This loop gets previous saved monitored list
        if filteredCollectionTreatments.isEmpty == false {
            for treatment in filteredCollectionTreatments {
                if treatment["containsTreatmentLabels"] == "true" {
                    monitoredList = treatment["monitored"]!
                }
            }
        }
        
    let arrayOfTF = [oneTreatmentTF,twoTreatmentTF,threeTreatmentTF,fourTreatmentTF,fiveTreatmentTF,
                     sixTreatmentTF,sevenTreatmentTF,eightTreatmentTF,nineTreatmentTF,tenTreatmentTF]
    let arrayTreatment = ["1","2","3","4","5","6","7","8","9","T"]
        
        //add new to previously saved monitored list. previous could be empty ""
    for index in 0..<arrayOfTF.count {
        if arrayOfTF[index]?.text?.isEmpty == false {
            if monitoredList.range(of: arrayTreatment[index] ) != nil { /* Has Value */ }
            else { monitoredList = monitoredList + arrayTreatment[index] }
            }
    }
    var set = Set<Character>()
    let squeezed = String(monitoredList.filter{ set.insert($0).inserted } )
        monitoredList = squeezed // remove duplicates 123454545666 -> 123456
    }
}
extension addTx {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueaddTxToTxVC" {
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
