Vue = require 'vue'
socket = io.connect("http://" + location.host)

module.exports = new Vue
  el: "#player"
  data:
    list: []
