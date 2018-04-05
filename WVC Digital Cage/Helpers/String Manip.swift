//
//  String Manip.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/2/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func stringExists(longString: String, subString: String) -> Bool {
        return longString.range(of: subString) != nil
    }
    func removeString(longString: String, subString: String) -> String {
        return longString.components(separatedBy: subString).joined()
    }
    func appendString(longString: String, subString: String) -> String {
        return longString+subString
    }
    
    func replaceChars(inString: String, replace: String, with: String) -> String{
        return inString.replacingOccurrences(of: replace, with: with)
    }
}

extension String {
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
    }
}
