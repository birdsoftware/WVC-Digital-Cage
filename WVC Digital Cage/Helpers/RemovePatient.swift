//
//  RemovePatient.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 12/14/17.
//  Copyright © 2017 Brian Bird. All rights reserved.
//

import Foundation
extension PatientsVC {
    func removeAllDataAndPicturesFor(patientID: String){
        
        removeSingleDict(patientID: patientID, userDefaultsName: "patientVitals")
        removeSingleDict(patientID: patientID, userDefaultsName: "patientPhysicalExam")
        removeSingleDict(patientID: patientID, userDefaultsName: "demographics")
        removeSingleDict(patientID: patientID, userDefaultsName: "procedures")
        //removeSingleDict(patientID: patientID, userDefaultsName: "missingPatientIDs")
        removeSingleDict(patientID: patientID, userDefaultsName: "badges")
        removeSingleDict(patientID: patientID, userDefaultsName: "patientRecords")
        
        removeMultipleDics(patientID:patientID, userDefaultsName: "ampms")
        removeMultipleDics(patientID: patientID, userDefaultsName: "incisions")
        
        removeSingleDict(patientID: patientID, userDefaultsName: "treatmentsAndNotes")
        removeMultipleDics(patientID: patientID, userDefaultsName: "collectionTxVitals")
        removeMultipleDics(patientID: patientID, userDefaultsName: "collectionTreatments")
        //
        //removeAMPM(patientID: patientID)
        //removeIncisions(patientID: patientID)
        removeAllNotificationFor(patientID: patientID)
        
        //removeBadgesFor(patientID: patientID)
        //removeDemographicsFor(patientID: patientID)
        //removePatientRecordFor(patientID: patientID)
        //removePhysicalExamFor(patientID: patientID)
        //removeProcedure(patientID: patientID)
        //removeVitalsFor(patientID: patientID)
        
        //removeTxVitalsFor(patientID: patientID) //ADD:3/6/17
        
        //Treatment Notes - only one record per patientID
        //var treatmentsAndNotes = UserDefaults.standard.object(forKey: "treatmentsAndNotes") as? Array<Dictionary<String,String>> ?? []

        removeMissingFor(patientID: patientID)
        deleteImage(imageName: patientID+".png") //See camera.swift
        deleteCollectionImages(patientID: patientID)
    }
    
    // REMOVE IMAGES
    func deleteCollectionImages(patientID:String){
        var collectionPhotos = UserDefaults.standard.object(forKey: "collectionPhotos") as? Array<Dictionary<String,String>> ?? []
        for photoRecord in collectionPhotos{
            if photoRecord["patientID"] == patientID {
                /*
                 * Delete Photo
                */
                print("deleting...\(photoRecord["photo"]!)")
                deleteImage(imageName: photoRecord["photo"]!)//+".png")
                /*
                 * Delete Photo Data
                 */
                if let index = dictIndexFrom(array: collectionPhotos, usingKey: "patientID", usingValue: patientID) {
                    collectionPhotos.remove(at: index)
                }
            }
        }
        UserDefaults.standard.set(collectionPhotos, forKey: "collectionPhotos")
        UserDefaults.standard.synchronize()
    }
    
