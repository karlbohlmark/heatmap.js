fs = require 'fs'

ybuckets = 50
xbuckets = 100

minval = 0
maxval = 200

nsamples = 4000

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

mean = 10
variance = 4
samples = for i in [0..nsamples]
	if i == nsamples / 6
    mean = 20
    variance = 7
	if i == nsamples * 2 / 6
    mean = 150 
    variance = 30
	if i == nsamples * 5 / 6
    mean = 200 
    variance = 30
  [ uniform(1000), Math.min(maxval, Math.max(minval, gaussian(mean, variance))) ]

fs.writeFileSync 'data.js','var data = ' + JSON.stringify(samples)
# ysize = maxval / ybuckets
# xsize = 1000 / xbuckets

# buckets = []    
# for sample in samples
#   xbucket = ~~( sample[0]/xsize )
#   ybucket = ~~( sample[1]/ysize )
#   buckets[xbucket]?=[]
#   count = buckets[xbucket][ybucket] || 0
#   buckets[xbucket][ybucket] = count + 1
# buckets

# console.dir(buckets)