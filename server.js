require('coffee-script/register');
require('./utils/generate-components-loader');
//require('./utils/derby-patch');
require('./src/server').run(__dirname + '/src/app', {static: __dirname + '/public'});
