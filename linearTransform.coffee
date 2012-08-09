class LinearTransform
  _k: 1
  _l: 0

  k:(factor)->
    return @_k if not factor
    @_k = factor

  l: (offset)->
    return @_l if not offset
    @_l = offset

  map: (x)->
    @_k * x + @_l

  invert: (y)->
    (y-@_l)/@_k

  multiplySlopeAtPoint: (slopeFactor, x)->
    k0 = @_k
    k1 = slopeFactor * k0
    l0 = @_l
    # k0*x + l0 = k1*x +l1 //because the point we are zooming around should stay put
    l1 = k0*x + l0 - k1*x
    @_k = k1
    @_l = l1;


  module.exports = LinearTransform