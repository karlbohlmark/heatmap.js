el = document.querySelector('body')

heatmap = new Heatmap(
  target: el
  width: 600
  height: 400
  xbuckets: 100
  ybuckets: 50
  ymax: 50
  xmax: 1000
)

heatmap.render(data)

