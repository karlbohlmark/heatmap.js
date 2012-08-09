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
        refBuckets = @layers[0].xbuckets
        for layer, i in @layers
            zoom = @xscale.k()
            layerZoomFactor = layer.xbuckets/refBuckets
            alpha = 0
            if(@layers.length>i+1)
                nextZoomFactor = @layers[i+1].xbuckets/refBuckets
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
    constructor: (@xscale, data, @width, @height)->
        @xbuckets = data.xbuckets
        @ybuckets = data.ybuckets
        @xpxl = @width/data.xbuckets
        @ypxl = @height/data.ybuckets
        @graphPosX = 0
        @graphPosY = @height - 100
        @buckets = @prepareBucketData data
        #@dataSource.on 'data', @emit.bind @, 'data'

    rgbFromLightness: (rankFraction)-> 
        rgb = hsl2rgb(210, 97, 5 + rankFraction * 90)
        #rgb = hsl2rgb(238, rankFraction*100, 60)
        #rgb = hsl2rgb(rankFraction * 255, 80, 60)
        "rgb(#{rgb.r},#{rgb.g},#{rgb.b})"

    prepareBucketData: (data)->
        values = []
        uniqueValuesObj = {}
        for buckets, timeIndex in data.buckets
            for sampleCount, valueIndex in buckets when sampleCount>0
                sampleCount = +sampleCount
                uniqueValuesObj[sampleCount] = 1
                values.push { timeIndex, valueIndex, sampleCount }
        uniqueValues = (parseInt(key) for key of uniqueValuesObj)
        uniqueValues.sort((a, b)-> b - a )
        colors = {}
        maxRank = uniqueValues.length
        colors[i] = @rgbFromLightness( (i+1)/maxRank) for i in [0..maxRank]
        values.sort (a, b)-> a.sampleCount - b.sampleCount
        values.forEach (value)-> 
            value.rank = uniqueValues.indexOf value.sampleCount
            value.color = colors[value.rank]

        values

    draw: (alpha)->
        if alpha?
            @canvas.style.opacity = alpha
            return if alpha=0

        @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
        viewPortStart = Math.floor(@xscale.invert(0)/@xpxl)-1
        viewPortEnd = Math.floor(@xscale.invert(@width)/@xpxl)
        lastColor = ''
        @buckets.forEach (bucket) =>
            return if bucket.timeIndex<viewPortStart or bucket.timeIndex>viewPortEnd
            posx = (bucket.timeIndex * @xpxl)
            sposx = @xscale.map(posx)
            endx = @xscale.map(posx + @xpxl)
            if bucket.color != lastColor
                @ctx.fillStyle = bucket.color 
                lastColor = bucket.color
            posy = @graphPosY - (bucket.valueIndex + 1) * @ypxl
            @ctx.fillRect sposx, posy, endx-sposx, @ypxl

    render: (data)=>
        @canvas = document.createElement('canvas')
        @canvas.width = @width
        @canvas.height = @height
        @canvas.style.position = 'absolute'
        @ctx = @canvas.getContext('2d')
        @canvas

module.exports = CanvasRenderer