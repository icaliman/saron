app = require './index'
utils = require 'saron-utils'

app.get app.pages.admin.href+'/:nodeId?', (page, model, params, next) ->
  user = model.get '_session.user'

  return page.redirect '/login' unless user

  monitor = model.at "monitor.#{user.id}"
  monitor.subscribe (err) ->
    return next err if err

    serverIds = monitor.at 'serverIds'
    unless serverIds.get()
      serverIds.set []

    servers = model.query 'servers', serverIds
    servers.subscribe (err) ->
      return next err if err

      model.refList '_page.servers', 'servers', serverIds

      page.render 'admin'


app.component 'admin', class AdminComponent
  init: (model) ->
    model.root.destroy '_views'
    for name, view of @app.views.nameMap
      if view.componentFactory?.constructor.prototype.targetView
        model.root.push '_views.'+view.componentFactory.constructor.prototype.targetView, name

  create: (model, dom) ->
    window.app = @app
    @initSocket()
    @tabs = @contentTarget.getElementsByClassName('nav-tabs')[0]
    @target = @contentTarget.getElementsByClassName('tab-content')[0]
    @calculateContentBox()
    @dom.addListener 'resize', window, => @calculateContentBox()
    @dom.addListener 'mouseover', @target, (e) =>
      @model.set 'mouseOver', true
    @dom.addListener 'mouseout', @target, (e) =>
      @model.set 'mouseOver', false
    model.root.on 'change', '_page.currentTab',  => setTimeout => @calculateContentBox()

  initSocket: ->
    primus = utils.getPrimus()
    @socket = primus.channel 'browser'
    @socket.send 'auth', @model.root.get '_session.user.id'
    @socket.on 'server-connection', (serverID, con) =>
      if @model.root.get "servers.#{serverID}"
        @model.root.set "servers.#{serverID}.connected", con

  calculateContentBox: ->
    @target.style.width = ''
    b = @target.getBoundingClientRect()
    scroll =
      top: document.body?.scrollTop || 0
      left: document.body?.scrollLeft || 0
    size =
      width: window.innerWidth || document.body.clientWidth
      height: window.innerHeight || document.body.clientHeight
    box =
      width: Math.max(b.width, 200)
      height: Math.max(size.height - b.top - scroll.top - 15, 100)
    old = @model.root.get '_page.contentBox'
    @target.style.width = box.width + 'px'
    @target.style.height = box.height + 'px'
    @tabs.style.width = box.width + 'px'

    console.log "RESIZE 111: ", box
    return if old && old.width == box.width && old.height == box.height
    @model.root.set '_page.contentBox', box
    console.log "RESIZE 222: ", box

    @model.set 'smallScreen', (box.width < 500)
    @model.set 'xsmallScreen', (box.width < 400)

  destroy: () ->
    utils.destroyPrimus()

app.component 'admin:server-list', class ServersListComponent
  init: (model) ->
    @select(0)

  create: ->
    @dom.on 'click', (e) =>
      unless @sServer.contains e.target
        @model.set 'showServers', false

  select: (index) ->
    @model.root.ref '_page.selectedServer', @model.at "servers.#{index}"

  showServers: ->
    @model.set 'showServers', true

app.component 'admin:server-settings', class ServerSettings
  deleteServer: ->
    server = @model.get 'server'
    if confirm "Are you sure you wont to stop monitoring '#{server.name}' ?"
      for s, i in @model.root.get("_page.servers")
        if s and  s.id is server.id
          @model.root.remove "_page.servers", i
          break

      app.history.push('/admin')
