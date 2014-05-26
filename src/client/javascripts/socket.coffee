window.config = require './config'
window.player = require './player'
window.theme  = require './theme'
window.app    = require './app'

window.Socket = class Socket
  @namespace: ""
  @url: "http://" + location.host
  @init: false
  @instace: ->
    if @namespace
      io.connect @url + "/" + @namespace, query: "id=" + @namespace
    else
      app.notifyMessage("You should set room name.")
  @init: ->
    unless @init
      socket = Socket.instace()
      socket.on 'notify', (data)->
        console.log data
        app.notifyMessage(data.message)
      socket.on 'draw', (data)->
        switch data.mode
          when "down"
            app.$.board.drawstart data.point
          when "move"
            app.$.board.draw data.point, data.color
    else
      app.notifyMessage("すでに接続されています。")

    # socket.on 'update', (data)->
    #   switch data.mode
    #     when "start"
    #       player.list = []
    #       socket.emit "update", config.$data
    #     when "listing"
    #       console.log data.infomation
    #   player.list.push data.infomation
    # socket.on 'theme', (data)->
    #   config.order = data.order
    #   theme.genre = data.theme.genre
    #   theme.theme = data.theme.theme
    #   theme.status = "view"

