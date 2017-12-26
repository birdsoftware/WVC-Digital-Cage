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
    
//    var newTxVitalCollection = [
//    [
//        "patientID":"snowball",
//        "date":"12/21/17",
//        "temperature":"103.9",
//        "heartRate":"130",
//        "respirations":"46",
//        "mm/Crt":"PL2",
//        "diet":"wet",
//        "v/D/C/S":"V/C",
//        "weightKgs":"21.3",
//        "initials":"B.B.",
//        "monitorFrequency":"daily",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"1",
//        "checkComplete":"true"
//    ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ],
//    [
//        "patientID":"snowball",
//        "date":"12/22/17",
//        "temperature":"102",
//        "heartRate":"",
//        "respirations":"",
//        "mm/Crt":"",
//        "diet":"",
//        "v/D/C/S":"V",
//        "weightKgs":"",
//        "initials":"A.B.",
//        "monitorFrequency":"",
//        "monitorDays":"1",
//        "monitored":"T,W",//T,H,R,M, D,C,W,I
//        "group":"2",
//        "checkComplete":"false"
//        ]]
    var collectionTxVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
    var filteredTxVitalsCollection = Array<Dictionary<String,String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        connectPanGesture()
        filterTxVitalsBy(selectedValue: seguePatientID)
    }
}
extension TxVC {
    
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
        if arr.count > 0
        {
            filteredTxVitalsCollection=arr as! Array<Dictionary<String,String>>
        } else {
            filteredTxVitalsCollection=Array<Dictionary<String,String>>()
        }
    }
}
extension TxVC {
    //
    // #MARK: - Collection
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTxVitalsCollection.count// > 0 ? filteredTxVitalsCollection.count : 1)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "txVitalsCollectionCell", for: indexPath) as! txVitalsCollectionViewCell
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
            colorCell(aCell: cell, aData: data)
            if (Int(data["group"]!)! % 2 == 0) {//ALTERNATE BY GROUP NUMBER
                cell.backgroundColor = UIColor(hex: 0xb9c4c4)//.WVCLightGray()
            }else {
                cell.backgroundColor = UIColor(hex: 0xeaeded)//7 shades lighter gray
            }
        }
        
        
        return cell
    }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        //remove? yes no alert
        simpleAlert(title: "Do somthing", message: "remove, update and save.", buttonTitle: "OK")
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
        } else if segue.identifier == "segueTxVCToaddTxVital" {//FORWARD->
            if let toVC = segue.destination as? addTxVital {
                toVC.seguePatientID = seguePatientID
                toVC.segueShelterName = segueShelterName
                toVC.seguePatientSex = seguePatientSex
                toVC.seguePatientAge = seguePatientAge
                toVC.seguePatientBreed = seguePatientBreed
            }
        }
    }
}
