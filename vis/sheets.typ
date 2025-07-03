#import "@preview/cetz:0.3.4"

#let sheet(..elements, is-3d: true) = {
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

    let x = if is-3d { -156deg } else { 90deg }
    let y = if is-3d { 30deg } else { 180deg }
    ortho(x: x, y: y, sorted: false, on-xz({
      rect((0, 0, 0), (10, 10, 0), fill: rgb("#0000"), name: "page")
      grid(
        "page.south-west",
        "page.north-east",
        stroke: 0.2pt,
      )

      for (zlevel, elements) in objects.enumerate() {
        for elem in elements {
          elem.value
        }
      }
    }))
  })
}

#let layer((x, y), (w, h), z: 0, fill: yellow) = {
  let res = ()

  // Rectangle
  res.push((
    value: cetz.draw.rect((x, y, z), (x + w, y + h, z), fill: fill),
    z: z,
  ))

  let stroke = (dash: (6pt,))

  for tempz in range(z) {
    res.push((
      value: cetz.draw.line((x, y, tempz), (x, y, tempz + 1), stroke: stroke),
      debug: (x, y),
      z: tempz,
    ))
    res.push((
      value: cetz.draw.line((x + w, y, tempz), (x + w, y, tempz + 1), stroke: stroke),
      debug: (x + w, y),
      z: tempz,
    ))
    res.push((
      value: cetz.draw.line((x, y + h, tempz), (x, y + h, tempz + 1), stroke: stroke),
      debug: (x, y + h),
      z: tempz,
    ))
    res.push((
      value: cetz.draw.line((x + w, y + h, tempz), (x + w, y + h, tempz + 1), stroke: stroke),
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
