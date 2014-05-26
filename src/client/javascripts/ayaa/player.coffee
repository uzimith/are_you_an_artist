module.exports = new Vue
  el: "#player"
  data:
    list: []
  methods:
    update: ()->
      Q.delay(0).done ->
        Socket.instace().emit "player-list"
