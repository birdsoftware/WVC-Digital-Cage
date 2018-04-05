//
//  Badge.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/5/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

//import Foundation
import UIKit

extension UIViewController{
    func createBadgeFrom(UIlabel:UILabel, text: String) {
        UIlabel.clipsToBounds = true
        UIlabel.layer.cornerRadius = UIlabel.font.pointSize * 1.2 / 2
        UIlabel.backgroundColor = .white//.bostonBlue()
        UIlabel.textColor = .DarkRed()
        UIlabel.text = text
    }
}
