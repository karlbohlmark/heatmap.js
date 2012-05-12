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

    max = 0
    for sample in samples
      xbucket = ~~( sample[0]/@xsize )
      ybucket = ~~( sample[1]/@ysize )
      buckets[xbucket]?=[]
      count = buckets[xbucket][ybucket] || 0
      buckets[xbucket][ybucket] = count + 1
      max = Math.max(max, count + 1)
    { data:buckets, max }

  render: (samples)->
    { data, max }  = @partition(samples)

    ypxl = @height/@ybuckets
    xpxl = @width/@xbuckets

    renderer = @options.renderer or 'html'

    @['render_' + renderer].call @, data, xpxl, ypxl, max

  render_canvas: (data, xpxl, ypxl, max)->
    @canvas = document.createElement('canvas')
    @canvas.width = @width
    @canvas.height = @height
    @ctx = @canvas.getContext('2d')

    #console.log xpxl, ypxl

    data.forEach (time, i) =>
      time.forEach (count, j) =>
        rgb = hsl2rgb(210, 97, (1-(count/max))*100)
        @ctx.fillStyle = "rgb(#{rgb.r},#{rgb.g},#{rgb.b})"
        posx = graphX + i * xpxl
        posy = graphY - (j + 1) * ypxl
        
        @ctx.fillRect posx, posy, xpxl+1, ypxl

    @drawAxis()

    @options.target.appendChild(@canvas)

  render_html: (data, xpxl, ypxl, max)->
    @div = document.createElement('div')
    @div.style.width = @width
    @div.style.height = @height

    data.forEach (time, i) =>
      time.forEach (count, j) =>
        bucket = document.createElement('div')

        rgb = hsl2rgb(210, 97, (1-(count/max))*100)
        bucket.style.backgroundColor = "rgb(#{rgb.r},#{rgb.g},#{rgb.b})"
        bucket.style.position = 'absolute'

        posx = graphX + i * xpxl
        posy = graphY - (j + 1) * ypxl

        bucket.setAttribute('data-bucket', JSON.stringify( {
          time: [ (i-1) * @xsize, i * @xsize ],
          value: [ (j-1) * @ysize, j * @ysize ],
          samples: count
        })); 
        
        bucket.style.width  = xpxl + 'px'
        bucket.style.height = ypxl + 'px'

        bucket.style.left   = posx + 'px'
        bucket.style.top    = posy + 'px'

        @div.appendChild bucket

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

    @div.addEventListener 'mouseover', (e)->
      showBucket e.target

    @div.addEventListener 'mouseout', (e)->
      closeDetail()

    # @drawAxis()

    @detail = document.createElement 'div'
    @detail.className = 'detail'
    @detail.innerHTML = """
    <dl>
      <dt>Time span: <dd class="timespan">
      <dt>Value span: <dd class="valuespan">
      <dt>Samples: <dd class="samples">
    </dl>"""
    @detail.style.position = 'absolute'
    @detail.style.display = 'none'

    @options.target.appendChild(@div)

    @options.target.appendChild(@detail)

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


window.Heatmap = Heatmap

