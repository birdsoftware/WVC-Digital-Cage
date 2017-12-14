//
//  Camera.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 11/13/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    // #MARK: - Image picker form camera
    //camera delegate func called after take photo
    //https://appsandbiscuits.com/take-save-and-retrieve-a-photo-ios-13-4312f96793ff
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func saveImage(imageName: String, patientPicture: UIImageView){
        print("Image \(imageName) saved")
        //create an instance of the FileManager
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //get the image we took with camera
        let image = patientPicture.image!
        //get the PNG data for this image
        let data = UIImagePNGRepresentation(image)
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    func saveImageNameToPatientRecords(imageName: String, patientID: String) {
        var patientRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
        if let index = dictIndexFrom(array: patientRecords, usingKey:"patientID", usingValue: patientID)
        {
            print("Saving photo: \(imageName) to index: \(index) for patientID: \(patientID)")
            patientRecords[index]["photo"] = imageName
            UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
            UserDefaults.standard.synchronize()
        }
    }
    func deleteImage(imageName: String){
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        do {
            try fileManager.removeItem(atPath: imagePath)
            print("YES! Deleted imageName \(imageName)")
        } catch {
            print("Error! could not delete imageName \(imageName)")
        }
    }
    func getImage(imageName: String, imageView: UIImageView){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            imageView.image = UIImage(contentsOfFile: imagePath)
        }else{
            //print("Panic! No Image!")
            imageView.image = UIImage(named: "dog circle")
        }
    }
    func returnImage(imageName: String) -> UIImage {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            //print("Panic! No Image!")
            return UIImage(named: "dog circle")!
        }
    }
}
