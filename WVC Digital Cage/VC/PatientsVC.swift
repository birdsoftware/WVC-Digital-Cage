//
//  PatientsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    //table view
    @IBOutlet weak var patientTable: UITableView!
    
    //segment
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var scopeSegmentControl: UISegmentedControl!
    
    //Container views
    @IBOutlet weak var containerPE: UIView!
    @IBOutlet weak var containerDem: UIView!
    @IBOutlet weak var containerPro: UIView!
    @IBOutlet weak var containerAMPM: UIView!
    
    //hider view
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var hideTrailingLC: NSLayoutConstraint!
    @IBOutlet weak var hideLeadingLC: NSLayoutConstraint!
    @IBOutlet weak var hideBottomLC: NSLayoutConstraint!
    @IBOutlet weak var hideTopLC: NSLayoutConstraint!
    
    //update record view URView
    @IBOutlet weak var URview: UIView!
    @IBOutlet weak var uRVTrailingLC: NSLayoutConstraint!
    @IBOutlet weak var uRVLeadingLC: NSLayoutConstraint!
    @IBOutlet weak var uRVBottomLC: NSLayoutConstraint!
    @IBOutlet weak var uRVTopLC: NSLayoutConstraint!
    
    //labels
    @IBOutlet weak var walkMeLabel: UILabel!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var patientIDLabel: UILabel!
    
    //buttons
    @IBOutlet weak var kennelNumberButton: RoundedButton!
    
    //search bar
    @IBOutlet weak var patientSearchBar: UISearchBar!
    
    //table data
    var patients:Array<Dictionary<String,String>> =
        [
            ["patientID":"804347","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804348","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804349","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804350","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804351","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""],
         ["patientID":"804352","kennelID":"1","Status":"Active", "intakeDate":"10/12/2017","owner":"Henderson","walkDate":""]]
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    
    var SearchData = Array<Dictionary<String,String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tapDismissKeyboard()
        setUpUI()
        //Delegates
        patientTable.delegate = self
        patientTable.dataSource = self
        //search delegate
        patientSearchBar.delegate = self
        SearchData=patientRecords

        //keyboard notification for update patient record
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
    //#MARK - Actions
    @IBAction func segmentControlAction(_ sender: Any) {
        changeSegmentAction()
    }
    @IBAction func walkMeAction(_ sender: Any) {
        //walkMeLabel
        //timer value exits? creat new : reset time
        updateWalkTime()
    }
    @IBAction func scopeSegmentAction(_ sender: Any) {
        var scopePredicate:NSPredicate
        switch scopeSegmentControl.selectedSegmentIndex
        {
        case 0://All
            SearchData=patientRecords
            patientTable.reloadData()
        case 1://Canine
            scopePredicate = NSPredicate(format: "SELF.group MATCHES[cd] %@", "Canine")
            predicateFilter(scopePredicate:scopePredicate)
        case 2://Feline
            scopePredicate = NSPredicate(format: "SELF.group MATCHES[cd] %@", "Feline")
            predicateFilter(scopePredicate:scopePredicate)
        case 3://Other
            scopePredicate = NSPredicate(format: "SELF.group MATCHES[cd] %@", "Other")
            predicateFilter(scopePredicate:scopePredicate)
        default:
            break;
        }
    }
    @IBAction func saveUPRAction(_ sender: Any) {
        hideUpdateRecordView()
    }
    @IBAction func closeUPRAction(_ sender: Any) {
        hideUpdateRecordView()
    }
}
extension PatientsVC {
    // #MARK: - SEARCH
    func predicateFilter(scopePredicate:NSPredicate){
        let arr=(patientRecords as NSArray).filtered(using: scopePredicate)
        if arr.count >= 0
        {
            SearchData=arr as! Array<Dictionary<String,String>>
        } else {
            SearchData=patientRecords
        }
        patientTable.reloadData()
        viewTitle.text = "My Active Patients (\(SearchData.count))"
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let patientIdPredicate = NSPredicate(format: "SELF.patientID CONTAINS[cd] %@", searchText)
        let intakeDatePredicate = NSPredicate(format: "SELF.intakeDate CONTAINS[cd] %@", searchText)
        let ownerPredicate = NSPredicate(format: "SELF.owner CONTAINS[cd] %@", searchText)
        
        let orPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [patientIdPredicate, intakeDatePredicate, ownerPredicate])
        
