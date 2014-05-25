Vue = require 'vue'
socket = io.connect("http://" + location.host)

require './components/board'
config = require './config'
player = require './player'

app = new Vue
  el: "#app"
  data:
    config: config.$data
    notify:
      show: false
      message: ""
  methods:
    exportFire: ->
      png = @$.board.$el.toDataURL()
      console.log png

socket.on 'draw', (data)->
  switch data.mode
    when "down"
      app.$.board.drawstart data.point
    when "move"
      app.$.board.draw data.point, data.color


socket.on 'reload', (data)->
  config.$data.name = data.name
  config.$data.room = data.room
  config.$data.color = data.color
socket.on 'setting', (data)->
  player.list.$set 0,data.infomation
socket.on 'update', (data)->
  console.log data.order
  switch data.mode
    when "start"
      player.list = []
      socket.emit "update", config.$data
    when "listing"
      console.log data.infomation
      player.list.push data.infomation
socket.on 'join', (data)->
  config.toggle()
  player.room = data.room
socket.on 'notify', (data)->
  app.notify.message = data.message
  app.notify.show = true
  setTimeout ->
    app.notify.show = false
  , 2000
