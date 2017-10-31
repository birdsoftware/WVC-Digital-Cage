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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Data:
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
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
        barChartUpdate (canine: Double(canineCount), feline: Double(felineCount), other: Double(otherCount))
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
