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
    func demographicParamaters(update:Dictionary<String,String>,
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
    func ampmParamaters(update:Dictionary<String,String>,
                               databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc ampmsId
            "patientID":    databasePID,
            "patientName":  update["patientID"]!,
            "attitude":      update["attitude"]!,
            "filterID":      update["filterID"]!,
            "initials":      update["initials"]!,
            "vDCS":         update["v/D/C/S"]!,
            "date":         update["date"]!,
            "urine":         update["urine"]!,
            "feces":         update["feces"]!,
            "appetite":         update["appetite%"]!
            ] as [String : Any]
        return parameters
    }
}
