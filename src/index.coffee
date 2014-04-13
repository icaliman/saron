app = module.exports = require('derby').createApp 'sink', __filename
app.loadViews __dirname + '/../views'
app.loadStyles __dirname + '/../assets/styles'
app.component require('d-connection-alert')
app.component require('d-before-unload')
app.component require('d-console')

derby = require('derby')

for a of derby
  console.log a

#model = derby.createModel();

#model.subscribe 'players', (err) ->
#  return console.log err if err
#  console.log "Model data:"
#  console.log model.get()

require './pages'

require './home'
require './console'
require './bench'
require './live-css'
require './leaderboard'
require './table'

['get', 'post', 'put', 'del'].forEach (method) ->
  app[method] app.pages.submit.href, (page, model, {body, query}) ->
    argsJson = JSON.stringify {method, body, query}, null, '  '
    model.set '_page.args', argsJson
    page.render 'submit'

app.get app.pages.error.href, ->
  throw new Error 500

app.get app.pages.back.href, (page) ->
  page.redirect 'back'
