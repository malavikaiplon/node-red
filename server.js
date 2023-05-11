var express = require('express');
var app = express();
var fs = require("fs");


app.use(express.static('public'));
app.get('/index.htm', function (req, res) {
    res.sendFile( __dirname + "/" + "index.htm" );
})
app.get('/process_get', function (req, res) {
    // Prepare output in JSON format
    response = {
       first_name:req.query.first_name,
       last_name:req.query.last_name,
       id:req.query.id,
       
    };
    console.log(response);
    res.end(JSON.stringify(response));
 })
 

var user = {
    "user5" : {
       "name" : "malavika",
       "password" : "password4",
       "profession" : "developer",
       "id": 4
    }
 }
 
 app.post('/addUser', function (req, res) {
    // First read existing users.
    fs.readFile( __dirname + "/" + "users.json", 'utf8', function (err, data) {
       data = JSON.parse( data );
       data["user5"] = user["user5"];
       console.log( data );
       res.end( JSON.stringify(data));
    });
 })
 var id = 2;

 app.delete('/deleteUser', function (req, res) {
    // First read existing users.
    fs.readFile( __dirname + "/" + "users.json", 'utf8', function (err, data) {
       data = JSON.parse( data );
       delete data["user" + 2];
        
       console.log( data );
       res.end( JSON.stringify(data));
    });
 })
 

var server = app.listen(8081, function () {
   var host = server.address().address
   var port = server.address().port
   console.log("Example app listening at http://%s:%s", host, port)
})