(function() {
  var el, heatmap;

  el = document.querySelector('body');

  heatmap = new Heatmap({
    target: el,
    width: 600,
    height: 300,
    xbuckets: 100,
    ybuckets: 50,
    ymax: 800,
    xmax: 1000
  });

  heatmap.render(data);

}).call(this);
