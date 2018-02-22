//Initialising node modules
var express = require("express");
var bodyParser = require("body-parser");
var sql = require("mssql");
var app = express(); 
var dbConfig = {};
// Body Parser Middleware
app.use(bodyParser.json()); 

//CORS Middleware
app.use(function (req, res, next) {
    //Enabling CORS 
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, contentType,Content-Type, Accept, Authorization");
    next();
});

//Setting up server
var server = app.listen(8083, function() {
    console.log('Server is running3..');
});

//Initiallising connection string
/*var dbConfig = {
domain: 'MASTEK',
    user:  'Chrisg102570',
    password: 'M8$tek#123',
    server: 'IND-MHPDW100512',
    database: 'CDPCRSDEV'
};*/

function configData(filepath, field, fvalue, callback){
	var file=require('xlsjs').readFile(filepath);
	console.log('file ---->' + file.Sheets.Sheet1);		
	
	var XLSX = require('xlsx')
	var workbook = XLSX.readFile(filepath);
	var sheet_name_list = workbook.SheetNames;
	//var xlData = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]);
	//console.log(xlData);
	sheet_name_list.forEach(function(y) {
		var worksheet = workbook.Sheets[y];
		var headers = {};
		var data = [];
		var xlsData = {} ;
		
		for(z in worksheet) {
			if(z[0] === '!') continue;
			//parse out the column, row, and value
			var col = z.substring(0,1);
			var row = parseInt(z.substring(1));
			var value = worksheet[z].v;
			
			//console.log ( col + ' ' + row + ' ' + value);
			//store header names
			if(row == 1) {
				headers[col] = value;
				continue;
			}

			if(!data[row]) data[row]={};
			data[row][headers[col]] = value;
		}
		//drop those first two rows which are empty
		data.shift();
		data.shift();
		console.log(data);
		
		xlsData = data.find(		
			(id) => {
			console.log (field + ' ' + fvalue);
			 if(field == 'Type'){
				return id.Type === fvalue;
			 }
			 if(field == 'Branch') {
				return id.BranchID === fvalue;
			 }
		   }
		);
		console.log('xls ---->' + xlsData);		
		console.log(xlsData);
		
		return callback(xlsData);
		/*dbConfig ['user'] = xlsData.Username;
		dbConfig ['password']= xlsData.Password;
		dbConfig ['server'] = xlsData.Host;
		dbConfig ['database']= xlsData.Database;*/
		
	});
}

//Function to connect to database and execute query
var  executeQuery = function(res, query){      
		console.log('connection ------> ' + JSON.stringify(dbConfig));
     sql.connect(dbConfig, function (err) {
         if (err) {   
                     console.log("Error while connecting database :- " + err);
                     res.send(err);
                  }
                  else {
                         // create Request object
                         var request = new sql.Request();
                         // query to the database
                         request.query(query, function (err, resp) {
                           if (err) {
                                      console.log("Error while querying database :- " + err);
                                      res.send(err);
                                     }
                                     else {
                                       console.log(resp);  									 
                                       res.send(resp);
                                            }
					   sql.close();
							
                               });
                       }
      });           
}

//GET API
app.get('/', function(req , res){
                var query = "select * from dbo.country";
                executeQuery (res, query);
});

app.get('/:pseudo', function(req , res){
                var query = "select * from dbo.country where countrypseudo='" + req.params.pseudo + "'";
                executeQuery (res, query);
});

app.get('/query/:branch/:qstr', function (req, res) {			
	var branch = req.params.branch;
	console.log('Branch : ' + branch);
	
	//var filepath = '.\\xls' + '\\dbConnection.xlsx';
	//var filepath = 'd:\\Hubot\\xls\\dbConnection.xlsx';
	//console.log('path --> ' + filepath);
    
	//var data = configData(filepath,branch);
	
	//console.log('Data : ' + data.Username);
	var filepath = 'd:\\Hubot\\xls\\configData.xlsx';
	var fvalue = 'connection';
	var field = 'Type';
	
	configData(filepath, field, fvalue, function(data) {
			console.log('Data : ' + data); 
			var tmpPath = 'd:\\Hubot\\';   // '.\\'
			var connpath = tmpPath  + data.Folder + '\\'+ data.Filename;
			console.log(connpath);
			var fvalue = branch;
			var field = 'Branch';
			console.log ('config -->' + field + ' ' + fvalue );
			configData(connpath, field, fvalue, function(connData) {
				console.log('Conn Data : ' + connData);
					dbConfig ['domain'] =  'MASTEK';
					dbConfig ['user'] = connData.Username;
					dbConfig ['password']= connData.Password;
					dbConfig ['server'] = connData.Host;
					dbConfig ['database']= connData.Database;
			});
			
	});	
	
	var query = req.params.qstr;
	console.log(query);
	executeQuery (res, query);
});

//POST API
 app.post('/', function(req , res){
                var query = "INSERT INTO dbo.country (countrypseudo,countrydesc) VALUES ('" + req.body.countrypseudo + "','" + req.body.countrydesc + "')";
                executeQuery (res, query);
});

//PUT API
 app.put("/api/user/:id", function(req , res){
                var query = "UPDATE dbo.country SET countrydesc= '" + req.body.countrydesc  +  "'   WHERE countryid= " + req.params.id;
                executeQuery (res, query);
});

// DELETE API
 app.delete("/api/user/:id", function(req , res){
                var query = "DELETE FROM dbo.country WHERE countryid=" + req.params.id;
                executeQuery (res, query);
});