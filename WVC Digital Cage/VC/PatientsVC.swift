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

class PatientsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,  MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate /*photoLib*/,
UINavigationControllerDelegate/*photoLib*/, UITextFieldDelegate {

    @IBOutlet var patientsView: UIView!
    
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
    
    //views
    
    @IBOutlet weak var hideView: UIView!
    //hider view items
    @IBOutlet weak var hideTrailingLC: NSLayoutConstraint!
    @IBOutlet weak var hideLeadingLC: NSLayoutConstraint!
    @IBOutlet weak var hideBottomLC: NSLayoutConstraint!
    @IBOutlet weak var hideTopLC: NSLayoutConstraint!
    //constraints
    @IBOutlet weak var AMPMTopConstraint: NSLayoutConstraint!
    //labels
    @IBOutlet weak var walkMeLabel: UILabel!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var patientIDLabel: UILabel!
    @IBOutlet weak var pdfLabel: UILabel!
    @IBOutlet weak var treatmentBadge: UILabel!
    
    //vitals fields
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
    
    //PDF page number
    var pageNumber = 1
    let endOfPage = 1040
    
    //table data
    var patientID = ""
    var selectedData = Dictionary<String,String>()
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    
    var missingPatientIDs = UserDefaults.standard.object(forKey: "missingPatientIDs") as? [String] ?? []
    
    var SearchData = Array<Dictionary<String,String>>()
    
    var imagePickerController : UIImagePickerController!
    
    var selectedRow:Int = 0
    
    //-- pull to refresh --
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-- pull to refresh --
        //let refreshControl = UIRefreshControl()
        patientTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(PatientsVC.refreshData), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Patients ...")
        
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
       center.addObserver(self,
                            selector: #selector(refreshPatientsTable),
                            name: NSNotification.Name(rawValue: "refreshPatientsTable"),
                                               object: nil)
        center.addObserver(self,
                           selector: #selector(refreshBadge),
                           name: NSNotification.Name(rawValue: "refreshBadge"),
                           object: nil)
        center.addObserver(self,
                           selector: #selector(moveAMPMUp),
                           name: NSNotification.Name(rawValue: "moveAMPMUp"), object: nil)
        center.addObserver(self,
                           selector: #selector(moveAMPMDown),
                           name: NSNotification.Name(rawValue: "moveAMPMDown"), object: nil)
    }
    override func viewDidAppear(_ animated: Bool){//SEGUE FROM VIEW 2 - UPDATE UI
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        SearchData=patientRecords
//        let sortResults = SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
//        SearchData = sortResults
        //Sort in place.
        sortSearchDataNow()
        patientTable.reloadData()
        //print("selectedPatientID: B \(seguePatientID)")
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
            createBadgeFrom(UIlabel:treatmentBadge, text: treatementCount(p: patientID) )
        }
    }
    //MARK - Sort Function
    func sortSearchDataNow(){
        //Sort in place.
        SearchData.sort {
            $0["kennelID"]!.compare($1["kennelID"]!, options: .numeric) == .orderedAscending
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
//            let sortResults = SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
//            SearchData = sortResults
            //Sort in place.
            sortSearchDataNow()
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
        pageNumber = 1
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
        }, completion: { completed in})
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
//        let sortResults = SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
//        SearchData = sortResults
        //Sort in place.
        sortSearchDataNow()
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
//        let sortResults = SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
//        SearchData = sortResults
        //Sort in place.
        sortSearchDataNow()
        patientTable.reloadData()
    }
}
extension PatientsVC {
    // #MARK: - UI
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
//        let sortResults = SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
//        SearchData = sortResults
        //Sort in place.
        sortSearchDataNow()
        patientTable.reloadData()
    }
    @objc func refreshBadge(){
        setBadges()
        createBadgeFrom(UIlabel:treatmentBadge, text: treatementCount(p: patientID) )
        print("refreshBadge")
    }
    @objc func moveAMPMUp(){
        let goUp:CGFloat = -360
        AMPMTopConstraint.constant = goUp
    }
    @objc func moveAMPMDown(){
        let goDown:CGFloat = -1
        AMPMTopConstraint.constant = goDown
    }
    // #MARK: - UI
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
//        let sortResults = SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
//        SearchData = sortResults
        //Sort in place.
        sortSearchDataNow()
        segmentControl.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)], for: .normal)
        scopeSegmentControl.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)], for: .normal)
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
                //Sort in place.
                sortSearchDataNow()
                
                //update the cloud record
                let updateDCCISPatient:Dictionary<String,String> =
                    [
                        "patientId": patientRecords[index]["cloudPatientID"]!,//cloudPatientID
                        "status": patientRecords[index]["status"]!,
                        "intakeDate": patientRecords[index]["intakeDate"]!,
                        "patientName": patientRecords[index]["patientID"]!,
                        "walkDate": patientRecords[index]["walkDate"]!,
                        "photoName": patientRecords[index]["photo"]!,
                        "kennelId": patientRecords[index]["kennelID"]!,
                        "owner": patientRecords[index]["owner"]!,
                        "groupString": patientRecords[index]["group"]!
                ]
                updateInDCCISCloud(thisPatient:updateDCCISPatient)
                break
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
    //
    // MARK: - Refresh Function
    //
    @objc func refreshData(){
        
        getAllIncisions()

        getBadgesFromDCCISCloud()
        
        getDemographicsFromDCCISCloud()

        getPhysicalExamsFromDCCISCloud()
        
        getVitalsFromDCCISCloud()
        
        getAllProcedures()
        
        getAllAmpm()
        
        //get all patients
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getPatients(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            print("got all IS Patients")
            self.patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
            self.SearchData=self.patientRecords
            self.sortSearchDataNow()
            self.patientTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    //
    // MARK: - API Calls
    //
    
    //PATIENTS
    func deletePatient(patientID: Int){
        let removeDG = DispatchGroup()
        removeDG.enter()
        DeleteInstantShare().patient(aview: patientsView, parameters: ["patientID":patientID], dispatchInstance: removeDG)
        
        removeDG.notify(queue: DispatchQueue.main) {
            print("deleted \(patientID)")
        }
    }
    func updateInDCCISCloud(thisPatient:[String : Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().Patient(aview: patientsView, parameters: thisPatient, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update walk me for Patient success")
        }
    }
    
    //VITALS
    func getVitalsFromDCCISCloud(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getVitals(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            //let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
            //print("got all IS Vitals \n \(patientVitals)")
        }
    }
    func updateVitalInDCCISCloud(thisVital:[String : Any]){
        let updateDG = DispatchGroup()
        updateDG.enter()
        UPDATE().vital(aview: patientsView, parameters: thisVital, dispachInstance: updateDG)
        
        updateDG.notify(queue: DispatchQueue.main) {
            print("update vital success")
            self.getVitalsFromDCCISCloud()
        }
    }
    func insertVitalInDCCISCloud(thisVital:[String : Any]){
        let insertDG = DispatchGroup()
        insertDG.enter()
        INSERT().newVital(aview: patientsView, parameters: thisVital, dispachInstance: insertDG)
        
        insertDG.notify(queue: DispatchQueue.main) {
            print("insert new vital success")
            self.getVitalsFromDCCISCloud()
        }
    }
    
    //update tables during refresh
    func getPhysicalExamsFromDCCISCloud(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getPhysicalExams(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            //let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
            print("got cloud PhysicalExams")
        }
    }
    func getDemographicsFromDCCISCloud(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getDemographic(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            //let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
            print("got cloud Demographics")
        }
    }
    func getBadgesFromDCCISCloud(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getBadges(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            print("got cloud Badges")
        }
    }
    func getAllIncisions(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getIncisions(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            print("got cloud incisions")
        }
    }
    func getAllProcedures(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getProcedures(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            print("got cloud procedures")
        }
    }
    func getAllAmpm(){
        let getDG = DispatchGroup()
        getDG.enter()
        GETAll().getAmpms(aview: patientsView, dispachInstance: getDG)
        
        getDG.notify(queue: DispatchQueue.main) {
            //showAmpm()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAmpm"), object: nil)
            print("got cloud ampms")
        }
    }
}

extension PatientsVC {
    //
    // #MARK: - Table View
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
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
        cell.status.font = UIFont.boldSystemFont(ofSize: 17)
        if thisPatient["status"] == "Archive" {
            cell.status.textColor = UIColor.WVCGray()
            
        } else if thisPatient["status"] == "Saved"{
            cell.status.textColor = UIColor.WVCActionBlue()
        } else {
            cell.status.textColor = UIColor.black
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedData = SearchData[indexPath.row]
        selectedRow = indexPath.row //used for populating Tx View patient data
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
        
        createBadgeFrom(UIlabel:treatmentBadge, text: treatementCount(p: patientID) )
    }
    func treatementCount(p: String) -> String{
        let array = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []
        let array2 = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
        let array3 = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
        var num = 0
        var numString = ""
        for dict in array{
            if dict["patientID"] == p{
                if dict["notes"]?.isEmpty == false {
                num += 1
                }
            }
        }
        for dict in array2{
            if dict["patientID"] == p{
                num += 1
            }
        }
        for dict in array3{
            if dict["patientID"] == p{
                num += 1
            }
        }
        if num != 0{
            numString = " \(num) "
        }
        return numString
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let thisPatient = SearchData[indexPath.row]
        var statusString = ""
        if thisPatient["status"] == "Archive"{ statusString = "Active" }
        else if thisPatient["status"] == "Active" { statusString = "Archive" }
    
        let email = UITableViewRowAction(style: .normal, title: "Email") { action, index in
            print("Email button tapped")
            self.emailButtonTapped(indexPathRow: indexPath.row)
        }
        //COLOR - Email
        email.backgroundColor = UIColor.seaBuckthorn()
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("Delete button tapped")
            self.deleteRecordAlert(title:"Are you sure you want to remove this Patient?", message:"This will forever remove all records for this patient.", buttonTitle:"OK", cancelButtonTitle: "Cancel", indexPath: indexPath)
        }
        //COLOR - Delete
        delete.backgroundColor = UIColor.red
        let archive = UITableViewRowAction(style: .normal, title: statusString/*"Archive" or "Active"*/) { action, index in
            print("Archive button tapped")
            self.archiveButtonTapped(indexPath: indexPath, statusString: statusString)
        }
        //COLOR - Archive
        if statusString == "Archive" {
            archive.backgroundColor = UIColor.WVCGray()
        } else {
            archive.backgroundColor = UIColor.WVCActionBlue()
        }
        return [email, delete, archive]
    }
    func emailButtonTapped(indexPathRow: Int){
        let selectedData:Dictionary<String,String> = self.SearchData[indexPathRow]
        self.sendEmailWithAttachemnt(patientData: selectedData)
    }
    func deleteButtonTapped(indexPath: IndexPath){
        let removeForThisPID = self.SearchData[indexPath.row]["patientID"]
        let cloudPatientID = self.SearchData[indexPath.row]["cloudPatientID"]
        print("delete:: \(removeForThisPID!)")
        self.removeAllDataAndPicturesFor(patientID:removeForThisPID!)
        //check if cloudPatientID exist
        
        if cloudPatientID != nil {
            self.deletePatient(patientID: Int(cloudPatientID!)!)
        } else {
            self.view.makeToast("found nil for this patient ID: \(removeForThisPID!)", duration: 2.1, position: .center)
        }
        self.showHideView()//show view & change constants
        patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        self.SearchData = self.patientRecords
        //let sortResults = self.SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
        //SearchData = sortResults
        //Sort in place.
        sortSearchDataNow()
        patientTable.reloadData()
        //self.patientTable.deleteRows(at: [indexPath], with: .fade)
    }
    func archiveButtonTapped(indexPath: IndexPath, statusString: String){
        print("Archive button tapped")
        let archiveForThisPID = self.SearchData[indexPath.row]["patientID"]
        for index in 0..<patientRecords.count {
            if patientRecords[index]["patientID"] == archiveForThisPID {
                patientRecords[index]["status"] = statusString//"Archive"//"Active"
            }
        }//[indexPath.row]["status"] = "Archive"
        UserDefaults.standard.set(self.patientRecords, forKey: "patientRecords")
        UserDefaults.standard.synchronize()
        self.SearchData = self.patientRecords
//        let sortResults = self.SearchData.sorted { $0["kennelID"]! < $1["kennelID"]! }
//        SearchData = sortResults
        //Sort in place.
        sortSearchDataNow()
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
    //
    // #MARK: - Save Vitals, Show Vitals, Remove Vitals
    //
    func saveVitals(){
        var patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        var patientHasVital = false
        var cloudPatientID = ""
        if let index = dictIndexFrom(array: patientRecords, usingKey:"patientID", usingValue: patientID) {
                cloudPatientID = patientRecords[index]["cloudPatientID"]! //unexpectedly found nil while unwrapping option value
            }
        
        let newVital:[String : Any] =
            [
                "patientID":cloudPatientID,
                "patientName":patientID,
                "temperature":temperature.text!,
                "pulse":pulse.text!,
                "weight":weight.text!,
                "exitWeight":exitWeight.text!,
                "cRT_MM":cRT_MM.text!,
                "respiration":respiration.text!,
                "initialsVitals":initialsVitals.text!
        ]
        
        //INSERT NEW CLOUD
        if patientVitals.isEmpty {//create new record/TABLE if DNE
            insertVitalInDCCISCloud(thisVital:newVital)
            print("INSERT NEW Vital \n \(newVital)")
            
        } else {
            for index in 0..<patientVitals.count {
                //make sure we are update or saving for the right patient
                if patientVitals[index]["patientID"] == patientID {//UPDATE by PID
                    
                    //UPDATE CLOUD
                    if let vitalId = patientVitals[index]["vitalId"] as? String {
                        let updatedVital:[String : Any] =
                            [
                                "vitalId":vitalId,
                                "patientID":patientVitals[index]["cloudPatientID"]!,
                                "patientName":patientID,
                                "temperature":temperature.text!,
                                "pulse":pulse.text!,
                                "weight":weight.text!,
                                "exitWeight":exitWeight.text!,
                                "cRT_MM":cRT_MM.text!,
                                "respiration":respiration.text!,
                                "initialsVitals":initialsVitals.text!
                        ]
                        updateVitalInDCCISCloud(thisVital:updatedVital)
                        print("UPDATE THIS Vital \n \(updatedVital)")
                        patientHasVital = true
                        return
                    }
                }
            } //patientID not found in patientVitals
            
            //INSERT NEW CLOUD
            if patientHasVital == false {
                insertVitalInDCCISCloud(thisVital:newVital)
                print("INSERT NEW Vital \n \(newVital)")
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
}
extension PatientsVC{
    //
    // MARK: - Email
    //
    func sendEmailWithAttachemnt(patientData: Dictionary<String,String>){
        
        emailActive = true //close keyboard?
        
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
            mail.addAttachmentData(fileData! as Data, mimeType: "application/pdf", fileName: "patientRecord.pdf")
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
        let patientIDHere = patientData["patientID"]
        let fileName: NSString = "patientRecord.pdf" as NSString
        
        let path:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = path.object(at: 0) as! NSString
        let pdfPathWithFile = documentDirectory.appendingPathComponent(fileName as String)
        
        // 2. Generate PDF with file path ---
        UIGraphicsBeginPDFContextToFile(pdfPathWithFile, CGRect.zero, nil)
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
        drawBackground()
        drawImageLogo(imageName: "WVCLogog")
        drawPatientRecordText(patientData: patientData)
        drawPatientPicture(imageName: patientIDHere! + ".png")
        drawVitalsText(patientID:patientIDHere!)
        drawPhysicalExam(patientID:patientIDHere!)
        drawDemographicsText(patientID:patientIDHere!)
        //drawIncisions(patientID:patientIDHere!)
        drawProcedures(patientID:patientIDHere!)
        drawAMPMs(patientID:patientIDHere!)
        drawIncisions(patientID:patientIDHere!)
        UIGraphicsEndPDFContext()
        
        return pdfPathWithFile
    }
    // PDF HEADER, BACKGROUND, LOGO ```````````````````````````````` PDF
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
    //REPEATING Incisions
    func drawIncisions(patientID:String){//REPEATING
        let allInc = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
        var nextInc = Dictionary<String,String>()
        
        if arrayContains(array:allInc, value:patientID) {//check if patient has incision
            
            //Start new page
            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
            
            //Add header, footer and logo
            pageNumber += 1
            pdfAdd(title: "Incision Checked",x: 50,y:100, pageNumber: pageNumber)

            var newTotalY = 110//100+300+160
            var xCol1 = 50 /*let xCol2 = 250 let xCol3 = 500*/
            let textRecWidth = 300
            
            let titles = ["date", "initials"]
            var title = CGRect()
            var value = CGRect()
            let spacerTwenty = 20
            
            var numColumns = 1
            //var isThisGoingToFirstPage = true
            //var numberPagesIncicions = 1

            for dict in allInc {
                if dict["patientID"] == patientID {
                    nextInc = dict
                    for item in titles {
                        let word = item.camelCaseToWords()
                        let uppercased = word.firstUppercased + ":"
                        newTotalY += spacerTwenty
                        
                        if newTotalY >= endOfPage {
                            
                            newTotalY = 125//top of new page
                            xCol1 += 250
                            
                            numColumns += 1
                            
                            if numColumns == 4 {
                                numColumns = 0
                                
                                //Start new page
                                UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
                                
                                //Add header, footer and logo
                                pageNumber += 1
                                pdfAdd(title: "Incision Checked",x: 50,y:100, pageNumber: pageNumber)
                                
                                //update starting column location for data
                                newTotalY = 125
                                xCol1 = 50
                            }
                        }

                        //draw this line
                        title = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:65)
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
                if item.value == "false" { demDict[item.key] = "Male" }
                if item.value == "true" { demDict[item.key] = "Female" }
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
    // -----
    // #MARK - Support PDF Footer, Title, add new page
    //
    func pdfAdd(title: String,x: Int, y:Int, pageNumber: Int){
        let textRecWidth = 200//title
        let titleTop = CGRect(x: x, y:y, width:textRecWidth, height:40)
        title.draw(in: titleTop, withAttributes: returnTitle1Attributes())
        printPDFFooter(pageNumber: pageNumber)
    }
    func setupNextPDFPage(numColumns: inout Int, xCol2: inout Int, newTotalY: inout Int, pageNumber: inout Int){
        numColumns = 0
        xCol2 = 50
        newTotalY = 125//80
        pageNumber += 1
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
        pdfAdd(title: "AM/PM Checked p\(pageNumber)",x: 50,y:100, pageNumber: pageNumber)
    }
    func printPDFFooter(pageNumber: Int){
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY hh:mm a"
        let dateString = formatter.string(from: now)//date(from: yourDateString)
        let stringNumber = "Created: \(dateString),    Page " + String(pageNumber)
        let textRecWidth = 250//footer
        let footer = CGRect(x: 550, y:1060, width:textRecWidth, height:40)
        stringNumber.draw(in: footer, withAttributes: returnTextAttributes())
        drawImageLogo(imageName: "WVCLogog")
    }
    //-----
    func drawAMPMs(patientID:String){//REPEATING
        var allAMPM = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
        //allAMPM.sort { $0["date"]! < $1["date"]! }//sort array in place
        
        //BUG 1
        allAMPM = sortArrayDictDesc(dict: allAMPM, dateFormat: "MM/dd/yy a")
        
        var nextAMPM = Dictionary<String,String>()
        
        if arrayContains(array:allAMPM, value:patientID) {//check if patient exists
        
            pdfAdd(title: "AM/PM Checked",x: 270,y:500, pageNumber: pageNumber)
            var newTotalY = 300+200
            
            var xCol2 = 270 /* let xCol3 = 500*//*let xCol1 = 40 */
            let textRecWidth = 200
            
            var localPageNumber = 1
            
            let titles = ["date","attitude", "feces", "urine", "appetite", "vDCS", "initials"] //"appetite%", "v/D/C/S"
            //"appetite%" -> "appetite" and "v/D/C/S" -> "vDCS"
            var title = CGRect()
            var value = CGRect()
            let spacerTwenty = 20
            var numColumns = 0
            newTotalY += 10
            for dict in allAMPM {
                if dict["patientID"] == patientID {
                    nextAMPM = dict
                    for item in titles {
                        let word = item.camelCaseToWords()
                        var uppercased = word.firstUppercased + ":"
                        if item == "appetite" { uppercased = "Appetite%:" }
                        newTotalY += spacerTwenty
                        
                        if newTotalY >= endOfPage {
                            
                            numColumns += 1//= numColumns + 1
                            xCol2 += 200
                            
                            newTotalY = 125//80
                            if localPageNumber /*pageNumber*/  == 1 { newTotalY = 530 }
                            
                            if numColumns == 3 {
                                if localPageNumber /*pageNumber*/ == 1 {
                                    setupNextPDFPage(numColumns: &numColumns, xCol2: &xCol2, newTotalY: &newTotalY, pageNumber: &pageNumber)
                                    localPageNumber += 1
                                }
                                else {//if pageNumber != 1 {
                                    numColumns += 1// = numColumns + 1
                                }
                            }
                            if numColumns == 5 {
                                setupNextPDFPage(numColumns: &numColumns, xCol2: &xCol2, newTotalY: &newTotalY, pageNumber: &pageNumber)
                            }
                        }
                        
                        //draw this line
                        title = CGRect(x: xCol2, y:newTotalY, width:textRecWidth, height:65)
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
//        let imagesListArray =
//            [UIImage(named: "dog1dalmation.png")!,UIImage(named: "dog2dalmation.png")!,UIImage(named: "dog3dalmation.png")!,UIImage(named: "dog4dalmation.png")!,UIImage(named: "dog5dalmation.png")!,UIImage(named: "dog6dalmation.png")!,UIImage(named: "dog7dalmation.png")!]
        
        let imagesListArray2 = [UIImage(named: "dog1gs.png")!,UIImage(named: "dog2gs.png")!,UIImage(named: "dog3gs.png")!,UIImage(named: "dog4gs.png")!,UIImage(named: "dog5gs.png")!,UIImage(named: "dog1gs.png")!,UIImage(named: "dog2gs.png")!,UIImage(named: "dog3gs.png")!,UIImage(named: "dog4gs.png")!,UIImage(named: "dog5gs.png")!]
        runningDogImage.animationImages = imagesListArray2
        runningDogImage.animationDuration = 1.0
        runningDogImage.startAnimating()
        self.view.bringSubview(toFront: walkAlertView)
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
                                        c ? displayBadges(first: "1/2", second: "DRY", third: nil, fourth: "⚠") : displayBadges(first: "1/2", second: "DRY", third: nil, fourth: nil)
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
extension PatientsVC {
    // Navigation Support Functions
    func sexOF(patientID: String) -> [String]{
        var returnSex = "Unknown"; var returnAge = "Unknown"; var returnBreed = "Unknown"
        let ds = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
        for d in ds{
            if d["patientID"] == patientID {
                if d["sex"] == "false" {
                    returnSex = "Male"
                } else { returnSex = "Female" }
                if d["age"] != "" {
                    returnAge = d["age"]!
                }
                if d["breed"] != "" {
                    returnBreed = d["breed"]!
                }
            }
        }
        return [returnSex,returnAge,returnBreed]
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
        } else if segue.identifier == "segueTx" {
            if let toVC = segue.destination as? TxVC {
                toVC.seguePatientID = patientID
                let thisPatient = SearchData[selectedRow]
                toVC.segueShelterName = thisPatient["owner"]
                let demographics = sexOF(patientID: patientID)
                toVC.seguePatientSex = demographics[0]
                toVC.seguePatientAge = demographics[1]
                toVC.seguePatientBreed = demographics[2]
            }
        }
    }
}

