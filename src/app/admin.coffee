app = require './index'

app.get app.pages.admin.href+'/:nodeId?', (page, model, params, next) ->
  user = model.get '_session.user'

  return page.redirect '/login' unless user

  servers = model.query 'servers', {userId: user.id}

  servers.subscribe (err) ->
    next err if err

    model.ref "_page.servers", servers

    page.render 'admin'


app.component 'admin', class Admin

  init: (model) ->
    console.log ">>>>>>>>>>> INIT ADMIN <<<<<<<<<<<<"
    @servers = model.ref 'servers', model.root.at("_page.servers")

    @select(0)

    if process.title is 'browser' and not window.primus
      console.log ">>>>>>>>>>>>>>>>>>>>>>> BROWSER: CREATE PRIMUS <<<<<<<<<<<<<<<<<<<<<<<"
      window.primus = new Primus()

  create: (model) ->
    console.log ">>>>>>>>>>> CREATE ADMIN <<<<<<<<<<<<"


  select: (index) ->
    @model.ref 'selected', @servers.at index
    @model.root.ref '_page.selectedServer', @servers.at index

  remove: (index) ->
#    console.log @servers.remove index
#    console.log @servers.get().length, Math.min(index, @servers.get().length-1)
    @select 1