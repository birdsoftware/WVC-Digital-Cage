//
//  DataStructures.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 3/27/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    struct Stack<Element> {//https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html
        var items = [Element]()
        mutating func push(_ item: Element) {
            items.append(item)
        }
        mutating func pop() -> Element {
            return items.removeLast()
        }
        mutating func peek() -> Element {
            return items.last!
        }
        mutating func pushFirst(_ item: Element) {
            items.insert(item, at: 0)
        }
        mutating func isEmpty() -> Bool {
            if items.count > 0 {
                return false
            }
            return true
        }
    }
}
