#import "@preview/cetz:0.3.4"

#let sheet(..elements) = {
  // Objects is an array with the shape:
  // (
  //   0: (/* all objects with z = 0 */),
  //   1: (/* all objects with z = 1 */),
  //   /* etc... */
  // )
  let objects = ()

  // Populate the objects array
  for el in elements.pos() {
    while objects.len() <= el.z {
      objects.push(())
    }

    objects.at(el.z).push(el)
  }

  cetz.canvas({
    import cetz.draw: *

    ortho(
      x: -156deg,
      y: 30deg,
      sorted: false,
      on-xz({
        rect((0, 0, 0), (10, 10, 0), fill: rgb("#0000"), name: "page")
        grid("page.south-west", "page.north-east", stroke: 0.2pt)

        for (zlevel, elements) in objects.enumerate() {
          for elem in elements {
            elem.value
          }
        }
      }),
    )
  })
}

#let layer((x, y), (w, h), z: 0) = {
  let res = ()

  // Rectangle
  res.push((
    value: cetz.draw.rect((x, y, z), (x + w, y + h, z), fill: yellow),
    z: z,
  ))

  for tempz in range(z) {
    res.push((
      value: cetz.draw.line((x, y, tempz), (x, y, tempz + 1), stroke: (dash: "dashed")),
      debug: (x, y),
      z: tempz,
    ))
    res.push((
      value: cetz.draw.line((x + w, y, tempz), (x + w, y, tempz + 1), stroke: (dash: "dashed")),
      debug: (x + w, y),
      z: tempz,
    ))
    res.push((
      value: cetz.draw.line((x, y + h, tempz), (x, y + h, tempz + 1), stroke: (dash: "dashed")),
      debug: (x, y + h),
      z: tempz,
    ))
    res.push((
      value: cetz.draw.line((x + w, y + h, tempz), (x + w, y + h, tempz + 1), stroke: (dash: "dashed")),
      debug: (x + w, y + h),
      z: tempz,
    ))

    repr((x, y))
    repr((x + w, y))
    repr((x, y + h))
    repr((x + w, y + h))
  }

  return res
}

#sheet(
  ..layer((0.5, 0.5), (5, 5), z: 1),
  ..layer((4, 4), (3, 4), z: 2),
)
