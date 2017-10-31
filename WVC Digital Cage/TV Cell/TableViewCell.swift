//
//  TableViewCell.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class PatientTableView: UITableViewCell {
    //Identifier: patientCell
    @IBOutlet weak var dogPhoto: UIImageView!
    @IBOutlet weak var patientId: UILabel!
    @IBOutlet weak var kennelID: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var intakeDate: UILabel!
    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
}

class ProcedureIncisionCheck: UITableViewCell {
    //identifier: incisionCell
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var initials: UILabel!
}
