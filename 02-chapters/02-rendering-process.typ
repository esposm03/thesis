#pagebreak(to: "odd")

= Il processo di rendering <chap:rendering-process>

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
6. *Interattività*, per esempio utilizzando alcuni elementi come bottoni;
7. Il software deve essere *multi-piattaforma*,
  supportando come minimo i forni UNOX ed i dispositivi _Android_ e _iOS_;
8. Infine, l'utilizzo delle risorse di sistema deve essere relativamente *efficiente*,
  dato che spesso il software verrà eseguito su dispositivi mobili.

Il lettore familiare con l'utilizzo della moderna piattaforma Web avrà sicuramente notato
che i _browser_ implementano molti di questi requisiti.
Anche l'azienda ha notato questa cosa, decidendo quindi di prendere ispirazione
dalle architetture che i _browser_ hanno sviluppato nel corso degli ultimi trent'anni.
In particolare, Servo@servo, un nuovo _browser_ sperimentale,
è stato preso come modello.

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

#import "../vis/stages.typ": render-stages

#figure(render-stages, caption: [Stadi del processo di _rendering_, e strutture dati di supporto]) <grafico:stadi-rendering>

== Lo stadio di Layout

Il primo stadio del processo di _rendering_ è lo stadio di Layout;
esso si occupa di decidere dove posizionare gli elementi dell'interfaccia grafica.
L'input di questa fase è una descrizione di ogni elemento della pagina e del suo stile,
rappresentato mediante un istanza di uno _`struct`_ in modo da avere _type-safety_.

// TODO: fare meglio questa parte. Possibilmente anche inserendo alcuni esempi di layout complicati?
// Non lo so per però, non sarebbe strettamente parlando qualcosa di relativo alla tesi.
Creare un sistema di layout efficace è estremamente complicato:
oltre ad essere corretto ed efficiente, deve anche essere capace di rappresentare
ogni possibile desiderio dei _designer_.

Vista la presenza di Servo, è venuto naturale scegliere di utilizzare CSS come metodo di design;
la libreria `taffy`@taffy, dipendenza di Servo, è un'implementazione robusta dei relativi algoritmi di layout.

// TODO: parlare un po' della struttura di taffy, e di come si usa?

== Lo stadio di Raster

Lo stadio di raster è forse lo stadio più importante di tutta l'applicazione.
Esso, dato un componente, la descrizione del suo stile, e l'output della fase di layout
(da cui si ricava, per esempio, la dimensione finale del componente),
si occupa di produrre un insieme di pixel che lo rappresentino.

Per effettuare la rasterizzazione di oggetti anche relativamente complicati
(pensiamo per esempio alla rasterizzazione del testo),
si è utilizzata una libreria chiamata `tiny-skia`@tiny-skia.
Come dice il nome, è una versione più piccola di `skia`,
la libreria di rendering 2D di Google.

=== Storia della rasterizzazione 2D

Al giorno d'oggi esistono diverse librerie di grafica 2D, tuttavia tutte presentano un'_API_ molto simile:
la libreria espone un _canvas_ (in italiano, "tela"), dove l'utente può disegnare usando un "pennello".
Operando sul pennello, è possibile disegnare percorsi ("path") diversi.

// TODO: parlare di tiny-skia
// TODO: fare un detour storico su PostScript

== Lo stadio di Layer

Lo stadio di Layer si occupa, data una lista di componenti già rasterizzati, di comporre un buffer finale, chiamato Layer.

== Lo stadio di Composizione

Lo stadio di Composizione si occupa, data una lista di layer, di comporre un buffer finale da mostrare a schermo.
