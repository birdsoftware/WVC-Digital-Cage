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
    @IBOutlet weak var cloudCount: UILabel!
    @IBOutlet weak var searchFilterResultLabel: UILabel!
    //search bar
    @IBOutlet weak var search: UISearchBar!
    
    
    //data
    var patientRecords = [Dictionary<String,String>]()//UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    var searchData = [Dictionary<String,String>]()
    var cloudData = [Dictionary<String,String>]()
    var searchActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudPatientsTable.delegate = self
        cloudPatientsTable.dataSource = self
        //searchData = patientRecords
        search.delegate = self
        //get count
        let getCountFlag = DispatchGroup(); getCountFlag.enter()
        GETPatientCount().pCount(dispachInstance: getCountFlag)
        getCountFlag.notify(queue: DispatchQueue.main) {
            let count = UserDefaults.standard.object(forKey: "dataBaseCount") as? String ?? ""
            if count == ""{
                self.cloudCount.text = "Cloud Cage Card Search"
            } else {
                self.cloudCount.text = "Search \(count) Cage Cards From The Cloud"
            }
        }
        
        //get all patients
        let getPatientsFlag = DispatchGroup(); getPatientsFlag.enter()
        GETPatients().getPatients(dispachInstance: getPatientsFlag)
        getPatientsFlag.notify(queue: DispatchQueue.main){
            self.cloudData = UserDefaults.standard.object(forKey: "dataBasePatients") as? Array<Dictionary<String,String>> ?? []
            let sortResults = self.cloudData.sorted { $0["intakeDate"]! > $1["intakeDate"]! }
            self.cloudData = sortResults
            self.searchData = self.cloudData
            self.cloudPatientsTable.reloadData()
        }
    }
}

extension CloudVC{
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchData.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: cloudTableView = tableView.dequeueReusableCell(withIdentifier: "cloudCell") as! cloudTableView
        
        var thisPatient = searchData[IndexPath.row]
        
        //cell.photo.image = returnImage(imageName: thisPatient["patientID"]! + ".png")
        cell.intakeDate.text = thisPatient["intakeDate"]
        cell.name.text = thisPatient["patientID"]
        cell.owner.text = thisPatient["owner"]
        cell.kennelId.text = thisPatient["kennelID"]
        cell.speciesGroup.text = thisPatient["group"]
        cell.status.text = thisPatient["status"]
        cell.count.text = "\(IndexPath.row+1)"
        
        return cell
    }
}

extension CloudVC{
    // #MARK: - SEARCH
    func predicateFilter(scopePredicate:NSPredicate){
        let arr=(cloudData as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            searchData=arr as! Array<Dictionary<String,String>>
        } else {
            searchData=cloudData
        }
        //SORT
        let sortResults = searchData.sorted { $0["intakeDate"]! < $1["intakeDate"]! }
        searchData = sortResults
        
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
        
        //let sortResults = cloudData.sorted { $0["intakeDate"]! < $1["intakeDate"]! }
        //searchData = sortResults
        cloudPatientsTable.reloadData()
        searchFilterResultLabel.text = ""
    }
}

