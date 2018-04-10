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
        drawTreatments(patientID:patientID)
        
        UIGraphicsEndPDFContext()
        
        return pdfPathWithFile
    }
    // 3. DRAW PDF HEADER, BACHGROUND, LOGO ```````````````````````````````` PDF
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
    // 4. DRAW treatment data and notes on top of page
    func drawTreatmentsAndNotes(patientID:String){
        let dictionary = getDataToPrint(forKey: "treatmentsAndNotes", patientID: patientID)

        var textRecWidth = 100; var textRecHeight = alignment.line.height
        var newTotalY = 120
        var newTotalX = 70
        var titleWidth = 60
        let titles = ["date", "lVT", "patientID",
                      "sex", "age", "shelter",
                      "breed", "dVM", "dX", "notes"]
        var notesEndLine = 0
        var title = CGRect()
        var value = CGRect()
        
        for item in titles {
            let word = item.camelCaseToWords()
            let uppercased = word.firstUppercased + ":"
            
            notesEndLine = 0
            titleWidth = stringWidth(item: item)//Int(width) + 20
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
                notesEndLine = 16
                //Figure out the height for notes
                let font = UIFont(name: "Helvetica", size: 16.0)
                let notesTotalLength = dictionary[item]!.size(OfFont: font!).width // size: {w: 98.912 h: 14.32}
                let numberRows = notesTotalLength/460
                let totalRowsHeight = Double(numberRows.rounded(.up)) * 16.32
                let totalRowsHeightInteger = Int(totalRowsHeight.rounded(.up))
                textRecWidth = 460;
                textRecHeight = totalRowsHeightInteger
                print("textRecHeight: \(textRecHeight)")
            }
            newTotalX += 170
            
            title = CGRect(x: newTotalX, y: newTotalY, width: textRecWidth, height: alignment.line.height)
            value = CGRect(x: newTotalX+titleWidth, y: newTotalY+notesEndLine, width: textRecWidth+90, height: textRecHeight)
            
            uppercased.draw(in: title, withAttributes: returnTitleAttributes())
            dictionary[item]?.draw(in: value, withAttributes: returnTextAttributes())
        }
        
        //UPDATE PDF META DATA
        updatePage(lastUseHeight: textRecHeight+200+20+notesEndLine, hasTreatmentVital: false, pageCount: 1, textRecWidth: 100)
    }
    func stringWidth(item: String) -> Int{
        let string = item//"hello world!"
        let font = UIFont(name: "Helvetica Bold", size: 16.0)
        let width = string.size(OfFont: font!).width // size: {w: 98.912 h: 14.32}
        return Int(width) + 20
    }
     // 5. REPEATING Treatment Vitals
    func drawTreatmentVitals(patientID:String){
        var hasTreatmentVital = false
        let array = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
        let pdfMeta = returnPageDictionary()
        
        //GET PDF META DATA
        let textRecWidth:Int = 110
        //let textRecHeight:Int = alignment.line.height
        var pageCount = pdfMeta["pageCount"]! as! Int
        var newTotalY = pdfMeta["lastUseHeight"]! as! Int
        if newTotalY < 310 {newTotalY = 310} //need to be below photo
        print("newTotalY: \(newTotalY)")
        
        var newTotalX = alignment.margin.left
        var titleWidth = 60
        let titles = [ "date", "temperature", "heartRate", "respirations", "mm/Crt", "diet", "v/D/C/S", "weightKgs", "initials" ]//, "monitorDays", "checkComplete", "patientID", "monitorFrequency", "monitored", "group"]
        var title = CGRect()
        var value = CGRect()
        if arrayContains(array:array, value:patientID) {//check if patient has Treatment Vital
            
            for column in array{
                if column["patientID"] == patientID {
                    hasTreatmentVital = true
                    //new column cariage return
                    if newTotalX >= alignment.margin.right {
                        newTotalX = alignment.margin.left
                        newTotalY += alignment.columnHeight.vitalColumnHeight
                    }
                    
                    //new page
                    if newTotalY >= 1100-alignment.columnHeight.vitalColumnHeight {
                        pageCount += 1
                        //Start new page
                        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
                        newTotalX = alignment.margin.left
                        newTotalY = alignment.margin.top
                    }
                    
                    for item in titles {
                        let word = item.camelCaseToWords()
                        let uppercased = word.firstUppercased + ":"
                        
                        titleWidth = stringWidth(item: item)
                        
                        title = CGRect(x: newTotalX, y: newTotalY, width: textRecWidth, height: alignment.line.height)
                        value = CGRect(x: newTotalX+titleWidth, y: newTotalY, width: textRecWidth+90, height: alignment.line.height)
                        
                        uppercased.draw(in: title, withAttributes: returnTitleAttributes())
                        column[item]?.draw(in: value, withAttributes: returnTextAttributes())
                        newTotalY += 30
                    }
                    newTotalY -= (titles.count*30)//go back to top of vital block "Date" y location or height
                    
                    newTotalX += alignment.columnWidth.txVitalColumnWidth
                }
            }
        }
        else {
            // no treatment vitals
           hasTreatmentVital = false
        }
        //UPDATE PDF META DATA
        updatePage(lastUseHeight: newTotalY, hasTreatmentVital: hasTreatmentVital, pageCount: pageCount, textRecWidth: 100)
        print("pageCount: \(pageCount)")
    }
    
    // 6. REPEATING Treatments
    func drawTreatments(patientID:String){
        let array = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
        let pdfMeta = returnPageDictionary()
        
        //GET PDF META DATA
        let textRecWidth:Int = 140
        let hasTreatmentVital:Bool = pdfMeta["hasTreatmentVital"]! as! Bool
        var pageCount = pdfMeta["pageCount"]! as! Int
        var newTotalY = pdfMeta["lastUseHeight"]! as! Int
        if hasTreatmentVital == true {
            newTotalY +=  alignment.columnHeight.vitalColumnHeight //if 5. exists above
        }
        print("newTotalY: \(newTotalY)")
        var newTotalX = alignment.margin.left
        var titleWidth = 100
    
        let titles = getTitles(patientID: patientID, array: array)
        let treatmentColumnHeight = titles.count * 31 + 31 //31 date, 62{1} 93{2} 124{3} 155 185 216 247 278 309 340
        
        var title = CGRect()
        var value = CGRect()
        if arrayContains(array:array, value:patientID) {//check if patient has Treatment Vital
            for column in array{
                if column["patientID"] == patientID {
                    
                    // cariage return new column
                    if newTotalX >= alignment.margin.right {
                        newTotalX = alignment.margin.left
                        newTotalY += treatmentColumnHeight//alignment.columnHeight.treatmentColumnHeight
                    }
                    
                    //new page
                    if newTotalY >= 1100-treatmentColumnHeight { //alignment.columnHeight.treatmentColumnHeight {
                        pageCount += 1
                        //Start new page
                        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 850, height: 1100), nil)
                        newTotalX = alignment.margin.left
                        newTotalY = alignment.margin.top
                    }
                    
                    for item in titles {
                        let word = item.camelCaseToWords()
                        let uppercased = word.firstUppercased + ":"
                        
                        titleWidth = stringWidth(item: item)
                        
                        title = CGRect(x: newTotalX, y: newTotalY, width: textRecWidth, height: alignment.line.height)
                        value = CGRect(x: newTotalX+titleWidth, y: newTotalY, width: textRecWidth+130, height: alignment.line.height)
                        
                        uppercased.draw(in: title, withAttributes: returnTitleAttributes())
                        column[item]?.draw(in: value, withAttributes: returnTextAttributes())
                        newTotalY += 30
                    }
                    newTotalY -= (titles.count*30)//go back to top of vital block "Date" y location or height
                    
                    newTotalX += alignment.columnWidth.treatmentWidth //this should be based on the width of longest treatment
                }
            }
        }
        print("pageCount: \(pageCount)")
    }
    func getTitles(patientID: String, array: Array<Dictionary<String,String>>) -> [String]{
        //let treatmentType = ["1","2","3","4","5","6","7","8","9","T"]
        for column in array{
            if column["patientID"] == patientID {
                return returnTitlesBasedOnMonitorList(monitoredString: column["monitored"]!)
            }
        }
        return [ "date" ]
    }
   func returnTitlesBasedOnMonitorList(monitoredString: String) -> [String]{
        if monitoredString.range(of:"T") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree", "treatmentFour", "treatmentFive", "treatmentSix", "treatmentSeven", "treatmentEight", "treatmentNine", "treatmentTen"]
        } else if monitoredString.range(of:"9") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree", "treatmentFour", "treatmentFive", "treatmentSix", "treatmentSeven", "treatmentEight", "treatmentNine"]
        } else if monitoredString.range(of:"8") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree", "treatmentFour", "treatmentFive", "treatmentSix", "treatmentSeven", "treatmentEight"]
        } else if monitoredString.range(of:"7") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree", "treatmentFour", "treatmentFive", "treatmentSix", "treatmentSeven"]
        } else if monitoredString.range(of:"6") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree", "treatmentFour", "treatmentFive", "treatmentSix"]
        } else if monitoredString.range(of:"5") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree", "treatmentFour", "treatmentFive"]
        } else if monitoredString.range(of:"4") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree", "treatmentFour"]
        } else if monitoredString.range(of:"3") != nil {
            return [ "date", "treatmentOne", "treatmentTwo", "treatmentThree"]
        } else if monitoredString.range(of:"2") != nil {
            return [ "date", "treatmentOne", "treatmentTwo"]
        } else if monitoredString.range(of:"1") != nil {
            return [ "date", "treatmentOne"]
        }
        
        else { return [ "date" ] }
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
