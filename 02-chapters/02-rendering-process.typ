#import "/vis/slider.typ": slider

#pagebreak(to: "odd")

= Il processo di rendering <chap:rendering-process>

Prima di iniziare questo progetto, l'azienda era solita sviluppare le proprie
interfacce utente utilizzando tecnologie Web come la libreria React @react.
Usando queste risorse diventa possibile sviluppare delle vere e proprie applicazioni,
dotate di grosse quantità di decorazioni e animazioni,
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
  supportando come minimo i forni UNOX e i dispositivi _Android_ e _iOS_;
8. Infine, l'utilizzo delle risorse di sistema deve essere relativamente *efficiente*,
  dato che spesso il software verrà eseguito su dispositivi mobili.

Il lettore familiare con l'utilizzo della moderna piattaforma Web avrà sicuramente notato
che i _browser_ implementano molti di questi requisiti.
Anche l'azienda ha notato questa cosa, decidendo quindi di prendere ispirazione
dalle architetture che i _browser_ hanno sviluppato nel corso degli ultimi trent'anni.
In particolare, Servo @servo, un nuovo _browser_ sperimentale,
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
rappresentato mediante un'istanza di uno _`struct`_
(in modo da avere sia più _type-safety_ sia maggiori prestazioni
rispetto all'uso di una rappresentazione testuale).

// TODO: fare meglio questa parte. Possibilmente anche inserendo alcuni esempi di layout complicati?
// Non lo so per però, non sarebbe strettamente parlando qualcosa di relativo alla tesi.
Creare un sistema di layout efficace è estremamente complicato:
oltre a essere corretto ed efficiente, deve anche essere capace di rappresentare
ogni possibile desiderio dei _designer_.
Fortunatamente, vista sia la presenza di Servo,
sia la familiarità del _team_ con CSS, è venuto naturale adottare
la libreria `taffy` @taffy, ossia quella che Servo
usa per implementare gli algoritmi di CSS,
come metodo di _layout_.

L'utilizzo di `taffy` richiede all'utente di fornire un tipo che rappresenti un albero di elementi.
Successivamente, per esso devono essere implementati dei _trait_
(l'equivalente in Rust di quelle che in altri linguaggi si chiamano interfacce)
che sostanzialmente forniscono un'astrazione tale da consentire a `taffy`
di visitare tutti i nodi dell'albero in maniera _depth-first_.
A partire da esse `taffy` implementa
i principali algoritmi di layout di CSS,
ossia `flexbox`, `grid` e `block`,
oltre a un sistema di _caching_ che
rimuove il più possibile il lavoro ripetuto.

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

// === Storia della rasterizzazione 2D

// Al giorno d'oggi esistono diverse librerie di grafica 2D, tuttavia tutte presentano un'_API_ molto simile:
// la libreria espone un _canvas_ (in italiano, "tela"), dove l'utente può disegnare usando un "pennello".
// Operando sul pennello, è possibile disegnare percorsi ("path") diversi.

// // TODO: parlare di tiny-skia
// // TODO: fare un detour storico su PostScript

== Lo stadio di Layer

Lo stadio di Layer si occupa, data una lista di componenti già rasterizzati,
di comporre assieme un'unica immagine,
in modo che quando un componente viene ridisegnato
debba essere ricreato solo il layer corrispondente,
e non tutto lo schermo.
Questo stadio non è strettamente necessario,
tuttavia l'aumento di efficienza che ha portato
si è rivelato essere fondamentale per i dispositivi meno potenti.

Lo stadio di Raster, ricordiamo,
ritorna un array monodimensionale di pixel,
che se accoppiati alla larghezza del componente
possono venire interpretati come immagine bidimensionale.
Per unire più immagini all'interno del _buffer_ di _layer_,
però, è fondamentale considerare che non possiamo effettuare direttamente una copia.
Invece, per ogni riga dell'immagine sorgente
dobbiamo copiare i pixel all'interno della posizione
corretta nell'immagine destinazione,
e poi spostarci "in basso" di una riga.
Per fare ciò, dobbiamo conoscere quella che in gergo tecnico viene chiamata _stride_,
ossia la quantità di memoria occupata da una riga dell'immagine.
Essa può essere diversa dalla larghezza dell'immagine, in quanto:
1. Un pixel può potenzialmente occupare più di un byte, e
2. È possibile che sia presente spazio di "padding"
  non considerato parte dell'immagine,
  ma inserito solitamente perché l'hardware
  richiede che ogni riga sia allineata a un certo numero di byte.

== Lo stadio di Composizione

Lo stadio di Composizione si occupa di unire i risultati dello stadio di Layer
per produrre un'immagine finale da mostrare a schermo.
La distinzione con esso sta nel fatto che
è lo stadio di Composizione ad applicare i _transform_
(ossia scala, rotazione, traslazione).

Questa distinzione è stata esplicitamente inserita
per consentire l'implementazione di elementi come
_slider_ in maniera efficiente.
Infatti, quando uno _slider_ viene spostato dall'utente,
l'unica cosa che cambia è la sua posizione;
questo significa che, se la posizione viene controllata mediante traslazione,
non è necessario rieseguire gli stadi di Raster e di Layer.
Ovviamente, questa ottimizzazione funziona solo se
gli elementi con trasformazioni appartengono a layer separati
da quelli degli elementi sottostanti.

#figure(
  caption: [Esempio di _slider_. Il cursore azzurro può essere spostato dall'utente.],
  slider,
)

È necessario evidenziare che le trasformazioni tridimensionali di CSS
non erano ancora implementate, insieme con la trasformazione di rotazione.
Questo ha semplificato di molto la fase di composizione,
dato che ogni oggetto mantiene una forma rettangolare.

=== Trasformazione di scala

L'implementazione della traslazione è estremamente semplice
(semplicemente modifica la posizione in cui il layer verrebbe inserito),
l'implementazione della scala è più complicata.
In particolare, una importante considerazione da fare prima di applicarla è:
se un oggetto viene scalato
dovrà venire disegnato con il numero di pixel finali,
o con il numero di pixel che avrebbe avuto senza scala?

Nel progetto era stata scelta la seconda opzione,
optando per l'uso di un algoritmo di _resampling_
per adattare il numero di pixel in modo che fosse corretto.
Esistono diversi algoritmi di _resampling_, ma i più comuni sono:
- *Nearest-Neighbor*: per ogni pixel di destinazione viene copiato
  il pixel sorgente a lui più vicino;
- *Bilinear*: ogni pixel finale viene calcolato come
  l'interpolazione tra i quattro pixel sorgenti più vicini;
- *Bicubic*: ogni pixel finale viene calcolato come
  l'interpolazione tra i nove pixel sorgenti più vicini;
- *Sinc*: un algoritmo di _resampling_ avanzato,
  che teoricamente fornisce la migliore ricostruzione possibile di un immagine;
- *Lanczos*: un'approssimazione di _Sinc_,
  che nella pratica spesso fornisce risultati migliori.

Per il progetto è stato implementato come metodo di _resampling_
il _Nearest-Neighbor_, in quanto gli altri metodi,
senza avere supporto dedicato da parte dell'hardware,
risultano troppo lenti,
e nella pratica si è notato che il _Nearest-Neighbor_
forniva risultati con qualità sufficiente per gli scopi del progetto.
