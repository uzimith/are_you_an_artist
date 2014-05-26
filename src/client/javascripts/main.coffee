require './reset'

window.Q = require 'q'

# Vue
window.Vue = require 'vue'
vueTouch = require('vue-touch')
Vue.use(vueTouch)

# app
window.Socket = require './ayaa/socket'
window.App    = require './ayaa/app'
window.Board  = require './ayaa/board'
window.Player = require './ayaa/player'
window.Config = require './ayaa/config'
