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
# app
#
io.on 'connection', (socket)->
  socket.session.join = false
  if socket.session.room
    socket.emit 'reload', socket.session.data
  #
  # connect
  #
  socket.emit "notify", message: "connection is established."
  #
  # draw
  #
  socket.on 'draw', (data)->
    console.log socket.session.room
    io.sockets.in(socket.session.room).emit 'draw', data
  #
  # theme
  #

  #
  # update
  #
  socket.on 'update', (data)->
    io.sockets.in(socket.session.room).emit 'update', mode: "listing", id: socket.id, infomation: data
  #
  # config
  #
  socket.on 'setting', (data)->
    socket.emit 'setting', id: 0, infomation: data
  socket.on 'join', (data)->
    if socket.session.join
      socket.emit "notify", message: "You already joinned"
      io.sockets.in(socket.session.room).emit 'update', mode: "start"
      return
    # join room
    console.log 'join ' + data.name  + " to " + data.room
    socket.join data.room
    socket.emit "join", room: data.room
    socket.emit "notify", message: data.name + " joined Room:" + data.room
    # update memeber's list
    console.log Object.keys(io.sockets.in(data.room).connected)
    # save to socket.session
    socket.session.join = true
    socket.session.id = socket.id
    socket.session.data = data
    socket.session.room = data.room
    socket.session.save()
    io.sockets.in(socket.session.room).emit 'update', mode: "start"
