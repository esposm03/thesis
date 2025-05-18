#pagebreak(to: "odd")

= Il processo di rendering

Prima di iniziare questo progetto, l'azienda era solita sviluppare le proprie
interfacce utente utilizzando tecnologie Web come la libreria React@react.
Usando queste risorse diventa possibile sviluppare delle vere e proprie applicazioni,
dotate di grosse quantità di decorazioni ed animazioni,
ma delegando al _browser_ dell'utente la visualizzazione a schermo.
Dopo aver ponderato a lungo il problema di come implementare un'applicazione simile,
e dopo numerose consultazioni con il team che si occupa di _design_,
sono stati identificati i seguenti requisiti di massima:
1. Possibilità di visualizzare *elementi* rettangolari,
  possibilmente con bordi arrotondati e varie altre decorazioni;
2. Possibilità di inserire *immagini* nell'applicazione;
3. Supporto all'inserimento di *testo*;
4. Consentire lo *scorrimento* delle viste, per esempio quando l'utente utilizza la rotellina del mouse;
5. Deve essere possibile l'inserimento di *effetti*, per esempio sfocatura.
6. Forte *interattività*, per esempio utilizzando alcuni elementi come bottoni;
7. Il software deve essere *multi-piattaforma*,
  supportando come minimo i forni UNOX ed i dispositivi _Android_ e _iOS_;
8. Infine, l'utilizzo delle risorse di sistema deve essere relativamente *efficiente*,
  dato che spesso il software verrà eseguito su dispositivi mobili.

Il lettore familiare con l'utilizzo della moderna piattaforma Web avrà sicuramente notato
che i _browser_ implementano molti di questi requisiti.
Anche l'azienda ha notato questa cosa, decidendo quindi di prendere ispirazione
dalle architetture che i _browser_ hanno sviluppato nel corso degli ultimi trent'anni.
In particolare, Servo@servo, un nuovo _browser_ sperimentale, è stato usato come modello principale,
seppur con molte semplificazioni.

I _browser engine_ moderni sono molto complessi, principalmente a causa di
_sandboxing_ e altre tecniche adottate per proteggere l'utente da possibili siti malevoli.
Tuttavia, se ignoriamo queste considerazioni non necessarie per il progetto,
possiamo trovare che l'architettura di _rendering_ è organizzata a "stadi" eseguiti in maniera lineare,
ossia il risultato di uno stadio viene consumato dallo stadio successivo
senza che il flusso del programma possa "tornare indietro".
Questo ne rende la comprensione più semplice,
dato che ogni stadio è indipendente dagli altri
se non per le strutture dati utilizzate per trasmettere i risultati.
L'architettura adottata dal progetto è mostrata in @grafico:stadi-rendering;
i nodi rappresentano le strutture dati,
mentre gli archi rappresentano i quattro stadi.
Seguirà una descrizione di ognuno degli stadi.

#import "@preview/cetz:0.3.4"
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge

#figure(
  diagram(
    node-stroke: .5pt,
    node-shape: "rect",
    node-inset: 4pt,
    spacing: 7em,

    node((0, 0), "DOM", height: 5em, width: 5em),
    node((0.5, 0.85), "Layout tree", height: 5em, width: 5em),
    node((1, 0), "Display lists", height: 5em, width: 5em),
    node((1.5, 0.85), [Layers], height: 5em, width: 5em),
    node((2, 0), [Risultato finale], height: 5em, width: 5em),

    edge((0, 0), (0.5, 0.85), "->", label-side: center, label-pos: 52%, [Layout]),
    edge((0.5, 0.85), (1, 0), "->", label-side: center, label-pos: 48%, [Layering]),
    edge((1, 0), (1.5, 0.85), "->", label-side: center, label-pos: 50%, [Raster]),
    edge((1.5, 0.85), (2, 0), "->", label-side: center, label-pos: 48%, [Composizione]),
  ),
  caption: [Fasi del processo di _rendering_, e strutture dati di supporto],
) <grafico:stadi-rendering>

== Lo stadio di Layout

Il primo stadio del processo di _rendering_ è lo stadio di Layout;
esso si occupa di decidere dove posizionare gli elementi dell'interfaccia grafica.

