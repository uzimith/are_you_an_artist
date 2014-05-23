Vue = require 'vue'
socket = io.connect("http://" + location.host)

config = require('./config')
require('./components/board')
require('./components/icon')

app = new Vue
  el: "#app"
  data:
    config: config.$data
    notify:
      show: false
      message: ""
  methods:
    move: (e)->
      position =
        x: e.pageX
        y: e.pageY
      @$broadcast "move", position
    exportFire: ->
      png = @$.board.$el.toDataURL()
      console.log png

socket.on 'draw', (data)->
  switch data.mode
    when "down"
      app.$.board.drawstart data.point
    when "move"
      app.$.board.draw data.point, data.color

socket.on 'notify', (data)->
  console.log data
  app.notify.message = data.message
  app.notify.show = true
  setTimeout ->
    app.notify.show = false
  , 2000
