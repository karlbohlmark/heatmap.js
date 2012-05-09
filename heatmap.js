(function() {
  var Heatmap, graphX, graphY;

  graphX = 20.5;

  graphY = 300;

  Heatmap = (function() {

    function Heatmap(options) {
      this.options = options;
      this.canvas = document.createElement('canvas');
      this.canvas.width = this.options.width;
      this.canvas.height = this.options.width;
      this.ctx = this.canvas.getContext('2d');
      this.width = this.options.width;
      this.height = this.options.height;
      this.xbuckets = this.options.xbuckets;
      this.ybuckets = this.options.ybuckets;
      this.xmax = this.options.xmax;
      this.ymax = this.options.ymax;
      this.xsize = this.xmax / this.xbuckets;
      this.ysize = this.ymax / this.ybuckets;
    }

    Heatmap.prototype.partition = function(samples) {
      var buckets, count, sample, xbucket, ybucket, _i, _len, _ref;
      buckets = [];
      for (_i = 0, _len = samples.length; _i < _len; _i++) {
        sample = samples[_i];
        xbucket = ~~(sample[0] / this.xsize);
        ybucket = ~~(sample[1] / this.ysize);
        if ((_ref = buckets[xbucket]) == null) buckets[xbucket] = [];
        count = buckets[xbucket][ybucket] || 0;
        buckets[xbucket][ybucket] = count + 1;
      }
      return buckets;
    };

    Heatmap.prototype.render = function(samples) {
      var data, xpxl, ypxl;
      var _this = this;
      data = this.partition(samples);
      ypxl = this.height / this.ybuckets;
      xpxl = this.width / this.xbuckets;
      data.forEach(function(time, i) {
        return time.forEach(function(count, j) {
          var posx, posy;
          _this.ctx.fillStyle = "rgb(" + Math.min(255, count * 30) + ",70,100)";
          posx = graphX + i * xpxl;
          posy = graphY - (j + 1) * ypxl;
          return _this.ctx.fillRect(posx, posy, _this.xsize, _this.ysize);
        });
      });
      this.drawAxis();
      return this.options.target.appendChild(this.canvas);
    };

    Heatmap.prototype.drawAxis = function() {
      var ctx, i, x1, x2, y, _results;
      ctx = this.ctx;
      ctx.beginPath();
      ctx.moveTo(20.5, 20);
      ctx.lineTo(20.5, 300);
      ctx.stroke();
      ctx.lineWidth = 1;
      i = 0;
      _results = [];
      while (i < 300 - 10) {
        ctx.beginPath();
        x1 = 19;
        x2 = 22;
        y = 300 - i - .5;
        ctx.moveTo(x1, y);
        ctx.lineTo(x2, y);
        ctx.stroke();
        _results.push(i += 10);
      }
      return _results;
    };

    return Heatmap;

  })();

  window.Heatmap = Heatmap;

}).call(this);
