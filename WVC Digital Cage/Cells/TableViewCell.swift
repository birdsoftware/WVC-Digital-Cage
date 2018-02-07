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
    @IBOutlet weak var dogPhotoFrame: UIImageView!
    @IBOutlet weak var patientId: UILabel!
    @IBOutlet weak var kennelID: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var intakeDate: UILabel!
    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var missingPiece: UIImageView!
}

class ProcedureIncisionCheck: UITableViewCell {
    //identifier: incisionCell
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var initials: UILabel!
}

class NotificationsTableView: UITableViewCell {
    //identifier: notificationCell
    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var patientID: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var message: UILabel!
    
}

class AMPMTableView: UITableViewCell {
    //ident: ampmCell
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var attitude: UILabel!
    @IBOutlet weak var feces: UILabel!
    @IBOutlet weak var urine: UILabel!
    @IBOutlet weak var appetite: UILabel!
    @IBOutlet weak var VDCS: UILabel!
    @IBOutlet weak var initials: UILabel!
    @IBOutlet weak var ampmEmoji: UILabel!
    
}

class mapDisplayTableView: UITableViewCell {
    //mapDisplayCell
    @IBOutlet weak var dogPhoto: UIImageView!
    @IBOutlet weak var patientId: UILabel!
    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var intakeDate: UILabel!
    @IBOutlet weak var walkDate: UILabel!
    @IBOutlet weak var lastAMPMDate: UILabel!
    @IBOutlet weak var lastIncisionDate: UILabel!
    
}

class syncTableView: UITableViewCell {
    //syncCell
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
}
