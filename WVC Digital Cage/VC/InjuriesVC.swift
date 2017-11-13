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
}
