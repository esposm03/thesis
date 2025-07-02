#import "@preview/cetz:0.3.4"
#import "@preview/fletcher:0.5.7" as fletcher: diagram, edge, node

#let render-stages = diagram(
  node-stroke: .5pt,
  node-shape: "rect",
  node-inset: 4pt,
  spacing: 7em,

  node((0, 0), "DOM", height: 5em, width: 5em),
  node((0.5, 0.85), "Layout tree", height: 5em, width: 5em),
  node((1, 0), "Raster buffers", height: 5em, width: 5em),
  node((1.5, 0.85), [Layers], height: 5em, width: 5em),
  node((2, 0), [Risultato finale], height: 5em, width: 5em),

  edge((0, 0), (0.5, 0.85), "->", label-side: center, label-pos: 52%, [Layout]),
  edge((0.5, 0.85), (1, 0), "->", label-side: center, label-pos: 48%, [Raster]),
  edge((1, 0), (1.5, 0.85), "->", label-side: center, label-pos: 50%, [Layering]),
  edge((1.5, 0.85), (2, 0), "->", label-side: center, label-pos: 48%, [Composizione]),
)
