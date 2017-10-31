//
//  AnalyticsVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 10/30/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit
import Charts//comment out /run simulator /uncomment

class AnalyticsVC: UIViewController {

    @IBOutlet weak var patientChart: PieChartView! //chnged class to PieChartView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        let patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
        let patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
        
        let entry1 = PieChartDataEntry(value: Double(patientRecords.count), label: "Patients")
        let entry2 = PieChartDataEntry(value: Double(patientVitals.count), label: "Vitals")
        let entry3 = PieChartDataEntry(value: Double(patientPhysicalExam.count), label: "Physical Exams")
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3], label: "Record Type")
        let data = PieChartData(dataSet: dataSet)
        patientChart.data = data
        patientChart.chartDescription?.text = "Patients by Record Type"
        
        //All other additions to this function will go here
        dataSet.colors = ChartColorTemplates.vordiplom()
        dataSet.valueColors = [UIColor.black]
        //This must stay at end of function
        patientChart.notifyDataSetChanged()
    }



}
