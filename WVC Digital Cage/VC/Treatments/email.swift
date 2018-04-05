import Foundation
import UIKit
import MessageUI //send email /*email*/MFMailComposeViewControllerDelegate

extension TxVC {
    //
    // #MARK: - email Treatement
    //
    func emailPDFTreatment(patientID: String){
        
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
        drawPatientPicture(imageName: patientID + ".png")
        
        drawTreatmentsAndNotes(patientID:patientID)
        drawTreatmentVitals(patientID:patientID)
        
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
    func getDataToPrint(forKey: String, patientID: String) -> [String : String]{
        let dictArray = UserDefaults.standard.object(forKey: forKey) as? Array<Dictionary<String,String>> ?? []
        var dictionary = Dictionary<String,String>()
        if let index = dictIndexFrom(array: dictArray, usingKey: "patientID", usingValue: patientID) {
            dictionary = dictArray[index]
        }
        return dictionary
    }
    func drawTreatmentsAndNotes(patientID:String){
        let dictionary = getDataToPrint(forKey: "treatmentsAndNotes", patientID: patientID)
//        let treatmentsAndNotes = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []
//        var treatDict = Dictionary<String,String>()
//        if let index = dictIndexFrom(array: treatmentsAndNotes, usingKey: "patientID", usingValue: patientID) {
//            treatDict = treatmentsAndNotes[index]
//        }
        var textRecWidth = 100; var textRecHeight = 40
        var newTotalY = 120
        var newTotalX = 70
        var titleWidth = 60
        let titles = ["date", "lVT", "patientID",
                      "sex", "age", "shelter",
                      "breed", "dVM", "dX", "notes"]
        
        var title = CGRect()
        var value = CGRect()
        
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            
            let string = item//"hello world!"
            let font = UIFont(name: "Helvetica", size: 14.0)
            let width = string.size(OfFont: font!).width // size: {w: 98.912 h: 14.32}
            titleWidth = Int(width) + 20
            //new line?
            if item == "sex" || item == "breed" || item == "notes" {
                newTotalY += 30
                newTotalX = 70
            }
            if item == "lVT" || item == "dVM" || item == "patientID" {
                titleWidth += 10
            }
            if item == "notes" {
                titleWidth = 0
                newTotalX = 70
                textRecWidth = 450; textRecHeight = 100
            }
            newTotalX += 170
            
            title = CGRect(x: newTotalX, y: newTotalY, width: textRecWidth, height: 40)
            value = CGRect(x: newTotalX+titleWidth, y: newTotalY, width: textRecWidth+90, height: textRecHeight)
            
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            dictionary[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
        print("x: \(newTotalX)")//240+100
        
        updatePage(lastUseHeight: 340, lastUseWidth: 0, pageCount: 1, textRecWidth: 100, textRecHeight: 40)
    }
    func drawTreatmentVitals(patientID:String){
        let treatmentVitals = getDataToPrint(forKey: "collectionTxVitals", patientID: patientID)
        let pdfMeta = returnPageDictionary()
        var textRecWidth:Int = 110//pdfMeta["textRecWid
        var textRecHeight:Int = pdfMeta["textRecHeight"]!
        var newTotalY = pdfMeta["lastUseHeight"]!
        var newTotalX = 70
        
        let titles = [ "date", "temperature", "heartRate", "respirations", "mm/Crt", "diet", "v/D/C/S", "weightKgs", "initials" ]
        //, "monitorDays", "checkComplete", "patientID", "monitorFrequency", "monitored", "group"]
        var title = CGRect()
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            
            
            
            title = CGRect(x: newTotalX, y: newTotalY, width: textRecWidth, height: textRecHeight)
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            newTotalY += 30
        }
    }
}//end extension

extension TxVC {
    // #MARK: - Text Font Attributes
    func returnTitle1Attributes() -> [NSAttributedStringKey: NSObject]{
        let fontTitle = UIFont(name: "Helvetica Bold", size: 19.0)!
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.left
        let textFontAttributes = [
            NSAttributedStringKey.font: fontTitle,
            NSAttributedStringKey.paragraphStyle: textStyle ]
        return textFontAttributes
    }
    func returnTitleAttributes() -> [NSAttributedStringKey: NSObject]{
        let fontTitle = UIFont(name: "Helvetica Bold", size: 16.0)!
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.left
        let textFontAttributes = [
            NSAttributedStringKey.font: fontTitle,
            NSAttributedStringKey.paragraphStyle: textStyle ]
        return textFontAttributes
    }
    func returnTextAttributes() -> [NSAttributedStringKey: NSObject]{
        let font:UIFont = UIFont(name:"Helvetica", size:14)!
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.left
        let textFontAttributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.paragraphStyle: textStyle ]
        return textFontAttributes
    }
}