    // REMOVE SINGLE DICT
    func removeSingleDict(patientID:String, userDefaultsName: String){
        var dictionary = UserDefaults.standard.object(forKey: userDefaultsName) as? Array<Dictionary<String,String>> ?? []
        if let index = dictIndexFrom(array: dictionary, usingKey:"patientID", usingValue: patientID) {
            dictionary.remove(at: index)
            print("removed \(userDefaultsName) \(dictionary.count)")
            UserDefaults.standard.set(dictionary, forKey: userDefaultsName)
            UserDefaults.standard.synchronize()
        }
    }
    // REMOVE MULTIPLE DICTS
    func removeMultipleDics(patientID:String, userDefaultsName: String){
        var dictionaryArray = UserDefaults.standard.object(forKey: userDefaultsName) as? Array<Dictionary<String,String>> ?? []
        
        for dict in dictionaryArray {
            if dict.values.contains(patientID){
                if let index = dictIndexFrom(array: dictionaryArray, usingKey: "patientID", usingValue: patientID) {
                    dictionaryArray.remove(at: index)
                }
            }
        }
        print("removed \(userDefaultsName) \(dictionaryArray.count)")
        UserDefaults.standard.set(dictionaryArray, forKey: userDefaultsName)
        UserDefaults.standard.synchronize()
    }
    
//    func removeVitalsFor(patientID:String){
//        var patientVitals = UserDefaults.standard.object(forKey: "patientVitals") as? Array<Dictionary<String,String>> ?? []
//        if let index = dictIndexFrom(array: patientVitals, usingKey:"patientID", usingValue: patientID) {
//            patientVitals.remove(at: index)
//            print("removed patientVitals \(patientVitals.count)")
//            UserDefaults.standard.set(patientVitals, forKey: "patientVitals")
//            UserDefaults.standard.synchronize()
//        }
//    }
//    func removePhysicalExamFor(patientID:String){
//        var patientPhysicalExam = UserDefaults.standard.object(forKey: "patientPhysicalExam") as? Array<Dictionary<String,String>> ?? []
//        if let index = dictIndexFrom(array: patientPhysicalExam, usingKey: "patientID", usingValue: patientID) {
//            patientPhysicalExam.remove(at: index)
//            print("removed patientPhysicalExam \(patientPhysicalExam.count)")
//            UserDefaults.standard.set(patientPhysicalExam, forKey: "patientPhysicalExam")
//            UserDefaults.standard.synchronize()
//        }
//    }
//    func removeDemographicsFor(patientID:String){
//        var demographics = UserDefaults.standard.object(forKey: "demographics") as? Array<Dictionary<String,String>> ?? []
//        if let index = dictIndexFrom(array: demographics, usingKey: "patientID", usingValue: patientID) {
//            demographics.remove(at: index)
//            print("removed demographics \(demographics.count)")
//            UserDefaults.standard.set(demographics, forKey: "demographics")
//            UserDefaults.standard.synchronize()
//        }
//    }
//    func removeProcedure(patientID:String){
//        var procedures = UserDefaults.standard.object(forKey: "procedures") as? Array<Dictionary<String,String>> ?? []
//        if let index = dictIndexFrom(array: procedures, usingKey: "patientID", usingValue: patientID) {
//            procedures.remove(at: index)
//            print("removed procedures \(procedures.count)")
//            UserDefaults.standard.set(procedures, forKey: "procedures")
//            UserDefaults.standard.synchronize()
//        }
//    }
    func removeMissingFor(patientID:String){
        var missingPatientIDs = UserDefaults.standard.object(forKey: "missingPatientIDs") as? [String] ?? []
        if missingPatientIDs.contains(patientID) {
            missingPatientIDs = missingPatientIDs.filter{$0 != patientID}
            print("removed missingPatientIDs \(missingPatientIDs.count)")
            UserDefaults.standard.set(missingPatientIDs, forKey: "missingPatientIDs")
            UserDefaults.standard.synchronize()
        }
    }
//    func removeBadgesFor(patientID: String){
//        var badges = UserDefaults.standard.object(forKey: "badges") as? Array<Dictionary<String,String>> ?? []
//        if let index = dictIndexFrom(array: badges, usingKey: "patientID", usingValue: patientID) {
//            badges.remove(at: index)
//            print("removed badges \(badges.count)")
//            UserDefaults.standard.set(badges, forKey: "badges")
//            UserDefaults.standard.synchronize()
//        }
//    }
//    func removePatientRecordFor( patientID: String) {
//        var PRecords = UserDefaults.standard.object(forKey: "patientRecords") as? Array<Dictionary<String,String>> ?? []
//        if let index = dictIndexFrom(array: PRecords, usingKey: "patientID", usingValue: patientID) {
//            PRecords.remove(at: index)
//            patientRecords = PRecords
//            print("removed patientRecords \(patientRecords.count)")
//            UserDefaults.standard.set(patientRecords, forKey: "patientRecords")
//            UserDefaults.standard.synchronize()
//        }
//    }
    
