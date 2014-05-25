Vue = require 'vue'
socket = io.connect("http://" + location.host)


module.exports = new Vue
  el: "#theme"
  data:
    genre: ""
    theme: ""
    show: false
    status: "input"
  methods:
    submit: ->
      @$root.status = "view"
    back: ->
      @$root.status= "input"
