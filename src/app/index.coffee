app = module.exports = require('derby').createApp 'saron', __filename
app.use require('d-bootstrap')
app.loadViews __dirname + '/../../views'
app.loadStyles __dirname + '/../../assets/styles'
app.component require('d-connection-alert')
app.component require('d-before-unload')

# Init Created components
app.use require('d-auth/components')
app.component require('./../../components/alert')


require './pages'

require './home'
require './login'
require './admin'


modules = require('../../config/modules.js').modules
app.proto.modules = ->
  return modules


# Init Saron components
require './modules'