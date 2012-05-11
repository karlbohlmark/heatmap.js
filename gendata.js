(function() {
  var fs, gaussian, i, maxval, mean, minval, nsamples, samples, uniform, variance, xbuckets, ybuckets;

  fs = require('fs');

  ybuckets = 50;

  xbuckets = 100;

  minval = 0;

  maxval = 200;

  nsamples = 4000;

  samples = [];

  gaussian = function(mean, variance) {
    var c, rad, x1, x2, y1;
    x1 = void 0;
    x2 = void 0;
    rad = void 0;
    y1 = void 0;
    while (true) {
      x1 = 2 * Math.random() - 1;
      x2 = 2 * Math.random() - 1;
      rad = x1 * x1 + x2 * x2;
      if (!(rad >= 1 || rad === 0)) break;
    }
    c = Math.sqrt(-2 * Math.log(rad) / rad);
    return variance * x1 * c + mean;
  };

  uniform = function(largest) {
    return ~~(Math.random() * largest);
  };

  mean = 10;

  variance = 4;

  samples = (function() {
    var _results;
    _results = [];
    for (i = 0; 0 <= nsamples ? i <= nsamples : i >= nsamples; 0 <= nsamples ? i++ : i--) {
      if (i === nsamples / 6) {
        mean = 20;
        variance = 7;
      }
      if (i === nsamples * 2 / 6) {
        mean = 150;
        variance = 30;
      }
      if (i === nsamples * 5 / 6) {
        mean = 200;
        variance = 30;
      }
      _results.push([uniform(1000), Math.min(maxval, Math.max(minval, gaussian(mean, variance)))]);
    }
    return _results;
  })();

  fs.writeFileSync('data.js', 'var data = ' + JSON.stringify(samples));

}).call(this);
