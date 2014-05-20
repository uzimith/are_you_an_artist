express = require('express')
app = express()
http = require('http')
server = http.createServer(app)

app.use express.static('client')
app.set 'port', process.env.PORT || 3000
server.listen  app.get 'port'

io = require('socket.io').listen(server)

redis = require('socket.io/lib/stores/redis')
redisConf =
  host: 'localhost', port: 6379

io.set 'store', new redis
  redisPub    : redisConf,
  redisSub    : redisConf,
  redisClient : redisConf,

#
# app
#

io.sockets.on 'connection', (socket) ->
  socket.emit 'news',hello: 'world'
  socket.on 'my other event', (data)->
    console.log data
