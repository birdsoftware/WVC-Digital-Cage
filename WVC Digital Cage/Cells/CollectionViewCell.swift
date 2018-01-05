//
//  CollectionViewCell.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/10/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    // injuriesCollectionCell
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var patientIDLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var note: UILabel!
}

class txVitalsCollectionViewCell: UICollectionViewCell {
    // txVitalsCollectionCell
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var heartRT: UILabel!
    @IBOutlet weak var resp: UILabel!
    @IBOutlet weak var mmCrt: UILabel!
    @IBOutlet weak var diet: UILabel!
    @IBOutlet weak var csvd: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var initials: UILabel!
    @IBOutlet weak var deleteImage: UIImageView!
    @IBOutlet weak var backView: UIView!
}

class treatmentCollectionViewCell: UICollectionViewCell {
    // txCollectionCell
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var one: UILabel!
    @IBOutlet weak var two: UILabel!
    @IBOutlet weak var three: UILabel!
    @IBOutlet weak var four: UILabel!
    @IBOutlet weak var five: UILabel!
    @IBOutlet weak var deleteImage: UIImageView!
    
    @IBOutlet weak var six: UILabel!
    @IBOutlet weak var seven: UILabel!
    @IBOutlet weak var eight: UILabel!
    @IBOutlet weak var nine: UILabel!
    @IBOutlet weak var ten: UILabel!
    @IBOutlet weak var backView: UIView!
}
