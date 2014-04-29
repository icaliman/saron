require('coffee-script/register');
//require('saron-starter').run(__dirname + '/src/app');
require('./src/server').run(__dirname + '/src/app', {static: __dirname + '/public'});
