#let nCols = 23
#let border = 1.2pt + black
#let borderThin = 0.4pt + black.lighten(30%)
#let cap-start = (right: borderThin, rest: border)
#let cap = (left: borderThin, right: borderThin, rest: border)
#let cap-end = (left: borderThin, rest: border)

#let r = grid.cell(fill: purple.lighten(40%), stroke: cap-start)[R]
#let g = grid.cell(fill: purple.lighten(40%), stroke: cap)[G]
#let b = grid.cell(fill: purple.lighten(40%), stroke: cap)[B]
#let a = grid.cell(fill: purple.lighten(40%), stroke: cap)[A]
#let x = grid.cell(fill: red.lighten(30%), stroke: cap)[X]
#let y = grid.cell(fill: red.lighten(30%), stroke: cap)[Y]
#let z = grid.cell(fill: red.lighten(30%), stroke: cap)[Z]
#let pad = grid.cell(fill: gray.lighten(30%), stroke: cap)[-]
#let w = grid.cell(fill: green.lighten(30%), stroke: cap)[W]
#let h = grid.cell(fill: green.lighten(30%), stroke: cap-end)[H]

#let vertex-buffer = align(center, grid(
  columns: (99% / nCols,) * nCols,
  inset: 8pt,
  grid.cell(colspan: 10, stroke: border, inset: 4pt)[Vertice 1],
  grid.cell(colspan: 10, stroke: border, inset: 4pt)[Vertice 2],
  grid.cell(colspan: 3, stroke: border, inset: 4pt)[Vertice 3],
  r, g, b, a,
  x, y, z, pad,
  w, h,
  r, g, b, a,
  x, y, z, pad,
  w, h,
  grid.cell(fill: white, stroke: cap-start, colspan: 3)[...],

  grid.cell(colspan: 1, inset: 3pt, align: left)[0],

  [], [],
  grid.cell(colspan: 2, inset: 3pt)[4],
  [], [],
  grid.cell(colspan: 2, inset: 3pt)[8],
  grid.cell(colspan: 2, inset: 3pt)[10],

  [], [],
  grid.cell(colspan: 2, inset: 3pt)[14],
  [], [],
  grid.cell(colspan: 2, inset: 3pt)[18],
  grid.cell(colspan: 2, inset: 3pt)[20],
))
