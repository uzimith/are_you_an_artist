Vue = require 'vue'
socket = io.connect("http://" + location.host)

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
          @$root.color = color

Vue.component 'room-palette',
  template: "#room-palette-template"
  replace: true
  methods:
    join: ->
      socket.emit 'join',
        name: @$root.name
        room: @$root.room
        color: @$root.color

module.exports = new Vue
  el: "#config"
  data:
    show: true
    name: ""
    color: "#000"
    room: ""
  ready: ->
    @$watch "name", @playerInfomation
    @$watch "color", @playerInfomation
  methods:
    toggle: ->
      @show = !@show
    playerInfomation: ->
      socket.emit 'setting', @$data
