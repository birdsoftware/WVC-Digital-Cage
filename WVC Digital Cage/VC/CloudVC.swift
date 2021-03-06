//
//  CloudVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import UIKit

class CloudVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var cloudPatientsTable: UITableView!
    //label
    @IBOutlet weak var marqueeLabel: UILabel!
    @IBOutlet weak var cloudCount: UILabel!
    @IBOutlet weak var searchFilterResultLabel: UILabel!
    //search bar
    @IBOutlet weak var search: UISearchBar!
    
    //data
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    var searchData = [Dictionary<String,String>]()
    var cloudData = [Dictionary<String,String>]()
    var searchActive = false
    
    var selectedRow = 0 //need to get the patientID for segue
    
    var checked = [Bool]()
    var selectedCards = [String]()
    var selectedRows = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegates
        cloudPatientsTable.delegate = self
        cloudPatientsTable.dataSource = self
        search.delegate = self
        
        // SHOW ACTIVITY INDICATOR, call the function from your view controller
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        //API calls
        getPatientRecordsCount()
        getAllFromPatientsTable()
        
        marqueeLabel.text = " "
        
        //run marquee
       // _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(CloudVC.marquee), userInfo: nil, repeats: true)
    }
    
    //
    // Button ACTION
    //
    @IBAction func downloadAction(_ sender: Any) {
        if selectedRows.isEmpty == false {
            
            for thisRow in selectedRows {
                saveNewPatientLocally(thisSelectedRow:thisRow)
                //let cloudPatientID = searchData[thisRow]["cloudPatientID"]!
                //print("cloudPatientID \(cloudPatientID)")
                
                
                //TIP: save new defaults key name each time API is called. Data needs to be stored in seperate key names. Can't reuse immediately!
                //     saveDefaults named here
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "ampms", appendHere: "ampms", saveDefaults: "getAMPMData")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "vitals", appendHere: "patientVitals", saveDefaults: "getVitalData")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "badges", appendHere: "badges", saveDefaults: "getBadgess")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "demographics", appendHere: "demographics", saveDefaults: "getDemographics")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "incisions", appendHere: "incisions", saveDefaults: "getIncisions")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "notifications", appendHere: "notifications", saveDefaults: "getNotifications")
                //patients API. See getAllFromPatientsTable()
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "physicalExam", appendHere: "patientPhysicalExam", saveDefaults: "getPhysicalExam")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "procedures", appendHere: "procedures", saveDefaults: "getProcedures")
                //treatments
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "treatmentNotes", appendHere: "treatmentsAndNotes", saveDefaults: "getTreatmentNotes")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "treatments", appendHere: "collectionTreatments", saveDefaults: "getTreatments")
                getData(id: searchData[thisRow]["cloudPatientID"]!, idName: "patientID", tableName: "treatmentVitals", appendHere: "collectionTxVitals", saveDefaults: "getTreatmentVitals")
        }
            
            print("selectedRows: \(selectedRows)")
        
            selectedRow = selectedRows.last! //show this patient first segue
            performSegue(withIdentifier: "segueCloudToPatientDB", sender: self)
            
        } else {
            simpleAlert(title: "Nothing Selected", message: "Select card(s) to download", buttonTitle: "OK")
        }
    }
}

extension CloudVC{
    //
    // #MARK: - Table View
    //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: cloudTableView = tableView.dequeueReusableCell(withIdentifier: "cloudCell") as! cloudTableView
        
        var thisPatient = searchData[IndexPath.row]
        
        //uncomment when image API avialable: cell.photo.image = returnImage(imageName: thisPatient["patientID"]! + ".png")
        cell.intakeDate.text = thisPatient["intakeDate"]
        cell.name.text = thisPatient["patientID"]
        cell.owner.text = thisPatient["owner"]
        cell.kennelId.text = thisPatient["kennelID"]
        cell.speciesGroup.text = thisPatient["group"]
        cell.status.text = thisPatient["status"]
        cell.count.text = "\(IndexPath.row+1)"
        
