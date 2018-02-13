//Initialising node modules
var express = require("express");
var bodyParser = require("body-parser");
var sql = require("mssql");
var app = express(); 

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
var dbConfig = {
domain: 'MASTEK',
    user:  'Chrisg102570',
    password: 'M8$tek#123',
    server: 'IND-MHPDW100512',
    database: 'CDPCRSDEV'
};

//Function to connect to database and execute query
var  executeQuery = function(res, query){             
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

app.get('/query/:qstr', function (req, res) {			
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