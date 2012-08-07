partition = (samples, xsize, ysize)->
  buckets = []

  max = 0
  for sample in samples
    xbucket = Math.floor( sample[0]/xsize )
    ybucket = Math.floor( sample[1]/ysize )
    buckets[xbucket]?=[]
    count = buckets[xbucket][ybucket] || 0
    buckets[xbucket][ybucket] = count + 1
    max = Math.max(max, count + 1)
  { data:buckets, max }

module.exports = partition

if not module.parent
    xbuckets = 200
    ybuckets = 200
    if process.argv.length>2
      xbuckets = parseInt(process.argv[2])
      ybuckets = parseInt(process.argv[3])

    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    data = ''
    process.stdin.on 'data', (chunk) -> data+=chunk
    process.stdin.on( 'end', ()-> 
      json = JSON.parse(data)
      partitioned = partition(json.samples, json.xmax/xbuckets, json.ymax/ybuckets)
      partitioned.xbuckets = xbuckets
      partitioned.ybuckets = ybuckets
      partitioned.xmax = json.xmax
      partitioned.ymax = json.ymax
      process.stdout.write JSON.stringify( partitioned )
    )

