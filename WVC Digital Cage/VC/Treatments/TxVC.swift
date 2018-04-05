//
//  TxVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/14/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

/*
 *  Change the Collection View "Scroll Direction" to "Horizontal" in Collection View  Box in
 *  Attributes Inspector.
 */

import MessageUI //send email
import UIKit
 //import QuartzCore

class TxVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate, /*email*/MFMailComposeViewControllerDelegate {
    
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
    
    @IBOutlet weak var LVTTF: UITextField!
    @IBOutlet weak var DVMTF: UITextField!
    @IBOutlet weak var DXTF: UITextField!
    
    //text view
    @IBOutlet weak var notes: UITextView!
    
    //button
    @IBOutlet weak var removeButton: RoundedButton!
    @IBOutlet weak var removeTreatmentButton: RoundedButton!
    
    //view
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var dragNotesTitleView: UIView!
    @IBOutlet weak var leftSideView: UIView!
    
    //layout
    @IBOutlet weak var notesViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var treatmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var treatmentLabelsHeightConstraint: NSLayoutConstraint!
    
    //Labels (UI)
    @IBOutlet weak var treatmentVitalsLabel: UILabel!
    @IBOutlet weak var treatmentsLabel: UILabel!
    
    //Labels (Treatment Cell) holding labels for 1st cell
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    @IBOutlet weak var threeLabel: UILabel!
    @IBOutlet weak var fourLabel: UILabel!
    @IBOutlet weak var fiveLabel: UILabel!
    @IBOutlet weak var sixLabel: UILabel!
    @IBOutlet weak var sevenLabel: UILabel!
    @IBOutlet weak var eightLabel: UILabel!
    @IBOutlet weak var nineLabel: UILabel!
    @IBOutlet weak var tenLabel: UILabel!
    //Labels (Treatment)
    @IBOutlet weak var tenTxLabel: UILabel!
    @IBOutlet weak var nineTxLabel: UILabel!
    @IBOutlet weak var eightTxLabel: UILabel!
    @IBOutlet weak var sevenTxLabel: UILabel!
    @IBOutlet weak var sixTxLabel: UILabel!
    @IBOutlet weak var fiveTxLabel: UILabel!
    @IBOutlet weak var fourTxLabel: UILabel!
    @IBOutlet weak var threeTxLabel: UILabel!
    @IBOutlet weak var twoTxLabel: UILabel!
    @IBOutlet weak var oneTxLabel: UILabel!
    @IBOutlet weak var dateTxLabel: UILabel!
    
    var todaysDateString = ""
    
    //segue data from patientsVC
    var seguePatientID: String!
    var segueShelterName: String!
    var seguePatientSex: String!
    var seguePatientAge: String!
    var seguePatientBreed: String!
    
    //Notes View pan
    var panGesture  = UIPanGestureRecognizer()
    
    //Treatment Vitals Dictionaries
    var collectionTxVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
    var filteredTxVitalsCollection = Array<Dictionary<String,String>>()
    
    //Treatments Dictionaries
    var collectionTreatments = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
    var filteredTreatments = Array<Dictionary<String,String>>()
    
    //bools
    var showDeleteImage = false
    var showDeleteImageTreatment = false
    
    var removeVitalsIndexSet = Set<Int>()
    var removeTreatmentIndexSet = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldsDelegates()
        textViewDelegates()
        setUI()
        connectPanGesture()
        
        //Treatment Vitals collection data
        filterDictionaryBy(selectedValue: seguePatientID, originalDictionary: &collectionTxVitals, filteredDict: &filteredTxVitalsCollection)
        
        //Treatments collection data
        filterDictionaryBy(selectedValue: seguePatientID, originalDictionary: &collectionTreatments, filteredDict: &filteredTreatments)
        
        useFilterDataToSetLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide remove buttons if No data to remove
        if filteredTxVitalsCollection.isEmpty { removeButton.isHidden = true }
        else { removeButton.isHidden = false }
        if filteredTreatments.isEmpty { removeTreatmentButton.isHidden = true }
        else { removeTreatmentButton.isHidden = false }
    }
    //
    // #MARK: - Button Action
    //
    @IBAction func removeTreatmentAction(_ sender: Any) {// VITAL
            if showDeleteImage{
                if removeVitalsIndexSet.isEmpty == false {

                    askToDeleteAlert(message:"", buttonTitle:"Cancel", type: "vital")
                    
                } else { setToNotSelected(button: removeButton, showImage: &showDeleteImage, collection: txVitalsCollection, dictionary: filteredTxVitalsCollection) }
            } else { setToSelected(button: removeButton,
                                     showImage: &showDeleteImage,
                                    collection: txVitalsCollection) }
    }
    @IBAction func removeUniqueTreatmentAction(_ sender: Any) {// TREATMENT
        if showDeleteImageTreatment {
            if removeTreatmentIndexSet.isEmpty == false {
                askToDeleteAlert(message:"", buttonTitle:"Cancel", type: "treatment")
            } else {
                setToNotSelected(button: removeTreatmentButton, showImage: &showDeleteImageTreatment, collection: txCollection, dictionary: filteredTreatments)
            }
        } else {
            setToSelected(button: removeTreatmentButton,
                            showImage: &showDeleteImageTreatment,
                                        collection: txCollection)
        }
    }
    @IBAction func addNotesAction(_ sender: Any) {
        //alertGetNote()
        textViewAlertGetNote()
    }
    @IBAction func emailAction(_ sender: Any) {
        saveTreatmentAndNotes()
        emailPDFTreatment(patientID: seguePatientID!)
    }
    func textViewAlertGetNote(){
        let alert = UIAlertController(title: "Add a note", message: "Date: \(todayTF.text!)", preferredStyle: .alert)
        let textView = UITextView()
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let controller = UIViewController()
        
        textView.frame = controller.view.frame
        controller.view.addSubview(textView)
        
        alert.setValue(controller, forKey: "contentViewController")
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.height * 0.8)
        
        // Submit button
        let submitAction = UIAlertAction(title: "Update now", style: .default, handler: { (action) -> Void in
            let textViewText = textView.text!
            // Get TextField's text
            var noteString = ""
            if textViewText == "" {
                noteString = "[\(self.todayTF.text!)] " + textViewText
            } else {
                noteString = self.notes.text + "\n[\(self.todayTF.text!)] " + textViewText
            }
            
            //update UI
            self.notes.text = noteString
            
            //save to local storage
            if textViewText != "" {
                self.saveTreatmentAndNotes()
            }
            
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.view.addConstraint(height)
        alert.addAction(submitAction)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
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
        todaysDateString = formatter.string(from: Date())
        todayTF.text = todaysDateString
        
        txVitalsCollection.delegate = self
        txVitalsCollection.dataSource = self
        txCollection.delegate = self
        txCollection.dataSource = self
        
        let treatmentsAndNotes = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []
        if treatmentsAndNotes.isEmpty == false {
            for tAndN in treatmentsAndNotes{
                if tAndN["patientID"] == seguePatientID {
                    LVTTF.text = tAndN["lVT"]
                    DVMTF.text = tAndN["dVM"]
                    DXTF.text = tAndN["dX"]
                    notes.text = tAndN["notes"]
                    break
                }
            }
        }
    }
    func useFilterDataToSetLabels(){
        //treatment labels treatmentHeightConstraint = 280
        if filteredTreatments.isEmpty == false {
            for treatment in filteredTreatments {
                if treatment["containsTreatmentLabels"] == "true"{
                    dateLabel.text = treatment["date"]
                    oneLabel.text = treatment["treatmentOne"]
                    twoLabel.text = treatment["treatmentTwo"]
                    threeLabel.text = treatment["treatmentThree"]
                    fourLabel.text = treatment["treatmentFour"]
                    fiveLabel.text = treatment["treatmentFive"]
                    sixLabel.text = treatment["treatmentSix"]
                    sevenLabel.text = treatment["treatmentSeven"]
                    eightLabel.text = treatment["treatmentEight"]
                    nineLabel.text = treatment["treatmentNine"]
                    tenLabel.text = treatment["treatmentTen"]
                    
                    if treatment["treatmentTen"] == "" {
                        notesViewTopConstraint.constant = -28
                        tenTxLabel.isHidden = true
                        if treatment["treatmentNine"] == "" {
                            notesViewTopConstraint.constant = notesViewTopConstraint.constant - 25
                            nineTxLabel.isHidden = true
                            if treatment["treatmentEight"] == "" {
                                notesViewTopConstraint.constant = notesViewTopConstraint.constant - 25
                                eightTxLabel.isHidden = true
                                if treatment["treatmentSeven"] == "" {
                                    notesViewTopConstraint.constant = notesViewTopConstraint.constant - 25
                                    sevenTxLabel.isHidden = true
                                    if treatment["treatmentSix"] == "" {
                                        //notesViewTopConstraint.constant = notesViewTopConstraint.constant - 25
                                        sixTxLabel.isHidden = true
                                        if treatment["treatmentFive"] == "" {
                                            fiveTxLabel.isHidden = true
                                            if treatment["treatmentFour"] == "" {
                                                fourTxLabel.isHidden = true
                                                if treatment["treatmentThree"] == "" {
                                                    threeTxLabel.isHidden = true
                                                    if treatment["treatmentTwo"] == "" {
                                                        twoTxLabel.isHidden = true
                                                        if treatment["treatmentOne"] == "" {
                                                            oneTxLabel.isHidden = true
                                                            dateTxLabel.isHidden = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    return
                }
            }
        }
    }
    func filterDictionaryBy(selectedValue: String, originalDictionary: inout [Dictionary<String,String>], filteredDict: inout [Dictionary<String,String>]){//collectionTxVitals filteredTxVitalsCollection
        var scopePredicate:NSPredicate
        scopePredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", selectedValue)
        let arr=(originalDictionary as NSArray).filtered(using: scopePredicate)
        if arr.isEmpty == false {//count > 0
            filteredDict = arr as! Array<Dictionary<String,String>>
        } else {
            filteredDict = Array<Dictionary<String,String>>()
        }
    }
}
extension TxVC {
    //
    // #MARK: - Collection View
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == txVitalsCollection {
            return filteredTxVitalsCollection.count
        } else {
            return filteredTreatments.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /* VITAL */
        if collectionView == txVitalsCollection {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "txVitalsCollectionCell", for: indexPath) as! txVitalsCollectionViewCell
            if showDeleteImage { cell.deleteImage.isHidden = false } else { cell.deleteImage.isHidden = true }
            
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
                colorCell(aCell: cell, aData: data)                                 /* grey */                /* 20% lighter */
                if (Int(data["group"]!)! % 2 == 0) { cell.backgroundColor = UIColor(hex: 0xb9c4c4) } else { cell.backgroundColor = UIColor(hex: 0xeaeded) }
                
                let cellDate = data["date"]!
                let truncatedCD = String(cellDate.dropLast(2))
                let truncatedDate = String(todaysDateString.dropLast(2))
                //print("truncatedDate \(truncatedDate) - truncatedCD \(truncatedCD)")
                if truncatedCD == truncatedDate {
                    cell.backView.isHidden = false
                    let thisView = cell.backView
                    createParticles(thisView: thisView)
                }else {
                    cell.backView.isHidden = true
                }
            }
            
            return cell
            
        }
        /* TREATMENT */
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "txCollectionCell", for: indexPath) as! treatmentCollectionViewCell
            if showDeleteImageTreatment { cell.deleteImage.isHidden = false } else { cell.deleteImage.isHidden = true }
            
            if filteredTreatments.isEmpty == false {
                let data = filteredTreatments[indexPath.row]
//                if data["containsTreatmentLabels"] == "false"{
                cell.date.text = data["date"]
                cell.one.text = data["treatmentOne"]
                cell.two.text = data["treatmentTwo"]
                cell.three.text = data["treatmentThree"]
                cell.four.text = data["treatmentFour"]
                cell.five.text = data["treatmentFive"]
                cell.six.text = data["treatmentSix"]
                cell.seven.text = data["treatmentSeven"]
                cell.eight.text = data["treatmentEight"]
                cell.nine.text = data["treatmentNine"]
                cell.ten.text = data["treatmentTen"]
                cell.backgroundColor = UIColor(hex: 0xeaeded)//b9c4c4)
                colorTxCell(aCell: cell, aData: data, row: indexPath.row)
                
                let cellDate = data["date"]!
                let truncatedCD = String(cellDate.dropLast(2))
                let truncatedDate = String(todaysDateString.dropLast(2))
                //print("truncatedDate \(truncatedDate) - truncatedCD \(truncatedCD)")
                if truncatedCD == truncatedDate {
                    cell.backView.isHidden = false
                    let thisView = cell.backView
                    createParticles(thisView: thisView)
                }else {
                    cell.backView.isHidden = true
                }
                }
            
            return cell
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /* VITAL */
        if collectionView == txVitalsCollection {
            
            let cell = collectionView.cellForItem(at: indexPath) as! txVitalsCollectionViewCell
            let lastCellColor = cell.backgroundColor
            if cell.isSelected {cell.backgroundColor = .WVCActionBlue()} else {cell.backgroundColor = lastCellColor}
        
            let selectedVital = filteredTxVitalsCollection[indexPath.row] //print("selectedVital: \(selectedVital)")
            if showDeleteImage {
                let selectedDict = filteredTxVitalsCollection[indexPath.row]
                updateUIGivenSelectedVitalCell(selectedDict: selectedDict, vitalCell: cell)
            } else {
                alertVitals(replaceCellColor: lastCellColor, forThisCell: cell, selectedVital: selectedVital)//edit cell
            }
        }
        /* TREATMENT */
        else {
            
            let cell = collectionView.cellForItem(at: indexPath) as! treatmentCollectionViewCell
            let lastCellColor = cell.backgroundColor
            if cell.isSelected {cell.backgroundColor = .WVCActionBlue()} else {cell.backgroundColor = lastCellColor}
            
            let selectedTreatment = filteredTreatments[indexPath.row]
            print("selectedTreatment \(selectedTreatment)")
            if showDeleteImageTreatment {
                let selectedDict = filteredTreatments[indexPath.row]
                updateUIGivenSelectedTxCell(selectedDict: selectedDict, txCell: cell)
            } else {
                // whatever is in "monitored": "1" will appear to initialize in alert
                alertTreatment(replaceCellColor: lastCellColor, forThisCell: cell, selectedTreatment: selectedTreatment)
            }
        }
    }
    //
    // Collection View Support Functions
    //
    func updateUIGivenSelectedVitalCell(selectedDict: [String : String], vitalCell:txVitalsCollectionViewCell){
        //insert Or remove index of selected
        //change background color based on selected
        //update remove button based on selected
        for index in 0..<collectionTxVitals.count{
            if collectionTxVitals[index]["patientID"] == selectedDict["patientID"]
                && collectionTxVitals[index]["date"] == selectedDict["date"]
                && collectionTxVitals[index]["group"] == selectedDict["group"] { //UPDATE
                //add selected index of collection to set
                if removeVitalsIndexSet.contains(index){
                    removeVitalsIndexSet.remove(index)
                    vitalCell.backgroundColor = UIColor(hex: 0xeaeded)
                } else { removeVitalsIndexSet.insert(index) }
                
                if removeVitalsIndexSet.isEmpty == false {
                    removeButton.setTitle("Remove \(removeVitalsIndexSet.count)", for: .normal)
                } else {
                    setToNotSelected(button: removeButton, showImage: &showDeleteImage, collection: txVitalsCollection, dictionary: filteredTxVitalsCollection)
                }
                return
            }
        }
    }
    func updateUIGivenSelectedTxCell(selectedDict: [String : String], txCell:treatmentCollectionViewCell){
        //insert Or remove index of selected
        //change background color based on selected
        //update remove button based on selected
        for index in 0..<collectionTreatments.count{
            if collectionTreatments[index]["patientID"] == selectedDict["patientID"]
                && collectionTreatments[index]["date"] == selectedDict["date"]
                && collectionTreatments[index]["containsTreatmentLabels"] == "false" { //UPDATE
                //add selected index of collection to set
                if removeTreatmentIndexSet.contains(index){
                    removeTreatmentIndexSet.remove(index)
                    txCell.backgroundColor = UIColor(hex: 0xeaeded)
                } else { removeTreatmentIndexSet.insert(index) }
                
                if removeTreatmentIndexSet.isEmpty == false {
                    removeTreatmentButton.setTitle("Remove \(removeTreatmentIndexSet.count)", for: .normal)
                } else {
                    setToNotSelected(button: removeTreatmentButton, showImage: &showDeleteImageTreatment, collection: txCollection, dictionary: filteredTreatments)
                }
                return
            }
        }
    }
    //Change colors
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
    
    func colorTxCell(aCell: treatmentCollectionViewCell, aData: [String:String], row: Int){
        //let currentColor = UIColor.WVCLightRed()
        //let isComplete = Bool(aData["checkComplete"]!)!
        let monitored = aData["monitored"]
        print("monitored \(monitored!), row \(row)")
        //let mOptions = ["1","2","3","4","5","6","7","8","9","T"]
        //let treatments = ["treatmentOne","treatmentTwo","treatmentThree","treatmentFour","treatmentFive","treatmentSix","treatmentSeven","treatmentEight","treatmentNine","treatmentTen"]
        //let cells = aCell as! Array<UITableViewCell>// = [aCell.one.backgroundColor, aCell.two.backgroundColor, aCell.three.backgroundColor, aCell.four.backgroundColor, aCell.five.backgroundColor, aCell.six.backgroundColor, aCell.seven.backgroundColor, aCell.eight.backgroundColor, aCell.nine.backgroundColor, aCell.ten.backgroundColor]
       // if isComplete { currentColor = UIColor.candyGreen() }
        
//        for index in 0..<treatments.count{
//            if monitored?.range(of:mOptions[index]) != nil {
//                if aData[treatments[index]] == "" {
//                    aCell.one.backgroundColor = .WVCLightRed()
//                } else {
//                    aCell.one.backgroundColor = .candyGreen() }
//            } else { aCell.one.backgroundColor = .clear }
//        }
        
        if monitored?.range(of:"1") != nil {
            if aData["treatmentOne"] == "" {
                aCell.one.backgroundColor = .WVCLightRed()
            } else {
                aCell.one.backgroundColor = .candyGreen() }
        } else { aCell.one.backgroundColor = .clear }
    
        if monitored?.range(of:"2") != nil {
            if aData["treatmentTwo"] == "" {
                aCell.two.backgroundColor = .WVCLightRed()
            } else {
                aCell.two.backgroundColor = .candyGreen() }
        } else { aCell.two.backgroundColor = .clear }

        if monitored?.range(of:"3") != nil {
            if aData["treatmentThree"] == "" {
                aCell.three.backgroundColor = .WVCLightRed()
            } else {
                aCell.three.backgroundColor = .candyGreen() }
        } else { aCell.three.backgroundColor = .clear }

        if monitored?.range(of:"4") != nil {
            if aData["treatmentFour"] == "" {
                aCell.four.backgroundColor = .WVCLightRed()
            } else {
                aCell.four.backgroundColor = .candyGreen() }
        } else { aCell.four.backgroundColor = .clear }
        
        if monitored?.range(of:"5") != nil {
            if aData["treatmentFive"] == "" {
                aCell.five.backgroundColor = .WVCLightRed()
            } else {
                aCell.five.backgroundColor = .candyGreen() }
        } else { aCell.five.backgroundColor = .clear }
        
        if monitored?.range(of:"6") != nil {
            if aData["treatmentSix"] == "" {
                aCell.six.backgroundColor = .WVCLightRed()
            } else {
                aCell.six.backgroundColor = .candyGreen() }
        } else { aCell.six.backgroundColor = .clear }
        
        if monitored?.range(of:"7") != nil {
            if aData["treatmentSeven"] == "" {
                aCell.seven.backgroundColor = .WVCLightRed()
            } else {
                aCell.seven.backgroundColor = .candyGreen() }
        } else { aCell.seven.backgroundColor = .clear }
        
        if monitored?.range(of:"8") != nil {
            if aData["treatmentEight"] == "" {
                aCell.eight.backgroundColor = .WVCLightRed()
            } else {
                aCell.eight.backgroundColor = .candyGreen() }
        } else { aCell.eight.backgroundColor = .clear }
        
        if monitored?.range(of:"9") != nil {
            if aData["treatmentNine"] == "" {
                aCell.nine.backgroundColor = .WVCLightRed()
            } else {
                aCell.nine.backgroundColor = .candyGreen() }
        } else { aCell.nine.backgroundColor = .clear }
        
        if monitored?.range(of:"T") != nil {
            if aData["treatmentTen"] == "" {
                aCell.ten.backgroundColor = .WVCLightRed()
            } else {
                aCell.ten.backgroundColor = .candyGreen() }
        } else { aCell.ten.backgroundColor = .clear }
        
    }
}
extension TxVC{
    //
    // #MARK: - custom alerts -> Note
    //
    func alertGetNote(){
        // Show Alert, get new vitals[n] text, show [Update] [Cancel] buttons
        let alert = UIAlertController(title: "Add a note",
                                      message: "Date: \(todayTF.text!)",
                                      preferredStyle: .alert)
        
        // Submit button
        let submitAction = UIAlertAction(title: "Update now", style: .default, handler: { (action) -> Void in
            
            // Get TextField's text
            var noteString = ""
            if self.notes.text == "" {
                noteString = "[\(self.todayTF.text!)] " + alert.textFields![0].text!
            } else {
                noteString = self.notes.text + "\n[\(self.todayTF.text!)] " + alert.textFields![0].text!
            }
            
            //update UI
            self.notes.text = noteString
            
            //save to local storage
            if alert.textFields![0].text! != "" {
                self.saveTreatmentAndNotes()
            }

        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })

        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Note"
            textField.clearButtonMode = .whileEditing
        }

        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    //
    // #MARK: - custom alerts -> Treatment
    //
    func alertTreatment(replaceCellColor: UIColor?, forThisCell: UICollectionViewCell, selectedTreatment: [String:String]){
        var treatment = ["patientID":selectedTreatment["patientID"]!,
                      "date":selectedTreatment["date"]!,
                      "treatmentOne":selectedTreatment["treatmentOne"]!,
                      "treatmentTwo":selectedTreatment["treatmentTwo"]!,
                      "treatmentThree":selectedTreatment["treatmentThree"]!,
                      "treatmentFour":selectedTreatment["treatmentFour"]!,
                      "treatmentFive":selectedTreatment["treatmentFive"]!,
                      "treatmentSix":selectedTreatment["treatmentSix"]!,
                      "treatmentSeven":selectedTreatment["treatmentSeven"]!,
                      "treatmentEight":selectedTreatment["treatmentEight"]!,
                      "treatmentNine":selectedTreatment["treatmentNine"]!,
                      "treatmentTen":selectedTreatment["treatmentTen"]!,
                      "monitorFrequency":selectedTreatment["monitorFrequency"]!,//daily or 2x daily
                      "monitorDays":selectedTreatment["monitorDays"]!,
                      "monitored":selectedTreatment["monitored"]!,
                      "checkComplete":selectedTreatment["checkComplete"]!,
                      "containsTreatmentLabels":"false"
        ]
        
        let monitored = selectedTreatment["monitored"]
        let mOptions = ["1","2","3","4","5","6","7","8","9","T"]
        let treatmets = ["treatmentOne","treatmentTwo","treatmentThree","treatmentFour","treatmentFive","treatmentSix","treatmentSeven","treatmentEight","treatmentNine","treatmentTen"]
        
        // Show Alert, get new vitals[n] text, show [Update] [Cancel] buttons
        let alert = UIAlertController(title: "Patient Treatments",
                                      message: "Inital Patient treatment(s)",
                                      preferredStyle: .alert)
        
        // Submit button
        let submitAction = UIAlertAction(title: "Update now", style: .default, handler: { (action) -> Void in
            // Get 6 TextField's text
            
        for index in 0..<mOptions.count{
            if monitored?.range(of:mOptions[index]) != nil {
                let t = alert.textFields![index].text!
                if (t.isEmpty == false) { treatment[ treatmets[index] ]! = t }
            }
        }
        
        forThisCell.backgroundColor = replaceCellColor
        
        //save to local storage and reload filtered based on patientID
        self.update(Treatment: treatment)
        self.filterDictionaryBy(selectedValue: self.seguePatientID, originalDictionary: &self.collectionTreatments, filteredDict: &self.filteredTreatments)
        
        self.txCollection.reloadData()
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in forThisCell.backgroundColor = replaceCellColor})
        
        // Add textFields and customize
        for index in 0..<mOptions.count{
            if monitored?.range(of:mOptions[index]) != nil {
                alert.addTextField { (textField: UITextField) in
                    textField.keyboardAppearance = .dark
                    textField.keyboardType = .default
                    textField.autocorrectionType = .default
                    textField.placeholder = "Treatment \(index+1)"
                    //show previously entered value in alert
                    if selectedTreatment[treatmets[index]]! != "" {textField.text = selectedTreatment[treatmets[index]]!}
                    textField.clearButtonMode = .whileEditing
                }
            }
        }
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func update(Treatment: [String:String]){
        if collectionTreatments.isEmpty == false {
            for index in 0..<collectionTreatments.count {
                if collectionTreatments[index]["patientID"] == Treatment["patientID"] && collectionTreatments[index]["date"] == Treatment["date"] &&
                    collectionTreatments[index]["containsTreatmentLabels"] == Treatment["containsTreatmentLabels"] { //UPDATE
                    for item in Treatment {
                        collectionTreatments[index][item.key] = item.value
                    }
                    UserDefaults.standard.set(collectionTreatments, forKey: "collectionTreatments")
                    UserDefaults.standard.synchronize()
                    return
                }
            }
        }
    }
    //
    // #MARK: - custom alerts -> Vitals
    //
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
            self.filterDictionaryBy(selectedValue: self.seguePatientID, originalDictionary: &self.collectionTxVitals, filteredDict: &self.filteredTxVitalsCollection)
            
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
    //
    // #MARK: - custom alerts -> Delete Vital or Treatment Cell?
    //
    func askToDeleteAlert(message:String,
                               buttonTitle:String,
                               type: String) {
        
        let selectedCount:Int = type == "vital" ? removeVitalsIndexSet.count : removeTreatmentIndexSet.count
        
        let plural:String = selectedCount > 1 ? "s" : ""
        
        let title = "Remove "+"\(selectedCount)"+" selected cell"+plural+"?"
        
        let myAlert = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        // Submit button
        let submitAction = UIAlertAction(title: "Remove", style: .default, handler: { (action) -> Void in
            //Remove Selected from Dictionary
            if type == "vital" {
                self.removeSelectedFromDict(itemsToRemove: self.removeVitalsIndexSet, fromThis: &self.collectionTxVitals, type: "vital")
                //Revert UI
                self.filterDictionaryBy(selectedValue: self.seguePatientID,
                                        originalDictionary: &self.collectionTxVitals,
                                        filteredDict: &self.filteredTxVitalsCollection)
                self.setButtonClearSet(type: "vital")
                
            } else {
                self.removeSelectedFromDict(itemsToRemove: self.removeTreatmentIndexSet, fromThis: &self.collectionTreatments, type: "treatment")
                //Revert UI
                self.filterDictionaryBy(selectedValue: self.seguePatientID,
                                        originalDictionary: &self.collectionTreatments,
                                        filteredDict: &self.filteredTreatments)
                self.setButtonClearSet(type: "treatment")
            }
            
        })
        
        myAlert.addAction(submitAction)
        
        //cancel button
        myAlert.addAction(UIAlertAction(title: buttonTitle, style: .destructive) { _ in
            if type == "vital" {
                self.setButtonClearSet(type: "vital")
            } else {
                self.setButtonClearSet(type: "treatment")
            }
        })
        present(myAlert, animated: true){}
    }
    func setButtonClearSet(type: String){
        if type == "vital" {
            self.setToNotSelected(button: self.removeButton, showImage: &self.showDeleteImage, collection: self.txVitalsCollection, dictionary: self.filteredTxVitalsCollection)
            self.removeVitalsIndexSet = Set<Int>()
        } else {
            self.setToNotSelected(button: self.removeTreatmentButton, showImage: &self.showDeleteImageTreatment, collection: self.txCollection, dictionary: self.filteredTreatments)
            self.removeTreatmentIndexSet = Set<Int>()
        }
    }
    func removeSelectedFromDict(itemsToRemove: Set<Int>, fromThis: inout [Dictionary<String, String>], type: String){
        //sort index in accending order ...,3,2,1,0
        let sortedArray = itemsToRemove.sorted(by: {$0>$1})
        for index in sortedArray {
            fromThis.remove(at: index)
            print("index: \(index)")
        }
        if type == "vital" {
            UserDefaults.standard.set(fromThis, forKey: "collectionTxVitals")
        } else {
            // Treatment
            //check to remove labels left over with Treatment Type
            var numberOfCellsWithoutLabel:Int? = nil
            for index in 0..<fromThis.count{
                if fromThis[index]["patientID"] == self.seguePatientID
                    && fromThis[index]["containsTreatmentLabels"] == "false"{
                    if numberOfCellsWithoutLabel != nil {
                        numberOfCellsWithoutLabel = numberOfCellsWithoutLabel! + 1
                    } else {
                        numberOfCellsWithoutLabel = 1
                    }
                }
            }
            if numberOfCellsWithoutLabel == nil {
                
                clearUILabelsHoldingCellLables()
                
                var indexToRemove = 0
                for index in 0..<fromThis.count{
                    if fromThis[index]["patientID"] == self.seguePatientID
                        && fromThis[index]["containsTreatmentLabels"] == "true"{
                        indexToRemove = index
                        break
                    }
                }
                //remove treatment cell with labels from defaults
                fromThis.remove(at: indexToRemove)
                print("index: \(index)")
            }
            UserDefaults.standard.set(fromThis, forKey: "collectionTreatments")
        }
        
        UserDefaults.standard.synchronize()
    }
    func clearUILabelsHoldingCellLables(){
        let labelArray:[UILabel] = [dateLabel, oneLabel,twoLabel,threeLabel,fourLabel,fiveLabel,sixLabel,sevenLabel,eightLabel,nineLabel,tenLabel]
        for label in labelArray {
            label.text = ""
        }
        
//        notesViewTopConstraint.constant = -28
//        tenTxLabel.isHidden = true
//        if treatment["treatmentNine"] == "" {
//            notesViewTopConstraint.constant = notesViewTopConstraint.constant - 25
//            nineTxLabel.isHidden = true
//            if treatment["treatmentEight"] == "" {
//                notesViewTopConstraint.constant = notesViewTopConstraint.constant - 25
//                eightTxLabel.isHidden = true
//                if treatment["treatmentSeven"] == "" {
//                    notesViewTopConstraint.constant = notesViewTopConstraint.constant - 25
    }
    func setToNotSelected(button: RoundedButton,
                          showImage: inout Bool,
                          collection: UICollectionView,
                          dictionary: [Dictionary<String,String>]){
        button.setTitle("Remove", for: .normal)
        button.backgroundColor = .white
        showImage = false
        collection.reloadData()
        if dictionary.isEmpty { button.isHidden = true }
    }
    func setToSelected(button: RoundedButton, showImage: inout Bool, collection: UICollectionView){
        button.backgroundColor = UIColor.WVCLightRed()
        showImage = true
        collection.reloadData() //txVitalsCollection
    }
}
extension TxVC {
    //
    // #MARK: - Setup Text View Delegates ADD: UITextViewDelegate
    //
    func textViewDelegates(){
        notes.delegate = self
        notes.tag = 0
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 0 {
            saveTreatmentAndNotes()
        }
    }
}
extension TxVC {
    //
    // #MARK: - Setup Text Field Delegates ADD: UITextFieldDelegate
    //
    func textFieldsDelegates(){
        LVTTF.delegate = self
        LVTTF.returnKeyType = UIReturnKeyType.next
        LVTTF.tag = 0
        DVMTF.delegate = self
        DVMTF.returnKeyType = UIReturnKeyType.next
        DVMTF.tag = 1
        DXTF.delegate = self
        DXTF.returnKeyType = UIReturnKeyType.next
        DXTF.tag = 2

    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= 0 && textField.tag <= 2{
            saveTreatmentAndNotes()
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
extension TxVC{
    //
    // #MARK: - Save
    //
    func animateToast(message: String){
    // ANIMATE  TOAST
        UIView.animate(withDuration: 1.1, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: { () -> Void in
        
        self.view.makeToast(message, duration: 1.1, position: .center)
        
        }, completion: { finished in})
    }
    
    func saveTreatmentAndNotes(){
        animateToast(message: "Saved Changes! (◕‿◕✿)")
        let newTreatAndNote =
            ["patientID":seguePatientID,
             "date":todayTF.text!,
             "shelter":segueShelterName,
             "sex":seguePatientSex,
             "age":seguePatientAge,
             "breed":seguePatientBreed,
             "lVT":LVTTF.text!,
             "dVM":DVMTF.text!,
             "dX":DXTF.text!,
             "notes":notes.text!
        ]
        
        var treatmentsAndNotes = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []
        var found = false
        if treatmentsAndNotes.isEmpty {//------------------CREATE----------
            UserDefaults.standard.set([newTreatAndNote], forKey: "treatmentsAndNotes")
            UserDefaults.standard.synchronize()
        } else {
            for index in 0..<treatmentsAndNotes.count {//--UPDATE by PID---
                if treatmentsAndNotes[index]["patientID"] == seguePatientID {
                    for item in newTreatAndNote {//patientID, date, shelter,..., notes
                        treatmentsAndNotes[index][item.key] = item.value
                    }
                    //treatmentsAndNotes[index]["notes"] = treatmentsAndNotes[index]["notes"]! + notes.text!
                    
                    UserDefaults.standard.set(treatmentsAndNotes, forKey: "treatmentsAndNotes")
                    UserDefaults.standard.synchronize()
                    found = true
                    return
                }
            }
            if found == false {//---------------------------APPEND NEW-----
                treatmentsAndNotes.append(newTreatAndNote as! [String : String])
                UserDefaults.standard.set(treatmentsAndNotes, forKey: "treatmentsAndNotes")
                UserDefaults.standard.synchronize()
            }
        }
    }
}
extension TxVC {
    
    func createParticles(thisView:UIView!) {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: thisView.center.x, y: 1)
        particleEmitter.emitterShape = kCAEmitterLayerLine
        particleEmitter.emitterSize = CGSize(width: thisView.frame.size.width, height: -8)
        particleEmitter.scale = 0.5
        
        let red = makeEmitterCell(color: UIColor.WVCActionBlue())
        let green = makeEmitterCell(color: UIColor(hex:0xFFD700))//UIColor.green)
        let blue = makeEmitterCell(color: UIColor.white)//.blue)
        
        particleEmitter.emitterCells = [red, green, blue]
        
        thisView.layer.addSublayer(particleEmitter)
    }
    
    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.velocity = 10
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        //let colorRefSeedcellcell = color.cgColor//UIColor.white.cgColor//(red: 1.00, green: 1.00, blue: 0.99, alpha: 1).cgColor
        cell.color = color.cgColor
        //cell.redSpeed = 0.17
        //cell.greenSpeed = -0.27
        //cell.blueSpeed = -0.53
        cell.alphaSpeed = -0.22
        cell.magnificationFilter = kCAFilterTrilinear
        //cell.minificationFilterBias = 0.78
        cell.scale = 0.2
        cell.scaleRange = 0.09
        cell.spin = 1.01
        cell.spinRange = 1.20
        cell.lifetime = 1.00
        cell.birthRate = 5.00
        cell.scaleSpeed = 0.09
        
        cell.contents = UIImage(named: "seedCell")?.cgImage
        return cell
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
