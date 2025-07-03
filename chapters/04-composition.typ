#pagebreak(to: "odd")

= Composizione

Le _GPU_ sono state progettate per la grafica 3D,
ed utilizzarle per produrre grafica 2D non è,
strettamente parlando, ciò per cui sono state progettate.

== Approccio iniziale: grafica 3D

Abbiamo quindi, inizialmente, pensato di produrre una scena tridimensionale,
in modo che potesse essere presa da una telecamera in proiezione ortogonale,
producendo un sistema simile a quello mostrato dalla @grafico:composizione.

#import "../vis/sheets.typ": layer, sheet

#let graphic = {
  sheet(..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red))
  sheet(..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red), is-3d: false)
}
#figure(graphic, caption: [Esempio di composizione di layer (colorati) sullo schermo]) <grafico:composizione>

== Approccio semplificato

Mentre implementavamo l'approccio precedente, ci siamo resi conto che, in realtà,
le _GPU_ lavorano su vertici in coordinate già relative allo schermo.
Di conseguenza, implementare un sistema 3D con telecamera ortogonale
risultava più complicato del necessario.
Allora abbiamo implementato un sistema in 2D,
dove i vertici del rettangolo avevano già le coordinate corrette.
