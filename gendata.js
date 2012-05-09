(function() {
  var buckets, count, fs, gaussian, i, maxval, mean, minval, nsamples, sample, samples, uniform, variance, xbucket, xbuckets, xsize, ybucket, ybuckets, ysize, _i, _len, _ref;

  fs = require('fs');

  ybuckets = 50;

  xbuckets = 100;

  minval = 0;

  maxval = 800;

  nsamples = 5000;

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

  mean = 200;

  variance = 50;

  samples = (function() {
    var _results;
    _results = [];
    for (i = 0; 0 <= nsamples ? i <= nsamples : i >= nsamples; 0 <= nsamples ? i++ : i--) {
      if (i === nsamples / 3) mean = 300;
      if (i === nsamples * 3 / 4) mean = 500;
      _results.push([uniform(1000), Math.min(maxval, Math.max(minval, gaussian(mean, variance)))]);
    }
    return _results;
  })();

  ysize = maxval / ybuckets;

  xsize = 1000 / xbuckets;

  buckets = [];

  for (_i = 0, _len = samples.length; _i < _len; _i++) {
    sample = samples[_i];
    xbucket = ~~(sample[0] / xsize);
    ybucket = ~~(sample[1] / ysize);
    if ((_ref = buckets[xbucket]) == null) buckets[xbucket] = [];
    count = buckets[xbucket][ybucket] || 0;
    buckets[xbucket][ybucket] = count + 1;
  }

  buckets;

  console.dir(buckets);

}).call(this);
