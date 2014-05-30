require('coffee-script/register');
require('./utils/generate-components-loader');
require('./src/server').run(__dirname + '/src/app', {static: __dirname + '/public'});
