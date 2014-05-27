module.exports = new Vue
  el: "#theme"
  data:
    status: 'input'
    genre: "果物"
    theme: "りんご"
  methods:
    submit: ->
      Socket.instace().emit "theme",
        genre: Theme.genre
        theme: Theme.theme
    back: ->
      Theme.status = "input"
