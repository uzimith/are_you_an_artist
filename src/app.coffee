Q = require 'q'
express = require 'express'
connect = require 'connect'
cookieParser = require 'cookie-parser'
session = require 'express-session'
RedisStore = require('connect-redis')(session)
sessionStore = new RedisStore
  url: process.env.REDISTOGO_URL || "redis://localhost:6379"
  prefix: 'session:'

COOKIE_SECRET = "keyboard cat"
COOKIE_KEY   = "sid"
app = express()
app.use cookieParser()
app.use session
  store: sessionStore
  secret: COOKIE_SECRET
  name  : COOKIE_KEY
  # db: 1
server = require('http').createServer(app)
io = require('socket.io')(server)
app.use express.static('client')
server.listen process.env.PORT || 3000

#
# session share
#
io.use (socket, next)->
  cookie = require('cookie').parse socket.request.headers.cookie
  cookie = connect.utils.parseSignedCookies cookie, COOKIE_SECRET
  sessionID = cookie[COOKIE_KEY]
  sessionStore.get sessionID, (err, session)->
    if !err and session
      data =
        sessionID: sessionID
        sessionStore: sessionStore
      Session = require('express-session').Session
      socket.session = new Session(data, session)
      socket.session.id = sessionID
      next()
    else
      next new Error(if err then err.message else "session error")

#
# dynamic namespace
#
io.use (socket, next)->
  namespace = socket.request._query.id
  if namespace
    socket.session.namespace = namespace
    socket.session.save()
    unless io.nsps.hasOwnProperty("/"+namespace)
      console.log Object.keys(io.of(namespace).connected)
      nsp = io.of("/" + namespace)
      nsp.on 'connection', (socket)->
        socket.on 'make', (data)->
          console.log Object.keys(io.of(nsp.name).connected)
          socket.emit "notify", message: "接続しました。"
  next()

#
# app
#
# io.on 'connection', (socket)->
#   console.log "connection"
#   console.log io.namespaces
#   socket.session.join = false
  # socket.on 'setting', (data)->
  #   socket.emit 'setting', id: 0, infomation: data
#   #
#   # draw
#   #
#   socket.on 'draw', (data)->
#     console.log socket.session.room
#     io.sockets.in(socket.session.room).emit 'draw', data
#   #
#   # theme
#   #
#   socket.on 'theme', (data)->
#     console.log data
#     players = io.sockets.in(data.room).connected
#     console.log Object.keys(players)
#     for key, value of players
#       if key is socket.id
#         console.log "me"
#         value.emit "theme", order: "*", theme: data
#       else
#         console.log "other"
#         value.emit "theme", order: 0, theme: data
#     io.sockets.in(socket.session.room).emit 'notify', message: "お題が発行されました"
#     io.sockets.in(socket.session.room).emit 'notify', message: "ゲームがスタートします。"
#   #
#   # game
#   #
#   socket.on 'start', (data)->
#     io.sockets.in(socket.session.room).emit 'notify', message: "ゲームがスタートします。"
#     io.sockets.in(socket.session.room).emit 'update', mode: "start"
#
#   #
#   # update
#   #
#   socket.on 'update', (data)->
#     data.id = socket.id
#     io.sockets.in(socket.session.room).emit 'update', mode: "listing", infomation: data
#   #
#   # config
#   #
  # socket.on 'join', (data)->
    # if socket.session.join
    #   socket.emit "notify", message: "You already joinned"
    #   # io.sockets.of(socket.sesion.namespace).emit 'update', mode: "start"
    #   return
    # console.log socket.session.namespace
    # # join room
    # console.log 'join ' + data.name  + " to " + data.room
    # socket.join data.room
    # socket.emit "join", room: data.room
    # socket.emit "notify", message: data.name + " joined Room:" + data.room
    # # update memeber's list
    # console.log Object.keys(io.connected)
    # console.log io.sockets.clients
    # # save to socket.session
    # socket.session.join = true
    # socket.session.id = socket.id
    # socket.session.data = data
    # socket.session.room = data.room
    # socket.session.save()
    # io.sockets.in(socket.session.room).emit 'update', mode: "start"
