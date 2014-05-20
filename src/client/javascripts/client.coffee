_.mixin(_.str.exports())

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
    v-on="    mousedown : down,
              mousemove : move,
              mouseup   : up,
              touchstart: down,
              touchmove : move,
              touchend  : up
    "></canvas>
  '''
  replace: true
  data:
    drawing: false
    prev:
      x: 0
      y: 0
  methods:
    #
    # get point position
    #
    point: (e)->
      x: 2*e.pageX - @$el.offsetTop
      y: 2*e.pageY - @$el.offsetLeft
    #
    # undo
    #
    undo: ->
      ctx = @$el.getContext '2d'
      ctx.putImageData prevImage, 0,0
    #
    # event methods
    #
    down: (e)->
      @drawing = true
      socket.emit "draw", {mode: "down", point: @point(e), color: @$parent.color}
    move: (e)->
      if @drawing
        socket.emit "draw", {mode: "move", point: @point(e), color: @$parent.color}
    up: (e)->
      @drawing = false
      socket.emit "draw", mode: "up"
    #
    # draw methods
    #
    draw: (point,color)->
      ctx = @$el.getContext '2d'
      ctx.lineWidth = 6
      ctx.strokeStyle = color
      ctx.fillStyle = color
      ctx.beginPath()
      ctx.lineCap = "round"
      ctx.moveTo @prev.x, @prev.y
      ctx.lineTo point.x, point.y
      ctx.stroke()
      ctx.closePath()
      @prev = point
    drawstart: (point)->
      console.log point
      @prev = point
      ctx = @$el.getContext '2d'
      prevImage = ctx.getImageData 0,0, @$el.width, @$el.height

app = new Vue
  el: "#app"
  data:
    color: "#d00"
    icon:
      x: 300
      y: -300
      class: "1-3"
  methods:
    iconMove: (e)->
      d = @icon.x + @icon.y - e.pageX - e.pageY
      # lazy tracking
      if d > 30 || d < -30
        @icon.x = e.pageX + 20
        @icon.y = e.pageY - 20
    undoFire: ->
      @$.drawArea.undo()

socket.on 'draw', (data)->
  switch data.mode
    when "down"
      app.$.drawArea.drawstart data.point
    when "move"
      app.$.drawArea.draw data.point, data.color
