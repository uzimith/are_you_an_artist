Vue = require 'vue'

Vue.component 'color-palette',
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

module.exports = new Vue
  el: "#config"
  data:
    show: true
    color: "#000"
    colors: [
      "#6499fa"
      "#fa7a64"
      "#fac564"
      "#e4fa64"
      "#fa6499"
      "#64fac5"
    ]
    charactor: "icon0-1"
