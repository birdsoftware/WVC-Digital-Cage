//
//  PatientsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //table view
    @IBOutlet weak var patientTable: UITableView!
    
    //segment
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    //Container views
    @IBOutlet weak var containerPE: UIView!
    @IBOutlet weak var containerDem: UIView!
    @IBOutlet weak var containerPro: UIView!
    @IBOutlet weak var containerAMPM: UIView!
    
    @IBOutlet weak var walkMeLabel: UILabel!
    
    //table data
    var patients:Array<Dictionary<String,String>> =
        [
            ["patientID":"804347","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804348","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804349","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804350","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804351","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804352","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapDismissKeyboard()
        setUpUI()
        //Delegates
        patientTable.delegate = self
        patientTable.dataSource = self
    }
    //#MARK - Actions
    @IBAction func segmentControlAction(_ sender: Any) {
        changeSegmentAction()
    }
    @IBAction func walkMeAction(_ sender: Any) {
        //walkMeLabel
        //timer value exits? creat new : reset time
        updateWalkTime()
    }
    
}
extension PatientsVC {
    // #MARK: - UI Hide Keyboard
    func tapDismissKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PatientsVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){ view.endEditing(true) }
    // #MARK: - UI Set Up
    func setUpUI(){
        containerPE.isHidden = false
        containerDem.isHidden = true
        containerPro.isHidden = true
        containerAMPM.isHidden = true
    }
    func updateWalkTime(){
        let patientID = "804348"
        for index in 0..<patients.count {
            if patients[index]["patientID"] == patientID {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let nowString = formatter.string(from: Date())
                
                if patients[index]["walkDate"] == "" {
                    patients[index]["walkDate"] = nowString
                    walkMeLabel.text = nowString
                } else {
                    let yourDateString = patients[index]["walkDate"]// = "< hour"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let lastWalkDate = dateFormatter.date(from: yourDateString!)
                    walkMeLabel.text = lastWalkDate!.timeAgo()
                    
                    patients[index]["walkDate"] = nowString
                }
            }
        }
    }
}
extension PatientsVC {
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return patients.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: PatientTableView = tableView.dequeueReusableCell(withIdentifier: "patientCell") as! PatientTableView
        let thisPatient = patients[IndexPath.row]

        cell.intakeDate.text = thisPatient["intakeDate"]
        cell.patientId.text = thisPatient["patientID"]
        cell.kennelID.text = thisPatient["kennelID"]
        cell.status.text = thisPatient["Status"]
        cell.owner.text = thisPatient["owner"]
        
        //cell.accessoryType = .disclosureIndicator // add arrow > to cell
        
        return cell
    }
}
extension PatientsVC {
    // #MARK: - Segment Functions
    func changeSegmentAction(){
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            containerPE.isHidden = false
            containerDem.isHidden = true
            containerPro.isHidden = true
            containerAMPM.isHidden = true
        case 1:
            containerPE.isHidden = true
            containerDem.isHidden = false
            containerPro.isHidden = true
            containerAMPM.isHidden = true
        case 2:
            containerPE.isHidden = true
            containerDem.isHidden = true
            containerPro.isHidden = false
            containerAMPM.isHidden = true
        case 3:
            containerPE.isHidden = true
            containerDem.isHidden = true
            containerPro.isHidden = true
            containerAMPM.isHidden = false
        default:
            break;
        }
    }
}
