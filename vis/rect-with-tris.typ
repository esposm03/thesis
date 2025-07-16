#import "@preview/cetz:0.4.0"

#let rect-with-tris = cetz.canvas({
  import cetz.draw: *

  let point(coords, name, dx, dy) = {
    circle(coords, radius: 0.1em, fill: black, name: name)
    content((rel: (dx, dy)), text(name))
  }

  scale(300%)

  let space = 3pt
  point((0, 0), "A", -space, -space)
  point((1, 0), "B", space, -space)
  point((1, 1), "C", space, space)
  point((0, 1), "D", -space, space)

  set-style(mark: (end: "straight"))

  let delta = 0.5pt
  let delta2 = 0.6pt
  line("A", "B")
  line("B", "C")
  line((to: "C", rel: (delta - delta2, -delta - delta2)), (to: "A", rel: (delta + delta2, -delta + delta2)))

  line("D", "A")
  line("C", "D")
  line((to: "A", rel: (-delta + delta2, delta + delta2)), (to: "C", rel: (-delta - delta2, delta - delta2)))
})
