var plan = require('./controller.js');

module.exports = function(application){

  application.post('/UpdatePlan', function(req, res){
    plan.UpdatePlan(req, res);
  });
  application.post('/AddPlan', function(req, res){
    plan.AddPlan(req, res);
  });
  application.post('/UpdateNode', function(req, res){
    plan.UpdateNode(req, res);
  });
  application.post('/GetNode', function(req, res){
    plan.GetNode(req, res);
  });
  application.get('/download/:filename', function(req, res){
    var fileToBeDownloaded = './uploads/' + req.params.filename;
    res.download(fileToBeDownloaded);
  });
  application.get('/GetOverallPlanning', function(req, res){
    plan.GetOverallPlanning(req, res);
  });
}
