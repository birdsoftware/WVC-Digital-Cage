//
//  AnalyticsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/30/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit
import Charts//comment out /run simulator /uncomment
//https://github.com/annalizhaz/ChartsForSwiftBasic

class AnalyticsVC: UIViewController {

    @IBOutlet weak var patientChart: PieChartView! //chnged class to PieChartView
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var bodyCondtionScore: PieChartView!
    
    //summary labels
    @IBOutlet weak var patientRecordsL: UILabel!
    @IBOutlet weak var vitalsL: UILabel!
    @IBOutlet weak var physicalExamsL: UILabel!
    @IBOutlet weak var demographicsL: UILabel!
    @IBOutlet weak var proceduresL: UILabel!
    @IBOutlet weak var incisionsL: UILabel!
    @IBOutlet weak var ampmL: UILabel!
    @IBOutlet weak var notificationsL: UILabel!
    
    var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
    let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
    let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
    var myNotifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
    var myDemographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
    var myAmpms = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
    var incisions = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
    var procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Data:
        //let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        //let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        //let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        printDictionaries(records: patientRecords, vitals: patientVitals, pe: patientPhysicalExam, notifications: myNotifications, myDemographics: myDemographics, myAmpms: myAmpms, incisions: incisions, procedures: procedures)
        //pie chart:
        pieChartUpdate(patientRecords: Double(patientRecords.count), vitals: Double(patientVitals.count), pysExams: Double(patientPhysicalExam.count))
        //bar chart:
        var canineCount = 0
        var felineCount = 0
        var otherCount = 0
        for patient in patientRecords{
            if (patient["group"] == "Canine") {
                canineCount = canineCount + 1
            } else if (patient["group"] == "Feline") {
                felineCount = felineCount + 1
            } else if (patient["group"] == "Other") {
                otherCount = otherCount + 1
            }
        }
        var bodyConditionScore = [0,0,0,0,0]
        
        for exam in patientPhysicalExam{
            if (exam["bodyConditionScore"] == "1") {
                bodyConditionScore[0] = bodyConditionScore[0] + 1
            } else if (exam["bodyConditionScore"] == "2") {
                bodyConditionScore[1] = bodyConditionScore[1] + 1
            } else if (exam["bodyConditionScore"] == "3") {
                bodyConditionScore[2] = bodyConditionScore[2] + 1
            } else if (exam["bodyConditionScore"] == "4") {
                bodyConditionScore[3] = bodyConditionScore[3] + 1
            } else if (exam["bodyConditionScore"] == "5") {
                bodyConditionScore[4] = bodyConditionScore[4] + 1
            }
        }
        barChartUpdate (canine: Double(canineCount), feline: Double(felineCount), other: Double(otherCount))
        bodyConditionScoreUpdate(s1: Double(bodyConditionScore[0]), s2: Double(bodyConditionScore[1]), s3: Double(bodyConditionScore[2]), s4: Double(bodyConditionScore[3]), s5: Double(bodyConditionScore[4]))
    }
}
extension AnalyticsVC{
    //Update UI
    func printDictionaries(records: Array<Dictionary<String,String>>,
                           vitals: Array<Dictionary<String,String>>,
                           pe: Array<Dictionary<String,String>>,
                           notifications: Array<Dictionary<String,String>>,
                           myDemographics: Array<Dictionary<String,String>>,
                           myAmpms: Array<Dictionary<String,String>>,
                           incisions: Array<Dictionary<String,String>>,
                           procedures: Array<Dictionary<String,String>>){
        patientRecordsL.text = String(records.count)
        vitalsL.text = String(vitals.count)
        physicalExamsL.text = String(pe.count)
        notificationsL.text = String(notifications.count)
        demographicsL.text = String(myDemographics.count)
        ampmL.text = String(myAmpms.count)
        incisionsL.text = String(incisions.count)
        proceduresL.text = String(procedures.count)
    }
}
extension AnalyticsVC{
    //pie charts
    func pieChartUpdate(patientRecords: Double, vitals: Double, pysExams: Double){
        let entry1 = PieChartDataEntry(value: patientRecords, label: "Patients")
        let entry2 = PieChartDataEntry(value: vitals, label: "Vitals")
        let entry3 = PieChartDataEntry(value: pysExams, label: "Physical Exams")
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3], label: "Record Type")
        let data = PieChartData(dataSet: dataSet)
        patientChart.data = data
        patientChart.chartDescription?.text = "Patients by Record Type"
        
        //All other additions to this function will go here
        dataSet.colors = ChartColorTemplates.vordiplom()
        dataSet.valueColors = [UIColor.black]
        
//        patientChart.legend.font = UIFont(name: "Futura", size: 10)!
//        patientChart.chartDescription?.font = UIFont(name: "Futura", size: 12)!
//        patientChart.chartDescription?.xOffset = patientChart.frame.width + 30
//        patientChart.chartDescription?.yOffset = patientChart.frame.height * (2/3)
//        patientChart.chartDescription?.textAlign = NSTextAlignment.left
        
        //This must stay at end of function
        patientChart.notifyDataSetChanged()
    }
    func bodyConditionScoreUpdate(s1: Double, s2: Double, s3: Double, s4: Double, s5: Double){
        let entry1 = PieChartDataEntry(value: s1, label: "Score of 1")
        let entry2 = PieChartDataEntry(value: s2, label: "Score of 2")
        let entry3 = PieChartDataEntry(value: s3, label: "Score of 3")
        let entry4 = PieChartDataEntry(value: s4, label: "Score of 4")
        let entry5 = PieChartDataEntry(value: s3, label: "Score of 5")
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3, entry4, entry5], label: "Record Type")
        let data = PieChartData(dataSet: dataSet)
        bodyCondtionScore.data = data
        bodyCondtionScore.chartDescription?.text = "Patients by Record Type"
        
        //All other additions to this function will go here
        dataSet.colors = ChartColorTemplates.vordiplom()
        dataSet.valueColors = [UIColor.black]
        
        //This must stay at end of function
        bodyCondtionScore.notifyDataSetChanged()
    }
}
extension AnalyticsVC{
//bar charts
    func barChartUpdate (canine: Double, feline: Double, other: Double) {
        let entry1 = BarChartDataEntry(x: 1.0, y: canine)
        let entry2 = BarChartDataEntry(x: 2.0, y: feline)
        let entry3 = BarChartDataEntry(x: 3.0, y: other)
        let dataSet = BarChartDataSet(values: [entry1, entry2, entry3], label: "Species Type")
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
        barChart.chartDescription?.text = "Number of Species by Type"
        
        //All other additions to this function will go here
        dataSet.colors = ChartColorTemplates.vordiplom()
        
        //This must stay at end of function
        barChart.notifyDataSetChanged()
    }
}
