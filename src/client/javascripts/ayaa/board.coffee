module.exports = new Vue
  template: "#board canvas"
  data:
    drawing: false
    prev:
      x: 0
      y: 0
  methods:
    # event methods
    down: (e)->
      @drawing = true
      Socket.instace().emit "draw", {mode: "down", point: @point(e), color: @$parent.color}
    move: (e)->
      if @drawing
        Socket.instace().emit "draw", {mode: "move", point: @point(e), color: @$parent.color}
    up: (e)->
      @drawing = false
      Socket.instace().emit "draw", mode: "up"
    # draw methods
    position: (e)->
      x: 2*(e.gesture.center.pageX - @$el.offsetLeft)
      y: 2*(e.gesture.center.pageY - @$el.offsetTop)
    draw: (position,color)->
      ctx = @$el.getContext '2d'
      ctx.lineWidth = 6
      ctx.strokeStyle = color
      ctx.fillStyle = color
      ctx.beginPath()
      ctx.lineCap = "round"
      ctx.moveTo @prev.x, @prev.y
      ctx.lineTo position.x, position.y
      ctx.stroke()
      ctx.closePath()
      @prev = position
    drawstart: (position)->
      @prev = position
