//
//  MapVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/15/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class MapVC: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // constraints
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSinglesConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightDoublesConstraint: NSLayoutConstraint!
    @IBOutlet weak var triplesLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var doublesLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var singlesLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayWidthConstraint: NSLayoutConstraint!
    
    //rotated labels
    @IBOutlet weak var triplesLabel: UILabel!
    @IBOutlet weak var doublesLabel: UILabel!
    @IBOutlet weak var singlesLabel: UILabel!
    //display labels
    @IBOutlet weak var displayTitle: UILabel!
    
    //map view
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var displayUIView: UIView!
    
    //button
    @IBOutlet var singleButtons: [UIButton]!
    @IBOutlet weak var closeDisplayButton: UIButton!
    
    //table
    @IBOutlet weak var displayTable: UITableView!
    
    
    //class vars
    // S 1-8    D 9-16,17-24    T 25-37   I 38-41   42 cat room and cage banks
    var kennelIntArray = ["S1","S2","S3","S4","S5","S6","S7","S8",
                          "D1","D2","D3","D4","D5","D6","D7","D8","D9","D10",
                          "D11","D12","D13","D14","D15","D16",
                          "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10",
                          "T11","T12","T13",
                          "I1","I2","I3","I4",
                          "Cage Banks", "Cat room"]
    let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    
    let myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
    let incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
    
    var searchData = Array<Dictionary<String,String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleButtons?.enumerated().forEach({ index, button in
            //button.tag = index
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        })
        occupiedKennels()
        setupUI()
        
        displayTable.delegate = self
        displayTable.dataSource = self
    }
    @objc func buttonClicked(sender: UIButton?) {
        resetColors()
        let tag = sender?.tag ?? 0
        print("tagNum \(tag)")
        setDisplayText(tagNum: tag)
        updateSearchData(kennelID: kennelID(fromTagNo: tag))
        colorButtonBackground(color: UIColor.seaBuckthorn(), tagNo: tag)
        if topConstraint.constant == 0 {
            /* Animation */
            openDisplay()
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    @IBAction func closeDisplayAction(_ sender: Any) {
        /* Animation */
        closeDisplay()
        resetColors()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    func openDisplay(){
        displayUIView.alpha = 1
        rightSinglesConstraint.constant = 280
        rightDoublesConstraint.constant = 50
        triplesLabelConstraint.constant = -20
        doublesLabelConstraint.constant = -32
        singlesLabelConstraint.constant = -33
        displayWidthConstraint.constant = 240
    }
    func closeDisplay(){
        displayUIView.alpha = 0
        rightConstraint.constant = 0
        rightSinglesConstraint.constant = 136
        rightDoublesConstraint.constant = 117
        triplesLabelConstraint.constant = 10
        doublesLabelConstraint.constant = 3
        singlesLabelConstraint.constant = 2
        displayWidthConstraint.constant = 0
    }
}

extension MapVC{
    func setupUI(){
        displayUIView.alpha = 0
        displayWidthConstraint.constant = 0
        rotate(thisLabel: triplesLabel)
        rotate(thisLabel: doublesLabel)
        rotate(thisLabel: singlesLabel)
    }
    func rotate(thisLabel: UILabel){
        thisLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2.0)))
    }
    func resetColors(){
        for button in singleButtons{
            button.backgroundColor = UIColor.sailBlue()
        }
        occupiedKennels()
    }
}
extension MapVC{
    func occupiedKennels(){
        //-1 extra since singleButtons is array
        var tagNo = 0
        for patient in patientRecords {
            if patient["status"] == "Active" {
            switch patient["kennelID"]! {
            case "S1","S2","S3","S4","S5","S6","S7","S8":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = (Int(String(patient["kennelID"]!.dropFirst(1)))!)//-1
                print("tagNo \(tagNo)")
                //singleButtons[tagNo].backgroundColor = UIColor.candyGreen()
                colorButtonBackground(color: UIColor.candyGreen(), tagNo: tagNo)
            case "D1","D2","D3","D4","D5","D6","D7","D8":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!))+8
                colorButtonBackground(color: UIColor.candyGreen(), tagNo: tagNo)
                print("tagNo \(tagNo)")
            case "D9","D10","D11","D12","D13","D14","D15","D16":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!))+8
                colorButtonBackground(color: UIColor.candyGreen(), tagNo: tagNo)
                print("tagNo \(tagNo)")
            case "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10","T11","T12","T13":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!))+24
                colorButtonBackground(color: UIColor.candyGreen(), tagNo: tagNo)
                print("tagNo \(tagNo)")
            case "I1","I2","I3","I4":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!))+37
                colorButtonBackground(color: UIColor.candyGreen(), tagNo: tagNo)
                print("tagNo \(tagNo)")
            case "Cat room","Cage Banks":
                tagNo = 42
                print("kennelID \(patient["kennelID"]!)")
                colorButtonBackground(color: UIColor.candyGreen(), tagNo: tagNo)
                print("tagNo \(tagNo)")
            default: tagNo = 0
            }
        }
        }
    }
    func colorButtonBackground(color: UIColor, tagNo: Int){
        for thisButton in singleButtons {
            let tagThisButton = thisButton.tag
            if(tagThisButton == tagNo){
                thisButton.backgroundColor = color
            }
        }
    }
    func kennelID(fromTagNo: Int) -> String{
        let first = fromTagNo//+1
        //1-8   = "S1","S2","S3","S4","S5","S6","S7","S8"
        //9-24  = "D1","D2","D3","D4","D5","D6","D7","D8",...,"D16"
        //25-37 = "T1","T2","T3","T4","T5","T6","T7","T8",...,"T13"
        //38-41
        //42 "Cat room"//"Cage Banks"
        switch first{
        case 1,2,3,4,5,6,7,8:
            return "S" + String(first)
        case 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24:
            return "D" + String( first - 8 )
        case 25,26,27,28,29,30,31,32,33,34,35,36,37:
            return "T" + String( first - 24 )
        case 38,39,40,41:
            return "I" + String( first - 37 )
        case 42:
            return "Cats & Cage Banks"
        default: return ""
        }
    }
    func setDisplayText(tagNum: Int){
        print("setDispTxt tagNum \(tagNum)")
        displayTitle.text = kennelID(fromTagNo: tagNum)
    }
    func updateSearchData(kennelID: String){
        var check1 = kennelID
        var check2 = kennelID
        if kennelID == "Cats & Cage Banks" {
            check1 = "Cage Banks"
            check2 = "Cat room"
        }
        searchData = Array<Dictionary<String,String>>()
        var newS:Dictionary<String,String> =
            [
                "patientID":"",
                "owner":"",
                "intakeDate":"",
                "walkDate":"",
                "lastAMPMDate":"",
                "lastIncision":""
        ]
        for patient in patientRecords {
            if patient["status"] == "Active" {
                if patient["kennelID"] == check1 || patient["kennelID"] == check2 {
                    newS["patientID"] = patient["patientID"]
                    newS["owner"] = patient["owner"]
                    newS["intakeDate"] = patient["intakeDate"]
                    newS["walkDate"] = patient["walkDate"]
                    searchData.append(newS)
                }
            }
        }
        displayTable.reloadData()
    }
}
extension MapVC{
    // #MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        let cell: mapDisplayTableView = tableView.dequeueReusableCell(withIdentifier: "mapDisplayCell") as! mapDisplayTableView
        let thisPatient = searchData[IndexPath.row]
        cell.dogPhoto.image = returnImage(imageName: thisPatient["patientID"]! + ".png")
        cell.intakeDate.text = thisPatient["intakeDate"]
        cell.patientId.text = thisPatient["patientID"]
        cell.owner.text = thisPatient["owner"]
        cell.walkDate.text = updateWalkDate(walkDate: thisPatient["walkDate"]!)
        cell.lastAMPMDate.text = lastAMPMDate(patientID: thisPatient["patientID"]!)
        cell.lastIncisionDate.text = lastIncisionDate(patientID: thisPatient["patientID"]!)
        return cell
    }
}
extension MapVC{
    func updateWalkDate(walkDate: String) -> String{
        if walkDate != ""{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let lastWalkDate = formatter.date(from: walkDate)
            formatter.dateFormat = "MM/dd/yy hh:mm a"
            let newFormatDate = formatter.string(from: lastWalkDate!)
            return newFormatDate//lastWalkDate!.timeAgo()
        } else {
            return "not yet"
        }
    }
    func lastAMPMDate(patientID: String)->String{
        var lastDate = "not yet"
        let scopePredicate:NSPredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", patientID)
        var arr=(myAmpms as NSArray).filtered(using: scopePredicate) as! Array<Dictionary<String,String>>
        arr.sort { $0["date"]! > $1["date"]! }//sort
        if let firstDate = arr.first{
            if firstDate["date"]?.isEmpty == false {
                lastDate = firstDate["date"]!
            } else {
                lastDate = "not yet"
            }
        }
        return lastDate
    }
    func lastIncisionDate(patientID: String)->String{
        var lastDate = "not yet"
        let scopePredicate:NSPredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", patientID)
        var arr=(incisions as NSArray).filtered(using: scopePredicate) as! Array<Dictionary<String,String>>
        arr.sort { $0["date"]! > $1["date"]! }//sort
        if let firstDate = arr.first{
            if firstDate["date"]?.isEmpty == false {
                lastDate = firstDate["date"]!
            } else {
                lastDate = "not yet"
            }
        }
        return lastDate
    }
}







