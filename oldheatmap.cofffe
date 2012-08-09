LinearTransform = require('./linearTransform')
CanvasRenderer = require('./canvasRenderer')
#partition = require('./partition')


class Heatmap
  xscale: new LinearTransform()
  constructor: (@options)->
    @width = @options.width
    @height = @options.height
    ###
    @xbuckets = @options.xbuckets
    @ybuckets = @options.ybuckets
    @xmax = @options.xmax
    @ymax = @options.ymax
    @xsize = @xmax/@xbuckets
    @ysize = @ymax/@ybuckets
    ###
    @graphPosX = @options.graphPosX
    @graphPosY = @options.graphPosY

  #partition: (samples)-> partition samples, @xsize, @ysize

  render: (data)->
    @data = data

    @renderer = new CanvasRenderer(
      @options.target, data
      {
        scale: @xscale
        width: @width
        height: @height
        graphPosX: @graphPosX
        graphPosY: @graphPosY
      }
    )

    @renderer.render(@data, @max)

    showBucket = (e)=> 
      return if e.offsetTop <= 8
      @detail.style.top = Math.max( e.offsetTop  - 130, 0) + 'px'
      @detail.style.left = e.offsetLeft + 18 + 'px'
      @detail.style.display = 'block'
      bucket = JSON.parse(e.getAttribute('data-bucket'))
      @detail.querySelector('.timespan').innerHTML = bucket.time[0] + '-' + bucket.time[1]
      @detail.querySelector('.valuespan').innerHTML = bucket.value[0] + '-' + bucket.value[1]
      @detail.querySelector('.samples').innerHTML = bucket.samples

    closeDetail = ()=>
      @detail.style.display = 'none'

    # @drawAxis()

  # drawAxis : ->
  #   ctx = @ctx
  #   ctx.strokeStyle = "rgb(128,128,128)"
  #   ctx.strokeWidth = 2
  #   ctx.beginPath()
  #   ctx.moveTo 20.5, 20
  #   ctx.lineTo 20.5, 300
  #   ctx.stroke()
  #   ctx.lineWidth = 1
  #   i = 0


module.exports = Heatmap