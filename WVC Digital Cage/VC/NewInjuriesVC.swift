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
    
    override func viewDidLoad() {
        super.viewDidLoad()

         titleLabel.text = "Add a photo and note for \(seguePatientID!)"
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
        // SAVE IMAGE TO APP LOCAL DIR
        //let collectionSize = collectionPhotos.count
        //saveImage(imageName: seguePatientID + "_\(collectionSize).png", patientPicture: patientPhoto)
        //saveImageNameToCollectionPhotos(imageName: seguePatientID + ".png",  patientID: seguePatientID)
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
