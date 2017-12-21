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
    
    //view
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var dragNotesTitleView: UIView!
    //layout
    @IBOutlet weak var notesViewTopConstraint: NSLayoutConstraint!
    //segue data from patientsVC
    var seguePatientID: String!
    var segueShelterName: String!
    
    var panGesture  = UIPanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        connectPanGesture()
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
        txVitalsCollection.delegate = self
        txVitalsCollection.dataSource = self
    }
}
extension TxVC {
    //
    // #MARK: - Collection
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1//(filteredCollection.count > 0 ? filteredCollection.count : 1)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "txVitalsCollectionCell", for: indexPath) as! txVitalsCollectionViewCell
//        if filteredCollection.isEmpty == false {
//            let data = filteredCollection[indexPath.row]
//            cell.date.text = data["date"]
//            cell.patientIDLabel.text = data["photo"]
//            cell.note.text = data["note"]
//            cell.image.image = returnImage(imageName: data["patientID"]! + "_\(indexPath.row).png")
//        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        //remove? yes no alert
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
            }
        }
    }
}
