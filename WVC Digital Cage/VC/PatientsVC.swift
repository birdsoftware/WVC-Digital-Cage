//
//  PatientsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit
import Foundation
import MessageUI //send email

class PatientsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate /*photoLib*/,
UINavigationControllerDelegate/*photoLib*/, UITextFieldDelegate {

    //Walk Alert animation image
    @IBOutlet weak var runningDogImage: UIImageView!
    @IBOutlet weak var walkAlertView: UIView!
    @IBOutlet weak var vitalsGrayBoxView: UIView!
    
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
    
    //labels
    @IBOutlet weak var walkMeLabel: UILabel!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var patientIDLabel: UILabel!
    @IBOutlet weak var pdfLabel: UILabel!
    
    //test fields
    @IBOutlet weak var temperature: UITextField!
    @IBOutlet weak var pulse: UITextField!
    @IBOutlet weak var cRT_MM: UITextField!
    @IBOutlet weak var respiration: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var exitWeight: UITextField!
    @IBOutlet weak var initialsVitals: UITextField!
    
      //buttons
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var kennelNumberButton: RoundedButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var screenShareButton: UIButton!
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var thirdButton: RoundedButton!
    @IBOutlet weak var cautionButton: UIButton!
    
    @IBOutlet weak var patientPicture: UIImageView!
    
    //search bar
    @IBOutlet weak var patientSearchBar: UISearchBar!
    
    //Boolean Flags
    var searchActive = false
    var shareActive = false
    var emailActive = false
    
    //segue data
    var seguePatientID:String!
    
    //table data
    var patientID = ""
    var selectedData = Dictionary<String,String>()
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    
    var missingPatientIDs = UserDefaults.standard.object(forKey: "missingPatientIDs") as? [String] ?? []
    
    var SearchData = Array<Dictionary<String,String>>()
    
    var imagePickerController : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldsDelegates()
        setUpUI()
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPatientsTable),
                                               name: NSNotification.Name(rawValue: "refreshPatientsTable"),
                                               object: nil)
        segmentControl.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0)], for: .normal)
        scopeSegmentControl.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0)], for: .normal)
    }
    override func viewDidAppear(_ animated: Bool){//SEGUE FROM VIEW 2 - UPDATE UI
        if let seguePatientID = seguePatientID {
            func indexOfPatients(pid: String) -> Int {
                return SearchData.index { (patient) -> Bool in
                    return patient["patientID"] == pid
                    } ?? NSNotFound
            }
            let indexOfSeguePatient = indexOfPatients(pid: seguePatientID)
            let path = NSIndexPath(row: indexOfSeguePatient, section: 0)
            patientTable.selectRow(at: path as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
            selectedData = SearchData[indexOfSeguePatient]
            hideHideView()
            //UPDATE UI VALUES
            shareButton.isHidden = false
            pdfLabel.isHidden = false
            screenShareButton.isHidden = false
            patientID = selectedData["patientID"]!
            UserDefaults.standard.set(patientID, forKey: "selectedPatientID")
            UserDefaults.standard.synchronize()
            showVitals(pid:patientID)
            getImage(imageName: patientID + ".png", imageView: patientPicture)
            patientIDLabel.text = patientID
            let kennelID = selectedData["kennelID"]!
            kennelNumberButton.setTitle(kennelID, for: .normal)
            if selectedData["walkDate"]! != ""{
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let yourDateString = selectedData["walkDate"]!
                let lastWalkDate = formatter.date(from: yourDateString)
                walkMeLabel.text = lastWalkDate!.timeAgo()
            } else {
                walkMeLabel.text = "not yet"
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPhysicalExam"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showDemographics"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAmpm"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showProcedure"), object: nil)
            setBadges()
        }
    }
    //#MARK - Actions
    @IBAction func segmentControlAction(_ sender: Any) {
        changeSegmentAction()
    }
    @IBAction func walkMeAction(_ sender: Any) {
        starWalkAlert()
    }
    @IBAction func takePhotoAction(_ sender: Any) {
        //TAKR Patient Picture
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func scopeSegmentAction(_ sender: Any) {
        var scopePredicate:NSPredicate
        switch scopeSegmentControl.selectedSegmentIndex
        {
        case 0://All
            SearchData=patientRecords
            SearchData.sort { $0["kennelID"]! < $1["kennelID"]! }
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
    @IBAction func shareScreenAction(_ sender: Any) {
        shareActive = true
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.view.drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let activityViewController = UIActivityViewController(activityItems: ["DCC App Screen Grab",img!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView//self.view
        activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed { // User canceled
                self.shareActive = false
                return
            } // User completed activity
            self.shareActive = false
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func shareAction(_ sender: Any) {
        shareActive = true
        //generate file path then pdf to attach
        let pdfPathWithFile = generatePDFFile(patientData: selectedData)
        // set up activity view controller
        let document = NSData(contentsOfFile: pdfPathWithFile)
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: ["DCC App PDF Post",document!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView//self.view
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [UIActivityType.markupAsPDF]
        activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed { // User canceled
                self.shareActive = false
                return
            } // User completed activity
            self.shareActive = false
        }
        present(activityViewController, animated: true, completion: nil)
    }
    //Walk Animation View Actions
    @IBAction func yesWalkAction(_ sender: Any) {
        //timer value exits? creat new : reset time
        self.updateWalkTime()
        self.removeNotification(code: "1", patientID: self.patientID) //TOCHECK:::
        self.removeNotification(code: "2", patientID: self.patientID) //TOCHECK:::
        self.closeWalkAlert()
        
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2, animations: {
                self.vitalsGrayBoxView.backgroundColor = UIColor.WVCActionBlue()
            })
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                self.vitalsGrayBoxView.backgroundColor = UIColor.lightGrey()
            })
        }, completion: { completed in
            
        })
        
    }
    @IBAction func noWalkAction(_ sender: Any) {
        closeWalkAlert()
    }
}
extension PatientsVC {
    // #MARK: - SEARCH
    func predicateFilter(scopePredicate:NSPredicate){
        let arr=(patientRecords as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            SearchData=arr as! Array<Dictionary<String,String>>
        } else {
            SearchData=patientRecords
        }
        SearchData.sort { $0["kennelID"]! < $1["kennelID"]! } //might be slow!!!
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
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        searchBar.endEditing(true)
        SearchData=patientRecords
        SearchData.sort { $0["kennelID"]! < $1["kennelID"]! }
        patientTable.reloadData()
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
        if searchActive == false && emailActive == false && shareActive == false{
        }
    }// #MARK: - When Keyboard shws DO: Move text view down
    @objc func keyboardWillHide(sender: NSNotification){
    }
    @objc func refreshPatientsTable(){
        missingPatientIDs = UserDefaults.standard.object(forKey: "missingPatientIDs") as? [String] ?? []
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        SearchData = patientRecords
        SearchData.sort { $0["kennelID"]! < $1["kennelID"]! }
        patientTable.reloadData()
    }
    // #MARK: - UI Set Up
    func setUpUI(){
        containerPE.isHidden = false
        containerDem.isHidden = true
        containerPro.isHidden = true
        containerAMPM.isHidden = true
        shareButton.isHidden = true
        pdfLabel.isHidden = true
        screenShareButton.isHidden = true
        viewTitle.text = "My Active Patients (\(patientRecords.count))"
        showHideView()
        //Delegates
        patientTable.delegate = self
        patientTable.dataSource = self
        //search delegate
        patientSearchBar.delegate = self
        SearchData=patientRecords
        SearchData.sort { $0["kennelID"]! < $1["kennelID"]! }
    }
    func updateWalkTime(){
        //let patientID = "804348"
        for index in 0..<patientRecords.count {
            if patientRecords[index]["patientID"] == patientID {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //get date now
                let nowString = formatter.string(from: Date())
                patientRecords[index]["walkDate"] = nowString//update instance
                walkMeLabel.text = Date().timeAgo()//update UI
                UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
                UserDefaults.standard.synchronize()//save instance
                SearchData = patientRecords//update search
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
}
extension PatientsVC {
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: PatientTableView = tableView.dequeueReusableCell(withIdentifier: "patientCell") as! PatientTableView
        let thisPatient = SearchData[IndexPath.row]
        cell.intakeDate.text = thisPatient["intakeDate"]
        cell.patientId.text = thisPatient["patientID"]
        cell.kennelID.text = thisPatient["kennelID"]
        cell.status.text = thisPatient["status"]
        cell.owner.text = thisPatient["owner"]
        let image = returnImage(imageName: thisPatient["patientID"]! + ".png")
        cell.dogPhoto.image = image
        switch thisPatient["group"]! {
            case "Canine":
                cell.dogPhotoFrame.image = UIImage(named: "circle_red")
            case "Feline":
                cell.dogPhotoFrame.image = UIImage(named: "circle_fern")
            case "Other":
                cell.dogPhotoFrame.image = UIImage(named: "circle_seaBuckthorn")
        default: break
        }
        if missingPatientIDs.contains(thisPatient["patientID"]!){
            cell.missingPiece.isHidden = false
        } else { cell.missingPiece.isHidden = true }
        if thisPatient["status"] == "Archive" {
            cell.backgroundColor = UIColor.polar()
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .checkmark
//        }
        selectedData = SearchData[indexPath.row]
        hideHideView()
        //UPDATE UI VALUES
        shareButton.isHidden = false
        pdfLabel.isHidden = false
        screenShareButton.isHidden = false
        patientID = selectedData["patientID"]!
        UserDefaults.standard.set(patientID, forKey: "selectedPatientID")
        UserDefaults.standard.synchronize()
        print("patientID: \(patientID)")
        showVitals(pid:patientID)
        getImage(imageName: patientID + ".png", imageView: patientPicture)
        //showPhysicalExam(pid:patientID)
        patientIDLabel.text = patientID
        let kennelID = selectedData["kennelID"]!
        kennelNumberButton.setTitle(kennelID, for: .normal)
        if selectedData["walkDate"]! != ""{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let yourDateString = selectedData["walkDate"]!
            let lastWalkDate = formatter.date(from: yourDateString)
            walkMeLabel.text = lastWalkDate!.timeAgo()
        } else {
            walkMeLabel.text = "not yet"
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPhysicalExam"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showDemographics"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAmpm"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showProcedure"), object: nil)
        setBadges()
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
        let email = UITableViewRowAction(style: .normal, title: "Email") { action, index in
            print("Email button tapped")
            self.emailButtonTapped(indexPathRow: indexPath.row)
        }
        email.backgroundColor = UIColor.orange
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("Delete button tapped")
            //self.deleteButtonTapped(indexPath: indexPath)
            self.deleteRecordAlert(title:"Are you sure you want to remove this Patient?", message:"This will forever remove all records for this patient.", buttonTitle:"OK", cancelButtonTitle: "Cancel", indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        let archive = UITableViewRowAction(style: .normal, title: "Archive") { action, index in
            print("Archive button tapped")
            self.archiveButtonTapped(indexPath: indexPath)
        }
        archive.backgroundColor = UIColor.blue
        return [email, delete, archive]
    }
    func emailButtonTapped(indexPathRow: Int){
        let selectedData:Dictionary<String,String> = self.SearchData[indexPathRow]
        self.sendEmailWithAttachemnt(patientData: selectedData)
    }
    func deleteButtonTapped(indexPath: IndexPath){
        let removeForThisPID = self.patientRecords[indexPath.row]["patientID"]
        
        self.removeVitalsFor(patientID:removeForThisPID!)
        self.removePhysicalExamFor(patientID:removeForThisPID!)
        self.removeDemographicsFor(patientID:removeForThisPID!)
        self.removeProcedure(patientID:removeForThisPID!)
        self.removeIncisions(patientID:removeForThisPID!)
        self.removeAMPM(patientID:removeForThisPID!)
        self.removeAllNotificationFor(patientID:removeForThisPID!)
        self.deleteImage(imageName: removeForThisPID!+".png")
        self.showHideView()
        self.patientRecords.remove(at: indexPath.row)
        UserDefaults.standard.set(self.patientRecords, forKey: "patientRecords")
        UserDefaults.standard.synchronize()
        self.SearchData = self.patientRecords
        self.patientTable.deleteRows(at: [indexPath], with: .fade)
    }
    func archiveButtonTapped(indexPath: IndexPath){
        print("Archive button tapped")
        self.patientRecords[indexPath.row]["status"] = "Archive"
        UserDefaults.standard.set(self.patientRecords, forKey: "patientRecords")
        UserDefaults.standard.synchronize()
        self.SearchData = self.patientRecords
        self.SearchData.sort { $0["kennelID"]! < $1["kennelID"]! }
        self.patientTable.reloadData()
    }
    func deleteRecordAlert(title:String, message:String,
                           buttonTitle:String,
                           cancelButtonTitle: String,
                           indexPath: IndexPath) {
        
        let myAlert = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        myAlert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {
            alert -> Void in
            //DO:
            self.deleteButtonTapped(indexPath: indexPath)
        }))
        
        myAlert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in })
        
