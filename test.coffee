Heatmap = require('./heatmap')
LinearTransform = require('./linearTransform')
el = document.querySelector('body')
heatmap = new Heatmap(
	el,
	null,
	{
		scale: new LinearTransform()
		width: 800
		height: 400
		renderer: 'canvas'
	}
)

heatmap.render(data)

