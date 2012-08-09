LinearTransform = require('./linearTransform')
Emitter = require('./Emitter')

class CanvasLayer extends Emitter
    constructor: (@xscale, data, @width, @height)->
        @xbuckets = data.xbuckets
        @ybuckets = data.ybuckets
        @xpxl = @width/data.xbuckets
        @ypxl = @height/data.ybuckets
        @graphPosX = 0
        @graphPosY = @height - 100
        @buckets = @prepareBucketData data

    rgbFromRankFraction: (rankFraction)-> 
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
        colors[i] = @rgbFromRankFraction( (i+1)/maxRank) for i in [0..maxRank]
        values.sort (a, b)-> a.sampleCount - b.sampleCount
        values.forEach (value)-> 
            value.rank = uniqueValues.indexOf value.sampleCount
            value.color = colors[value.rank]

        values

    draw: (alpha)->
        if alpha?
            @canvas.style.opacity = alpha
            return if alpha==0

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

module.exports = CanvasLayer