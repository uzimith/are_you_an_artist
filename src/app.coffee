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
  client.on 'draw', (data)->
    console.log data
    io.emit 'draw',
      mode: data.mode
      point: data.point
      color: data.color
