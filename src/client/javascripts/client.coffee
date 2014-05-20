_.mixin(_.str.exports())

#
# socket.io
#
socket = io.connect("http://" + location.host)

#
# drawing
#
prevImage = null

Vue.component 'draw',
  template: '''
  <canvas id="draw-area" v-component="draw"
    width="800" height="800"
    style="width: 400px; height: 400px;"
    v-on="    mousedown : startDraw,
              mouseup   : endDraw,
              mousemove : draw,
              touchstart: startDraw,
              touchend  : endDraw,
              touchmove : draw
    "></canvas>
  '''
  replace: true
  data:
    drawing: false
    prev:
      x: 0
      y: 0
  methods:
    point: (e)->
      x: 2*e.pageX - @$el.offsetTop
      y: 2*e.pageY - @$el.offsetLeft
    undo: ->
      ctx = @$el.getContext '2d'
      ctx.putImageData prevImage, 0,0
    draw: (e)->
      if @drawing
        ctx = @$el.getContext '2d'
        ctx.lineWidth = 6
        ctx.strokeStyle = @$parent.color
        ctx.fillStyle = @$parent.color
        ctx.beginPath()
        ctx.lineCap = "round"
        ctx.moveTo @prev.x, @prev.y
        ctx.lineTo @point(e).x, @point(e).y
        ctx.stroke()
        ctx.closePath()
        @prev = @point(e)
    startDraw: (e)->
      @drawing = true
      @prev = @point(e)
      ctx = @$el.getContext '2d'
      prevImage = ctx.getImageData 0,0, @$el.width, @$el.height
    endDraw: ->
      @drawing = false

new Vue
  el: "#app"
  data:
    color: "#d00"
    icon:
      x: 300
      y: -300
  methods:
    iconMove: (e)->
      d = @icon.x + @icon.y - e.pageX - e.pageY
      # lazy tracking
      if d > 30 || d < -30
        @icon.x = e.pageX + 20
        @icon.y = e.pageY - 20
    undoFire: ->
      @$.drawArea.undo()
