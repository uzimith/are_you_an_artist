Vue = require 'vue'
require './components/board'

module.exports = new Vue
  el: "#app"
  data:
    notify:
      show: false
      message: ""
  methods:
    exportFire: ->
      png = @$.board.$el.toDataURL()
      console.log png
    notifyMessage: (message)->
      @notify.message = message
      @notify.show = true
      setTimeout ->
        @notify.show = false
      , 2000
