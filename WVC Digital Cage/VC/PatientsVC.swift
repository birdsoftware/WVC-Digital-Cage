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
    
    @IBOutlet weak var patientPicture: UIImageView!
    
    //search bar
    @IBOutlet weak var patientSearchBar: UISearchBar!
    
    //Boolean Flags
    var searchActive = false
    var shareActive = false
    var emailActive = false
    
    //table data
    var patientID = ""
    var selectedData = Dictionary<String,String>()
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    
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
    }
    //#MARK - Actions
    @IBAction func segmentControlAction(_ sender: Any) {
        changeSegmentAction()
    }
    @IBAction func walkMeAction(_ sender: Any) {
        //walkMeLabel
        //timer value exits? creat new : reset time
        updateWalkTime()
        removeNotification(code: "1", patientID: patientID) //TOCHECK:::
        removeNotification(code: "2", patientID: patientID) //TOCHECK:::
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
            //showUpdateRecordView()
            
        }
    }// #MARK: - When Keyboard shws DO: Move text view down
    @objc func keyboardWillHide(sender: NSNotification){
        
    }
    @objc func refreshPatientsTable(){
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        SearchData = patientRecords
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
        cell.dogPhoto.image = returnImage(imageName: thisPatient["patientID"]! + ".png")
        switch thisPatient["group"]! {
            case "Canine":
                cell.imageBackgroundView.backgroundColor = UIColor.DarkRed()
            case "Feline":
                cell.imageBackgroundView.backgroundColor = UIColor.Fern()
            case "Other":
                cell.imageBackgroundView.backgroundColor = UIColor.seaBuckthorn()
            default:
                cell.imageBackgroundView.backgroundColor = UIColor.cyan
        }
        if thisPatient["Status"] == "Archive" {
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
        
        self.patientRecords.remove(at: indexPath.row)
        UserDefaults.standard.set(self.patientRecords, forKey: "patientRecords")
        UserDefaults.standard.synchronize()
        self.SearchData = self.patientRecords
        self.patientTable.deleteRows(at: [indexPath], with: .fade)
    }
    func archiveButtonTapped(indexPath: IndexPath){
        print("Archive button tapped")
        self.patientRecords[indexPath.row]["Status"] = "Archive"
        UserDefaults.standard.set(self.patientRecords, forKey: "patientRecords")
        UserDefaults.standard.synchronize()
        self.SearchData = self.patientRecords
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
        UIGraphicsEndPDFContext()
        
        return pdfPathWithFile
    }
    // PDF GEN ```````````````````````````````````````````````````` PDF
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
    func drawPatientRecordText(patientData: Dictionary<String,String>){
        //set up columns for 850 by 1100 page
        let logoHeight = 60
        let spacerFifty = 50
        let spacerTwenty = 20
        //let xCol1 = 50
        let xCol2 = 250
        //let xCol3 = 550
        let textRecWidth = 200
        
        var newTotalY = logoHeight+spacerFifty + spacerTwenty
        
        let titles = ["patientID","Status","intakeDate","owner"]
        
        var title = CGRect()
        var value = CGRect()
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            newTotalY += spacerTwenty
            title = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:40)
            newTotalY += spacerTwenty
            value = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:60)
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            patientData[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
    }
    func drawVitalsText(patientID:String){
        let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        var vitalData = Dictionary<String,String>()
        for vital in patientVitals {
            if vital["patientID"] == patientID {
                vitalData = vital
            }
        }
        //set up columns for 850 by 1100 page
        let logoHeight = 210
        let spacerFifty = 50
        let spacerTwenty = 20
        let xCol1 = 50
        //let xCol2 = 300
        let textRecWidth = 200
        
        var newTotalY = logoHeight+spacerFifty + spacerTwenty
        
        let titles = ["temperature","pulse","cRT_MM","respiration","weight","exitWeight","initialsVitals"]
        
        var title = CGRect()
        var value = CGRect()
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            newTotalY += spacerTwenty
            title = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:40)
            newTotalY += spacerTwenty
            value = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:60)
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            vitalData[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
    }
    func drawPhysicalExam(patientID:String){
        let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        var physcialExamData = Dictionary<String,String>()
        for pe in patientPhysicalExam {
            if pe["patientID"] == patientID {
                physcialExamData = pe
            }
        }
        //["urogenital": "false", "nervousSystem": "false", "respiratory": "true", "digestiveTeeth": "false", "ears": "false", "musculoskeletal": "false", "patientID": "81231", "nose": "false", "generalAppearance": "true", "lymphNodes": "false", "skinFeetHair": "false", "eyes": "false", "comments": "\n1) hbhjblhj\n6) breathing good", "bodyConditionScore": "5"]
        //replace true with normal & flase with abnormal
        for item in physcialExamData {
            if item.value == "false" {
                physcialExamData[item.key] = "Normal"
            }
            if item.value == "true" {
                physcialExamData[item.key] = "Abnormal"
            }
        }
        //set up columns for 850 by 1100 page
        let logoHeight = 60
        let spacerFifty = 50
        let spacerTwenty = 20
        let xCol3 = 500
        let textRecWidth = 300
        var valueHeight = 60
        
        let titleTop = CGRect(x: xCol3, y:120, width:textRecWidth, height:40)
        let titleTopString = "Physical Examination"
        titleTopString.draw(in: titleTop, withAttributes: returnTitle1Attributes())
        
        var newTotalY = logoHeight+spacerFifty + spacerTwenty
        
        let titles = ["generalAppearance","skinFeetHair","musculoskeletal","nose","digestiveTeeth","respiratory","ears","nervousSystem","lymphNodes","eyes","urogenital","bodyConditionScore","comments"]
        
        var title = CGRect()
        var value = CGRect()
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            newTotalY += spacerTwenty
            title = CGRect(x: xCol3, y:newTotalY, width:textRecWidth, height:40)
            newTotalY += spacerTwenty
            if item == "comments"{
                valueHeight = 200
            }
            value = CGRect(x: xCol3, y:newTotalY, width:textRecWidth, height:valueHeight)
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            physcialExamData[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
    }
    func returnTitle1Attributes() -> [NSAttributedStringKey: NSObject]{
        let fontTitle = UIFont(name: "Helvetica Bold", size: 18.0)!
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
        }
    }
}
extension PatientsVC{
    // #MARK: - Image picker form camera
    //camera delegate func called after take photo
    //https://appsandbiscuits.com/take-save-and-retrieve-a-photo-ios-13-4312f96793ff
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        // RESIZE IMAGE
           let smallerSizeImage = resizeImage(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!, newWidth: 200)
        // UPDATE UI IMAGE
           patientPicture.image = smallerSizeImage
        // SAVE IMAGE TO APP LOCAL DIR
           saveImage(imageName: patientID + ".png")
           saveImageNameToPatientRecords(imageName: patientID + ".png")
        self.patientTable.reloadData()
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func saveImage(imageName: String){
        print("Image \(imageName) saved")
        //create an instance of the FileManager
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //get the image we took with camera
        let image = patientPicture.image!
        //get the PNG data for this image
        let data = UIImagePNGRepresentation(image)
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    func saveImageNameToPatientRecords(imageName: String) {
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        if let index = dictIndexFrom(array: patientRecords, usingKey:"patientID", usingValue: patientID)
        {
            print("Saving photo: \(imageName) to index: \(index) for patientID: \(patientID)")
            patientRecords[index]["photo"] = imageName
            UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
            UserDefaults.standard.synchronize()
        }
    }
    func getImage(imageName: String, imageView: UIImageView){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            imageView.image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Panic! No Image!")
            imageView.image = UIImage(named: "dog circle")
        }
    }
    func returnImage(imageName: String) -> UIImage {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            print("Panic! No Image!")
            return UIImage(named: "dog circle")!
        }
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


