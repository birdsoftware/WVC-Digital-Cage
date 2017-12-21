//
//  NewInjuriesVC.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import UIKit

class NewInjuriesVC: UIViewController, UIImagePickerControllerDelegate /*photoLib*/,
UINavigationControllerDelegate/*photoLib*/ {

    @IBOutlet weak var patientPhoto: UIImageView!
    //text field
    @IBOutlet weak var noteTF: UITextField!
    //label
    @IBOutlet weak var titleLabel: UILabel!
    
    var seguePatientID: String!
    
    var imagePickerController : UIImagePickerController!
    var collectionPhotos = UserDefaults.standard.object(forKey: "collectionPhotos") as? Array<Dictionary<String,String>> ?? []
    var newCollection = [
                "patientID":"",
                "photo":"",
                "note":"",
                "date":""
            ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //deleteImage(imageName: "Garfield_1.png")
        //clear(arrayDicName: "collectionPhotos")
         titleLabel.text = "Add a photo and note for \(seguePatientID!)"
        //collectionPhotos.sort { $0["patientID"]! < $1["patientID"]! }//sort array in place
    }
    //#MARK - Actions
    @IBAction func takePhotoAction(_ sender: Any) {
        //TAKR Patient Picture
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func saveAction(_ sender: Any) {
        // SAVE IMAGE TO APP LOCAL DIR
        let imageNumber = returnCountOfKeys(aDicts: collectionPhotos, aKey: "patientID", matchKey: seguePatientID)// count of selectedPatientIds
        print("imageNumber: \(imageNumber)")
        saveImage(imageName: seguePatientID + "_\(imageNumber).png", patientPicture: patientPhoto)
        saveImageNameToCollectionPhotos(imageName: seguePatientID + "_\(imageNumber).png",  patientID: seguePatientID)
        //SEGUE back to InjuriesVC
        self.performSegue(withIdentifier: "segueBackToInjuries", sender: self)
    }
    @IBAction func closeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueBackToInjuries", sender: self)
    }
}
extension NewInjuriesVC {
    //
    // #MARK: - Image picker form camera
    //          camera delegate func called after take photo
    //          https://appsandbiscuits.com/take-save-and-retrieve-a-photo-ios-13-4312f96793ff
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        // RESIZE IMAGE
        let smallerSizeImage = resizeImage(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!, newWidth: 200)
        // UPDATE UI IMAGE
        patientPhoto.image = smallerSizeImage
    }
}
extension NewInjuriesVC {
    //
    // #MARK: - Saving Locally
    //
    func updateInjuriesObject(name: String){
        // Date now
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let nowString = formatter.string(from: Date())
        newCollection = [
            "patientID":seguePatientID,
            "photo":name,
            "note":noteTF.text!,
            "date":nowString
        ]
    }
    func saveImageNameToCollectionPhotos(imageName: String,  patientID: String) {
        updateInjuriesObject(name: imageName)
        if collectionPhotos.isEmpty { //CREATE
            UserDefaults.standard.set([newCollection], forKey: "collectionPhotos")
            UserDefaults.standard.synchronize()
        } else {
            //CHECK imageName EXISTS
            if let index = dictIndexFrom(array: collectionPhotos, usingKey:"photo", usingValue: imageName)
            { //UPDATE
                //collectionPhotos[index]["photo"] = imageName
                collectionPhotos[index]["note"] = newCollection["note"]
                collectionPhotos[index]["date"] = newCollection["date"]
                UserDefaults.standard.set(collectionPhotos, forKey: "collectionPhotos")
                UserDefaults.standard.synchronize()
            } else { //APPEND
                collectionPhotos.append(newCollection)
                UserDefaults.standard.set(collectionPhotos, forKey: "collectionPhotos")
                UserDefaults.standard.synchronize()
            }
        }
    }
}
extension NewInjuriesVC {
    //
    // #MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueBackToInjuries" {
            if let toVC = segue.destination as? InjuriesVC {
                toVC.seguePatientID = seguePatientID
            }
        }
    }
}
