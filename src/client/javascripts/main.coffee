require './reset'

# Vue
window.Vue = require 'vue'
vueTouch = require('vue-touch')
Vue.use(vueTouch)

# app
window.Socket = require './ayaa/socket'
window.App    = require './ayaa/app'
window.Player = require './ayaa/player'
window.Config = require './ayaa/config'
