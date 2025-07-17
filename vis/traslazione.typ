#import "@preview/cetz:0.4.0"
#import "/common/variables.typ": chart, my_point

#let traslazione = cetz.canvas({
  import cetz.draw: *

  chart((-2, -2), (10, 4))

  my_point(1, 0, "A")
  my_point(3, -1, "B")
  line("A", "B", stroke: red)

  my_point(6, 3, "A'", my-fill: green, dy: 0.3)
  my_point(8, 2, "B'", my-fill: green, dy: 0.3)
  line("A'", "B'", my-fill: green)

  line("A", "A'", stroke: (dash: "dashed"), mark: (end: (symbol: ">")))
  line("B", "B'", stroke: (dash: "dashed"), mark: (end: (symbol: ">")))
})
