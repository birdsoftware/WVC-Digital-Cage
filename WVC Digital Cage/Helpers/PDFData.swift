//
//  PDFData.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 4/4/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import UIKit
import Foundation

extension UIViewController {
    func updatePage(lastUseHeight: Int, lastUseWidth: Int, pageCount: Int, textRecWidth: Int, textRecHeight: Int){
        let dictionary = ["lastUseHeight": lastUseHeight, "lastUseWidth":lastUseWidth, "pageCount":pageCount, "textRecWidth":textRecWidth, "textRecHeight":textRecHeight]

        UserDefaults.standard.set(dictionary, forKey: "pdfData")
        UserDefaults.standard.synchronize()
    }
    func returnPageDictionary() -> [String : Int]{
        let pdfData = UserDefaults.standard.object(forKey: "pdfData") as? Dictionary<String,Int> ?? [:]
        return pdfData
    }
}
