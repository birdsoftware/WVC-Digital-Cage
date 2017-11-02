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
}