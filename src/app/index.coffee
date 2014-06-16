app = module.exports = require('derby').createApp 'saron', __filename
app.serverUse(module, 'derby-stylus')
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


app.proto.create = (model, dom) ->
  dom.on 'click', (e) =>
    unless @navBar.contains e.target
      @model.set '_page.showMenu', false

modules = require('../../config/modules.js').modules
app.proto.modules = ->
  return modules

app.proto.toggleMenu = ->
  @model.set '_page.showMenu', !@model.get '_page.showMenu'

# Init Saron components
require './components'