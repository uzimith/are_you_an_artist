Vue = require 'vue'

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

module.exports = new Vue
  el: "#config"
  data:
    show: true
    name: ""
    color: "#000"
    order: "-"
    room: ""
  ready: ->
    @$watch "name", @setting
    @$watch "color", @setting
  methods:
    toggle: ->
      @show = !@show
    setting: ->
      player.list.$set 0, @playerInfomation()
    playerInfomation: ->
      {
        name: @$root.name
        room: @$root.room
        color: @$root.color
      }
    make: ->
      # socket = io.connect "http://" + location.host
      # Socket.namespace = @$root.room
      Socket.namespace = "test"
      Socket.init()
      Socket.instace().emit 'make'
      # console.log Socket.instace()
