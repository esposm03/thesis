#import "@preview/cetz:0.4.0"
#import "/common/variables.typ": chart, equation, flex-caption, my_point

#let rototraslazione = cetz.canvas({
  import cetz.draw: *

  chart((-2, -2), (10, 4))

  my_point(1, 1, "A")
  my_point(1, 3, "B")
  line("A", "B", stroke: red)

  my_point(1, -1, "A'", my-fill: blue)
  my_point(3, -1, "B'", my-fill: blue)
  line("A'", "B'", my-fill: blue)

  arc-through("A", (calc.sqrt(2), 0), "A'", stroke: (dash: "dashed"))
  arc-through("B", (calc.sqrt(10), 0), "B'", stroke: (dash: "dashed"))

  my_point(6, 2, "A''", my-fill: green, dy: 0.3)
  my_point(8, 2, "B''", my-fill: green, dy: 0.3)
  line("A''", "B''", my-fill: green)

  line("A'", "A''", stroke: (dash: "dashed"), mark: (end: (symbol: ">")))
  line("B'", "B''", stroke: (dash: "dashed"), mark: (end: (symbol: ">")))
})

