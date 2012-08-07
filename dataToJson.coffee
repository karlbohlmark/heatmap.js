fs = require 'fs'
times = fs.readFileSync('times.txt').toString()

samples = times.split('\n')

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

maxTimeToLastBytePayload = new Max()
maxRequestTime = new Max()
minRequestTime = new Min()

arr = for sample in samples
	vals = sample.split ' '
	requestTime = vals[0]
	timeToLastBytePayload = vals[5]

	maxRequestTime.receive requestTime
	minRequestTime.receive requestTime
	maxTimeToLastBytePayload.receive timeToLastBytePayload

	[parseInt(requestTime), parseInt(timeToLastBytePayload)]

arr = ([entry[0]-minRequestTime.value(), entry[1]] for entry in arr when entry[0]==entry[0] && entry[1] == entry[1])


process.stdout.write( 
	JSON.stringify({
		samples: arr, 
		xmax: maxRequestTime.value()-minRequestTime.value(),
		ymax: maxTimeToLastBytePayload.value()
	})
)