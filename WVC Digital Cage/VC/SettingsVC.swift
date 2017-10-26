//
//  SettingsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/26/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let savedUserEmailAddress = UserDefaults.standard.string(forKey: "userEmailAddress") ?? ""
        if savedUserEmailAddress == "" {
            emailAddress.placeholder = "First initial.last@wvc.org"
        } else {
            emailAddress.text = savedUserEmailAddress
        }
    }

    @IBAction func saveChangesAction(_ sender: Any) {
        let userEmailAddress = emailAddress.text
        UserDefaults.standard.set(userEmailAddress, forKey: "userEmailAddress")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "segueFromSettingsToMainDB", sender: self)
    }
}
