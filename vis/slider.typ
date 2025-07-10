#import "@preview/cetz:0.4.0"

#let slider = cetz.canvas({
  import cetz.draw: *

  rect((), (rel: (10, 0.1)), radius: 0.05, name: "slider")
  circle((to: "slider.20%", rel: (0, 0.05)), radius: 0.2, fill: aqua)
})
