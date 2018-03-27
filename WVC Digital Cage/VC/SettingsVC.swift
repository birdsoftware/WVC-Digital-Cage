//
//  SettingsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/26/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//
import MessageUI //send email
import UIKit

class SettingsVC: UIViewController,/*email*/MFMailComposeViewControllerDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var devButton: UIButton!
    @IBOutlet weak var versionBuildLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap))
        tapGesture.numberOfTapsRequired = 5
        devButton.addGestureRecognizer(tapGesture)
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let build = Bundle.main.infoDictionary!["CFBundleVersion"]!
        versionBuildLabel.text = "Version: \(version), build: \(build) "
        
        let savedUserEmailAddress = UserDefaults.standard.string(forKey: "userEmailAddress") ?? ""
        if savedUserEmailAddress == "" {
            emailAddress.placeholder = "First initial.last@wvc.org"
        } else {
            emailAddress.text = savedUserEmailAddress
        }
    }
    @objc func normalTap(_ sender: UIGestureRecognizer){
        // create the alert
        let alert = UIAlertController(title: "Add Test Data", message: "This is my message.", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            self.addTestData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func saveChangesAction(_ sender: Any) {
        let userEmailAddress = emailAddress.text
        UserDefaults.standard.set(userEmailAddress, forKey: "userEmailAddress")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "segueFromSettingsToMainDB", sender: self)
    }

    @IBAction func emailHelpAction(_ sender: Any) {
        sendEmailWithAttachemnt()
    }
}
extension SettingsVC {
    func sendEmailWithAttachemnt(){
        //let savedUserEmailAddress = UserDefaults.standard.string(forKey: "userEmailAddress") ?? ""
        
        let emailMessage = "<p> Please help me with the following issue or bug: "
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self //as! MFMailComposeViewControllerDelegate
            
            mail.setToRecipients([/*"bbirdunlv@yahoo.com",*/"b.bird@wvc.org"])
            mail.setSubject("WVC DCA Bug Report:")
            mail.setMessageBody(emailMessage, isHTML: true)
            
            //let pdfPathWithFile = generatePDFFile(patientID: patientID)
            
            //let fileData = NSData(contentsOfFile:pdfPathWithFile)
            
            //mail.addAttachmentData(fileData! as Data, mimeType: "application/pdf", fileName: "treatmentRecord.pdf")
            self.present(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Could Not Send Email", message:"Your device must have an acctive mail account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
        }
    }
    // #MARK: -  Dismiss Email Controller
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        //emailActive = false
        controller.dismiss(animated: true, completion: nil)
    }
}
