hsl2rgb = (h, s, l) ->
  m1 = undefined
  m2 = undefined
  hue = undefined
  r = undefined
  g = undefined
  b = undefined
  s /= 100
  l /= 100
  unless s is 0
    if l <= 0.5
      m2 = l * (s + 1)
    else
      m2 = l + s - l * s
    m1 = l * 2 - m2
    hue = h / 360
    r = ~~HueToRgb(m1, m2, hue + 1 / 3)
    g = ~~HueToRgb(m1, m2, hue)
    b = ~~HueToRgb(m1, m2, hue - 1 / 3)
  r: r
  g: g
  b: b
HueToRgb = (m1, m2, hue) ->
  v = undefined
  if hue < 0
    hue += 1
  else hue -= 1  if hue > 1
  if 6 * hue < 1
    v = m1 + (m2 - m1) * hue * 6
  else if 2 * hue < 1
    v = m2
  else if 3 * hue < 2
    v = m1 + (m2 - m1) * (2 / 3 - hue) * 6
  else
    v = m1
  255 * v

window.hsl2rgb = hsl2rgb