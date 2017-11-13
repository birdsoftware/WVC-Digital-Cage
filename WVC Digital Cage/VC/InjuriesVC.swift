//
//  InjuriesVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/10/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class InjuriesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var injuriesCollection: UICollectionView!
    //label
    @IBOutlet weak var titleLabel: UILabel!
    //text field
    
    //image
    
    var seguePatientID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}
extension InjuriesVC {
    //UI
    func setupUI(){
        injuriesCollection.delegate = self
        injuriesCollection.dataSource = self
        titleLabel.text = seguePatientID + "'s Photos"
    }
}
extension InjuriesVC {
    //collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9//dataFile.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "injuriesCollectionCell", for: indexPath) as! CollectionViewCell
//        let data:Dictionary<String,String> = dataFile[indexPath.row]
//        cell.image.image = UIImage(named: data["image"]!)
//        cell.model.text = data["model"]
//        cell.detail1.text = data["detail1"]
//        cell.year.text = data["year"]
//        cell.mileage.text = data["mileage"]
//        cell.textView.attributedText = buildLink(str:"View Listing", url: data["link"]!)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
}
extension InjuriesVC {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToNewInjuries" {
            if let toVC = segue.destination as? NewInjuriesVC {
                toVC.seguePatientID = seguePatientID
            }
        }
    }
}
