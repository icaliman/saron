app = module.exports = require('derby').createApp 'saron', __filename
app.use require('d-bootstrap')
app.loadViews __dirname + '/../../views'
app.loadStyles __dirname + '/../../assets/styles'
app.component require('d-connection-alert')
app.component require('d-before-unload')

app.use require('derby-login/components')

# Init Created components
#app.use require('d-auth/components')
app.component require('./../../components/alert')


app.get '*', (page, model, params, next) ->
  console.log "---------------------------------------------------------"
  if model.get '_session.loggedIn'
    userId = model.get '_session.userId'
    $user = model.at "users.#{userId}"
    model.subscribe $user, ->
      model.ref '_session.user', $user
      next()
  else
    next()


require './pages'

require './home'
require './login'
require './admin'


modules = require('../../config/modules.js').modules
app.proto.modules = ->
  return modules


# Init Saron components
require './modules'