        //configure you cell here.
        if checked[IndexPath.row] == false{
            cell.accessoryType = .none
        } else if checked[IndexPath.row] {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let count = checked.count
        checked = Array(repeating: false, count: count)
        checked[indexPath.row] = true
        selectedCards.append(searchData[indexPath.row]["patientID"]!)
        selectedRows.append(indexPath.row)
        //Array of strings to string
        marqueeLabel.text = selectedCards[0]
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        checked[indexPath.row] = false
        selectedCards = [String]()
        selectedRows = [Int]()
        marqueeLabel.text = " "
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
//            //SINGLE SELECTION -----------------------------------------------------------------------
//            if cell.accessoryType == .checkmark {
//                cell.accessoryType = .none
//                checked[indexPath.row] = false
//                selectedCards = [String]()
//                selectedRows = [Int]()
//                marqueeLabel.text = " "
//
//            } else {
//                cell.accessoryType = .checkmark
//                let count = checked.count
//                checked = Array(repeating: false, count: count)
//                checked[indexPath.row] = true
//                selectedCards.append(searchData[indexPath.row]["patientID"]!)
//                selectedRows.append(indexPath.row)
//               //Array of strings to string
//                marqueeLabel.text = selectedCards[0]//.joined(separator: ",")// + ","
//            }
//            //SINGLE SELECTION -----------------------------------------------------------------------
//
//            //let str = "Swift 3.0 is the best version of Swift to learn, so if you're starting fresh you should definitely learn Swift 3.0."
//            //let replaced = str.replacingOccurrences(of: "3.0", with: "4.0")
//
////            //WORKS MULTIPLE CHECKED ---------------------------------------------------------------
////            if cell.accessoryType == .checkmark {
////                cell.accessoryType = .none
////                checked[indexPath.row] = false
//////                for index in 0..<selectedCards.count{
//////                    if selectedCards[index] == searchData[indexPath.row]["patientID"]!{
//////                        selectedCards.remove(at: index)
//////                        break
//////                    }
//////                }
////
////
////                //filter out checked row item
////                selectedCards = selectedCards.filter{$0 != searchData[indexPath.row]["patientID"]!}
////                selectedRows = selectedRows.filter{$0 != indexPath.row}
////                if selectedCards.count == 0 {
////                    marqueeLabel.text = " "
////                } else {
////                    marqueeLabel.text = selectedCards.joined(separator: ",")// + ","
////                }
////
////            } else {
////                cell.accessoryType = .checkmark
////                checked[indexPath.row] = true
////                selectedCards.append(searchData[indexPath.row]["patientID"]!)
////                selectedRows.append(indexPath.row)
////
////                //Array of strings to string
////                marqueeLabel.text = selectedCards.joined(separator: ",")// + ","
////            }
////            //WORKS MULTIPLE CHECKED ^^ ---------------------------------------------------------------
//        }
//    }
}

extension CloudVC{
    //
    // #MARK: - SEARCH BAR
    //
    func predicateFilter(scopePredicate:NSPredicate){
        let arr=(cloudData as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            searchData=arr as! Array<Dictionary<String,String>>
        } else {
            searchData=cloudData
        }
        //SORT
        //let sortResults = searchData.sorted { $0["intakeDate"]! > $1["intakeDate"]! }
        //searchData = sortResults
        sortSearchDataNow()
        
        cloudPatientsTable.reloadData()
        //viewTitle.text = "My Active Patients (\(SearchData.count))"
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let patientIdPredicate = NSPredicate(format: "SELF.patientID CONTAINS[cd] %@", searchText)
        let intakeDatePredicate = NSPredicate(format: "SELF.intakeDate CONTAINS[cd] %@", searchText)
        let ownerPredicate = NSPredicate(format: "SELF.owner CONTAINS[cd] %@", searchText)
        
        let orPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [patientIdPredicate, intakeDatePredicate, ownerPredicate])
        
        predicateFilter(scopePredicate:orPredicate)//<- reload table occurs in this function
        searchFilterResultLabel.text = "\(searchData.count) found"
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
        searchData=cloudData
        
        //let sortResults = cloudData.sorted { $0["intakeDate"]! > $1["intakeDate"]! }
        //searchData = sortResults
        cloudPatientsTable.reloadData()
        searchFilterResultLabel.text = ""
    }
    //
    //MARK - Sort Function
    //
    func sortSearchDataNow(){
        //Sort in place.
        searchData.sort {
            $0["intakeDate"]!.compare($1["intakeDate"]!, options: .numeric) == .orderedAscending
        }
    }
}


extension CloudVC{
    //
    // #MARK: - API Calls
    //
    
    func getPatientRecordsCount() {
        let getCountFlag = DispatchGroup(); getCountFlag.enter()
        GETPatientCount().pCount(dispachInstance: getCountFlag)
        getCountFlag.notify(queue: DispatchQueue.main) {
            let count = UserDefaults.standard.object(forKey: "dataBaseCount") as? String ?? ""
            if count == ""{ self.cloudCount.text = "Cloud Cage Card Search"
            } else { self.cloudCount.text = "Search \(count) Cage Cards From The Cloud" }
        }
    }
    