    // Treatment Vitals - multiple ADD:3/6/17
    
//    func removeTxVitalsFor( patientID: String) {
//        var txVitals = UserDefaults.standard.object(forKey: "collectionTxVitals") as? Array<Dictionary<String,String>> ?? []
//
//        for array in txVitals {
//            if array.values.contains(patientID){
//                if let index = dictIndexFrom(array: txVitals, usingKey: "patientID", usingValue: patientID) {
//                    txVitals.remove(at: index)
//                }
//            }
//        }
//        print("removed collectionTxVitals \(txVitals.count)")
//        UserDefaults.standard.set(txVitals, forKey: "collectionTxVitals")
//        UserDefaults.standard.synchronize()
//    }
    
    //Treatments - multiple ADD:3/6/17
//    func removeTreatmentsFor( patientID: String ){
//        var treatments = UserDefaults.standard.object(forKey: "collectionTreatments") as? Array<Dictionary<String,String>> ?? []
//
//        for array in treatments {
//            if array.values.contains(patientID){
//                if let index = dictIndexFrom(array: treatments, usingKey: "patientID", usingValue: patientID) {
//                    treatments.remove(at: index)
//                }
//            }
//        }
//        print("removed collectionTreatments \(treatments.count)")
//        UserDefaults.standard.set(treatments, forKey: "collectionTreatments")
//        UserDefaults.standard.synchronize()
//    }
    
    //REMOVE 1 OR MORE MATCHES
//    func removeAMPM(patientID:String){
//        var ampmsHere = UserDefaults.standard.object(forKey: "ampms") as? Array<Dictionary<String,String>> ?? []
//        //        var ampmRecordsWithPatientID = Array<Dictionary<String,String>>()
//        //        let scopePredicate = NSPredicate(format: "SELF.patientID !=[cd] %@", patientID)
//        //        let arr=(ampms as NSArray).filtered(using: scopePredicate)
//        //        if arr.count > 0
//        //        {
//        //            ampmRecordsWithPatientID=arr as! Array<Dictionary<String,String>>
//        //        } else {
//        //            ampmRecordsWithPatientID=ampms
//        //        }
//        for  array in ampmsHere {
//            if array.values.contains(patientID) {
//                if let index = dictIndexFrom(array: ampmsHere, usingKey: "patientID", usingValue: patientID) {
//                    ampmsHere.remove(at: index)
//                }
//            }
//        }
//        print("removed ampms \(ampmsHere.count)")
//        UserDefaults.standard.set(ampmsHere, forKey: "ampms")
//        UserDefaults.standard.synchronize()
//    }
//    func removeIncisions(patientID:String){
//        var incisionsHere = UserDefaults.standard.object(forKey: "incisions") as? Array<Dictionary<String,String>> ?? []
//        //        var incisionsWithPatientID = Array<Dictionary<String,String>>()
//        //        let scopePredicate = NSPredicate(format: "SELF.patientID !=[cd] %@", patientID)
//        //        let arr=(incisions as NSArray).filtered(using: scopePredicate)
//        //        if arr.count > 0
//        //        {
//        //            incisionsWithPatientID=arr as! Array<Dictionary<String,String>>
//        //        } else {
//        //            incisionsWithPatientID=incisions
//        //        }
//        for  arrayIncision in incisionsHere {
//            if arrayIncision.values.contains(patientID) {
//                if let index = dictIndexFrom(array: incisionsHere, usingKey: "patientID", usingValue: patientID) {
//                    incisionsHere.remove(at: index)
//                }
//            }
//        }
//        print("removed incisions \(incisionsHere.count)")
//        UserDefaults.standard.set(incisionsHere, forKey: "incisions")
//        UserDefaults.standard.synchronize()
//    }
    func removeAllNotificationFor(patientID: String) {
        let notifications = UserDefaults.standard.object(forKey: "notifications") as? Array<Dictionary<String,String>> ?? []
        var notificationsWithPatientID = Array<Dictionary<String,String>>()
        let scopePredicate = NSPredicate(format: "SELF.patientID !=[cd] %@", patientID)//"SELF.patientID MATCHES[cd] %@"
        let arr=(notifications as NSArray).filtered(using: scopePredicate)
        if arr.count > 0
        {
            notificationsWithPatientID=arr as! Array<Dictionary<String,String>>
        } else {
            notificationsWithPatientID=notifications
        }
        print("removed notifications \(notificationsWithPatientID.count)")
        UserDefaults.standard.set(notificationsWithPatientID, forKey: "notifications")
        UserDefaults.standard.synchronize()
    }
}
