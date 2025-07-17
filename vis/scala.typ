#import "@preview/cetz:0.4.0"
#import "/common/variables.typ": chart

#let scala = cetz.canvas({
  import cetz.draw: *

  rect((-1.5, -1.5), (3, 1.5), fill: green, name: "scaled")
  rect((-1, -1), (2, 1), fill: red, name: "original")

  set-style(mark: (end: (symbol: ">")))

  line((-1, -1), (-1.5, -1.5), stroke: (dash: "dashed"))
  line((-1, 1), (-1.5, 1.5), stroke: (dash: "dashed"))
  line((2, 1), (3, 1.5), stroke: (dash: "dashed"))
  line((2, -1), (3, -1.5), stroke: (dash: "dashed"))

  chart((-3, -3), (5, 3))
})