        present(myAlert, animated: true){}
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
extension PatientsVC {
    // #MARK: - Save Vitals, Show Vitals, Remove Vitals
    func saveVitals(){
        var patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        let newV:Dictionary<String,String> =
            [
            "patientID":patientID,
            "temperature":temperature.text!,
            "pulse":pulse.text!,
            "cRT_MM":cRT_MM.text!,
            "respiration":respiration.text!,
            "weight":weight.text!,
            "exitWeight":exitWeight.text!,
            "initialsVitals":initialsVitals.text!
            ]
        var found = false
        if patientVitals.isEmpty {//create new record/TABLE if DNE
            UserDefaults.standard.set([newV], forKey: "patientVitals")
            UserDefaults.standard.synchronize()
        } else {
            for index in 0..<patientVitals.count {
                if patientVitals[index]["patientID"] == patientID {//UPDATE by PID
                    patientVitals[index]["temperature"] = temperature.text!
                    patientVitals[index]["pulse"] = pulse.text!
                    patientVitals[index]["cRT_MM"] = cRT_MM.text!
                    patientVitals[index]["respiration"] = respiration.text!
                    patientVitals[index]["temperature"] = temperature.text!
                    patientVitals[index]["weight"] = weight.text!
                    patientVitals[index]["exitWeight"] = exitWeight.text!
                    patientVitals[index]["initialsVitals"] = initialsVitals.text!
                    UserDefaults.standard.set(patientVitals, forKey: "patientVitals")
                    UserDefaults.standard.synchronize()
                    found = true
                    return
                }
            }
            if found == false {//APPEND NEW
                patientVitals.append(newV)
                UserDefaults.standard.set(patientVitals, forKey: "patientVitals")
                UserDefaults.standard.synchronize()
            }
        }
    }
    func showVitals(pid:String){
        var patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        //print("patientVitals:\(patientVitals)")
        for index in 0..<patientVitals.count {
            //print("\(patientVitals[index]["patientID"]) \(pid)")
            if patientVitals[index]["patientID"] == pid {
                temperature.text = patientVitals[index]["temperature"]
                pulse.text = patientVitals[index]["pulse"]
                cRT_MM.text = patientVitals[index]["cRT_MM"]
                respiration.text = patientVitals[index]["respiration"]
                temperature.text = patientVitals[index]["temperature"]
                weight.text = patientVitals[index]["weight"]
                exitWeight.text = patientVitals[index]["exitWeight"]
                initialsVitals.text = patientVitals[index]["initialsVitals"]
                return
            }
            else {
                temperature.text = ""
                pulse.text = ""
                cRT_MM.text = ""
                respiration.text = ""
                temperature.text = ""
                weight.text = ""
                exitWeight.text = ""
                initialsVitals.text = ""
            }
        }
    }
    func removeVitalsFor(patientID:String){
        var patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        if let index = dictIndexFrom(array: patientVitals, usingKey:"patientID", usingValue: patientID) {
            patientVitals.remove(at: index)
            print("removed patientVitals \(patientVitals.count)")
            UserDefaults.standard.set(patientVitals, forKey: "patientVitals")
            UserDefaults.standard.synchronize()
        }
    }
    func removePhysicalExamFor(patientID:String){
        var patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        if let index = dictIndexFrom(array: patientPhysicalExam, usingKey: "patientID", usingValue: patientID) {
            patientPhysicalExam.remove(at: index)
            print("removed patientPhysicalExam \(patientPhysicalExam.count)")
            UserDefaults.standard.set(patientPhysicalExam, forKey: "patientPhysicalExam")
            UserDefaults.standard.synchronize()
        }
    }
    func removeDemographicsFor(patientID:String){
        var demographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
        if let index = dictIndexFrom(array: demographics, usingKey: "patientID", usingValue: patientID) {
            demographics.remove(at: index)
            print("removed demographics \(demographics.count)")
            UserDefaults.standard.set(demographics, forKey: "demographics")
            UserDefaults.standard.synchronize()
        }
    }
    func removeProcedure(patientID:String){
        var procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
        if let index = dictIndexFrom(array: procedures, usingKey: "patientID", usingValue: patientID) {
            procedures.remove(at: index)
            print("removed procedures \(procedures.count)")
            UserDefaults.standard.set(procedures, forKey: "procedures")
            UserDefaults.standard.synchronize()
        }
    }
    //REMOVE 1 OR MORE MATCHES
    func removeAMPM(patientID:String){
        let ampms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        var ampmRecordsWithPatientID = Array<Dictionary<String,String>>()
        let scopePredicate = NSPredicate(format: "SELF.patientID !=[cd] %@", patientID)
        let arr=(ampms as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            ampmRecordsWithPatientID=arr as! Array<Dictionary<String,String>>
        } else {
            ampmRecordsWithPatientID=ampms
        }
        print("removed ampms \(ampmRecordsWithPatientID.count)")
        UserDefaults.standard.set(ampmRecordsWithPatientID, forKey: "ampms")
        UserDefaults.standard.synchronize()
    }
    func removeIncisions(patientID:String){
        let incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
        var incisionsWithPatientID = Array<Dictionary<String,String>>()
        let scopePredicate = NSPredicate(format: "SELF.patientID !=[cd] %@", patientID)
        let arr=(incisions as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            incisionsWithPatientID=arr as! Array<Dictionary<String,String>>
        } else {
            incisionsWithPatientID=incisions
        }
        print("removed incisions \(incisionsWithPatientID.count)")
        UserDefaults.standard.set(incisionsWithPatientID, forKey: "incisions")
        UserDefaults.standard.synchronize()
    }
    func removeAllNotificationFor(patientID: String) {
        let notifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
        var notificationsWithPatientID = Array<Dictionary<String,String>>()
        let scopePredicate = NSPredicate(format: "SELF.patientID !=[cd] %@", patientID)//"SELF.patientID MATCHES[cd] %@"
        let arr=(notifications as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            notificationsWithPatientID=arr as! Array<Dictionary<String,String>>
        } else {
            notificationsWithPatientID=notifications
        }
        print("removed notifications \(notificationsWithPatientID.count)")
        UserDefaults.standard.set(notificationsWithPatientID, forKey: "notifications")
        UserDefaults.standard.synchronize()
    }
}
extension PatientsVC{
    // MARK: - Email
    func sendEmailWithAttachemnt(patientData: Dictionary<String,String>){
        
        emailActive = true
        
        let savedUserEmailAddress = UserDefaults.standard.string(forKey: "userEmailAddress") ?? ""
        
        let patientID = patientData["patientID"]!
        let emailMessage = "<p> Please see attached PDF for Patient: " + patientID + " </p>"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setToRecipients([savedUserEmailAddress])//"bbirdunlv@yahoo.com","b.bird@wvc.org"])
            mail.setSubject("WVC DCC Patient: " + patientID)
            mail.setMessageBody(emailMessage, isHTML: true)
            
            let pdfPathWithFile = generatePDFFile(patientData: patientData)
            let fileData = NSData(contentsOfFile:pdfPathWithFile)
            mail.addAttachmentData(fileData! as Data, mimeType: "application/pdf", fileName: "test.pdf")
            self.present(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Could Not Send Email", message:"Your device must have an acctive mail account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
        }
    }
    // #MARK: -  Dismiss Email Controller
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        emailActive = false
        controller.dismiss(animated: true, completion: nil)
    }
    // #MARK: - Generate PDF File
    func generatePDFFile(patientData: Dictionary<String,String>) -> String {
        // 1. Generate file path then pdf to attach ---
        let fileName: NSString = "test.pdf" as NSString
        
        let path:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = path.object(at: 0) as! NSString
        let pdfPathWithFile = documentDirectory.appendingPathComponent(fileName as String)
        
        // 2. Generate PDF with file path ---
        UIGraphicsBeginPDFContextToFile(pdfPathWithFile, CGRect.zero, nil)
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
        drawBackground()
        drawImageLogo(imageName: "WVCLogog")
        drawPatientRecordText(patientData: patientData)
        let patientIDHere = patientData["patientID"]
        drawPatientPicture(imageName: patientIDHere! + ".png")
        drawVitalsText(patientID:patientIDHere!)
        drawPhysicalExam(patientID:patientIDHere!)
        drawDemographicsText(patientID:patientIDHere!)
        drawIncisions(patientID:patientIDHere!)
        drawProcedures(patientID:patientIDHere!)
        drawAMPMs(patientID:patientIDHere!)
        UIGraphicsEndPDFContext()
        
        return pdfPathWithFile
    }
    // PDF HEADER, BACHGROUND, LOGO ```````````````````````````````` PDF
    func drawBackground () {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        let rect:CGRect = CGRect(x:0, y:0, width:850, height:1100)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
    }
    func drawImageLogo(imageName: String) {
        let imageRect:CGRect = CGRect(x:350, y:30, width:200, height:63)
        let image = UIImage(named: imageName)
        
        image?.draw(in: imageRect)
    }
    func drawPatientPicture(imageName: String) {
    let imageRect:CGRect = CGRect(x:40, y:120, width:170, height:170)
    let image = returnImage(imageName: imageName)
    
    image.draw(in: imageRect)
    }
    // COLUMN 1 - Procedures & AM/PMs
    func drawProcedures(patientID:String){
        let procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
        var proc = Dictionary<String,String>()
        if let index = dictIndexFrom(array: procedures, usingKey:"patientID", usingValue: patientID) {
            proc = procedures[index]
        }
        for item in proc {
            if item.value == "false" {
                proc[item.key] = "No"
            }
            if item.value == "true" {
                proc[item.key] = "Yes"
            }
        }
        if arrayContains(array:procedures, value:patientID) {//check if patient has incision
            let titleTopString = "Procedure"
            var newTotalY = 300
            let xCol1 = 40 /*let xCol2 = 250 let xCol3 = 500*/
            let textRecWidth = 200
            let titleTop = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:40)
            titleTopString.draw(in: titleTop, withAttributes: returnTitle1Attributes())
            
            let titles = ["lab", "bloodWork", "radiographs", "surgeryDate", "suture"]
            var title = CGRect()
            var value = CGRect()
            let spacerTwenty = 20
            newTotalY += 10

            for item in titles {
                let word = item.camelCaseToWords()
                let uppercased = word.firstUppercased + ":"
                newTotalY += spacerTwenty
                title = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:40)
                newTotalY += spacerTwenty
                value = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:60)
                uppercased.draw(in: title, withAttributes: returnTitleAttributes())
                proc[item]?.draw(in: value, withAttributes: returnTextAttributes())
            }
        }
    }
    func drawIncisions(patientID:String){//REPEATING
        let allInc = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
        var nextInc = Dictionary<String,String>()
        
        if arrayContains(array:allInc, value:patientID) {//check if patient has incision
            let titleTopString = "Incision Checked"
            var newTotalY = 100+300+160
            let xCol1 = 40 /*let xCol2 = 250 let xCol3 = 500*/
            let textRecWidth = 300
            let titleTop = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:40)
            titleTopString.draw(in: titleTop, withAttributes: returnTitle1Attributes())
            
            let titles = ["date", "initials"]
            var title = CGRect()
            var value = CGRect()
            let spacerTwenty = 20
            newTotalY += 10
            for dict in allInc {
                if dict["patientID"] == patientID {
                    nextInc = dict
                    for item in titles {
                        let word = item.camelCaseToWords()
                        let uppercased = word.firstUppercased + ":"
                        newTotalY += spacerTwenty
                        title = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:65)
                        //newTotalY += spacerTwenty
                        value = CGRect(x: xCol1+65, y:newTotalY, width:textRecWidth, height:75)
                        uppercased.draw(in: title, withAttributes: returnTitleAttributes())
                        nextInc[item]?.draw(in: value, withAttributes: returnTextAttributes())
                    }
                }
            }
        }
    }
    // COLUMN 2 - records, vitals, demographics
    func drawPatientRecordText(patientData: Dictionary<String,String>){
        let titles = ["patientID","status","intakeDate","owner"]
        
        /*let xCol1 = 50*/ var xCol2 = 270 /*let xCol3 = 550*/
        var newTotalY = 110
        let textRecWidth = 200
        let spacerTwenty = 20
        
        var title = CGRect()
        var value = CGRect()
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            newTotalY += spacerTwenty
            title = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:40)
            //newTotalY += spacerTwenty
            if item == "owner"{ xCol2 -= 100; newTotalY += spacerTwenty}
            value = CGRect(x: xCol2+100, y:newTotalY, width:textRecWidth, height:80)
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            patientData[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
    }
    func drawVitalsText(patientID:String){
        let titles = ["temperature","pulse","cRT_MM","respiration","weight","exitWeight","initialsVitals"]
        let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        var vitalData = Dictionary<String,String>()
        for vital in patientVitals {
            if vital["patientID"] == patientID {
                vitalData = vital
                if vitalData["temperature"] != "" { vitalData["temperature"] = vitalData["temperature"]! + " °F" }
                if vitalData["weight"] != "" {vitalData["weight"] = vitalData["weight"]! + " Kg"}
                if vitalData["exitWeight"] != "" {vitalData["exitWeight"] = vitalData["exitWeight"]! + " Kg"}
            }
        }
        //set up columns for 850 by 1100 page
        let logoHeight = 170
        let spacerFifty = 50
        let spacerTwenty = 20
        /*let xCol1 = 50*/ let xCol2 = 270 /*let xCol3 = 550*/
        let textRecWidth = 200
        var newTotalY = logoHeight+spacerFifty + spacerTwenty
        
        var title = CGRect()
        var value = CGRect()
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            newTotalY += spacerTwenty
            title = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:40)
            //newTotalY += spacerTwenty
            value = CGRect(x: xCol2+120, y:newTotalY, width:textRecWidth, height:80)
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            vitalData[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
    }
        func drawDemographicsText(patientID:String){
            var dems = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
            var demDict = Dictionary<String,String>()
            if let index = dictIndexFrom(array: dems, usingKey:"patientID", usingValue: patientID) {
                demDict = dems[index]
            }
            for item in demDict {
                if item.value == "false" { demDict[item.key] = "male" }
                if item.value == "true" { demDict[item.key] = "female" }
            }
            /*let xCol1 = 50*/ let xCol2 = 270 /*let xCol3 = 550*/ //850 by 1100 page
            var newTotalY = 100+300
            let textRecWidth = 200
            let spacerTwenty = 20
            
            let titles = ["age","breed","sex"]
            
            var title = CGRect()
            var value = CGRect()
            for item in titles {
                let word = item.camelCaseToWords()
                let uppercased = word.firstUppercased + ":"
                newTotalY += spacerTwenty
                title = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:40)
                //newTotalY += spacerTwenty
                value = CGRect(x: xCol2+60, y:newTotalY, width:textRecWidth, height:80)
                uppercased.draw(in: title, withAttributes: returnTitleAttributes())
                demDict[item]?.draw(in: value, withAttributes: returnTextAttributes())
            }
        }
    func drawAMPMs(patientID:String){//REPEATING
        var allAMPM = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        allAMPM.sort { $0["date"]! < $1["date"]! }//sort array in place
        var nextAMPM = Dictionary<String,String>()
        
        if arrayContains(array:allAMPM, value:patientID) {//check if patient exists
            let titleTopString = "AM/PM Checked"
            var newTotalY = 300+200
            /*let xCol1 = 40 */var xCol2 = 270 /* let xCol3 = 500*/
            let textRecWidth = 200
            let titleTop = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:40)
            titleTopString.draw(in: titleTop, withAttributes: returnTitle1Attributes())
            
            let titles = ["date","attitude", "feces", "urine", "appetite%", "v/D/C/S", "initials"]
            var title = CGRect()
            var value = CGRect()
            let spacerTwenty = 20
            newTotalY += 10
            for dict in allAMPM {
                if dict["patientID"] == patientID {
                    nextAMPM = dict
                    for item in titles {
                        let word = item.camelCaseToWords()
                        let uppercased = word.firstUppercased + ":"
                        newTotalY += spacerTwenty
                        if newTotalY >= 1050 { xCol2 = 500; newTotalY = 530}
                        title = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:65)
                        //newTotalY += spacerTwenty
                        value = CGRect(x: xCol2+90, y:newTotalY, width:textRecWidth, height:75)
                        uppercased.draw(in: title, withAttributes: returnTitleAttributes())
                        nextAMPM[item]?.draw(in: value, withAttributes: returnTextAttributes())
                    }
                }
            }
        }
    }
    // COLUMN 3 - Draw Physical Exam
    func drawPhysicalExam(patientID:String){
        let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        var physcialExamData = Dictionary<String,String>()
        for pe in patientPhysicalExam {
            if pe["patientID"] == patientID {
                physcialExamData = pe
            }
        }
        for item in physcialExamData {
            if item.value == "false" {
                physcialExamData[item.key] = "Normal"
            }
            if item.value == "true" {
                physcialExamData[item.key] = "Abnormal"
            }
        }
        //set up columns for 850 by 1100 page
        let spacerTwenty = 20
        
        /*let xCol1 = 50 let xCol2 = 250*/ var xCol3 = 500
        var newTotalY = 110 + spacerTwenty
        
        let textRecWidth = 300
        var valueHeight = 75
        
        let titleTop = CGRect(x: xCol3, y:120, width:textRecWidth, height:40)
        let titleTopString = "Physical Examination"
        titleTopString.draw(in: titleTop, withAttributes: returnTitle1Attributes())
        
        let titles = ["generalAppearance", "skinFeetHair", "musculoskeletal", "nose", "digestiveTeeth", "respiratory", "ears", "nervousSystem", "lymphNodes", "eyes", "urogenital", "bodyConditionScore", "comments"]
        
        var title = CGRect()
        var value = CGRect()
        var count = 0
        for item in titles {
            count += 1
            let word = item.camelCaseToWords()
            var uppercased = "\(count) " + word.firstUppercased + ":"
            if count > 12 { uppercased = word.firstUppercased + ":" }
            newTotalY += spacerTwenty
            title = CGRect(x: xCol3, y:newTotalY, width:textRecWidth, height:65)
            //newTotalY += spacerTwenty
            if item == "comments"{ valueHeight = 300; xCol3 -= 200; newTotalY += spacerTwenty}
            value = CGRect(x: xCol3+200, y:newTotalY, width:textRecWidth, height:valueHeight)
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            physcialExamData[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
    }
    // #MARK: - Text Font Attributes
    func returnTitle1Attributes() -> [NSAttributedStringKey: NSObject]{
        let fontTitle = UIFont(name: "Helvetica Bold", size: 19.0)!
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.left
        let textFontAttributes = [
            NSAttributedStringKey.font: fontTitle,
            NSAttributedStringKey.paragraphStyle: textStyle ]
        return textFontAttributes
    }
    func returnTitleAttributes() -> [NSAttributedStringKey: NSObject]{
        let fontTitle = UIFont(name: "Helvetica Bold", size: 16.0)!
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.left
        let textFontAttributes = [
            NSAttributedStringKey.font: fontTitle,
            NSAttributedStringKey.paragraphStyle: textStyle ]
        return textFontAttributes
    }
    func returnTextAttributes() -> [NSAttributedStringKey: NSObject]{
        let font:UIFont = UIFont(name:"Helvetica", size:14)!
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.left
        let textFontAttributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.paragraphStyle: textStyle ]
        return textFontAttributes
    }
}
extension PatientsVC {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCustomNotification" {//
            //let selectedRow = ((inboxTable.indexPathForSelectedRow as NSIndexPath?)?.row)! //returns int
            //var Data = Dictionary<String,String>()//restInbox[selectedRow]
            if let toViewController = segue.destination as? customNotifVC {
                toViewController.segueWhereThisViewWasLanchedFrom = "patientsVC"//
                toViewController.seguePatientID = patientID
            }
        } else if segue.identifier == "segueInjuries" {
            if let toVC = segue.destination as? InjuriesVC {
                toVC.seguePatientID = patientID
            }
        }
    }
}
extension PatientsVC {
    //
    // #MARK: - Image picker form camera
    //          camera delegate func called after take photo
    //          https://appsandbiscuits.com/take-save-and-retrieve-a-photo-ios-13-4312f96793ff
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        // RESIZE IMAGE
        let smallerSizeImage = resizeImage(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!, newWidth: 200)
        // UPDATE UI IMAGE
        patientPicture.image = smallerSizeImage
        // SAVE IMAGE TO APP LOCAL DIR
        saveImage(imageName: patientID + ".png", patientPicture: patientPicture)
        saveImageNameToPatientRecords(imageName: patientID + ".png",  patientID: patientID)
        self.patientTable.reloadData()
    }
}
extension PatientsVC {
    // #MARK: - Setup Text Field Delegates
    func textFieldsDelegates(){
        temperature.delegate = self
        temperature.returnKeyType = UIReturnKeyType.next
        temperature.tag = 0
        pulse.delegate = self
        pulse.returnKeyType = UIReturnKeyType.next
        pulse.tag = 1
        cRT_MM.delegate = self
        cRT_MM.returnKeyType = UIReturnKeyType.next
        cRT_MM.tag = 2
        respiration.delegate = self
        respiration.returnKeyType = UIReturnKeyType.next
        respiration.tag = 3
        weight.delegate = self
        weight.returnKeyType = UIReturnKeyType.next
        weight.tag = 4
        exitWeight.delegate = self
        exitWeight.returnKeyType = UIReturnKeyType.next
        exitWeight.tag = 5
        initialsVitals.delegate = self
        initialsVitals.returnKeyType = UIReturnKeyType.go
        initialsVitals.tag = 6
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= 0 && textField.tag <= 6{
            saveVitals()
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
extension PatientsVC {
    func starWalkAlert(){
        let imagesListArray =
            [UIImage(named: "dog1.png")!,UIImage(named: "dog2.png")!,UIImage(named: "dog3.png")!,UIImage(named: "dog4.png")!,UIImage(named: "dog1.png")!,UIImage(named: "dog2.png")!,UIImage(named: "dog3.png")!,UIImage(named: "dog4.png")!,UIImage(named: "dog1.png")!,UIImage(named: "dog2.png")!,UIImage(named: "dog3.png")!,UIImage(named: "dog4.png")!]
        runningDogImage.animationImages = imagesListArray
        runningDogImage.animationDuration = 2.0
        runningDogImage.startAnimating()
        self.view.bringSubview(toFront: walkAlertView)
        //runningDogImage
        //walkAlertView
        
    }
    func closeWalkAlert(){
        self.view.sendSubview(toBack: walkAlertView)
        runningDogImage.stopAnimating()
    }
}

extension PatientsVC {
    func setBadges() {
        //update badges
        func updateButton(button: UIButton, isNil: String?){
            if isNil != nil {
                button.isHidden = false
                button.setTitle(isNil!, for: .normal)
            } else {
                button.isHidden = true
            }
        }
        func displayBadges(first: String?, second: String?, third: String?, fourth: String?){
            updateButton(button: firstButton, isNil: first)
            updateButton(button: secondButton, isNil: second)
            updateButton(button: thirdButton, isNil: third)
            updateButton(button: cautionButton, isNil: fourth)
            //                if first != nil {
            //                    firstButton.isHidden = false
            //                    firstButton.setTitle(first!, for: .normal)
            //                } else {
            //                    firstButton.isHidden = true
            //                }
            //                if second != nil {
            //                    secondButton.isHidden = false
            //                    secondButton.setTitle(second!, for: .normal)
            //                } else {
            //                    secondButton.isHidden = true
            //                }
            //                if third != nil {
            //                    thirdButton.isHidden = false
            //                    thirdButton.setTitle(third!, for: .normal)
            //                } else {
            //                    thirdButton.isHidden = true
            //                }
            //                if fourth != nil {
            //                    cautionButton.isHidden = false
            //                } else {
            //                    cautionButton.isHidden = true
            //                }
        }
        let badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
        if badges.isEmpty{
            displayBadges(first: nil, second: nil, third: nil, fourth: nil)
        } else {
            var found = false
            for badge in badges {
                if badge["patientID"] == patientID{
                    found = true
                    let npo = Bool(badge["isNpo"]!)!
                    let isHalf = Bool(badge["isHalf"]!)!
                    let isTwice = Bool(badge["isTwice"]!)!
                    let isWet = Bool(badge["isWet"]!)!
                    let isDry = Bool(badge["isDry"]!)!
                    let c = Bool(badge["isCaution"]!)!
                    if !npo && !isHalf && !isTwice && !isWet && !isDry && !c {// everything is false
                        displayBadges(first: nil, second: nil, third: nil, fourth: nil)
                        break
                    }
                    if npo {
                        if isTwice {  // 2X - Apple
                            if isWet {// WET
                                //c TRUE:  NPO    2X    WET    Caution
                                //c FALSE: NPO    2X    WET
                                c ? displayBadges(first: "NPO", second: "2X", third: "WET", fourth: "⚠") : displayBadges(first: "NPO", second: "2X", third: "WET", fourth: nil)
                            } else {  // ! WET
                                if isDry { // DRY
                                    //NPO    2X    DRY    Caution
                                    //NPO    2X    DRY
                                    c ? displayBadges(first: "NPO", second: "2X", third: "DRY", fourth: "⚠") : displayBadges(first: "NPO", second: "2X", third: "DRY", fourth: nil)
                                } else { // ! DRY ! WET
                                    //NPO 2X Caution
                                    //NPO 2X
                                    c ? displayBadges(first: "NPO", second: "2X", third: nil, fourth: "⚠") : displayBadges(first: "NPO", second: "2X", third: nil, fourth: nil)
                                }
                            }
                        } else {     // !2X - Banana
                            if isHalf { // !2x is 1/2
                                if isWet {
                                    //NPO    "1/2"    WET    Caution
                                    //NPO    "1/2"    WET
                                    c ? displayBadges(first: "NPO", second: "1/2", third: "WET", fourth: "⚠") : displayBadges(first: "NPO", second: "1/2", third: "WET", fourth: nil)
                                } else { // !WET
                                    if isDry { // DRY
                                        //NPO    "1/2"    DRY    Caution
                                        //NPO    "1/2"    DRY
                                        c ? displayBadges(first: "NPO", second: "1/2", third: "DRY", fourth: "⚠") : displayBadges(first: "NPO", second: "1/2", third: "DRY", fourth: nil)
                                    } else {   // ! WET  ! DRY
                                        //NPO            Caution
                                        //NPO
                                        c ? displayBadges(first: "NPO", second: "1/2", third: nil, fourth: "⚠") : displayBadges(first: "NPO", second: "1/2", third: nil, fourth: nil)
                                    }
                                }
                            } else { // !2X !1/2 - Orange
                                if isWet {
                                    //NPO    WET    Caution
                                    //NPO    WET
                                    c ? displayBadges(first: "NPO", second: "WET", third: nil, fourth: "⚠") : displayBadges(first: "NPO", second: "WET", third: nil, fourth: nil)
                                } else { // ! WET
                                    if isDry { // DRY
                                        //NPO    "1/2"    DRY    Caution
                                        //NPO    "1/2"    DRY
                                        c ? displayBadges(first: "NPO", second: "DRY", third: nil, fourth: "⚠") : displayBadges(first: "NPO", second: "DRY", third: nil, fourth: nil)
                                    } else {   // ! WET  ! DRY
                                        //NPO            Caution
                                        //NPO
                                        c ? displayBadges(first: "NPO", second: nil, third: nil, fourth: "⚠") : displayBadges(first: "NPO", second: nil, third: nil, fourth: nil)
                                    }
                                }
                            }
                        }
                        
                    } else {          // !NPO
                        if isTwice {  // 2x - grape
                            if isWet {// WET
                                //2X    WET        Caution
                                //2X    WET
                                c ? displayBadges(first: "2X", second: "WET", third: nil, fourth: "⚠") : displayBadges(first: "2X", second: "WET", third: nil, fourth: nil)
                            } else {  // !WET
                                if isDry {
                                    //2X    DRY        Caution
                                    //2X    DRY
                                    c ? displayBadges(first: "2X", second: "DRY", third: nil, fourth: "⚠") : displayBadges(first: "2X", second: "DRY", third: nil, fourth: nil)
                                } else {//!WET !DRY
                                    //2X            Caution
                                    //2X
                                    c ? displayBadges(first: "2X", second: nil, third: nil, fourth: "⚠") : displayBadges(first: "2X", second: nil, third: nil, fourth: nil)
                                }
                            }
                        } else {      // !2x
                            if isHalf{ // 1/2 - pear
                                if isWet {// WET
                                    //"1/2"    WET        Caution
                                    //"1/2"    WET
                                    c ? displayBadges(first: "1/2", second: "WET", third: nil, fourth: "⚠") : displayBadges(first: "1/2", second: "WET", third: nil, fourth: nil)
                                } else {  // !WET
                                    if isDry { // DRY
                                        //"1/2"    DRY        Caution
                                        //"1/2"    DRY
                                    } else { //!WET   !DRY
                                        //"1/2"            Caution
                                        //"1/2"
                                        c ? displayBadges(first: "1/2", second: nil, third: nil, fourth: "⚠") : displayBadges(first: "1/2", second: nil, third: nil, fourth: nil)
                                    }
                                }
                            } else {// !2X !1/2 - pineapple
                                if isWet { // WET
                                    //WET            Caution
                                    //WET
                                    c ? displayBadges(first: "WET", second: nil, third: nil, fourth: "⚠") : displayBadges(first: "WET", second: nil, third: nil, fourth: nil)
                                } else { // !WET
                                    if isDry {
                                        //DRY            Caution
                                        //DRY
                                        c ? displayBadges(first: "DRY", second: nil, third: nil, fourth: "⚠") : displayBadges(first: "DRY", second: nil, third: nil, fourth: nil)
                                    } else {// !WET  !DRY
                                        //Caution
                                        if c {
                                            displayBadges(first: nil, second: nil, third: nil, fourth: "⚠")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }//end for
            if !found {
                displayBadges(first: nil, second: nil, third: nil, fourth: nil)
            }
        }
    }
}


