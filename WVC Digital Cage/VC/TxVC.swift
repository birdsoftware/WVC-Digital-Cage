//
//  TxVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/14/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class TxVC: UIViewController {

    var seguePatientID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
