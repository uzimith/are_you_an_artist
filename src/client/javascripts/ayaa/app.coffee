
module.exports = new Vue
  el: "#app"
  data:
    notify:
      show: false
      message: ""
  methods:
    notifyMessage: (message)->
      @notify.message = message
      @notify.show = true
      setTimeout ->
        App.notify.show = false
      , 2000
