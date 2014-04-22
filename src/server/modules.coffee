conf = require './../../config/modules.js'

exports.init = (store, primus) ->
  console.log "Init Saron Modules"

  openServerSideSockets(store, primus)

  initPlugins(store, primus)


openServerSideSockets = (store, primus) ->
  daemon = primus.channel('daemon');

  daemon.on 'connection', (spark) ->
    console.log "Saron: New Daemon connection!"

    nodeId = null

#    spark.send 'connection'

    spark.on 'auth', (auth, cb) ->
      console.log "Saron daemon auth: ", auth

      model = store.createModel({fetchOnly: true})

      userQuery = model.query 'auths', {'local.email': auth.email, $limit: 1}
      userQuery.fetch (err) ->
        return cb err if err
        return cb "Email #{auth.email} is not registered!" unless userQuery.get()[0]

        user = userQuery.get()[0]

        serverQuery = model.query 'servers', {userId: user.id, name: auth.nodeName}
        serverQuery.fetch (err) ->
          return cb err if err

          serverNode = serverQuery.get()[0]
          unless serverNode
            serverNode =
              id: model.id()
              userId: user.id
              name: auth.nodeName
            model.add 'servers', serverNode

          model.set "servers.#{serverNode.id}.connected", true

          nodeId = serverNode.id

          cb null, nodeId
#      spark.send auth
#      cb("OK")
#      if auth.email

    spark.on 'end', () ->
      console.log "Daemon disconnected"


#  Init all Saron server side modules
initPlugins = (store, primus) ->
  for m in conf.modules
    module = require 'saron-' + m
    module.init store, primus