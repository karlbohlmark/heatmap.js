fs = require 'fs'

ybuckets = 50
xbuckets = 100

minval = 1
maxval = 70

nsamples = 5000

samples = []

gaussian = (mean, variance)->
  x1 = undefined
  x2 = undefined
  rad = undefined
  y1 = undefined
  loop
    x1 = 2 * Math.random() - 1
    x2 = 2 * Math.random() - 1
    rad = x1 * x1 + x2 * x2
    break unless rad >= 1 or rad is 0
  c = Math.sqrt(-2 * Math.log(rad) / rad)
  variance * x1 * c + mean

uniform = (largest)-> ~~(Math.random()*largest)

exponential = (a)-> Math.log(1-Math.random())/(-a)


samples = for i in [0..nsamples]
	if i<nsamples*.85
    [ uniform(1000), Math.min(maxval, Math.max(minval, 7 * exponential(1.8) )) ]
  else
    [ uniform(300), Math.min(maxval, Math.max(minval, 10 + 7 * exponential(3) )) ]

fs.writeFileSync 'data.js','var data = ' + JSON.stringify(samples)
ysize = maxval / ybuckets
xsize = 1000 / xbuckets

buckets = []    
for sample in samples
  xbucket = ~~( sample[0]/xsize )
  ybucket = ~~( sample[1]/ysize )
  buckets[xbucket]?=[]
  count = buckets[xbucket][ybucket] || 0
  buckets[xbucket][ybucket] = count + 1
buckets

console.dir(buckets)