    func getAllFromPatientsTable(){
        
        let getPatientsFlag = DispatchGroup(); getPatientsFlag.enter()
        GETPatients().getPatients(dispachInstance: getPatientsFlag)
        
        getPatientsFlag.notify(queue: DispatchQueue.main){
        
            self.cloudData = UserDefaults.standard.object(forKey: "dataBasePatients") as? Array<Dictionary<String,String>> ?? []
            
            self.checked = Array(repeating: false, count: self.cloudData.count)
            
            //let sortResults = self.cloudData.sorted { $0["intakeDate"]! > $1["intakeDate"]! }
            //self.cloudData = sortResults
            self.searchData = self.cloudData
            self.sortSearchDataNow()
            self.cloudData = self.searchData
            self.cloudPatientsTable.reloadData()
            
            // HIDE ACTIVITY INDICATOR, call the function from your view controller
            ViewControllerUtils().hideActivityIndicator(uiView: self.view)
            self.view.viewWithTag(1)?.removeFromSuperview()
        }
    }
    
    func getData(id: String, idName: String, tableName: String, appendHere: String, saveDefaults: String){
        let getDataFlag = DispatchGroup(); getDataFlag.enter()
        GET().recordFor(id: id, idName: idName, tableName: tableName, saveDefaults: saveDefaults, dispachInstance: getDataFlag)
        getDataFlag.notify(queue: DispatchQueue.main){
            let APIData = UserDefaults.standard.object(forKey: saveDefaults) as? Array<Dictionary<String,Any>> ?? []
            var appendArray = UserDefaults.standard.object(forKey: appendHere) as? Array<Dictionary<String,String>> ?? []
            
            for dict in APIData{
                var convertedDict = [String: String]()
                
                dict.forEach { convertedDict[$0.0] = "\($0.1)" } //convert dictionary Any to String. [String: Any] - > [String: String]
                
                //if appendHere == "ampms" || appendHere == "patientVitals" || appendHere == "procedures"{ "badges"
                    if  let value = dict["patientName"]{
                        convertedDict["patientID"] = "\(value)"
                    }
                //}
                if tableName == "treatmentVitals" {
                    if  let value = dict["mmCrt"]{
                        convertedDict["mm/Crt"] = "\(value)"
                    }
                    let convertedTxVitalsDict = [
                        "patientID":dict["patientName"],
                        "date":dict["date"],
                        "temperature":dict["temperature"],
                        "heartRate":dict["heartRate"],
                        "respirations":dict["respirations"],
                        "mm/Crt":dict["mmCrt"],
                        "diet":dict["diet"],
                        "v/D/C/S":dict["cSVD"],
                        "weightKgs":dict["weightKgs"],
                        "initials":dict["initials"],
                        "monitorFrequency":dict["monitorFrequency"],//daily or 2x daily
                        "monitorDays":dict["monitorDays"],
                        "monitored":dict["monitored"],//T,H,R,M, D,C,W,I
                        "group":dict["groupNumber"],//"1",//check and auto increment
                        "checkComplete":dict["checkComplete"]]
                    convertedDict = convertedTxVitalsDict as! [String : String]
                }
                
                appendArray.append(convertedDict)
            }
            
            UserDefaults.standard.set(appendArray, forKey: appendHere)
            UserDefaults.standard.synchronize()
        }
    }
}

extension CloudVC {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "segueCloudToPatientDB" {
            
            //selectedRow = ((cloudPatientsTable.indexPathForSelectedRow as NSIndexPath?)?.row)! //Int
            let selectedPatientID = searchData[selectedRow]["patientID"]!//selectedCards[0]//searchData[selectedRow]["patientID"]
            
            if let toViewController = segue.destination as? PatientsVC {
                toViewController.seguePatientID = selectedPatientID
            }
        }
    }
}

extension CloudVC {
    //
    // #MARK: - local storage update
    //
    func saveNewPatientLocally(thisSelectedRow:Int){

        let newP:Dictionary<String,String> =
            ["patientID":searchData[thisSelectedRow]["patientID"]!,
             "kennelID":searchData[thisSelectedRow]["kennelID"]!,
             "status":"Saved",
             "intakeDate":searchData[thisSelectedRow]["intakeDate"]!,
             "owner":searchData[thisSelectedRow]["owner"]!,
             "group":searchData[thisSelectedRow]["group"]!,
             "walkDate":searchData[thisSelectedRow]["walkDate"]!,
             "photo":searchData[thisSelectedRow]["photo"]!
        ]
        
        if patientRecords.isEmpty == false{
            patientRecords.append(newP)
            UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.set([newP], forKey: "patientRecords")
            UserDefaults.standard.synchronize()
        }
    }
    
}

extension CloudVC {
    @objc func marquee(){

        let str = marqueeLabel.text!
        let indexFirst = str.index(str.startIndex, offsetBy: 0)
        let indexSecond = str.index(str.startIndex, offsetBy: 1)
        marqueeLabel.text = String(str.suffix(from: indexSecond)) + String(str[indexFirst])

    }
}
