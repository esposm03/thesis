#import "/vis/slider.typ": slider

#pagebreak(to: "odd")

= Il processo di rendering <chap:rendering-process>

Prima di iniziare questo progetto, l'azienda era solita sviluppare le proprie
interfacce utente utilizzando tecnologie _web_ come la libreria React @react. //_web_
Usando queste risorse diventa possibile sviluppare delle vere e proprie applicazioni,
dotate di grosse quantità di decorazioni e animazioni,
ma delegando al _browser_#sub[G] dell'utente la visualizzazione a schermo.
Dopo aver ponderato a lungo il problema di come implementare un'applicazione simile
e dopo numerose consultazioni con il _team_ che si occupa di _design_,
sono stati identificati i seguenti requisiti di massima:
1. Possibilità di visualizzare *elementi* rettangolari,
  possibilmente con bordi arrotondati e varie altre decorazioni;
2. Possibilità di inserire *immagini* nell'applicazione;
3. Supporto all'inserimento di *testo*;
4. Consentire lo *scorrimento* delle viste, per esempio quando l'utente utilizza la rotellina del mouse;
5. Deve essere possibile l'inserimento di *effetti*, per esempio sfocatura.
6. *Interattività*, per esempio utilizzando alcuni elementi come bottoni;
7. Il _software_ deve essere *multi-piattaforma*,
  supportando come minimo i forni UNOX e i dispositivi _Android_ e _iOS_;
8. Infine, l'utilizzo delle risorse di sistema deve essere relativamente *efficiente*,
  dato che spesso il _software_ verrà eseguito su dispositivi mobili.

A seguito dell’analisi dei requisiti individuati, l’azienda ha rilevato che la
maggior parte di essi risulta già implementata nei moderni browser. Di
conseguenza, si è deciso di trarre ispirazione dalle architetture sviluppate da
questi ultimi nel corso degli ultimi trent’anni. In particolare, è stato
adottato come modello Servo @servo, un browser sperimentale di nuova
generazione.

I _browser engine_ moderni sono molto complessi, principalmente a causa di
_sandboxing_#sub[G] e altre tecniche adottate per proteggere l'utente da possibili siti malevoli.
Tuttavia, se ignoriamo queste considerazioni, non necessarie per il progetto,
possiamo trovare che l'architettura di _rendering_ è organizzata a "stadi" eseguiti in maniera lineare,
ossia dove il risultato di uno stadio viene consumato dallo stadio successivo
senza che il flusso del programma possa "tornare indietro".
Questo ne rende la comprensione più semplice,
dato che ogni stadio è indipendente dagli altri
se non per le strutture dati utilizzate per trasmettere i risultati.
L'architettura adottata dal progetto è mostrata in @grafico:stadi-rendering;
i nodi rappresentano le strutture dati,
mentre gli archi rappresentano i quattro stadi.
Seguirà una descrizione di ognuno di essi nelle sezioni successive.

#import "../vis/stages.typ": render-stages

#figure(render-stages, caption: [Stadi del processo di _rendering_, e strutture dati di supporto]) <grafico:stadi-rendering>

== Lo stadio di Layout

