Emitter = require('./Emitter')

class CanvasRenderer extends Emitter
    constructor: (@targetEl, options)->
        _super.call @
        @xscale = options.scale || new LinearTransform()
        @width  = options.width || @targetEl.clientWidth
        @height = options.height || @targetEl.clientHeight
        @ybuckets = options.ybuckets || 10
        @xbuckets = options.xbuckets || 50
        @xpxl   = @width / @xbuckets
        @ypxl   = @height / @ybuckets
        @graphPosY = options.graphPosY || 300
        @graphPosX = options.graphPosX || 0

    panOffset: 0
    initZoom: ()=>
        @canvas.addEventListener 'mousewheel', (e)=>
            zoomFactor= @zoomFactorFromMouseDelta e.wheelDelta
            x = @xscale.invert(e.x)
            k0 = @xscale.k()
            k1 = zoomFactor * k0
            @xscale.k( k1 )

            l0 = @xscale.l()
            # k0*x + l0 = k1*x +l1 //because the point we are zooming around should stay put
            l1 = k0*x + l0 - k1*x

            @xscale.l( l1 );

            @draw()
            e.preventDefault()

    initPan: ()=>
        panMove = (move)=>
            panOffset = (move.x - @panStart)
            @xscale.l(@offsetStart + panOffset)
            @draw()

        panUp = (move)=>
            @panStart = 0
            @offsetStart = 0
            @canvas.removeEventListener 'mousemove', panMove
            @canvas.removeEventListener 'mouseup', panUp

        panDown = (down)=>
            @panStart = down.x
            @offsetStart = @xscale.l()
            @canvas.addEventListener 'mousemove', panMove
            @canvas.addEventListener 'mouseup', panUp
      
        @canvas.addEventListener('mousedown', panDown)
        
    zoomFactorFromMouseDelta: (delta) -> delta / 180 + 1

    setData: (data, max)=>
        @data = data
        @max = max
        @emit 'data', data, max

    render: (data, max)=>
        @canvas = document.createElement('canvas')
        @canvas.width = @width
        @canvas.height = @height
        @ctx = @canvas.getContext('2d')
        
        @on 'data', @draw
        @setData(data, max)
        
        @targetEl.appendChild(@canvas)

        @initZoom()
        @initPan()

    draw: ()=>
        @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
        @data.forEach (time, i) =>
            console.log time
            time.forEach (count, j) =>
                rgb = hsl2rgb(210, 97, (1-(count/@max))*100)
                @ctx.fillStyle = "rgb(#{rgb.r},#{rgb.g},#{rgb.b})"
                posx = (i * @xpxl)
                posy = @graphPosY - (j + 1) * @ypxl

                sposx = @xscale.map(posx)
                endx = @xscale.map(posx + @xpxl)
                @ctx.fillRect sposx, posy, endx-sposx, @ypxl

module.exports = CanvasRenderer