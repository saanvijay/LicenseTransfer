var lc = require('./controller.js');

module.exports = function(application){

  application.post('/GenerateLicense', function(req, res){
    lc.GenerateLicense(req, res);
  });
  application.post('/ShareLicense', function(req, res){
    lc.ShareLicense(req, res);
  });
  application.post('/RequestLicense', function(req, res){
    lc.RequestLicense(req, res);
  });
  application.get('/GetAllLicenses', function(req, res){
    lc.GetAllLicenses(req, res);
  });
}
