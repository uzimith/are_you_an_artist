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

playerList = (io, nsp)->
  _.chain(io.of(nsp.name).connected)
    .map (client, id)->
      p = JSON.parse(client.request._query.user)
      p['id'] = id
      p
    .value()

io.use (socket, next)->
  mode = socket.request._query.mode
  namespace = socket.request._query.id
  if namespace
    socket.session.namespace = namespace
    socket.session.save()
    #
    # make room
    #
    unless _.has io.nsps, "/"+namespace
      console.log "make-room:" + namespace
      nsp = io.of("/" + namespace)
      nsp.on 'connection', (client)->
        #
        # connect notify
        #
        client.emit "notify", message: nsp.name + "に接続しました。", id: client.id
        #
        # manual player-list
        #
        client.on 'player-list', (profile)->
          nsp.list = playerList(io, nsp)
          io.of(nsp.name).emit "player-list", nsp.list
        client.on "kick", (id)->
          unless id and _.has io.of(nsp.name).connected, id
            return
          disconnect_user = _.findWhere nsp.list, id: id
          io.of(nsp.name).connected[id].disconnect()
          # update playerlist
          nsp.list = playerList(io, nsp)
          io.of(nsp.name).emit "player-list", nsp.list
          io.of(nsp.name).emit "notify", message: disconnect_user['name'] + "を切断しました。"
        #
        # draw
        #
        client.on 'draw', (data)->
          # TODO : draw limit
          io.of(nsp.name).emit 'draw', data
        #
        # theme
        #
        client.on 'theme', (data)->
          member = _.size(io.of(nsp.name).connected) - 1
          if member < 3
            client.emit "notify", message: "プレイヤー人数が足りません。"
            return
          random = _.random 1, member
          order = _.shuffle [1..member]
          nsp.list =_.chain(io.of(nsp.name).connected)
            .map (player, id)->
              p = JSON.parse(player.request._query.user)
              p['id']
              p['order'] = if id is client.id then "*" else order.pop()
              # emit theme
              if p['order'] is random
                player.emit 'theme',
                  genre: data.genre
                  theme: "あなたが偽物です。"
              else
                player.emit 'theme',
                  genre: data.genre
                  theme: data.theme
              p
            .value()
          io.of(nsp.name).emit "player-list", nsp.list
          io.of(nsp.name).emit "notify", message: "ゲームを開始しました。"
    else
      if mode is "confirm"
        Q.delay(1000).done ->
          io.of("/"+ namespace).emit "exist"
  next()
