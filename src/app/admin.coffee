app = require './index'

app.get app.pages.admin.href+'/:nodeId?', (page, model, params, next) ->
  user = model.get '_session.user'

  return page.redirect '/login' unless user

  servers = model.query 'servers', {userId: user.id, $orderby: {name: 1}}

  servers.subscribe (err) ->
    next err if err

    model.ref "_page.servers", servers

    page.render 'admin'


app.component 'admin', class AdminComponent
  init: (model) ->
    console.log ">>>>>>>>>>> INIT ADMIN <<<<<<<<<<<<"

    if process.title is 'browser'
      unless window.primus
        console.log ">>>>>>>>>>>>>>>>>>>>>>> BROWSER: CREATE PRIMUS <<<<<<<<<<<<<<<<<<<<<<<"
        window.primus = new Primus() #({manual: true})
#      window.primus.open()

  create: (model, dom) ->
    console.log ">>>>>>>>>>> CREATE ADMIN <<<<<<<<<<<<", @contentTarget

    @target = @contentTarget.getElementsByClassName('tab-content')[0]

    @calculateContentBox()
    @dom.addListener 'resize', window, => @calculateContentBox()
#    @dom.addListener 'mouseover', window, => @calculateContentBox()

  calculateContentBox: ->
#    return if @lastWindowWidth == (window.innerWidth || document.body.innerWidth)

    @target.style.width = '';
    b = @target.getBoundingClientRect()
    size =
      width: window.innerWidth || document.body.clientWidth
      height: window.innerHeight || document.body.clientHeight
    box =
      width: Math.max(b.width, 200)
      height: Math.max(size.height - b.top, 200)

    @model.root.set '_page.contentBox', box

    @target.style.width = box.width + 'px'
    @target.style.height = box.height + 'px'

    @lastWindowWidth = size.width

  destroy: () ->
    console.log "0000000000000000000000000000000000000000000000000000000000"
#    window.primus.end()

app.component 'admin:server-list', class ServersListComponent
  init: (model) ->
    console.log ">>>>>>>>>>> INIT ADMIN SERVER LIST <<<<<<<<<<<<"
    @select(0)

  select: (index) ->
    @model.root.ref '_page.selectedServer', @model.at "servers.#{index}"

  remove: (index) ->
    @servers.remove index
#    @model.root.del "servers.#{@servers.get(index).id}"
#    @servers.get().length, Math.min(index, @servers.get().length-1)
    @select index