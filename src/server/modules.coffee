conf = require './../../config/modules.js'

exports.init = (store, primus, cb) ->
  console.log "Init Saron Modules"

  resetServersConnection store, ->

    openServerSideSockets(store, primus)

    initPlugins(store, primus)

    cb && cb()


openServerSideSockets = (store, primus) ->
  daemon = primus.channel('daemon');

  daemonSparkIDs = {}

  daemon.on 'connection', (spark) ->
    console.log ">>>>>>>>>>>>>>>>>>>>> Saron: New Daemon connection!"

    serverID = null

    spark.on 'auth', (auth, cb) ->
      console.log "Saron daemon auth: ", auth

      model = store.createModel({fetchOnly: true})

      userQuery = model.query 'auths', {'local.email': auth.email, $limit: 1}
      userQuery.fetch (err) ->
        return cb err if err
        return cb "Email #{auth.email} is not registered!" unless userQuery.get()[0]

        user = userQuery.get()[0]

        $server = model.query 'servers', {userId: user.id, name: auth.nodeName}
        $server.fetch (err) ->
          return cb err if err

          server = $server.get()[0]
          unless server
            server =
              id: model.id()
              userId: user.id
              name: auth.nodeName
            model.add 'servers', server

          model.set "servers.#{server.id}.connected", true

          serverID = server.id
          daemonSparkIDs[serverID] = spark.id

          model.unload()
          cb null, serverID

    spark.on 'end', () ->
      console.log "Daemon disconnected"
      console.log "================================--------------------------------=========================="

      return if spark.id != daemonSparkIDs[serverID]
      delete daemonSparkIDs[serverID]

      model = store.createModel({fetchOnly: true})
      server = model.at "servers.#{serverID}"
      server.fetch (err)  ->
        return if err
        server.set 'connected', false
        model.unload()

#  Init all Saron server side modules
initPlugins = (store, primus) ->
  for m in conf.modules
    module = require 'saron-' + m
    module.init store, primus

resetServersConnection = (store, cb) ->
  console.log "------------------=================--------------------"
  model = store.createModel({fetchOnly: true})
  servers = model.at 'servers'
  servers.fetch (err) ->
    return if err
    for path of servers.root._fetchedDocs
      model.set path + '.connected', false
    model.unload()
    cb && cb()