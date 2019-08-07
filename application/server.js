// nodejs server setup 

// call the packages we need
var express       = require('express');        // call express
var bodyParser    = require('body-parser');
var http          = require('http')
var fs            = require('fs');
var Fabric_Client = require('fabric-client');
var path          = require('path');
var util          = require('util');
var os            = require('os');

// instantiate the application
var application = express();

application.use(bodyParser.urlencoded({ extended: true }));
application.use(bodyParser.json());


require('./routes.js')(application);

// Save our port
var port = process.env.PORT || 8000;


// Start the server and listen on port 
application.listen(port,function(){
  console.log("Live on port: " + port);
});

