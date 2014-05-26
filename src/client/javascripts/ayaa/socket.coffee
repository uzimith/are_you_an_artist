module.exports = class Socket
  @namespace: ""
  @url: "http://" + location.host
  @initialized: false
  @cache: null
  @instace: (mode)->
    if @cache
      return @cache
    if @namespace
      @cache = io.connect @url + "/" + @namespace,
        query: "mode=" + mode + "&id=" + @namespace
        'forceNew' : true
    else
      App.notifyMessage("ルーム名を指定してください。")
  @confirm: ->
    socket = Socket.instace("confirm")
    socket.on "exist", (data)->
      App.notifyMessage("そのルーム名はすでに存在しています。")
      socket.close()
      Socket.cache = null
      Socket.initialized = false
      location.hash = ""
      Config.toggle()
  @init: ->
    unless @initialized
      socket = Socket.instace()
      socket.on 'notify', (data)->
        console.log data
        App.notifyMessage(data.message)
      socket.on 'draw', (data)->
        switch data.mode
          when "down"
            board.drawstart data.position
          when "move"
            board.draw data.position, data.color
    else
      App.notifyMessage("すでに接続されています。")
