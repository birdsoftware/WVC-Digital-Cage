//
//  textViewAlert.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 3/29/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func textAlertExample(){
        let alert = UIAlertController(title: "Add a note", message: nil, preferredStyle: .alert)
        let textView = UITextView()
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let controller = UIViewController()
        
        textView.frame = controller.view.frame
        controller.view.addSubview(textView)
        
        alert.setValue(controller, forKey: "contentViewController")
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.height * 0.8)
        
        // Submit button
//        let submitAction = UIAlertAction(title: "Update now", style: .default, handler: { (action) -> Void in
//            let textViewText = textView.text!
//            // Get TextField's text
//            var noteString = ""
//            if textViewText == "" {
//                noteString = "[\(self.todayTF.text!)] " + textViewText
//            } else {
//                noteString = self.notes.text + "\n[\(self.todayTF.text!)] " + textViewText
//            }
//
//            //update UI
//            self.notes.text = noteString
//
//            //save to local storage
//            if textViewText != "" {
//                self.saveTreatmentAndNotes()
//            }
//
//        })
//
//        // Cancel button
//        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
//
        alert.view.addConstraint(height)
//        alert.addAction(submitAction)
//        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
}
