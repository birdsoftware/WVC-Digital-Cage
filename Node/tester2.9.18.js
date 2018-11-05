var http = require("http");
var express = require('express');
var app = express();
var mysql      = require('mysql');
var bodyParser = require('body-parser');
//load patients route
//≈require('./routes/patients')();

//start mysql connection
var connection = mysql.createConnection({
  host     : 'dcc.cnyc2d9mjtr2.us-west-2.rds.amazonaws.com', //mysql database host name
  user     : 'dcc', //mysql database user name
  password : '2425oquendo', //mysql database password
  port 	   : '3306', //mysql database name
  database : 'dcc'
});

connection.connect(function(err) {
  if (err) throw err
  console.log('You are now connected to dcc database...')
})
//end mysql connection

//start body-parser configuration
app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
}));
//end body-parser configuration

//create app server
var server = app.listen(9000,  "ec2-54-244-57-24.us-west-2.compute.amazonaws.com", function () {

  var host = server.address().address
  var port = server.address().port

  console.log("Example app listening at http://%s:%s", host, port)

});

//rest api to get all results
//http://ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/patients
app.get('/patients', function (req, res) {

   connection.query('select * from patients', function (error, results, fields) {
	  if (error) throw error;
	  res.end(JSON.stringify(results));
	  //res.send(JSON.stringify({"status":200, "error":null,"response":results}));
	});

});
//app.use('/patients', patients.getAllPatients); //patients.js

//rest api to check if table exist
app.get('/tableExist', function (req, res) {

   connection.query('select 1 from patients limit 1', function (error, results, fields) {
	if (error){
	   res.json({type: false, data: error});
	//Example Postman Response for error:
	//{
	//    "type": false,
	//    "data": {
	//        "code": "ER_NO_SUCH_TABLE",
	//        "errno": 1146,
	//        "sqlMessage": "Table 'dcc.patients2' doesn't exist",
	//        "sqlState": "42S02",
	//        "index": 0,
	//        "sql": "select 1 from  patients2 limit 1"
	//    }
	//}
	}
	else {
	   res.json({type: true, data: results});
	}
   });

});

//rest api to get a single patient data
//http://ec2-54-244-57-24.us-west-2.compute.amazonaws.com:9000/patients/Bob
app.get('/patients/:name', function (req, res) {
   console.log(req);
   connection.query('select * from patients where patientName=?', [req.params.name], function (error, results, fields) {
	  if (error) throw error;
	  res.end(JSON.stringify(results));
	});
});

app.get('/patients/:name/intakeDate/:inDate', function (req, res) {//not replace / with %2F in 12/15/2017
   var pName  = req.params.name;
   var pDate = req.params.inDate;
   connection.query('select * from patients where patientName = "' + pName + '" and intakeDate = "' + pDate  + '"', function (error, results, fields) {
	if (error){
           res.json({type: false, data: error});
        }
        else {
           res.json({type: true, data: results});
        }
   });

});

//-------------------
// PATIENTS
//-------------------
//rest api to create a new record into mysql database
//{"status":"Active", "intakeDate":"12/15/2017", "patientName":"Suzy", "walkDate":"2017-12-15 10:00:21", "photoName":"Suzy.png", "kennelId":"S1", "owner":"The Animal Foundation (TAF)", "groupString":"Canine"}
app.post('/patientsInsert2', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO patients SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//rest api to UPDATE record into mysql database
app.put('/patientsUpdate', function (req, res) {
   connection.query('UPDATE `patients` SET `status`=?,`intakeDate`=?,`patientName`=?,`walkDate`=?,`photoName`=?,`kennelId`=?,`owner`=?,`groupString`=? where `patientId`=?',
	[req.body.status,
	req.body.intakeDate,
	req.body.patientName,
	req.body.walkDate,
	req.body.photoName,
	req.body.kennelId,
	req.body.owner,
	req.body.groupString,
	req.body.patientId], function (error, results, fields) {
	  if (error) throw error;
	  res.end(JSON.stringify(results));
	});
});

//rest api to DELETE record from mysql database
app.delete('/patientsDelete2/:id', function (req, res) {
   console.log(req.body);
   connection.query('DELETE FROM `patients` WHERE `patientName` = ?', [req.body.id], function (error, results, fields) {
	  if (error) throw error;
	  res.end('Record has been deleted!');
	});
});
app.delete('/patientsDelete/:id', function (req, res){
//DELETE FROM `patients` WHERE `patients`.`patientId` = 78;
   connection.query('DELETE FROM `patients` WHERE `patients`.`patientId` = ?', [req.params.id], function (error, results, fields){
	if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// VITALS
//-------------------
//rest api to create a new record into mysql database
//{"temperature": update["temperature"]!,"pulse": update["pulse"]!,"weight": update["weight"]!,
// "exitWeight":update["exitWeight"]!, "cRT_MM": update["cRT_MM"]!,"respiration": update["respiration"]!,
// "initialsVitals": update["initialsVitals"]!, "patientName": update["patientID"]!,"patientId": "123"}

app.post('/vitalsInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO vitals SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// PHYSICAL EXAM
//-------------------
app.post('/peInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO physicalExam SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// NOTIFICATION
//-------------------
app.post('/notificationInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO notifications SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// DEMOGRAPHICS
//-------------------
app.post('/demographicsInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO demographics SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// AMPM
//-------------------
//Bulk insert API using VALUES
app.post('/ampmInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO ampms SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// INCISIONS
//-------------------
//Bulk insert API using VALUES
app.post('/incisionsInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO incisions SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// PROCEDURES
//-------------------
//Bulk insert API using VALUES
app.post('/proceduresInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO procedures SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// BADGES
//-------------------
//Bulk insert API using VALUES
app.post('/badgesInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO badges SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// TREATMENT VITALS
//-------------------
//Bulk insert API using VALUES
app.post('/treatmentVitalsInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO treatmentVitals SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// TREATMENTS
//-------------------
//Bulk insert API using VALUES
app.post('/treatmentsInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO treatments SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});

//-------------------
// TREATMENT NOTES
//-------------------
//Bulk insert API using VALUES
app.post('/treatmentNotesInsert', function (req, res) {
   var postData  = req.body;
   connection.query('INSERT INTO treatmentNotes SET ?', postData, function (error, results, fields) {
          if (error){
           res.json({type: false, data: error});
          }
          else {
            res.json({type: true, data: results});
          }
   });
});
