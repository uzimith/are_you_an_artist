Vue = require 'vue'

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
        submit: ->
          console.log @show
          @show = !@show

Vue.component 'charactor-palette',
  template: "#charactor-palette-template"
  replace: true
  computed:
    charactor: ->
      "icon" + @x + "-" + @y
  created: ->
    @$watch "x", ->
      @$root.charactor = @charactor
    @$watch "y", ->
      @$root.charactor = @charactor
  data:
    x: 0
    xrange: [0..9]
    y: 0
    yrange: [0..7]

module.exports = new Vue
  el: "#config"
  data:
    show: true
    color: "#000"
    charactor: "icon1-1"
