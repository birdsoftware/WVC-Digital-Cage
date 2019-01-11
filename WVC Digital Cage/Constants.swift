//
//  Constants.swift
//  WVC Digital Cage
//
//  Created by Brian Bird on 1/26/18.
//  Copyright © 2018 Brian Bird. All rights reserved.
//
// command on terminal to clear connections to port 9000
// fuser -k 9000/tcp

import Foundation

struct Constants {
    struct instantShare {
        static let url_IS = "http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/"
        struct Ampm {
            static let getAllAmpm = url_IS + "getAllAmpm"
            static let getAllAmpmKey = "ampms"
            static let getAmpmCount = url_IS + "getAmpmCount"
            static let insertAmpm = url_IS + "insertAmpm"
            static let updateAmpm = url_IS + "updateAmpm"
            static let deleteAmpm = url_IS + "deleteAmpm"
        }
        struct Procedures {
            static let getAllProcedures = url_IS + "getAllProcedures"
            static let getAllProceduresKey = "procedures"
            static let getProceduresCount = url_IS + "getProceduresCount"
            static let insertProcedure = url_IS + "insertProcedure"
            // {
            //    "proceduresId":"3",
            //    "patientID": "1",
            //    "patientName": "remove",
            //    "radiographs": "rm",
            //    "bloodWork": "rm",
            //    "suture":"sq",
            //    "lab":"m",
            //    "surgeryDate":"07/09/18 02:44 PM"
            // }
            static let updateProcedure = url_IS + "updateProcedure"
            // {
            //    "proceduresId":"3"
            // }
            static let deleteProcedures = url_IS + "deleteProcedures"
        }
        struct Incisions {
            static let getAllIncisions = url_IS + "getAllIncisions"
            static let getAllIncisionsKey = "incisions"
            static let getIncisionsCount = url_IS + "getIncisionsCount"
            static let insertIncision = url_IS + "insertIncisions"
            // {
            //      "incisionsId": "1",
            //      "patientID": "1",
            //      "patientName": "Baby",
            //      "date": "2018-12-18 19:14:59",
            //      "initials": "true"
            //  }
            static let updateIncision = url_IS + "updateIncisions"
            static let deleteIncision = url_IS + "deleteIncision"
        }
        struct Badges {
            static let getAllBadges = url_IS + "getAllBadges"
            static let getAllBadgesKey = "badges"
            static let getBadgesCount = url_IS + "getBadgesCount"
            static let insertBadge = url_IS + "insertBadge"
            // {
            //      "badgesId": "4",
            //      "patientID": "2",
            //      "patientName": "0965749",
            //      "isWet": "true",
            //      "isDry": "false",
            //      "isNpo": "true",
            //      "isTwice": "true",
            //      "isHalf": "false",
            //      "isCaution": "true"
            // }
            static let updateBadge = url_IS + "updateBadge"
        }
        struct Demographics {
            // /getAllDemographics
            static let getAllDemographics = url_IS + "getAllDemographics"
            static let getAllDemographicsKey = "demographics"
            
            // /insertDemographic
            static let insertDemographic = url_IS + "insertDemographic"
            
            // /updateDemographic
            // {
            //     "demographicsId":"5",
            //     "patientID": "7",
            //     "patientName": "Brutus",
            //     "age": "1 year, 6 months",
            //     "breed": "Mixed",
            //     "sex": "Male"
            // }
            static let updateDemographic = url_IS + "updateDemographic"
        }
        struct PhysicalExams {
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getAllPhysicalExams
            static let getAllPhysicalExams = url_IS + "getAllPhysicalExams"
            static let getALLPhysicalExamsKey = "patientPhysicalExam"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getPhysicalExamsCount
            static let getPhysicalExamsCount = url_IS + "getPhysicalExamsCount"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getSinglePhysicalExam/:patientID
            static let getSinglePhysicalExam = url_IS + "getSinglePhysicalExam/"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/insertPhysicalExam
            // {
            //      "patientID": "7",
            //      "patientName": "Brutus",
            //      "generalAppearance": "healthy",
            //      "skinFeetHair": "good",
            //      "musculoskeletal": "bad",
            //      "nose": "bar",
            //      "digestiveTeeth": "cavity in left canine 1 and 2",
            //      "respiratory": "wheezing",
            //      "ears": "good",
            //      "nervousSystem": "good",
            //      "lymphNodes": "lump in right neck lymph node",
            //      "eyes": "occlusion in both eyes",
            //      "urogenital": "ok",
            //      "bodyConditionScore": "3.0",
            //      "comments": "Overal health is in need of special care. Digestive medication and tylenol every 12 hours for next 4 days."
            // }
            static let insertPhysicalExam = url_IS + "insertPhysicalExam"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/updatePhysicalExam
            // {
            //    "physicalExamId": 3,
            //    "patientID": 7,
            //    "patientName": "Brutus",
            //    "generalAppearance": "test",
            //    "skinFeetHair": "test",
            //    "musculoskeletal": "test",
            //    "nose": "bar",
            //    "digestiveTeeth": "cavity in left canine 1 and 2",
            //    "respiratory": "wheezing",
            //    "ears": "test",
            //    "nervousSystem": "confused when given commands",
            //    "lymphNodes": "lump in right neck lymph node",
            //    "eyes": "occlusion in both eyes",
            //    "urogenital": "constipated",
            //    "bodyConditionScore": "3.0",
            //    "comments": "Overal health is in need of special care. Digestive medication and tylenol every 12 hours for next 4 days."

