var derby = require('derby');
var Primus = require('primus.io');

exports.run = run;

function run(app, options, cb) {
  options || (options = {});
  var port = options.port || process.env.PORT || 3000;

  function listenCallback(err) {
    console.log('%d listening. Go to: http://localhost:%d/', process.pid, port);
    cb && cb(err);
  }
  function createServer() {
    if (typeof app === 'string') app = require(app);
    require('./server').setup(app, options, function(err, expressApp, store) {
      if (err) throw err;
      var server = require('http').createServer(expressApp);
      var primus = new Primus(server, { transformer: 'browserchannel', parser: 'JSON' });
      require('./modules').init(store, primus, function() {
        server.listen(port, listenCallback);
      });
    });
  }
  derby.run(createServer);
}

// # unless fs.existsSync app.serializedDir
// #   app.serialize store, {minify: true}, (err) ->
// #     throw err if err