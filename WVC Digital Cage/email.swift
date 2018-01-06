import Foundation
import UIKit
import MessageUI //send email /*email*/MFMailComposeViewControllerDelegate

extension TxVC {
    //
    // #MARK: - email Treatement
    //
    func emailPDFTreatment(patientID: String){
        //Treatment Vitals Dictionaries
        //var collectionTxVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
        //var filteredTxVitalsCollection = Array<Dictionary<String,String>>()
        
        //Treatments Dictionaries
        //var collectionTreatments = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
        //var filteredTreatments = Array<Dictionary<String,String>>()
        
        sendEmailWithAttachemnt(patientID: patientID)
        
    }
    
    func sendEmailWithAttachemnt(patientID: String){
        
        let savedUserEmailAddress = UserDefaults.standard.string(forKey: "userEmailAddress") ?? ""
        
        let emailMessage = "<p> Please see attached PDF for Patient: " + patientID + " </p>"
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self //as! MFMailComposeViewControllerDelegate
            
            mail.setToRecipients([savedUserEmailAddress])//"bbirdunlv@yahoo.com","b.bird@wvc.org"])
            mail.setSubject("WVC DCC Patient: " + patientID)
            mail.setMessageBody(emailMessage, isHTML: true)
            
            let pdfPathWithFile = generatePDFFile(patientID: patientID)
            
            let fileData = NSData(contentsOfFile:pdfPathWithFile)
            
            mail.addAttachmentData(fileData! as Data, mimeType: "application/pdf", fileName: "treatmentRecord.pdf")
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
    // #MARK: - Generate PDF File
    func generatePDFFile(patientID: String) -> String {
        // 1. Generate file path then pdf to attach ---
        let fileName: NSString = "treatmentRecord.pdf" as NSString
        
        let path:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = path.object(at: 0) as! NSString
        let pdfPathWithFile = documentDirectory.appendingPathComponent(fileName as String)
        
        // 2. Generate PDF with file path ---
        UIGraphicsBeginPDFContextToFile(pdfPathWithFile, CGRect.zero, nil)
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
        drawBackground()
        drawImageLogo(imageName: "WVCLogog")
        //drawPatientRecordText(patientData: patientData)
        drawPatientPicture(imageName: patientID + ".png")
        //drawVitalsText(patientID:patientIDHere!)
        //drawPhysicalExam(patientID:patientIDHere!)
        //drawDemographicsText(patientID:patientIDHere!)
        //drawIncisions(patientID:patientIDHere!)
        drawTreatmentsAndNotes(patientID:patientID)
        //drawAMPMs(patientID:patientIDHere!)
        UIGraphicsEndPDFContext()
        
        return pdfPathWithFile
    }
    // PDF HEADER, BACHGROUND, LOGO ```````````````````````````````` PDF
    func drawBackground () {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        let rect:CGRect = CGRect(x:0, y:0, width:850, height:1100)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
    }
    func drawImageLogo(imageName: String) {
        let imageRect:CGRect = CGRect(x:350, y:30, width:200, height:63)
        let image = UIImage(named: imageName)
        
        image?.draw(in: imageRect)
    }
    func drawPatientPicture(imageName: String) {
        let imageRect:CGRect = CGRect(x:40, y:120, width:170, height:170)
        let image = returnImage(imageName: imageName)
        
        image.draw(in: imageRect)
    }
    // COLUMN 1 - Procedures & AM/PMs
    func drawTreatmentsAndNotes(patientID:String){
        let treatmentsAndNotes = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []
        var treat = Dictionary<String,String>()
//        if let index = dictIndexFrom(array: procedures, usingKey:"patientID", usingValue: patientID) {
//            proc = procedures[index]
//        }
//        for item in proc {
//            if item.value == "false" {
//                proc[item.key] = "No"
//            }
//            if item.value == "true" {
//                proc[item.key] = "Yes"
//            }
//        }
//        if arrayContains(array:treat, value:patientID) {//check if patient has incision
//            let titleTopString = "Procedure"
//            var newTotalY = 300
//            let xCol1 = 40 /*let xCol2 = 250 let xCol3 = 500*/
//            let textRecWidth = 200
//            let titleTop = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:40)
//            titleTopString.draw(in: titleTop, withAttributes: returnTitle1Attributes())
//            
//            let titles = ["lab", "bloodWork", "radiographs", "surgeryDate", "suture"]
//            var title = CGRect()
//            var value = CGRect()
//            let spacerTwenty = 20
//            newTotalY += 10
//            
//            for item in titles {
//                let word = item.camelCaseToWords()
//                let uppercased = word.firstUppercased + ":"
//                newTotalY += spacerTwenty
//                title = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:40)
//                newTotalY += spacerTwenty
//                value = CGRect(x: xCol1, y:newTotalY, width:textRecWidth, height:60)
//                uppercased.draw(in: title, withAttributes: returnTitleAttributes())
//                proc[item]?.draw(in: value, withAttributes: returnTextAttributes())
//            }
//        }
    }
}//end extension
