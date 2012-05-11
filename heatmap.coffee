graphX = 20.5
graphY = 300


class Heatmap
  constructor: (@options)->
    @width = @options.width
    @height = @options.height
    @xbuckets = @options.xbuckets
    @ybuckets = @options.ybuckets
    @xmax = @options.xmax
    @ymax = @options.ymax
    @xsize = @xmax/@xbuckets
    @ysize = @ymax/@ybuckets

  partition: (samples)->
    buckets = []    
    for sample in samples
      xbucket = ~~( sample[0]/@xsize )
      ybucket = ~~( sample[1]/@ysize )
      buckets[xbucket]?=[]
      count = buckets[xbucket][ybucket] || 0
      buckets[xbucket][ybucket] = count + 1
    buckets

  render: (samples)->
    data = @partition(samples)

    ypxl = @height/@ybuckets
    xpxl = @width/@xbuckets

    renderer = @options.renderer or 'canvas'

    @['render_' + renderer].call @, data, xpxl, ypxl

  render_canvas: (data, xpxl, ypxl)->
    @canvas = document.createElement('canvas')
    @canvas.width = @width
    @canvas.height = @height
    @ctx = @canvas.getContext('2d')

    data.forEach (time, i) =>
      time.forEach (count, j) =>
        @ctx.fillStyle = "rgb(" + Math.min(255, count * 30) + ",70,100)"
        posx = graphX + i * xpxl
        posy = graphY - (j + 1) * ypxl
        @ctx.fillRect posx, posy, @xsize, @ysize

    @drawAxis()

    @options.target.appendChild(@canvas)

  render_html: (data, xpxl, ypxl)->
    @div = document.createElement 'div'

    data.forEach (time, i) =>
      time.forEach (count, j) =>

  drawAxis : ->
    ctx = @ctx
    ctx.beginPath()
    ctx.moveTo 20.5, 20
    ctx.lineTo 20.5, 300
    ctx.stroke()
    ctx.lineWidth = 1
    i = 0

    while i < 300 - 10
      ctx.beginPath()
      x1 = 19
      x2 = 22
      y = 300 - i - .5
      ctx.moveTo x1, y
      ctx.lineTo x2, y
      ctx.stroke()
      i += 10

  
window.Heatmap = Heatmap

