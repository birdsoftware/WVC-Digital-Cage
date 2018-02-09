//
//  Constants.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//

import Foundation

struct Constants {
    struct Patient {
        static let url = "ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/"
        static let patient =        "http://" + url + "patients/"       //+ patientID
        static let postPatient =    "http://" + url + "patientsInsert2"
        static let postVitals =     "http://" + url + "vitalsInsert"
        static let postPE =         "http://" + url + "peInsert"
        static let postNotificat =  "http://" + url + "notificationInsert"
        static let postDemog =      "http://" + url + "demographicsInsert"
        static let postAMPM =       "http://" + url + "ampmInsert"
        static let postIncisions =  "http://" + url + "incisionsInsert"
        static let postProcedure =  "http://" + url + "proceduresInsert"
        static let postBadges =     "http://" + url + "badgesInsert"
        static let postTxVitals =   "http://" + url + "treatmentVitalsInsert"
        static let postTx =         "http://" + url + "treatmentsInsert"
        static let postTxNotes =    "http://" + url + "treatmentsNotesInsert"
    }
}
class params {
    func patientParameters(update:Dictionary<String,String>) -> [String : Any]{
        let parameters = [
            "status":       update["status"]!,
            "intakeDate":   update["intakeDate"]!,
            "patientName":  update["patientID"]!,
            "walkDate":     update["walkDate"]!,
            "photoName":    update["photo"]!,
            "kennelId":     update["kennelID"]!,
            "owner":        update["owner"]!,
            "groupString":  update["group"]!
            ] as [String : Any]
        return parameters
    }
    func vitalParameters(update:Dictionary<String,String>,
                         databasePID:Int) -> [String : Any]{
        let parameters = [
            "temperature":  update["temperature"]!,
            "pulse":        update["pulse"]!,
            "weight":       update["weight"]!,
            "exitWeight":   update["exitWeight"]!,
            "cRT_MM":       update["cRT_MM"]!,
            "respiration":  update["respiration"]!,
            "initialsVitals": update["initialsVitals"]!,
            "patientName":  update["patientID"]!,
            "patientId":    databasePID
            ] as [String : Any]
        return parameters
    }
    func peParameters(update:Dictionary<String,String>,
                      databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc physicalExamId
            "patientId":        databasePID,
            "patientName":      update["patientID"]!,
            "generalAppearance": update["generalAppearance"]!,
            "skinFeetHair":     update["skinFeetHair"]!,
            "musculoskeletal":  update["musculoskeletal"]!,
            "nose":             update["nose"]!,
            "digestiveTeeth":   update["digestiveTeeth"]!,
            "respiratory":      update["respiratory"]!,
            "ears":             update["ears"]!,
            "nervousSystem":    update["nervousSystem"]!,
            "lymphNodes":       update["lymphNodes"]!,
            "eyes":             update["eyes"]!,
            "urogenital":       update["urogenital"]!,
            "bodyConditionScore": update["bodyConditionScore"]!,
            "comments":         update["comments"]!
            ] as [String : Any]
        return parameters
    }
    func myNotifiParameters(update:Dictionary<String,String>,
                            databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc notificationsId
            "patientID":    databasePID,
            "patientName":  update["patientID"]!,
            "message":      update["message"]!,
            "type":         update["type"]!,
            "code":         update["code"]!,
            "dateLong":     update["dateLong"]!,
            "image":        update["image"]!
            ] as [String : Any]
        return parameters
    }
    func demographicParameters(update:Dictionary<String,String>,
                               databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc demographicsId
            "patientID":    databasePID,
            "patientName":  update["patientID"]!,
            "age":          update["age"]!,
            "breed":        update["breed"]!,
            "sex":          update["sex"]!
            ] as [String : Any]
        return parameters
    }
    func ampmParameters(update:Dictionary<String,String>,
                               databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc ampmsId
            "patientID":    databasePID,
            "patientName":  update["patientID"]!,
            "attitude":      update["attitude"]!,
            "filterID":      update["filterID"]!,
            "initials":      update["initials"]!,
            "vDCS":          update["v/D/C/S"]!,
            "date":          update["date"]!,
            "urine":         update["urine"]!,
            "feces":         update["feces"]!,
            "appetite":      update["appetite%"]!
            ] as [String : Any]
        return parameters
    }
    func incisionsParameters(update:Dictionary<String,String>,
                             databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc incisionsId
            "patientID":    databasePID,
            "patientName":  update["patientID"]!,
            "date":         update["date"]!,
            "initials":     update["initials"]!
            ] as [String : Any]
        return parameters
    }
    func proceduresParameters(update:Dictionary<String,String>,
                              databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc incisionsId
            "patientID":        databasePID,
            "patientName":      update["patientID"]!,
            "radiographs":      update["radiographs"]!,
            "bloodWork":         update["bloodWork"]!,
            "suture":           update["suture"]!,
            "lab":              update["lab"]!,
            "surgeryDate":      update["surgeryDate"]!
            ] as [String : Any]
        return parameters
    }
    func badgesParameters(update:Dictionary<String,String>,
                              databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc incisionsId
            "patientID":        databasePID,
            "patientName":      update["patientID"]!,
            "isWet":      update["isWet"]!,
            "isDry":         update["isDry"]!,
            "isNpo":           update["isNpo"]!,
            "isTwice":              update["isTwice"]!,
            "isHalf":      update["isHalf"]!,
            "isCaution":      update["isCaution"]!
            ] as [String : Any]
        return parameters
    }
    func treatmentVitalsParameters(update:Dictionary<String,String>,
                          databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc incisionsId
            "patientID":        databasePID,
            "patientName":      update["patientID"]!,
            "temperature":      update["temperature"]!,
            "heartRate":         update["heartRate"]!,
            "respirations":      update["respirations"]!,
            "mmCrt":           update["mm/Crt"]!,
            "diet":      update["diet"]!,
            "cSVD":      update["v/D/C/S"]!,
            "weightKgs":      update["weightKgs"]!,
            "initials":      update["initials"]!,
            "date":      update["date"]!,
            "monitorDays":      update["monitorDays"]!,
            "checkComplete":      update["checkComplete"]!,
            "monitorFrequency":      update["monitorFrequency"]!,
            "monitored":      update["monitored"]!,
            "groupNumber":      update["group"]!
            ] as [String : Any]
        return parameters
    }
    func treatmentsParameters(update:Dictionary<String,String>,
                                   databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc incisionsId
            "patientID":                    databasePID,
            "patientName":                  update["patientID"]!,
            "date":                         update["date"]!,
            "treatmentOne":                 update["treatmentOne"]!,
            "treatmentTwo":                 update["treatmentTwo"]!,
            "treatmentThree":               update["treatmentThree"]!,
            "treatmentFour":                update["treatmentFour"]!,
            "treatmentFive":                update["treatmentFive"]!,
            "treatmentSix":                 update["treatmentSix"]!,
            "treatmentSeven":               update["treatmentSeven"]!,
            "treatmentEight":               update["treatmentEight"]!,
            "treatmentNine":                update["treatmentNine"]!,
            "treatmentTen":                 update["treatmentTen"]!,
            "monitored":                    update["monitored"]!,
            "monitorDays":                  update["monitorDays"]!,
            "monitorFrequency":             update["monitorFrequency"]!,
            "containsTreatmentLabels":      update["containsTreatmentLabels"]!,
            "checkComplete":                update["checkComplete"]!
            ] as [String : Any]
        return parameters
    }
}
