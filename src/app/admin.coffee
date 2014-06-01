app = require './index'
utils = require 'saron-utils'

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
    primus = utils.getPrimus()

  create: (model, dom) ->
    @tabs = @contentTarget.getElementsByClassName('nav-tabs')[0]
    @target = @contentTarget.getElementsByClassName('tab-content')[0]
    @calculateContentBox()
    @dom.addListener 'resize', window, => @calculateContentBox()
    @dom.addListener 'mouseover', @target, (e) =>
      @target.className = 'tab-content mouse-over'
    @dom.addListener 'mouseout', @target, (e) =>
      @target.className = 'tab-content'

  calculateContentBox: ->
    @target.style.width = '';
    b = @target.getBoundingClientRect()
    size =
      width: window.innerWidth || document.body.clientWidth
      height: window.innerHeight || document.body.clientHeight
    box =
      width: Math.max(b.width, 200)
      height: Math.max(size.height - b.top, 200)
    @target.style.width = box.width + 'px'
    @target.style.height = box.height + 'px'
    @tabs.width = box.width + 'px'
    @model.root.set '_page.contentBox', box

  destroy: () ->
    utils.destroyPrimus()

app.component 'admin:server-list', class ServersListComponent
  init: (model) ->
    @select(0)

  select: (index) ->
    @model.root.ref '_page.selectedServer', @model.at "servers.#{index}"

  remove: (index, e) ->
#    @model.at("servers").remove index
    @model.root.del "servers.#{@model.at("servers").get(index).id}"

    e.stopPropagation()

app.component 'admin:server-settings', class ServerSettings
  deleteServer: ->
    server = @model.at 'server'
    if confirm "Are you sure you wont to stop monitoring '" + server.get('name') + "' ?"
      @model.root.del "servers.#{server.get('id')}"