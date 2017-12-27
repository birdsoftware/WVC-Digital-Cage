//
//  CollectionViewCell.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/10/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    //injuriesCollectionCell
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var patientIDLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var note: UILabel!
}

class txVitalsCollectionViewCell: UICollectionViewCell {
    //txVitalsCollectionCell
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
    
}