Il primo stadio del processo di _rendering_ è lo stadio di _layout_;
esso si occupa di decidere dove posizionare gli elementi dell'interfaccia grafica.
L'_input_ di questa fase è una descrizione di ogni elemento della pagina e del suo stile,
rappresentato mediante un'istanza di uno _`struct`_
(in modo da avere sia più _type-safety_ sia maggiori prestazioni
rispetto all'uso di una rappresentazione testuale).

// TODO: fare meglio questa parte. Possibilmente anche inserendo alcuni esempi di _layout_ complicati?
// Non lo so per però, non sarebbe strettamente parlando qualcosa di relativo alla tesi.
Creare un sistema di _layout_ efficace è estremamente complicato:
oltre a essere corretto ed efficiente, deve anche essere capace di rappresentare
ogni possibile desiderio dei _designer_.
Fortunatamente, vista sia la presenza di Servo,
sia la familiarità del _team_ con CSS, è venuto naturale adottare
la libreria `taffy` @taffy
(utilizzata da Servo come implementazione degli algoritmi di CSS)
come metodo di _layout_.

L'utilizzo di `taffy` richiede all'utente di fornire un tipo che rappresenti un albero di elementi.
Successivamente, per esso devono essere implementati dei _trait_
(l'equivalente in Rust di quelle che in altri linguaggi si chiamano interfacce)
che sostanzialmente forniscono un'astrazione tale da consentire a `taffy`
di visitare tutti i nodi dell'albero in maniera _depth-first_.
A partire da esse `taffy` implementa
i principali algoritmi di _layout_ di CSS,
ossia `flexbox`, `grid` e `block`,
oltre a un sistema di _caching_ che
rimuove il più possibile il lavoro ripetuto.

== Lo stadio di Raster

//_raster_ con R maiuscola
Lo stadio di _raster_ è con tutta probabilità il più all'interno dell'applicazione.
Esso, dato un componente, la descrizione del suo stile, e l'_output_ della fase di _layout_
(da cui si ricava, per esempio, la sua dimensione finale),
si occupa di produrre un insieme di _pixel_ che lo rappresentino.

Per effettuare la rasterizzazione di oggetti anche relativamente complessi
(pensiamo per esempio alla rasterizzazione del testo),
si è utilizzata una libreria chiamata `tiny-skia`@tiny-skia.
Come dice il nome, è una versione più piccola di `skia`,
una libreria di rendering 2D sviluppata da Google.

== Lo stadio di Layer

La stadio di _layer_ si occupa di comporre, a partire da una lista di componenti
già rasterizzati, un'unica immagine. Questo approccio consente, quando il
componente viene ridisegnato, di ricreare solo il _layer_ corrispondente e non
tutto lo schermo.

Questo stadio non è strettamente necessario.
Tuttavia l'aumento di efficienza che ha portato
si è rivelato essere fondamentale per i dispositivi meno potenti.

Lo stadio di _raster_, è utile ricordare, produce in _output_ un _array_ monodimensionale di _pixel_,
che se accoppiato alla larghezza del componente
può essere interpretato come immagine bidimensionale.
Per unire più immagini all'interno del _buffer_ di _layer_,
però, è fondamentale considerare che non è possibile effettuare direttamente una copia.
Invece, per ogni riga dell'immagine sorgente è necessario copiare
i _pixel_ all'interno della posizione
corretta nell'immagine destinazione,
e, successivamente, spostarsi "in basso" di una riga.
Per fare ciò, è fondamentale conoscere quella che in gergo tecnico viene chiamata _stride_,
ossia la quantità di memoria occupata da una riga dell'immagine.
Essa può essere diversa dalla larghezza dell'immagine, in quanto:
1. Un _pixel_ può potenzialmente occupare più di un _byte_.
2. È possibile che sia presente spazio di "_padding_"
  non considerato parte dell'immagine,
  ma inserito solitamente perché l'_hardware_
  richiede che ogni riga sia allineata a un certo numero di _byte_.

== Lo stadio di Composizione

Lo stadio di Composizione si occupa di unire i risultati dello stadio di _layer_
per produrre un'immagine finale da mostrare a schermo.
La distinzione rispetto ad esso sta nel fatto che è lo stadio di Composizione ad occuparsi di applicare i _transform_ (ossia scala, rotazione, traslazione).

Questa distinzione è stata esplicitamente inserita
per consentire l'implementazione di elementi come
_slider_ in maniera efficiente.
A tal proposito, quando uno _slider_ viene spostato dall'utente,
l'unica cosa che cambia è la sua posizione;
questo significa che, se la posizione viene controllata mediante traslazione,
non è necessario rieseguire gli stadi di _raster_ e di _layer_.
Ovviamente, questa ottimizzazione funziona nel caso in cui
gli elementi con trasformazioni appartengono a _layer_ separati
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
(è sufficiente modificare la posizione in cui il _layer_ verrebbe inserito);
al contrario, invece, l'implementazione della scala è più complicata.
In particolare, un'importante considerazione da fare prima di applicarla è:
se un oggetto viene scalato,
dovrà venire disegnato con il numero di _pixel_ finali
o con il numero di _pixel_ che avrebbe avuto senza scala?

All'interno del progetto è stata adottata la seconda opzione,
optando per l'uso di un algoritmo di _resampling_
per adattare il numero di _pixel_ in modo che fosse corretto.
Esistono diversi algoritmi di _resampling_ @image-scaling-gallery, ma i più comuni sono:
- *Nearest-Neighbor*: per ogni _pixel_ di destinazione viene copiato
  il _pixel_ sorgente a lui più vicino @nearest-neighbor;
- *Bilinear*: ogni _pixel_ finale viene calcolato come
  l'interpolazione tra i quattro _pixel_ sorgenti più vicini @bilinear;
- *Bicubic*: ogni _pixel_ finale viene calcolato come
  l'interpolazione tra i nove _pixel_ sorgenti più vicini @bicubic;
- *Sinc*: un algoritmo di _resampling_ avanzato,
  che teoricamente fornisce la migliore ricostruzione possibile di un immagine @sinc;
- *Lanczos*: un'approssimazione di _Sinc_,
  che nella pratica spesso fornisce risultati migliori @lanczos.

Per il progetto è stato scelto come metodo di _resampling_ il _Nearest-Neighbor_,
in quanto gli altri metodi risultavano troppo lenti
in assenza di supporto dedicato da parte dell'_hardware_,
e nella pratica si è notato che il _Nearest-Neighbor_
forniva risultati con qualità sufficiente per gli scopi del progetto.

== Architettura del software

Il _software_ è relativamente complicato, presentando numerosi moduli e strutture dati.
Gli _struct_ principali sono:
- `Runtime`: è responsabile dell'interazione tra applicazione e _renderer_.
  Inoltre, incapsula l'_event loop_#sub[G] dell'applicazione.
- `Gui`: si occupa di tutto ciò che concerne l'interazione con il sistema operativo,
  come la gestione della finestra, la ricezione degli eventi,
  e la visualizzazione dei risultati del _rendering_.
- `AppUI`: si occupa di eseguire il processo di _rendering_,
  inviando i risultati a `Gui`.
- `Dom`: si occupa di salvare la lista di componenti;
  inoltre, incapsula parte della logica di _rendering_.
- `BaseComponent`: rappresenta un componente dell'interfaccia utente,
  e fornisce metodi per accedere alle sue proprietà.
  Inoltre, contiene un metodo che esegue il _raster_.

In @appendix:architettura è mostrato il _control flow_ del _renderer_,
mediante un grafico che mostra il flusso delle chiamate
che portano alla generazione di un _frame_.
