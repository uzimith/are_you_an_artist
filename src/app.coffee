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
      next()
    else
      next new Error(if err then err.message else "session error")

#
# app
#
io.on 'connection', (socket)->
  session = socket.session
  #
  # connect
  #
  socket.emit "notify", message: "connection is established."
  #
  # draw
  #
  socket.on 'draw', (data)->
    io.sockets.in(session.room).emit 'draw', data
  #
  # config
  #
  socket.on 'join', (data)->
    session.name = data.name
    session.room = data.room
    session.save()
    console.log 'join :' + session.name  + " to " + session.room
    socket.join data.room
    socket.emit "notify", message: session.name + " joined Room:" + session.room
