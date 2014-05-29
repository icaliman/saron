var coffeeify = require('coffeeify');
var derby = require('derby');
var express = require('express');
var redis = require('redis');
var RedisStore = require('connect-redis')(express);
var racerBrowserChannel = require('racer-browserchannel');
var liveDbMongo = require('livedb-mongo');
var parseUrl = require('url').parse;
//var auth = require('d-auth');
var derbyLogin = require('derby-login');
derby.use(require('racer-bundle'));

exports.setup = setup;

function setup(app, options) {
  var redisClient;
  if (process.env.REDIS_HOST) {
    redisClient = redis.createClient(process.env.REDIS_PORT, process.env.REDIS_HOST);
    redisClient.auth(process.env.REDIS_PASSWORD);
  } else if (process.env.OPENREDIS_URL) {
    var redisUrl = parseUrl(process.env.OPENREDIS_URL);
    redisClient = redis.createClient(redisUrl.port, redisUrl.hostname);
    redisClient.auth(redisUrl.auth.split(":")[1]);
  } else {
    redisClient = redis.createClient();
  }
  // redisClient.select(1);

  var mongoUrl = process.env.MONGO_URL || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/derby-app';
  // The store creates models and syncs data
  var store = derby.createStore({
    db: liveDbMongo(mongoUrl + '?auto_reconnect', {safe: true})
  , redis: redisClient
  });

  store.on('bundle', function(browserify) {
    // Add support for directly requiring coffeescript in browserify bundles
    browserify.transform(coffeeify);
  });

  var expressApp = express()
    .use(express.favicon())
    // Gzip dynamically rendered content
    .use(express.compress())
    // Respond to requests for application script bundles
    .use(app.scripts(store, {extensions: ['.coffee']}))

  if (options && options.static) {
    expressApp.use(express.static(options.static));
  }

  var auth_options = {
    collection: 'auths', // db collection
    publicCollection: 'users', // projection of db collection
    passport: { // passportjs options
      registerCallback: function(req, res, user, done) {
        var model = req.getModel();
        var $user = model.at('auths.' + user.id);
        model.fetch($user, function() {
          $user.set('email', $user.get('local.email'), done);
        })
      }
    },
    strategies: { // passportjs strategies
//      facebook: {
//        strategy: require('passport-facebook').Strategy,
//        conf: {
//          clientID: '58362219983',
//          clientSecret: 'da0fb6cbcb6cac1a0aca9f78200935d2',
//          callbackURL: 'http://localhost:3000/auth/facebook/callback'
//        }
//      },
//      github: {
//        strategy: require('passport-github').Strategy,
//        conf: {
//          clientID: 'eeb00e8fa12f5119e5e9',
//          clientSecret: '61631bdef37fce808334c83f1336320846647115'
//        }
//      },
//      vkontakte: {
//        strategy: require('passport-vkontakte').Strategy,
//        conf: {
//          clientID: '4373291',
//          clientSecret: 'fOZiLyGhSH1DHWLFFfZo',
//          callbackURL: 'http://localhost:3000/auth/vkontakte/callback'
//        }
//      }
    },
    user: { // projection
      id: true,
      email: true,
//      local: true,
      facebook: true,
      github: true,
      vkontakte: true
    }
  }

  expressApp
    // Add browserchannel client-side scripts to model bundles created by store,
    // and return middleware for responding to remote client messages
    .use(racerBrowserChannel(store))
    // Adds req.getModel method
    .use(store.modelMiddleware())

    .use(express.cookieParser())
    .use(express.session({
      secret: process.env.SESSION_SECRET || 'YOUR SECRET HERE'
    , store: new RedisStore()
    }))
//    .use(createUserId)
    .use(express.bodyParser())
//    .use(express.methodOverride())
//    .use(auth.middleware({passUser: true}))
    .use(derbyLogin.middleware(auth_options))


    // Creates an express middleware from the app's routes
    .use(app.router())
    .use(expressApp.router)
    .use(errorMiddleware)

  derbyLogin.routes(expressApp, store);

  expressApp.all('*', function(req, res, next) {
    next('404: ' + req.url);
  });

  exports.store = store;

  return expressApp;
}

//function createUserId(req, res, next) {
//  var model = req.getModel();
//  var userId = req.session.userId;
//  if (!userId) userId = req.session.userId = model.id();
//  model.set('_session.userId', userId);
//  next();
//}

var errorApp = derby.createApp();
errorApp.loadViews(__dirname + '/../../views/errors/error');
errorApp.loadStyles(__dirname + '/../../assets/styles/error');

function errorMiddleware(err, req, res, next) {
  if (!err) return next();

  var message = err.message || err.toString();
  var status = parseInt(message);
  status = ((status >= 400) && (status < 600)) ? status : 500;

  if (status < 500) {
    console.log(err.message || err);
  } else {
    console.log(err.stack || err);
  }

  var page = errorApp.createPage(req, res, next);
  page.renderStatic(status, status.toString());
}
