app = require './index'

app.get '/login', (page, model, params, next) ->
  page.render 'login'