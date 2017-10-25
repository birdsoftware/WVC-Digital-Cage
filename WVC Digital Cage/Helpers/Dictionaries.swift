//
//  Dictionaries.swift
//  Brian Bird
//
//  Created by Brian Bird on 10/25/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    //DELETE
    //using .index(where:) method which performs performs 0(n):
    //https://stackoverflow.com/questions/43675437/how-to-delete-object-in-array-of-dictionaries-using-key-value
    func dictIndexFrom(array: [[String:String]], usingKey: String, usingValue: String) -> Array<Any>.Index?{
        let index = array.index(where: { (dictionary) -> Bool in
            guard let value = dictionary[usingKey]
                else { return false }
            return value == usingValue//255024731588044
        })
        return index
        //USE:
        // if let index = dictIndexFrom(array: array, usingKey:"photo_id", usingValue: "4") {
        //     array.remove(at: index)
        // }
    }
}
