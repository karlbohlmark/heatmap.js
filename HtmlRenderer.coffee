class HtmlRenderer
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
        
        bucket.style.width  = 1 + xpxl + 'px'
        bucket.style.height = ypxl + 'px'

        bucket.style.left   = posx + 'px'
        bucket.style.top    = posy + 'px'

        @div.appendChild bucket
  @div.addEventListener 'mouseover', (e)->
      showBucket e.target

  @div.addEventListener 'mouseout', (e)->
      closeDetail()

###
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
###

module.exports = HtmlRenderer