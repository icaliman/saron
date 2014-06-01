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
#  init: (model) ->

  create: (model, dom) ->
    @initSocket()
    @tabs = @contentTarget.getElementsByClassName('nav-tabs')[0]
    @target = @contentTarget.getElementsByClassName('tab-content')[0]
    @calculateContentBox()
    @dom.addListener 'resize', window, => @calculateContentBox()
    @dom.addListener 'mouseover', @target, (e) =>
      @target.className = 'tab-content mouse-over'
    @dom.addListener 'mouseout', @target, (e) =>
      @target.className = 'tab-content'

  initSocket: ->
    primus = utils.getPrimus()
    @socket = primus.channel 'browser'
    @socket.send 'auth', @model.root.get '_session.user.id'
    @socket.on 'server-connection', (serverID, con) =>
      if @model.root.get "servers.#{serverID}"
        @model.root.set "servers.#{serverID}.connected", con

  calculateContentBox: ->
    @target.style.width = '';
    b = @target.getBoundingClientRect()
    size =
      width: window.innerWidth || document.body.clientWidth
      height: window.innerHeight || document.body.clientHeight
    box =
      width: Math.max(b.width, 200)
      height: Math.max(size.height - b.top - 15, 200)
    @target.style.width = box.width + 'px'
    @target.style.height = box.height + 'px'
    @tabs.style.width = box.width + 'px'
    @model.root.set '_page.contentBox', box

  destroy: () ->
    utils.destroyPrimus()

app.component 'admin:server-list', class ServersListComponent
  init: (model) ->
    @select(0)

  select: (index) ->
    @model.root.ref '_page.selectedServer', @model.at "servers.#{index}"

app.component 'admin:server-settings', class ServerSettings
  deleteServer: ->
    server = @model.get 'server'
    if confirm "Are you sure you wont to stop monitoring '#{server.name}' ?"
      for s, i in @model.root.get("_page.servers")
        if s and  s.id is server.id
          @model.root.remove "_page.servers", i
          break

      app.history.push('/admin')
