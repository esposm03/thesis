#import "@preview/cetz:0.4.0"

#let pat = tiling(size: (30pt, 30pt))[
  #place(line(start: (0%, 0%), end: (100%, 100%), stroke: 0.1pt))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.1pt))
]

#let cube(a, b) = {
  import cetz.draw: *

  let ax = a.at(0)
  let bx = b.at(0)
  let ay = a.at(1)
  let by = b.at(1)
  let az = a.at(2)
  let bz = b.at(2)

  line((ax, ay, az), (bx, ay, az), stroke: 0.4pt)
  line((ax, ay, az), (ax, by, az), stroke: 0.4pt)
  line((bx, by, az), (bx, ay, az), stroke: 0.4pt)
  line((bx, by, az), (ax, by, az), stroke: 0.4pt)

  line((ax, ay, bz), (bx, ay, bz), stroke: 0.4pt)
  line((ax, ay, bz), (ax, by, bz), stroke: 0.4pt)
  line((bx, by, bz), (bx, ay, bz), stroke: 0.4pt)
  line((bx, by, bz), (ax, by, bz), stroke: 0.4pt)

  line((ax, ay, az), (ax, ay, bz), stroke: 0.4pt)
  line((ax, by, az), (ax, by, bz), stroke: 0.4pt)
  line((bx, ay, az), (bx, ay, bz), stroke: 0.4pt)
  line((bx, by, az), (bx, by, bz), stroke: 0.4pt)
}

#let clip-space = cetz.canvas(cetz.draw.ortho(x: -145deg, y: 35deg, {
  import cetz.draw: *

  cube((0, 0, 0), (3, 3, 3))

  let a = (-0.5, 2, 2)
  let b = (2, -1, 2)
  let c = (3.6, 3.5, 2)
  merge-path(name: "tri", close: true, {
    line(a, b)
    line(b, c)
  })

  rect((0, 0, 2), (3, 3, 2), name: "area", stroke: 0.1pt)
  rect((0, 0, 1), (3, 3, 1), stroke: 0.1pt)

  intersections("poly", "tri", "area")

  // for-each-anchor("poly", name => {
  //   circle("poly." + name, radius: 3pt)
  //   content((to: "poly." + name, rel: (0.5, 0.5, 0.5)), name)
  // })

  on-layer(-1, merge-path(fill: red, stroke: 1.9pt + black, close: true, {
    line("poly.0", "poly.1")
    line((), "poly.2")
    line((), "poly.3")
    line((), (3, 3, 2))
    line((), "poly.5")
    line((), "poly.4")
  }))
}))
