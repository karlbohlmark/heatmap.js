// Generated by CoffeeScript 1.3.1
(function() {
  var CanvasRenderer, Heatmap, LinearTransform;

  LinearTransform = require('./linearTransform');

  CanvasRenderer = require('./canvasRenderer');

  Heatmap = (function() {

    Heatmap.name = 'Heatmap';

    Heatmap.prototype.xscale = new LinearTransform();

    function Heatmap(options) {
      this.options = options;
      this.width = this.options.width;
      this.height = this.options.height;
      /*
          @xbuckets = @options.xbuckets
          @ybuckets = @options.ybuckets
          @xmax = @options.xmax
          @ymax = @options.ymax
          @xsize = @xmax/@xbuckets
          @ysize = @ymax/@ybuckets
      */

      this.graphPosX = this.options.graphPosX;
      this.graphPosY = this.options.graphPosY;
    }

    Heatmap.prototype.render = function(data) {
      var closeDetail, showBucket,
        _this = this;
      this.data = data;
      this.renderer = new CanvasRenderer(this.options.target, data, {
        scale: this.xscale,
        width: this.width,
        height: this.height,
        graphPosX: this.graphPosX,
        graphPosY: this.graphPosY
      });
      this.renderer.render(this.data, this.max);
      showBucket = function(e) {
        var bucket;
        if (e.offsetTop <= 8) {
          return;
        }
        _this.detail.style.top = Math.max(e.offsetTop - 130, 0) + 'px';
        _this.detail.style.left = e.offsetLeft + 18 + 'px';
        _this.detail.style.display = 'block';
        bucket = JSON.parse(e.getAttribute('data-bucket'));
        _this.detail.querySelector('.timespan').innerHTML = bucket.time[0] + '-' + bucket.time[1];
        _this.detail.querySelector('.valuespan').innerHTML = bucket.value[0] + '-' + bucket.value[1];
        return _this.detail.querySelector('.samples').innerHTML = bucket.samples;
      };
      return closeDetail = function() {
        return _this.detail.style.display = 'none';
      };
    };

    return Heatmap;

  })();

  module.exports = Heatmap;

}).call(this);
