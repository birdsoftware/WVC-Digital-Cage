//
//  IntExtension.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/3/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation


extension Int {
    func times(_ f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
    func times( f: @autoclosure () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
}
/*
var s = "a"
3.times {
    s.append(Character("b"))
}
s // "abbb"


var d = 3.0
5.times(d += 1.0)
d // 8.0
*/
