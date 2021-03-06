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
        query: "mode=" + mode + "&user=" + JSON.stringify(Config.user) + "&id=" + @namespace
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
      Player.list = [Config.user]
      Config.toggle()
  @init: ->
    unless @initialized
      socket = Socket.instace()
      socket.on 'notify', (data)->
        App.notifyMessage(data.message)
        if data.id
          Config.id = data.id
      socket.on 'draw', (data)->
        switch data.mode
          when "down"
            Board.drawstart data.position
          when "move"
            Board.draw data.position, data.color
      socket.on 'player-list', (data)->
        console.log data
        Player.list = data
        Board.clear()
      socket.on 'theme', (data)->
        console.log data
        Theme.theme = data.theme
        Theme.genre = data.genre
        Theme.status = "view"
      Theme.show = true
    else
      App.notifyMessage("すでに接続されています。")
