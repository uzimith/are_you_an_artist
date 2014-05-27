Vue.component 'user-palette',
  template: "#user-palette-template"
  replace: true

Vue.component 'color-palette',
  template: "#color-palette-template"
  replace: true
  data:
    colors: [
      "#6D8301"
      "#A09B08"
      "#75C007"
      "#B77417"
      "#0E4744"
      "#278996"
      "#30C3A6"
      "#6499fa"
      "#0F3675"
      "#D1B231"
      "#4BA35D"
      "#7B736E"
      "#C87E84"
      "#C94C5C"
      "#fa6499"
      "#BC2F36"
      "#622A52"
      "#4D5A58"
      "#20AA30"
      "#275B41"
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
    id: ""
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
      @panel = "join"
    if location.search
      @user = _.chain location.search.substring(1).split("&")
        .map (v)-> v.split("=")
        .reduce (hash,value)-> 
          hash[value[0]] = decodeURIComponent(value[1])
          hash
        , {}
        .value()
  methods:
    toggle: ->
      @show = !@show
    make: ->
      location.hash = @room
      Socket.namespace = @room
      Socket.confirm()
      Socket.init()
      Player.update()
      @toggle()
    join: ->
      Socket.namespace = @room
      Socket.init()
      Player.update()
      @toggle()

