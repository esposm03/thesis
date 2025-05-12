#import "../config/variables.typ": digid

// Non su primo capitolo
// #pagebreak(to:"odd")

= Introduzione

// TODO: aggiungere riferimenti a:
// Termine nel glossario
// Citazione in linea
// Citazione nel pie' di pagina

== L'azienda

Il progetto di stage si è svolto presso la sede di Cadoneghe dell'azienda UNOX S.p.A.
L'azienda si occupa della progettazione e produzione di forni professionali
per i settori della ristorazione, del _retail_, della pasticceria, e della panificazione,
e vanta 690 dipendenti solo nella sede di Padova.

UNOX si occupa di tutte le fasi del ciclo di vita dei forni,
dalla progettazione e produzione alla commercializzazione e vendita.
Alcuni dei prodotti presentano un sistema _smart_, denominato #digid,
che fornisce funzionalità quali programmazione delle cotture, controllo remoto,
o emissione di notifiche in caso di particolari eventi.

== L'idea

Il sistema #digid, attualmente, è installato solo sui forni di fascia più alta che UNOX produce.
L'azienda si è posta l'obiettivo di ridurre i costi dell'_hardware_ utilizzato da #digid,
in modo da poter iniziare ad inserirlo anche nelle fasce più basse del proprio mercato.
Secondo test effettuati internamente, però, la precedente implementazione non riusciva
a fornire prestazioni adeguate per il cambio previsto, e di conseguenza
era necessario sostituire la vecchia implementazione con una più veloce.

Da qualche mese, quindi, sta venendo sviluppato un _renderer_ 2D completamente nuovo,
capace di raggiungere prestazioni molto superiori alla piattaforma precedente.
Il progetto di stage prevede, quindi, di affiancare il _team_ di sviluppo
nell'ottimizzazione delle prestazioni, mediante l'integrazione
di codice capace di sfruttare la _GPU_ del sistema per accelerare le fasi più critiche.

== Organizzazione del testo

Il presente documento descrive il lavoro svolto durante il periodo di stage, della durata di trecentododici ore, dal laureando Samuele Esposito presso l'azienda UNOX S.p.A.

// TODO: aggiornare
Il documento è suddiviso in #context { counter(heading).final().at(0) } capitoli:

1. Introduzione (capitolo corrente): viene introdotto il progetto di stage,
  con una breve spiegazione del contesto che ha portato alla sua creazione.
  Successivamente, vengono fornite alcune indicazioni sulla struttura della tesi.

Riguardo la stesura del testo, relativamente al documento sono state adottate le seguenti convenzioni tipografiche:

- gli acronimi, le abbreviazioni e i termini ambigui o di uso non comune menzionati vengono definiti nel glossario, situato alla fine del presente documento;
- per la prima occorrenza dei termini riportati nel glossario viene utilizzata la seguente nomenclatura: _parola_#super[G];
- i termini in lingua straniera o facenti parti del gergo tecnico sono evidenziati con il carattere _corsivo_.

// #cetz.canvas({
//   import cetz.draw: *

//   let z1 = 1

//   let layer(name, x, y, w, h, z: 0) = group(
//     name: name,
//     {
//       rect((x, y, z), (x + w, x + h, z), stroke: none, name: "rect")
//       line("rect.south-east", (rel: (z: z)), stroke: (dash: "dashed"))
//       line("rect.north-east", (rel: (z: z)), stroke: (dash: "dashed"))
//       line("rect.south-west", (rel: (z: z)), stroke: (dash: "dashed"))
//       line("rect.north-west", (rel: (z: z)), stroke: (dash: "dashed"))
//       rect((x, y, z), (x + w, x + h, z), fill: yellow, name: "rect")
//     },
//   )

//   ortho(
//     x: -150deg,
//     y: 30deg,
//     z: 6deg,
//     sorted: false,
//     on-xz({
//       rect((0, 0, 0), (10, 10, 0), fill: rgb("#0000"), name: "page")
//       grid("page.south-west", "page.north-east", stroke: 0.2pt)
//       layer("b", 5, 4, 3, 2, z: 3)
//       layer("a", 0, 0, 5, 5, z: 1)
//     }),
//   )
// })
