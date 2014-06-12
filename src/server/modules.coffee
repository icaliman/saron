conf = require './../../config/modules'

exports.init = (store, primus, cb) ->
  console.log "Init Saron Modules"

  resetServersConnection store, ->
    openServerSideSockets(store, primus)
    initPlugins(store, primus)
    cb && cb()


openServerSideSockets = (store, primus) ->
  daemons = primus.channel('daemon');
  browsers = primus.channel('browser');

  daemonSparkIDs = {}

  browsers.on 'connection', (spark) ->
    spark.on 'auth', (userID) ->
      spark.join userID

  daemons.on 'connection', (spark) ->
    console.log ">>>>>>>>>>>>>>>>>>>>> Saron: New Daemon connection!"

    serverID = null
    userID = null

    setInterval ( ->
      spark.send 'test', 123
    ), 4000

    spark.on 'auth', (auth) ->
      console.log "Saron daemon auth: ", auth

      cb = (err, msg) ->
        console.log "Send authorize to daemon: ", arguments
        spark.send 'authorized', err, serverID

      model = store.createModel({fetchOnly: true})

      userQuery = model.query 'auths', {'local.email': auth.email, $limit: 1}
      userQuery.fetch (err) ->
        return cb err if err
        return cb "Email #{auth.email} is not registered!" unless userQuery.get()[0]
        user = userQuery.get()[0]

        monitor = model.at "monitor.#{user.id}"
        monitor.subscribe (err) ->
          return cb err if err

          serverIds = monitor.at 'serverIds'
          servers = model.query 'servers', serverIds
          servers.subscribe (err) ->
            return cb err if err

#            TODO: optimize this
            server = null
            for s, i in servers.get()
              if s.name is auth.nodeName
                server = s
                break
            unless server
              server =
                id: model.id()
                name: auth.nodeName
                userID: user.id
              model.add 'servers', server
              serverIds.push server.id

            model.set "servers.#{server.id}.connected", true

            userID = user.id
            serverID = server.id
            daemonSparkIDs[serverID] = spark.id

            browsers.room(userID).send 'server-connection', serverID, true

            model.unload()
            cb null, serverID
#            spark.send 'authorized', serverID

    spark.on 'end', () ->
      console.log "Daemon disconnected"

      return if spark.id != daemonSparkIDs[serverID]
      delete daemonSparkIDs[serverID]

      model = store.createModel({fetchOnly: true})
      server = model.at "servers.#{serverID}"
      server.fetch (err)  ->
        return if err
        server.set 'connected', false
        browsers.room(userID).send 'server-connection', serverID, false
        model.unload()

#  Init all Saron server side modules
initPlugins = (store, primus) ->
  for m in conf.modules
    module = require 'saron-' + m
    module.init store, primus

resetServersConnection = (store, cb) ->
  model = store.createModel({fetchOnly: true})
  servers = model.at 'servers'
  servers.fetch (err) ->
    return if err
    for path of servers.root._fetchedDocs
      model.set path + '.connected', false
    model.unload()
    cb && cb()