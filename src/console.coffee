app = require './index'

app.get app.pages.cmd.href, (page, model, params, next) ->
  page.render 'console'


app.proto.newCommand = (command, callback) ->
  try
    callback null, eval(command)
  catch error
    callback error.message
