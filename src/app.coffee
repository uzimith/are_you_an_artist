Q = require('q')

express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io')(server)
app.use express.static('client')
server.listen process.env.PORT || 3000

redis = require('redis-url').connect(process.env.REDISTOGO_URL || "redis://localhost:6379")

#
# app
#
io.on 'connection', (client)->
  #
  # connect
  #
  client.emit "notify", message: client.request.cookie
  client.emit "notify", message: "connection is established."
  #
  # draw
  #
  client.on 'draw', (data)->
    io.emit 'draw', data
  #
  # join
  #
  client.on 'join', (name)->
    console.log 'join :' + client.id  + " to " + name
    console.log client.rooms
    console.log client.client
    client.join name
    client.emit "notify", message: "joined " + name
