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
    var collectionPhotos = Array<Dictionary<String,String>>()
    var filteredCollection = Array<Dictionary<String,String>>()
    
    var seguePatientID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        filterInjuriesBy(selectedValue: seguePatientID)
    }
}
extension InjuriesVC {
    //UI
    func setupUI(){
        injuriesCollection.delegate = self
        injuriesCollection.dataSource = self
        titleLabel.text = seguePatientID + "'s Photos"
        collectionPhotos = UserDefaults.standard.object(forKey: "collectionPhotos") as? Array<Dictionary<String,String>> ?? []
    }
    func filterInjuriesBy(selectedValue: String){
        var scopePredicate:NSPredicate
        scopePredicate = NSPredicate(format: "SELF.patientID MATCHES[cd] %@", selectedValue)
        let arr=(collectionPhotos as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            filteredCollection=arr as! Array<Dictionary<String,String>>
        } else {
            filteredCollection=Array<Dictionary<String,String>>()
        }
    }
}
extension InjuriesVC {
    //collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (filteredCollection.count > 0 ? filteredCollection.count : 1)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "injuriesCollectionCell", for: indexPath) as! CollectionViewCell
        if filteredCollection.isEmpty == false {
            let data = filteredCollection[indexPath.row]
            cell.date.text = data["date"]
            cell.patientIDLabel.text = data["photo"]
            cell.note.text = data["note"]
            cell.image.image = returnImage(imageName: data["patientID"]! + "_\(indexPath.row).png")
        }
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
        } else if segue.identifier == "segueFromInjuriesToPatients" {
            if let toVC = segue.destination as? PatientsVC {
                toVC.seguePatientID = seguePatientID
            }
        }
    }
}
