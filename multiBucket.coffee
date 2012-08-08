partition = require './partition'

doMultiPartition = (data, bucketSizes)->
    sampleData = data
    partitionings = for size, i in bucketSizes
        xbuckets = size[0]
        ybuckets = size[1]
        partitioned = partition(sampleData.samples, sampleData.xmax/xbuckets, sampleData.ymax/ybuckets)
        partitioned.xbuckets = xbuckets
        partitioned.ybuckets = ybuckets
        { xbuckets, ybuckets, buckets: partitioned.data, maxBucketSampleCount: partitioned.max }
    
    { partitionings, ymax: data.ymax, xmax: data.xmax }


main = ()->
    bucketSizes = [[ 100, 200], [200, 200]]
    if process.argv.length>2
        bucketSizes = []
        level = []
        for arg, index in process.argv when index>1
            level.push parseInt(arg)
            if index % 2 != 0
                bucketSizes.push level
                level = []

    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    data = ''
    process.stdin.on 'data', (chunk) -> data+=chunk
    process.stdin.on 'end', () -> 
        process.stdout.write( JSON.stringify( doMultiPartition( JSON.parse(data), bucketSizes ) ) )

main() if not module.parent