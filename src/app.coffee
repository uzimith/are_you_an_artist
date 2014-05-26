Q = require 'q'
_ = require 'underscore'
express = require 'express'
connect = require 'connect'
cookieParser = require 'cookie-parser'
session = require 'express-session'
RedisStore = require('connect-redis')(session)
sessionStore = new RedisStore
  url: process.env.REDISTOGO_URL || "redis://localhost:6379"
  prefix: 'session:'

COOKIE_SECRET = process.env.SECRET || "keyboard cat"
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

playerList = (connected, me)->
  _.chain(connected)
    .pluck("client")
    .map (v)->
      hash = JSON.parse(v.request._query.user)
      hash['id'] = v.id
      hash['me'] = (me is v.id)
      hash
    .value()

io.use (socket, next)->
  mode = socket.request._query.mode
  namespace = socket.request._query.id
  if namespace
    socket.session.namespace = namespace
    socket.session.save()
    # make room
    unless io.nsps.hasOwnProperty("/"+namespace)
      console.log "make-room:" + namespace
      nsp = io.of("/" + namespace)
      nsp.on 'connection', (client)->
        client.emit "notify", message: nsp.name + "に接続しました。"
        client.on 'player-list', (profile)->
          list = playerList(io.of(nsp.name).connected, client.id)
          console.log list
          io.of(nsp.name).emit 'player-list', list
        client.on "kick", (id)->
          io.of(nsp.name).connected[id].disconnect()
          list = playerList(io.of(nsp.name).connected, client.id)
          io.of(nsp.name).emit 'player-list', list
        client.on 'draw', (data)->
          io.of(nsp.name).emit 'draw', data
    else
      if mode is "confirm"
        Q.delay(1000).done ->
          io.of("/"+ namespace).emit "exist"
  next()
