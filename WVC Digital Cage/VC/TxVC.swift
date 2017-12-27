//
//  TxVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/14/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class TxVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //collections
    @IBOutlet weak var txVitalsCollection: UICollectionView!
    @IBOutlet weak var txCollection: UICollectionView!
    
    //text fields
    @IBOutlet weak var patientID: UITextField!
    @IBOutlet weak var shelterTF: UITextField!
    @IBOutlet weak var todayTF: UITextField!
    @IBOutlet weak var patientSexTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var breedTF: UITextField!
    //button
    @IBOutlet weak var removeButton: RoundedButton!
    
    //view
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var dragNotesTitleView: UIView!
    //layout
    @IBOutlet weak var notesViewTopConstraint: NSLayoutConstraint!
    //segue data from patientsVC
    var seguePatientID: String!
    var segueShelterName: String!
    var seguePatientSex: String!
    var seguePatientAge: String!
    var seguePatientBreed: String!
    
    var panGesture  = UIPanGestureRecognizer()
    
    var collectionTxVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
    var filteredTxVitalsCollection = Array<Dictionary<String,String>>()
    
    //bool
    var showDeleteImage = false
    
    var removeVitalsIndexSet = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        connectPanGesture()
        filterTxVitalsBy(selectedValue: seguePatientID)
    }
    override func viewWillAppear(_ animated: Bool) {
        if filteredTxVitalsCollection.isEmpty { removeButton.isHidden = true }
        else { removeButton.isHidden = false }
    }
    //
    // #MARK: - Button Action
    //
    @IBAction func removeTreatmentAction(_ sender: Any) {
            if showDeleteImage{
                if removeVitalsIndexSet.isEmpty == false {
                    let selectedCount = removeVitalsIndexSet.count
                    var plural = ""
                    if selectedCount > 1 { plural = "s" }
                    askToDeleteVitalAlert(title:"Remove "+"\(selectedCount)"+" selected cell"+plural+"?", message:"", buttonTitle:"Cancel")
                } else { resetRemoveButtonToNotSelected() }
            } else { resetRemoveButtonToSelected() }
    }
}
extension TxVC {
    //
    // #MARK: - Pan gesture
    //
    func connectPanGesture(){
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(TxVC.draggedView(_:)))
        notesView.isUserInteractionEnabled = true
        notesView.addGestureRecognizer(panGesture)
    }
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubview(toFront: notesView)
        let translation = sender.translation(in: self.view)
        notesView.center = CGPoint(x: notesView.center.x + translation.x, y: notesView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
}
extension TxVC {
    //
    // #MARK: - UI
    //
    func setUI(){
        patientID.text = seguePatientID
        shelterTF.text = segueShelterName
        patientSexTF.text = seguePatientSex
        breedTF.text = seguePatientBreed
        ageTF.text = seguePatientAge
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy a"
        let nowString = formatter.string(from: Date())
        todayTF.text = nowString
        txVitalsCollection.delegate = self
        txVitalsCollection.dataSource = self
    }
    func filterTxVitalsBy(selectedValue: String){
        var scopePredicate:NSPredicate
        scopePredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", selectedValue)
        let arr=(collectionTxVitals as NSArray).filtered(using: scopePredicate)
        if arr.isEmpty == false {//count > 0
            filteredTxVitalsCollection=arr as! Array<Dictionary<String,String>>
        } else {
            filteredTxVitalsCollection=Array<Dictionary<String,String>>()
        }
    }
}
extension TxVC {
    //
    // #MARK: - Collection View
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTxVitalsCollection.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "txVitalsCollectionCell", for: indexPath) as! txVitalsCollectionViewCell
        if showDeleteImage {
            cell.deleteImage.isHidden = false
        } else { cell.deleteImage.isHidden = true }
        if filteredTxVitalsCollection.isEmpty == false {
            let data = filteredTxVitalsCollection[indexPath.row]
            cell.date.text = data["date"]
            cell.temperature.text = data["temperature"]
            cell.heartRT.text = data["heartRate"]
            cell.resp.text = data["respirations"]
            cell.mmCrt.text = data["mm/Crt"]
            cell.diet.text = data["diet"]
            cell.csvd.text = data["v/D/C/S"]
            cell.weight.text = data["weightKgs"]
            cell.initials.text = data["initials"]
            colorCell(aCell: cell, aData: data)                                 /* grey*/                /*20% lighter*/
            if (Int(data["group"]!)! % 2 == 0) {cell.backgroundColor = UIColor(hex: 0xb9c4c4)} else {cell.backgroundColor = UIColor(hex: 0xeaeded)}
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! txVitalsCollectionViewCell
        let lastCellColor = cell.backgroundColor
        if cell.isSelected {cell.backgroundColor = .WVCActionBlue()} else {cell.backgroundColor = lastCellColor}
        let selectedVital = filteredTxVitalsCollection[indexPath.row] //print("selectedVital: \(selectedVital)")
        if showDeleteImage {
            let selectedDict = filteredTxVitalsCollection[indexPath.row]
            for index in 0..<collectionTxVitals.count{
                if collectionTxVitals[index]["patientID"] == selectedDict["patientID"]
                    && collectionTxVitals[index]["date"] == selectedDict["date"]
                    && collectionTxVitals[index]["group"] == selectedDict["group"] { //UPDATE
                    //add selected index of collection to set
                    if removeVitalsIndexSet.contains(index){
                        removeVitalsIndexSet.remove(index)
                        cell.backgroundColor = UIColor(hex: 0xeaeded)
                    } else { removeVitalsIndexSet.insert(index) }
                    
                    if removeVitalsIndexSet.isEmpty == false {
                        removeButton.setTitle("Remove \(removeVitalsIndexSet.count)", for: .normal)
                    } else {
                        resetRemoveButtonToNotSelected()
                    }
                    return
                }
            }
        } else {
            //edit cell
            alertVitals(replaceCellColor: lastCellColor, forThisCell: cell, selectedVital: selectedVital)
        }
    }
    //
    // Collection View Support Functions
    //
    func colorCell(aCell: txVitalsCollectionViewCell, aData: [String:String]){
        var currentColor = UIColor.WVCLightRed()
        let isComplete = Bool(aData["checkComplete"]!)!
        let monitored = aData["monitored"]
        if isComplete { currentColor = UIColor.candyGreen() }
        if monitored?.range(of:"T") != nil { aCell.temperature.backgroundColor = currentColor } else {aCell.temperature.backgroundColor = .clear}
        if monitored?.range(of:"H") != nil { aCell.heartRT.backgroundColor = currentColor } else {aCell.heartRT.backgroundColor = .clear}
        if monitored?.range(of:"R") != nil { aCell.resp.backgroundColor = currentColor } else {aCell.resp.backgroundColor = .clear}
        if monitored?.range(of:"M") != nil { aCell.mmCrt.backgroundColor = currentColor } else {aCell.mmCrt.backgroundColor = .clear}
        if monitored?.range(of:"D") != nil { aCell.diet.backgroundColor = currentColor } else {aCell.diet.backgroundColor = .clear}
        if monitored?.range(of:"C") != nil { aCell.csvd.backgroundColor = currentColor } else {aCell.csvd.backgroundColor = .clear}
        if monitored?.range(of:"W") != nil { aCell.weight.backgroundColor = currentColor } else {aCell.weight.backgroundColor = .clear}
    }
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cellToDeselect = collectionView.cellForItem(at: indexPath) as! txVitalsCollectionViewCell
//        cellToDeselect.backgroundColor = lastCellColor
//    }
}
extension TxVC{
    // #MARK: - custom alerts
    func alertVitals(replaceCellColor: UIColor?, forThisCell: UICollectionViewCell, selectedVital: [String:String]){
        var vitals = ["patientID":selectedVital["patientID"]!,
                      "date":selectedVital["date"]!,
                      "temperature":"",
                      "heartRate":"",
                      "respirations":"",
                      "mm/Crt":"",
                      "diet":"",
                      "v/D/C/S":"",
                      "weightKgs":"",
                      "initials":"",
                      "monitorFrequency":selectedVital["monitorFrequency"]!,//daily or 2x daily
                      "monitorDays":selectedVital["monitorDays"]!,
                      "monitored":selectedVital["monitored"]!,
                      "group":selectedVital["group"]!,
                      "checkComplete":"true"
        ]
        // Show Alert, get new vitals[n] text, show [Update] [Cancel] buttons
        let alert = UIAlertController(title: "Patient Vitals",
                                      message: "Update patient vitals",
                                      preferredStyle: .alert)
        
        // Submit button
        let submitAction = UIAlertAction(title: "Update now", style: .default, handler: { (action) -> Void in
            // Get 6 TextField's text
            var temperature = alert.textFields![0].text!
            var heartRate = alert.textFields![1].text!
            var respirations = alert.textFields![2].text!
            var mmCrt = alert.textFields![3].text!
            var diet = alert.textFields![4].text!
            var csvd = alert.textFields![5].text!
            var weight = alert.textFields![6].text!
            var initials = alert.textFields![7].text!
            
            //check for empty fields
            if (temperature.isEmpty == false) { vitals["temperature"] = temperature } else { temperature = "" }
            if (heartRate.isEmpty == false) { vitals["heartRate"] = heartRate } else { heartRate = "" }
            if (respirations.isEmpty == false) { vitals["respirations"] = respirations } else { respirations = "" }
            if (mmCrt.isEmpty == false) { vitals["mm/Crt"] = mmCrt } else {  mmCrt = "" }
            if (diet.isEmpty == false) {  vitals["diet"] = diet } else { diet = "" }
            if (csvd.isEmpty == false) { vitals["v/D/C/S"] = csvd } else {  csvd = ""  }
            if (weight.isEmpty == false) { vitals["weightKgs"] = weight } else { weight = "" }
            if (initials.isEmpty == false) { vitals["initials"] = initials } else { initials = "" }
            
            forThisCell.backgroundColor = replaceCellColor
            
            self.update(Vital: vitals)
            self.filterTxVitalsBy(selectedValue: self.seguePatientID)
            
            //self.saveVitalsToWebServer
            
            self.txVitalsCollection.reloadData()
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in forThisCell.backgroundColor = replaceCellColor})
        
        // Add Temp textField and customize
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Temperature °F"
            if selectedVital["temperature"]! != "" {textField.text = selectedVital["temperature"]!}
            textField.clearButtonMode = .whileEditing
        }
        // . Heart Rate .
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Heart Rate"
            if selectedVital["heartRate"]! != "" {textField.text = selectedVital["heartRate"]!}
            textField.clearButtonMode = .whileEditing
        }
        // . Respirations .
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Respirations"
            if selectedVital["respirations"]! != "" {textField.text = selectedVital["respirations"]!}
            textField.clearButtonMode = .whileEditing
        }
        // . MM/CRT .
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "MM/CRT"
            if selectedVital["mm/Crt"]! != "" {textField.text = selectedVital["mm/Crt"]!}
            textField.clearButtonMode = .whileEditing
        }
        // . Diet .
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Diet"
            if selectedVital["diet"]! != "" {textField.text = selectedVital["diet"]!}
            textField.clearButtonMode = .whileEditing
        }
        // . csvd .
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "C/S/V/D"
            if selectedVital["v/D/C/S"]! != "" {textField.text = selectedVital["v/D/C/S"]!}
            textField.clearButtonMode = .whileEditing
        }
        // . weight .
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Weight Kgs"
            if selectedVital["weightKgs"]! != "" {textField.text = selectedVital["weightKgs"]!}
            textField.clearButtonMode = .whileEditing
        }
        // . initials .
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Initials required"
            if selectedVital["initials"]! != "" {textField.text = selectedVital["initials"]!}
            textField.clearButtonMode = .whileEditing
        }
        
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func update(Vital: [String:String]){
        if collectionTxVitals.isEmpty == false {
            for index in 0..<collectionTxVitals.count {
                if collectionTxVitals[index]["patientID"] == Vital["patientID"] && collectionTxVitals[index]["date"] == Vital["date"] && collectionTxVitals[index]["group"] == Vital["group"] { //UPDATE
                    for item in Vital {
                        collectionTxVitals[index][item.key] = item.value
                    }
                    UserDefaults.standard.set(collectionTxVitals, forKey: "collectionTxVitals")
                    UserDefaults.standard.synchronize()
                    return
                }
            }
        }
    }
    func askToDeleteVitalAlert(title:String, message:String, buttonTitle:String) {
        
        let myAlert = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)

        // Submit button
        let submitAction = UIAlertAction(title: "Remove", style: .default, handler: { (action) -> Void in
            //Remove Selected from Dictionary
            //sort index in accending order ...,3,2,1,0
            let sortedArray = self.removeVitalsIndexSet.sorted(by: {$0>$1})
            for index in sortedArray {
                self.collectionTxVitals.remove(at: index)
                print("index: \(index)")
            }
            UserDefaults.standard.set(self.collectionTxVitals, forKey: "collectionTxVitals")
            UserDefaults.standard.synchronize()
            //Revert UI
            self.filterTxVitalsBy(selectedValue: self.seguePatientID)
            self.resetRemoveButtonToNotSelected()//reload filted dictionary data
            self.removeVitalsIndexSet = Set<Int>()
        })
        
        myAlert.addAction(submitAction)
        
        //cancel button
        myAlert.addAction(UIAlertAction(title: buttonTitle, style: .destructive) { _ in
            self.resetRemoveButtonToNotSelected()
            self.removeVitalsIndexSet = Set<Int>()
        })
        present(myAlert, animated: true){}
        
    }
    func resetRemoveButtonToNotSelected(){
        removeButton.setTitle("Remove", for: .normal)
        removeButton.backgroundColor = UIColor.WVCLightRed()
        showDeleteImage = false
        txVitalsCollection.reloadData()
        if filteredTxVitalsCollection.isEmpty { removeButton.isHidden = true }
        else { //removeButton.isHidden = false
        }
    }
    func resetRemoveButtonToSelected(){
        removeButton.backgroundColor = .white
        showDeleteImage = true
        txVitalsCollection.reloadData()
    }
}
extension TxVC {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {//<-Back
        if segue.identifier == "segueTxToPatientDB" {
            if let toVC = segue.destination as? PatientsVC {
                toVC.seguePatientID = seguePatientID
            }
        } else if segue.identifier == "segueTxVCToaddTxVital" {//FORWARD -> addTxVital
            if let toVC = segue.destination as? addTxVital {
                toVC.seguePatientID = seguePatientID
                toVC.segueShelterName = segueShelterName
                toVC.seguePatientSex = seguePatientSex
                toVC.seguePatientAge = seguePatientAge
                toVC.seguePatientBreed = seguePatientBreed
            }
        } else if segue.identifier == "segueTxVCToaddTx" {//FORWARD -> addTx
            if let toVC = segue.destination as? addTx {
                toVC.seguePatientID = seguePatientID
                toVC.segueShelterName = segueShelterName
                toVC.seguePatientSex = seguePatientSex
                toVC.seguePatientAge = seguePatientAge
                toVC.seguePatientBreed = seguePatientBreed
            }
        }
    }
}
