//
//  SimpleAlert.swift
//  Compadres
//
//  Created by Brian Bird on 8/16/17.
//  Copyright © 2017 MPM. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func simpleAlert(title:String, message:String, buttonTitle:String) {
        
        let myAlert = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        myAlert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in })
        present(myAlert, animated: true){}
        
    }
    
    func simpleTFAlert(title:String, message:String, buttonTitle:String, outputTextView:UITextView, senderTag: Int /*tag on switch*/, dispachInstance: DispatchGroup) {
        
        let myAlert = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        myAlert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {
            alert -> Void in
            //TODO: Add UITextField code
            dispachInstance.leave() // User Responded
        //Section 1
        let myComment = myAlert.textFields![0] as UITextField
        
        if myComment.text != "" {
            //TODO: Do something with this data
            //let firstTwoChars = String(message.characters.prefix(2))
            let original = outputTextView.text!
            outputTextView.text = original + "\n" + String(senderTag) + ") " + String(describing: myComment.text!)
            
        } else {
            //TODO: Add error handling
        }
    }))
            
            
        // Add Height textField and customize
        myAlert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = message + " comment"
            textField.clearButtonMode = .whileEditing
            
        }
        
        present(myAlert, animated: true){}
    }
}
