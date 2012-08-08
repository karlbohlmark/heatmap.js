Emitter = require('./Emitter')

class CanvasRenderer extends Emitter
    constructor: (@targetEl, @data, options)->
        _super.call @
        @xscale = options.scale || new LinearTransform()
        @width  = options.width || @targetEl.clientWidth
        @height = options.height || @targetEl.clientHeight
        @graphPosY = options.graphPosY || 300
        @graphPosX = options.graphPosX || 0

    panOffset: 0
    initZoom: ()=>
        @container.addEventListener 'mousewheel', (e)=>
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
            @container.removeEventListener 'mousemove', panMove
            @container.removeEventListener 'mouseup', panUp

        panDown = (down)=>
            @panStart = down.x
            @offsetStart = @xscale.l()
            @container.addEventListener 'mousemove', panMove
            @container.addEventListener 'mouseup', panUp
      
        @container.addEventListener('mousedown', panDown)
        
    zoomFactorFromMouseDelta: (delta) -> delta / 180 + 1

    setData: (data)=>
        @data = data
        @emit 'data', data

    render: (data)=>
        @container = document.createElement 'div'
        @container.style.width = @width + 'px'
        @container.style.height = @height + 'px'
        @targetEl.appendChild @container

        @layers = (new CanvasLayer(@xscale, partition, @width, @height) for partition in data.partitionings)

        @container.appendChild(layer.render()) for layer in @layers
        @draw()
        @initZoom()
        @initPan()


    draw: ()->
        prevZoomFactor = 0
        refBuckets = @layers[0].data.xbuckets
        for layer, i in @layers
            zoom = @xscale.k()
            layerZoomFactor = layer.data.xbuckets/refBuckets
            alpha = 0
            if(@layers.length>i+1)
                nextZoomFactor = @layers[i+1].data.xbuckets/refBuckets
            else
                nextZoomFactor = 0
            
            alpha = @getAlpha zoom, layerZoomFactor, prevZoomFactor, nextZoomFactor

            layer.draw(alpha)
            prevZoomFactor = layerZoomFactor

    getAlpha: (zoom, layerZoomFactor, prevZoomFactor, nextZoomFactor)->
        if (zoom < layerZoomFactor and prevZoomFactor==0) or (zoom> layerZoomFactor and nextZoomFactor==0)
            return 1

        if zoom < layerZoomFactor
            quarter = (layerZoomFactor - prevZoomFactor)/4
            fadeinThreshold = prevZoomFactor + quarter
            alpha = (zoom - fadeinThreshold) / (quarter * 2)
            alpha = 0 if alpha<0
            alpha = 1 if alpha>1
            return alpha
        
        if zoom > layerZoomFactor
            quarter = (nextZoomFactor - layerZoomFactor)/4
            fadeoutThreshold = layerZoomFactor + quarter
            alpha = 1 - (zoom - fadeoutThreshold) / (quarter * 2)
            alpha = 0 if alpha<0
            alpha = 1 if alpha>1
            return alpha
            
        return 1 if zoom == layerZoomFactor

        throw new Error('Cannot calculate alpha from:' + JSON.stringify(Array::slice.call(arguments)))

class CanvasLayer extends Emitter
    constructor: (@xscale, @data, @width, @height)->
        @max = @data.maxBucketSampleCount
        @xpxl = @width/@data.xbuckets
        @ypxl = @height/@data.ybuckets
        @graphPosX = 0
        @graphPosY = @height - 100
        #@dataSource.on 'data', @emit.bind @, 'data'


    draw: (alpha)->
        if alpha?
            @canvas.style.opacity = alpha
            return if alpha=0

        @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
        viewPortStart = Math.floor(@xscale.invert(0))
        @data.buckets.forEach (time, i) =>
            posx = (i * @xpxl)
            sposx = @xscale.map(posx)
            endx = @xscale.map(posx + @xpxl)
            time.forEach (count, j) =>
                rgb = hsl2rgb(210, 97, (1-(count/@max))*100)
                @ctx.fillStyle = "rgb(#{rgb.r},#{rgb.g},#{rgb.b})"
                posy = @graphPosY - (j + 1) * @ypxl
                @ctx.fillRect sposx, posy, endx-sposx, @ypxl

    render: (data)=>
        @canvas = document.createElement('canvas')
        @canvas.width = @width
        @canvas.height = @height
        @canvas.style.position = 'absolute'
        @ctx = @canvas.getContext('2d')
        @canvas

module.exports = CanvasRenderer