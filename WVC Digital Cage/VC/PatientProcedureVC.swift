//
//  PatientProcedureVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/27/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientProcedureVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var incisionTable: UITableView!
    
    var incisions = [["date":"10/27/17 10:22 AM","initials":"B.B."],["date":"10/26/17 11:02 AM","initials":"C.J."]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate
        incisionTable.delegate = self
        incisionTable.dataSource = self
    }
}
extension PatientProcedureVC {
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return incisions.count
        }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: ProcedureIncisionCheck = tableView.dequeueReusableCell(withIdentifier: "incisionCell") as! ProcedureIncisionCheck
        let this = incisions[IndexPath.row]//patientRecords[IndexPath.row]
        cell.date.text = this["date"]
        cell.initials.text = this["initials"]
        return cell
    }
}
