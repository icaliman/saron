app = require './index'

app.get app.pages.admin.href+'/:nodeId?', (page, model, params, next) ->
  user = model.get '_session.user'

  return page.redirect '/login' unless user

  servers = model.query 'servers', {userId: user.id, $orderby: {name: 1}}

  servers.subscribe (err) ->
    next err if err

    model.ref "_page.servers", servers

    page.render 'admin'


app.component 'admin:servers-list', class ServersList

  init: (model) ->
    console.log ">>>>>>>>>>> INIT ADMIN <<<<<<<<<<<<"
    @servers = model.at 'servers'

    if process.title is 'browser' and not window.primus
      console.log ">>>>>>>>>>>>>>>>>>>>>>> BROWSER: CREATE PRIMUS <<<<<<<<<<<<<<<<<<<<<<<"
      window.primus = new Primus()

  create: (model) ->
    console.log ">>>>>>>>>>> CREATE ADMIN <<<<<<<<<<<<"
    @calculateContentBox()

    @select(0)


  select: (index) ->
    @model.set 'selectedServer', @servers.get index

  remove: (index) ->
#    console.log @servers.remove index
#    console.log "Remove:", index
#    @model.root.remove "_page.servers", index
#    console.log @servers.get().length, Math.min(index, @servers.get().length-1)
#    @select index

#    server = @servers.get index
#    @servers.push server
#    @model.root.push "_page.servers", server

  calculateContentBox: ->
    target = document.getElementById('contentTarget')
    el = target.getElementsByClassName('tab-content')[0]
    b = el.getBoundingClientRect()
    size =
      width: window.innerWidth || document.body.clientWidth
      height: window.innerHeight || document.body.clientHeight
    box =
      width: Math.max(b.width, 200)
      height: Math.max(size.height - b.top, 200)
    @model.root.set '_page.contentBox', box

    el.style.width = box.width + 'px'
    el.style.height = box.height + 'px'
