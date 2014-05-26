Vue = require 'vue'

socket = require "./socket"

module.exports = new Vue
  el: "#theme"
  data:
    genre: ""
    theme: ""
    show: false
    status: "input"
  methods:
    submit: ->
      socket.emit "theme", genre: @$root.genre, theme: @$root.theme
    back: ->
      @$root.status = "input"
    start: ->
      socket.emit 'start'
