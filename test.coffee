Heatmap = require('./heatmap')
el = document.querySelector('body')
heatmap = new Heatmap(
  target: el
  width: 800
  height: 400
  renderer: 'canvas'
)

heatmap.render(data)

