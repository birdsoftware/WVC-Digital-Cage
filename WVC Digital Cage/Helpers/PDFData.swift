//
//  PDFData.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/4/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import UIKit
import Foundation

struct alignment {
    struct margin {
        static let left = 50
        static let right = 800
        static let top = 50
        static let bottom = 1050
    }
    struct line {
        static let height = 40
    }
    struct sizePage {
        static let width = 850
        static let height = 1100
    }
    struct columnWidth {
        static let txVitalColumnWidth = 160
    }
    struct columnHeight {
        static let vitalColumnHeight = 300
    }
}

extension UIViewController {
    func updatePage(lastUseHeight: Int, lastUseWidth: Int, pageCount: Int, textRecWidth: Int){
        let dictionary = ["lastUseHeight": lastUseHeight, "lastUseWidth":lastUseWidth, "pageCount":pageCount, "textRecWidth":textRecWidth]

        UserDefaults.standard.set(dictionary, forKey: "pdfData")
        UserDefaults.standard.synchronize()
    }
    func returnPageDictionary() -> [String : Int]{
        let pdfData = UserDefaults.standard.object(forKey: "pdfData") as? Dictionary<String,Int> ?? [:]
        return pdfData
    }
}
