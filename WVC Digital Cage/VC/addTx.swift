//
//  addTx.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/27/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class addTx: UIViewController {

    //segue vars
    var seguePatientID: String!
    var segueShelterName: String!
    var seguePatientSex: String!
    var seguePatientAge: String!
    var seguePatientBreed: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    

}
extension addTx {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueaddTxToTxVC" {
            if let toVC = segue.destination as? TxVC {//<-BACK
                toVC.seguePatientID = seguePatientID
                toVC.segueShelterName = segueShelterName
                toVC.seguePatientSex = seguePatientSex
                toVC.seguePatientAge = seguePatientAge
                toVC.seguePatientBreed = seguePatientBreed
            }
        }
    }
}
