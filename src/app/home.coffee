app = require './index'

app.get '/', (page, model, params, next) ->
  page.render 'home'

#app.component 'home', class SaronHome
#  init: (model) ->
