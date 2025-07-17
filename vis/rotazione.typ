#import "@preview/cetz:0.4.0"
#import "/common/variables.typ": chart, my_point

#let rotazione = cetz.canvas({
  import cetz.draw: *

  chart((-2, -2), (10, 4))

  my_point(1, 1, "A")
  my_point(1, 3, "B")
  line("A", "B", stroke: red)

  my_point(1, -1, "A'", my-fill: blue)
  my_point(3, -1, "B'", my-fill: blue)
  line("A'", "B'", my-fill: blue)

  arc-through("A", (calc.sqrt(2), 0), "A'", mark: (end: (symbol: ">")), stroke: (dash: "dashed"))
  arc-through("B", (calc.sqrt(10), 0), "B'", mark: (end: (symbol: ">")), stroke: (dash: "dashed"))
})
