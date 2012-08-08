fs = require 'fs'
times = fs.readFileSync('times.txt').toString()
partition = require './partition'

class Reducer
	constructor:(@val, @reduce, @name)->
		delete @name if not @name
	receive: (val)->
		val = parseInt(val)
		return if Number.isNaN(val)
		@val = @reduce(@val, val)
	value: ()-> @val
	toString: ()-> return @val.toString()

class Max extends Reducer
	constructor:(@name)->
		super(-Infinity, Math.max, name)

class Min extends Reducer
	constructor:(@name)->
		super(Infinity, Math.min, name)

samples = times.split('\n')

maxTimeToLastBytePayload = new Max()
maxRequestTime = new Max()
minRequestTime = new Min()

###
maxTimeToFirstByte = new MaxCollector()
maxTimeToFirstBytePayload = new MaxCollector()
maxTimeToLastBytePayload = new MaxCollector('time to last byte')
###

arr = for sample in samples
	vals = sample.split ' '
	requestTime = vals[0]
	timeToLastBytePayload = vals[6]

	maxRequestTime.receive requestTime
	minRequestTime.receive requestTime

	maxTimeToLastBytePayload.receive( timeToLastBytePayload )
	###
	minRequestTime.receive( requestTime = vals[0] )
	maxTimeToFirstByte.collect( timeToFirstByte = vals[4] )
	maxTimeToFirstBytePayload.collect( timeToFirstBytePayload = vals[5] )
	maxTimeToLastBytePayload.collect( timeToLastBytePayload = vals[6] )
	###
	[parseInt(requestTime), parseInt(timeToLastBytePayload)]

arr = ([entry[0]-minRequestTime.value(), entry[1]] for entry in arr when entry[0]==entry[0] && entry[1] == entry[1])

ysize = maxTimeToLastBytePayload.value() / (ybuckets = 50)
xsize = (maxRequestTime.value() - minRequestTime.value()) / (xbuckets = 200)

console.log maxRequestTime.value() - minRequestTime.value(), maxTimeToLastBytePayload.value()

###
console.log( maxRequestTime.value() - minRequestTime.value() );
console.log( minTimeToLastBytePayload.value() , maxTimeToLastBytePayload.value() )
###


process.stdout.write( JSON.stringify( partition arr, xsize, ysize ) )