            static let updatePhysicalExam = url_IS + "updatePhysicalExam"
        }
        struct Vitals {
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getSingleVital/:patientID
            static let getSingleVital = url_IS + "getSingleVital/"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getAllVitals
            static let getAllVitals = url_IS + "getAllVitals"
            static let getAllVitalsKey = "patientVitals"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/insertVital
            // BODY Implicit use of auto increment on patientId
            //      Explicit use works also: "vitalId":2 as long as record DNE.
            //  {
            //      "patientId": 1,
            //      "patientName": "0965741",
            //      "temperature": "100.1",
            //      "pulse": "99",
            //      "weight": "22",
            //      "exitWeight": "25",
            //      "cRT_MM": "bar",
            //      "respiration": "100",
            //      "respiration": "B.B."
            //  }
            // RESPONSE:
            // {
            //    "type": true
            // }
            static let insertVital = url_IS + "insertVital"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/updateVital
            //  {
            //      "vitalId": 1,
            //      "patientID": 1,
            //      "patientName": "0965741",
            //      "temperature": "100.1",
            //      "pulse": "99",
            //      "weight": "22",
            //      "exitWeight": "25",
            //      "cRT_MM": "bar",
            //      "respiration": "100",
            //      "initialsVitals": "B.B."
            //  }
            // RESPONSE:
            // {
            //    "type": true
            // }
            static let updateVital = url_IS + "updateVital"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getVitalsCount
            static let getVitalsCount = url_IS + "getVitalsCount"
            
            // http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/deleteVital
            // Example Input:
            // { "vitalId"   : "17" }
            static let deleteVital = url_IS + "deleteVital"
        }
        struct Patient {
            
            //http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getSinglePatient/1
            static let getSinglePatient = url_IS + "getSinglePatient/"
            
            //http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/insertPatient
            /*{
                "patientId": 10, //patientId is optional, if left off MySQL will auto increment
                "status": "Archive",
                "intakeDate": "08/11/2018",
                "patientName": "Baby",
                "walkDate": "",
                "photoName": "Baby.png",
                "kennelId": "D4",
                "owner": "Desert Haven Animal Society (DHAS)",
                "groupString": "Canine"
            }*/
            static let insertPatient = url_IS + "insertPatient"
            
            //http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/updatePatient
            /*{
                "patientId":2,
                "status": "Archive",
                "intakeDate": "01/23/2018",
                "patientName": "0965749",
                "walkDate": "2018-01-25 12:15:07",
                "photoName": "0965749.png",
                "kennelId": "S5",
                "owner": "Henderson Shelter (HS)",
                "groupString": "Canine"
            }*/
            static let updatePatient = url_IS + "updatePatient"
            
            //http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getAllPatients
            static let getAllPatients = url_IS + "getAllPatients"
            //static let getAllPatientsKey = "allPatientsIS" patientRecords
            
            //http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/getPatientsCount
            static let getPatientsCount = url_IS + "getPatientsCount"
            
            //http://ec2-52-33-132-52.us-west-2.compute.amazonaws.com:9000/api/deletePatient
            /*{
                "patientID"   : "10"
            }*/
            static let deletePatient = url_IS + "deletePatient"
        }
    }
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
        static let postTxNotes =    "http://" + url + "treatmentNotesInsert"
        
        static let deletePatient =  "http://" + url + "patientsDelete"
        
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
            "sex":          update["sex"]! //Note true means Female
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
    func treatmentNotesParameters(update:Dictionary<String,String>,
                                  databasePID: Int) -> [String : Any]{
        let parameters = [
            //autoInc treatmentNotesId
            "patientID":                    databasePID,
            "patientName":                  update["patientID"]!,
            "lVT":                         update["lVT"]!,
            "shelter":                 update["shelter"]!,
            "breed":                 update["breed"]!,
            "dVM":               update["dVM"]!,
            "age":                update["age"]!,
            "date":                update["date"]!,
            "dX":                 update["dX"]!,
            "sex":               update["sex"]!,   //Note true means female
            "notes":               update["notes"]!
            ] as [String : Any]
        return parameters
    }
}
