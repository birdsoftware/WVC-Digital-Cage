//
//  toggle.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/29/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

extension Bool {
    mutating func toggle() {
        self = !self
    }
}

/*
 * use: var myBool = true
 *      myBool.toggle()
 *
 * out: print("myBool: \(myBool)")
 */
