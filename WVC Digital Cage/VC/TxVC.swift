//
//  TxVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/14/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class TxVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //text fields
    @IBOutlet weak var patientID: UITextField!
    @IBOutlet weak var shelterTF: UITextField!
    
    //table
    @IBOutlet weak var txTable: UITableView!
    
    //segue data from patientsVC
    var seguePatientID: String!
    var segueShelterName: String!
    
    let sectionTitles: [String] = ["Treatment Vitals", "Treatments", "Notes"]
    let sectionImages: [UIImage] = [#imageLiteral(resourceName: "vitals"),#imageLiteral(resourceName: "treatment notification"),#imageLiteral(resourceName: "note black")]
    let s1Data: [String] = ["Row 1", "Row 2", "Row 3"]
    let s2Data: [String] = ["Row 1", "Row 2", "Row 3"]
    let s3Data: [String] = ["Row 1", "Row 2", "Row 3"]
    
    var sectionData: [Int: [String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        txTable.dataSource = self
        txTable.delegate = self
        
        sectionData = [0:s1Data, 1:s2Data, 2:s3Data]
    }

}
extension TxVC {
    //
    // #MARK: Table View
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
            return 1//(sectionData[section]?.count)!
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        let image = UIImageView(image: sectionImages[section])
        image.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
        view.addSubview(image)
        let label = UILabel()
        label.text = sectionTitles[section]
        label.frame = CGRect(x: 45, y: 5, width: 200, height: 35)
        view.addSubview(label)
        let button = UIButton()
        button.setTitle("Add New", for: .normal)
        button.frame = CGRect(x: self.view.frame.size.width-280, y: 5, width: 75, height: 35)
        view.addSubview(button)
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell");
            }
            //cell!.textLabel?.text = sectionData[indexPath.section]![indexPath.row]
            
            return cell!
    }
}

extension TxVC {
    //
    // #MARK: - UI
    //
    func setUI(){
        patientID.text = seguePatientID
        shelterTF.text = segueShelterName
    }
}
extension TxVC {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueTxToPatientDB" {
            if let toVC = segue.destination as? PatientsVC {
                toVC.seguePatientID = seguePatientID
            }
        }
    }
}
