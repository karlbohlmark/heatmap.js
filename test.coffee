Heatmap = require('./heatmap')
el = document.querySelector('body')
data = partitioned;
heatmap = new Heatmap(
  target: el
  width: 600
  height: 400
  xbuckets: data.xbuckets
  ybuckets: data.ybuckets
  ymax: data.ymax
  xmax: data.xmax
  renderer: 'canvas'
)

heatmap.render()