        predicateFilter(scopePredicate:orPredicate)//<- reload table occurs in this function

        viewTitle.text = "My Active Patients (\(SearchData.count))"
    }
}
extension PatientsVC {
    // #MARK: - UI Hide Keyboard
    func tapDismissKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PatientsVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){ view.endEditing(true) }
    // #MARK: - When Keyboard hides DO: Move text view up
    @objc func keyboardWillShow(sender: NSNotification){
        showUpdateRecordView()
    }// #MARK: - When Keyboard shws DO: Move text view down
    @objc func keyboardWillHide(sender: NSNotification){

    }
    // #MARK: - UI Set Up
    func setUpUI(){
        containerPE.isHidden = false
        containerDem.isHidden = true
        containerPro.isHidden = true
        containerAMPM.isHidden = true
        viewTitle.text = "My Active Patients (\(patientRecords.count))"
        showHideView()
        hideUpdateRecordView()
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
    func showHideView(){
        hideView.isHidden = false
        hideTrailingLC.constant = 0
        hideLeadingLC.constant = 2
        hideBottomLC.constant = 0
        hideTopLC.constant = 0
    }
    func hideHideView(){
        hideView.isHidden = true
    }
    func showUpdateRecordView(){
        URview.isHidden = false
        uRVTopLC.constant = 0
        uRVBottomLC.constant = 0
        uRVLeadingLC.constant = 0
        uRVTrailingLC.constant = 0
    }
    func hideUpdateRecordView(){
        URview.isHidden = true
    }
}
extension PatientsVC {
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData.count//patientRecords.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: PatientTableView = tableView.dequeueReusableCell(withIdentifier: "patientCell") as! PatientTableView
        let thisPatient = SearchData[IndexPath.row]//patientRecords[IndexPath.row]
        cell.intakeDate.text = thisPatient["intakeDate"]
        cell.patientId.text = thisPatient["patientID"]
        cell.kennelID.text = thisPatient["kennelID"]
        cell.status.text = thisPatient["Status"]
        cell.owner.text = thisPatient["owner"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .checkmark
//        }
        var selectedData:Dictionary<String,String> = SearchData[indexPath.row]
        hideHideView()
//        let intakeDate = selectedData["intakeDate"]!
        let patientID = selectedData["patientID"]!
        patientIDLabel.text = patientID
        let kennelID = selectedData["kennelID"]!
        kennelNumberButton.setTitle(kennelID, for: .normal)
//        let status = selectedData["Status"]!
//        let owner = selectedData["owner"]!
        
        //print("intakeDate: \(intakeDate), patientID: \(patientID), kennelID: \(kennelID), status: \(status), owner: \(owner)")
//   UserDefaults.standard.set(selectedUsers, forKey: "connectSelectedUsers")
//     UserDefaults.standard.synchronize()
//       selectedUsereTableView.reloadData()
//     }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("Edit button tapped")
        }
        edit.backgroundColor = UIColor.orange
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //self.selectedRow = indexPath.row
            //self.removeMedication(indexPath: indexPath, typeString: "Delete")
            //self.medicationData.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            //3. Update UI
            self.patientRecords.remove(at: indexPath.row)//self.selectedRow)
            self.patientTable.deleteRows(at: [indexPath], with: .fade)
            UserDefaults.standard.set(self.patientRecords, forKey: "patientRecords")
            UserDefaults.standard.synchronize()
            print("Delete button tapped")
        }
        delete.backgroundColor = UIColor.red
        let archive = UITableViewRowAction(style: .normal, title: "Archive") { action, index in
            //self.isEditing = false
            print("Archive button tapped")
            self.patientRecords[indexPath.row]["Status"] = "Archive"
            UserDefaults.standard.set(self.patientRecords, forKey: "patientRecords")
            UserDefaults.standard.synchronize()
            self.SearchData = self.patientRecords
            self.patientTable.reloadData()
        }
        archive.backgroundColor = UIColor.blue
        return [edit, delete, archive]
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
