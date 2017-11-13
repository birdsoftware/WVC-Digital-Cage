//
//  StringExtensions.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/30/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation

extension String {
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) == true {
                return ($0 + " " + String($1))
            }
            else {
                return $0 + String($1)
            }
        }
    }
    //var camelCase = "generalAppearance"
    //camelCase = camelCase.camelCaseToWords()
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
