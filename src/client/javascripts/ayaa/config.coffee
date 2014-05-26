Vue.component 'user-palette',
  template: "#user-palette-template"
  replace: true

Vue.component 'color-palette',
  template: "#color-palette-template"
  replace: true
  data:
    colors: [
      "#6499fa"
      "#fa7a64"
      "#fac564"
      "#e4fa64"
      "#fa6499"
      "#64fac5"
    ]
  components:
    'color-frame':
      template: "<div class='color'></div>"
      replace: true
      created: ->
        @$el.style.backgroundColor = @$value
      methods:
        selectColor: (color)->
          Config.user.color = color

module.exports = new Vue
  el: "#config"
  data:
    show: true
    room: ""
    user:
      name: ""
      color: "#000"
      order: "-"
    panel: ""
  created: ->
    @$watch "user", (user)->
      Player.list.$set 0, user
    if location.hash
      @room = location.hash.substring 1
      @user = _.chain location.search.substring(1).split("&")
        .map (v)-> v.split("=")
        .reduce (hash,value)-> 
          hash[value[0]] = decodeURIComponent(value[1])
          hash
        , {}
        .value()
      @panel = "join"
  methods:
    toggle: ->
      @show = !@show
    make: ->
      location.hash = @room
      Socket.namespace = @room
      Socket.confirm()
      Socket.init()
      @toggle()
    join: ->
      Socket.namespace = @room
      Socket.init()
      @toggle()

