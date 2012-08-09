Emitter = require('./Emitter')
CanvasLayer = require('./canvasLayer')

class HeatMap extends Emitter
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
            zoomFactor = @zoomFactorFromMouseDelta e.wheelDelta
            x = @xscale.invert(e.x)
            @xscale.multiplySlopeAtPoint(zoomFactor, x)
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
            return alpha
        
        if zoom > layerZoomFactor
            quarter = (nextZoomFactor - layerZoomFactor)/4
            fadeoutThreshold = layerZoomFactor + quarter
            alpha = 1 - (zoom - fadeoutThreshold) / (quarter * 2)
            alpha = 1 if alpha>1
            return alpha
            
        return 1 if zoom == layerZoomFactor

        throw new Error('Cannot calculate alpha from:' + JSON.stringify(Array::slice.call(arguments)))

module.exports = HeatMap