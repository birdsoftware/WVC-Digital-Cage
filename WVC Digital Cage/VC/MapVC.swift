//
//  MapVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/15/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class MapVC: UIViewController, UIScrollViewDelegate {
    
    // constraints
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    //scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    //map view
    @IBOutlet weak var mapView: UIView!
    //button
    @IBOutlet var singleButtons: [UIButton]!
    
    // S 1-8    D 9-16,17-24    T 25-37   I 38-41   42 cat room and cage banks
    var kennelIntArray = ["S1","S2","S3","S4","S5","S6","S7","S8",
                          "D1","D2","D3","D4","D5","D6","D7","D8","D9","D10",
                          "D11","D12","D13","D14","D15","D16",
                          "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10",
                          "T11","T12","T13",
                          "I1","I2","I3","I4",
                          "Cage Banks", "Cat room"]
    let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleButtons?.enumerated().forEach({ index, button in
            button.tag = index
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        })
        occupiedKennels()
    }
    @objc func buttonClicked(sender: UIButton?) {
        let tag = sender?.tag ?? 0
        singleButtons[tag].backgroundColor = UIColor.candyGreen()
        print("\(kennelID(fromTagNo: tag))")
        if topConstraint.constant == 0 {
            openDisplay()
        }
    }
    func occupiedKennels(){
        //-1 extra since singleButtons is array
        var tagNo = 0
        for patient in patientRecords {
            switch patient["kennelID"]! {
            case "S1","S2","S3","S4","S5","S6","S7","S8":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = (Int(String(patient["kennelID"]!.dropFirst(1)))!)-1
                print("tagNo \(tagNo)")
                singleButtons[tagNo].backgroundColor = UIColor.DarkRed()
            case "D1","D2","D3","D4","D5","D6","D7","D8":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!)-1)+8
                singleButtons[tagNo].backgroundColor = UIColor.DarkRed()
                print("tagNo \(tagNo)")
            case "D9","D10","D11","D12","D13","D14","D15","D16":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!)-1)+8
                singleButtons[tagNo].backgroundColor = UIColor.DarkRed()
                print("tagNo \(tagNo)")
            case "T1","T2","T3","T4","T5","T6","T7","T8","T9","T10","T11","T12","T13":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!)-1)+24
                singleButtons[tagNo].backgroundColor = UIColor.DarkRed()
                print("tagNo \(tagNo)")
            case "I1","I2","I3","I4":
                print("kennelID \(patient["kennelID"]!)")
                tagNo = ((Int(String(patient["kennelID"]!.dropFirst(1)))!)-1)+37
                singleButtons[tagNo].backgroundColor = UIColor.DarkRed()
                print("tagNo \(tagNo)")
            case "Cat room","Cage Banks":
                tagNo = 41
                print("kennelID \(patient["kennelID"]!)")
                singleButtons[tagNo].backgroundColor = UIColor.DarkRed()
                print("tagNo \(tagNo)")
            default: tagNo = 0
            }
        }
    }
    func kennelID(fromTagNo: Int) -> String{
        let first = fromTagNo+1
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
                return "Cat room"//"Cage Banks"
            default: return ""
            }
    }
    func openDisplay(){
        let width = view.frame.width
        let height = view.frame.height
        topConstraint.constant = height * 0.2
        rightConstraint.constant = width * 0.2
    }
    func closeDisplay(){
        topConstraint.constant = 0
        rightConstraint.constant = 0
    }
}











