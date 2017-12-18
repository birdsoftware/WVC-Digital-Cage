//
//  TxVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/14/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class TxVC: UIViewController {
    
    //text fields
    @IBOutlet weak var patientID: UITextField!
    @IBOutlet weak var shelterTF: UITextField!
    
    //table
    @IBOutlet weak var txTable: UITableView!
    
    //segue data from patientsVC
    var seguePatientID: String!
    var segueShelterName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

}
extension TxVC {
    //
    // #MARK: Table View
    //
    
}

extension TxVC {
    //
    // #MARK: - UI
    //
    func setUI(){
        patientID.text = seguePatientID
        shelterTF.text = segueShelterName
    }
}
extension TxVC {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueTxToPatientDB" {
            if let toVC = segue.destination as? PatientsVC {
                toVC.seguePatientID = seguePatientID
            }
        }
    }
}
