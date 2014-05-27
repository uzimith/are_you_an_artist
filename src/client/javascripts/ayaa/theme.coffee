module.exports = new Vue
  el: "#theme"
  data:
    show: false
    status: 'input'
    genre: ""
    theme: ""
  methods:
    submit: ->
      Socket.instace().emit "theme",
        genre: Theme.genre
        theme: Theme.theme
    back: ->
      Theme.status = "input"
