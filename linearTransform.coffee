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


  module.exports = LinearTransform