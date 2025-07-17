#import "/vis/vertex-buffer.typ": vertex-buffer
#import "/vis/clip-space.typ": clip-space
#import "/common/variables.typ": code, flex-caption

#pagebreak(to: "odd")

= Programmazione di GPU <chap:gpu-programming>

Le _GPU_ sono dispositivi estremamente potenti e flessibili.
Esse sono coprocessori che agiscono in maniera asincrona
rispetto al processore principale,
il quale si occupa solamente di inviargli comandi
e successivamente recuperare il risultato.
La natura asincrona è estremamente importante,
dato che le _GPU_ presentano una memoria separata da quella principale,
e i trasferimenti da una all'altra sono relativamente lenti.
Inoltre, consente alla _CPU_#sub[G] di eseguire altre attività in attesa del completamento di quelle della _GPU_.

Inizialmente, le _GPU_ contenevano solamente una _pipeline_
esplicitamente progettata per il _rendering_ di grafica 3D#sub[G].
Con il tempo, però, si è vista una vera e propria trasformazione delle
_GPU_ in processori generici altamente paralleli,
consentendo vastissime applicazioni in ambiti scientifici
non strettamente legati alla _grafica_.
Queste capacità, utilizzabili dall'utente mediante scrittura di _compute shader_,
non verranno però discusse in questa tesi,
in quanto non sono state utilizzate all'interno del progetto di _stage_.
Il lettore interessato può trovarne una spiegazione in @gpu-computing.

Nel resto di questo capitolo, viene trattata la struttura e l'utilizzo della _pipeline_ grafica.
È importante ricordare che i dettagli specifici del funzionamento sono differenti
in base a quale _API_ (Vulkan, OpenGL, ecc.) viene utilizzata;
in questa tesi viene discussa la _pipeline_ di _WebGPU_,
l'_API_ adottata dal progetto,
che può risultare differente da altre in merito ai dettagli specifici.

== Vertex buffer

La prima fase del _rendering_ consiste nella creazione e il popolamento di un _vertex buffer_.
Esso è un _array_ di strutture definite dal programmatore,
solitamente contenenti almeno le coordinate del vertice da disegnare.
Ogni vertice che si vuole disegnare sarà rappresentato da un elemento del _vertex buffer_.

Affinché le _vertex shader_ (trattate in @chap:gpu-programming:vertex-shaders)
riescano a interpretare questo _buffer_, tuttavia,
l'applicazione deve informare la _GPU_ di come le strutture al suo interno sono organizzate.

Supponiamo, per esempio, di voler definire una _vertex shader_
capace di creare dei rettangoli colorati a schermo.
Essa avrà bisogno dei seguenti input:
- Il *colore* con cui vogliamo rappresentare il rettangolo.
  Decidiamo di passarlo in rappresentazione RGBA
  (ossia con i quattro canali di rosso, verde, blu e trasparenza,
  ognuno salvato con un byte).
- La *posizione* nello spazio tridimensionale,
  rappresentata con tre interi con segno, ognuno da 1 byte;
- La *dimensione* del rettangolo,
  rappresentata con due interi con segno,
  sempre di 1 byte ciascuno.

Potremmo decidere, quindi, di organizzare il _buffer_ come in @grafico:vertex-buffer,
dove le celle viola contengono il colore del vertice
(_RGBA_ sta per _red_, _green_, _blue_, _alpha_),
le celle rosse contengono la sua posizione
(i tre assi _X_, _Y_, _Z_),
e le celle verdi la sua dimensione
(_W_ sta per _width_, mentre _H_ sta per _height_).
Si può notare che sono state inserite delle celle vuote (di "_padding_"),
per scopi di allineamento.
In particolare, è stato deciso di allineare il campo *dimensione* a 2 byte
per facilitarne la scrittura alla _CPU_.
È inoltre presente una dimensione di ogni vertice che è un multiplo di quattro byte
(in quanto richiesto dalla _GPU_).

#figure(vertex-buffer, caption: [Possibile organizzazione di un _vertex buffer_]) <grafico:vertex-buffer>

Per rendere questo _buffer_ comprensibile alla _GPU_,
è necesario fornire un oggetto simile a quello rappresentato
in @code:vertex-buffer-layout, per descriverne il layout.
Si elencano di seguito i campi:
- `attributes`: un _array_ di oggetti che descrivono gli attributi del _vertex buffer_.
  Ogni attributo viene descritto da:
  - `format`, che indica il tipo di dato (per esempio `sint8` o `uint32`),
    opzionalmente insieme a un numero di canali;
  - `offset`, ossia la distanza tra il primo byte del vertice e l'inizio dell'attributo;
  - `shaderLocation`, ossia quale "slot" la _shader_ potrà utilizzare per accedere al valore.
- `arrayStride`: indica la dimensione di un singolo vertice.
  Notare che non è obbligatoriamente uguale alla somma delle dimensioni dei singoli attributi,
  per esempio se si decide di inserire byte di _padding_.
- `stepMode`: può avere come valori `"vertex"` (il default) oppure `"instance"`.
  Definisce se l'indice del _buffer_ deve essere incrementato una volta per ogni vertice,
  oppure una volta per ogni oggetto nella scena
  (mantenendo quindi lo stesso indice per tutti i vertici dello stesso oggetto).
  Dato che noi dobbiamo disegnare quattro vertici a partire dallo stesso input,
  imposteremo `'instance'` come `stepMode`; il default è `'vertex'`,

#code(caption: [Esempio di un descrittore del _layout_ di un _vertex buffer_])[
  ```js
  {
    attributes: [
      { format: 'unorm8x4', offset: 0, shaderLocation: 0 }, // colore
      { format: 'snorm8x4', offset: 4, shaderLocation: 1 }, // posizione
      { format: 'snorm8x2', offset: 8, shaderLocation: 2 }, // dimensione
    ];
    arrayStride: 12;
    stepMode: 'instance';
  }
  ```
] <code:vertex-buffer-layout>

== Vertex shader <chap:gpu-programming:vertex-shaders>

Una volta definito il _vertex buffer_, è necessario scrivere una
_vertex shader_ capace di lavorare con questo _buffer_.
Una _shader_ è un piccolo programma, solitamente definito in un linguaggio apposito,
che la _GPU_ esegue tante volte durante durante l'esecuzione della sua _pipeline_ grafica.
Le _vertex shader_ sono uno dei due tipi principali di _shader_,
insieme alle _fragment shader_ (di cui discuteremo in @chap:gpu-programming:fragment-shader).

Le _shader_, in _WebGPU_, sono definite in un linguaggio apposito,
chiamato _WGSL_ (_WebGPU Shading Language_).
Per definire una _vertex shader_ è sufficiente passare il @code:vertex-shader-noop a _WebGPU_:
esso definisce una semplice funzione, chiamata `vs_main`,
che ritorna un valore di tipo `vec4<f32>`.
La funzione è annotata con l'attributo `@vertex`,
mentre il suo valore di ritorno è annotato con `@builtin(position)`.
All'interno del corpo della funzione, prima viene creata una costante
(`let` definisce una variabile non modificabile) con nome `out` e tipo `vec4<f32>`,
a cui viene assegnato un vettore contenente quattro volte 1.
Successivamente, il valore della variabile `out` viene ritornato.

#code(caption: [La più piccola _vertex shader_ valida])[
  ```wgsl
  @vertex
  fn vs_main() -> @builtin(position) vec4<f32> {
    let out: vec4<f32> = vec4<f32>(1, 1, 1, 1);
    return out;
  }
  ```
] <code:vertex-shader-noop>

// TODO: dire che cosa sono i tipi scalari
Le variabili, in _WGSL_, possono avere i seguenti tipi:
- `i32`, `u32`: interi da 32 bit (4 byte), rispettivamente con e senza segno;
- `f16`, `f32`: numeri _floating-point_, rispettivamente da 16 bit (2 byte) o 32 bit (4 byte);
- `bool`: un valore booleano, `true` oppure `false`.
- `vecN<T>`: un vettore, con `N` componenti di tipo scalare `T`.
- `matCxR<T>`: una matrice di `C` colonne e `R` righe, con componenti di tipo _floating-point_ `T`;
- `array<E>`: un _array_ con dimensione determinata a runtime, ed elementi di tipo `E`;
- `array<E, N>`: un _array_ con dimensione `N`, ed elementi di tipo `E`;
- `struct Nome { field1: type1, field2: type2, ... }`, una struttura.

Gli argomenti di una funzione marcata `@vertex` possono essere di tipo scalare o di tipo struttura.
Se scalari, ognuno deve essere marcato con un attributo `@builtin` oppure con un attributo `@location`;
se strutture, lo stesso requisito si applica a ognuno dei campi della stessa.
Questi due attributi specificano da dove la _GPU_ deve recuperare i valori.
`@builtin` indica uno tra vari significati "predefiniti" che un attributo può avere.
Per gli attributi specificati dall'utente, `@location` indica l'ordine in cui essi vengono passati alla _shader_.

=== Clip space coordinates <chap:gpu-programming:clip-space>

Si può notare che il tipo di ritorno della _shader_ in @code:vertex-shader-noop
è un vettore con quattro componenti, nonostante venga fatto un _rendering_ in tre dimensioni.
Ciò avviene in quanto le _vertex shader_ ritornino vertici con coordinate espresse in *clip-space*.
Ciò significa che esse sono un vettore a quattro componenti:

$ vec(x_c, y_c, z_c, w_c) $

dove $x_c$, $y_c$ e $z_c$ definiscono una posizione nello spazio,
mentre $w_c$ definisce la dimensione di un cubo, chiamato _clip volume_,
in cui tutti i vertici devono essere contenuti per evitare che la _GPU_ li scarti.

#let clip-caption = flex-caption(
  [Esempio di _clip space_, con un triangolo parzialmente al suo interno.
    La parte evidenziata in rosso è quella completamente inscritta nel _clip volume_],
  [Esempio di _clip space_, con un triangolo parzialmente al suo interno.],
)
#figure(clip-space, caption: clip-caption) <grafico:clip-space>

L'utilità di questo _clip-space_ è semplicemente di consentire alla _GPU_
di implementare il _clipping_#sub[G] in maniera efficiente,
dato che tutti i vertici visibili a schermo rispettano le condizioni
$
  cases(
    -w_c <= x_c <= w_c,
    -w_c <= y_c <= w_c,
    0 <= z_c <= w_c,
  )
$
dove le prime due condizioni asseriscono che il vertice sia all'interno dell'area dello schermo,
mentre l'ultima asserisce che il vertice non sia "troppo vicino" (ossia abbia $z_c < 0$),
oppure "troppo lontano" (ossia abbia $z_c > w_c$).
In @grafico:clip-space si trova un esempio di _clip-space_.
Il triangolo al suo interno è parzialmente occluso,
e si può notare che l'area colorata, ossia quella visibile, è quella all'interno del _clip volume_.

Se l'utente volesse implementare proiezioni prospettiche, sistemi di telecamere, o altri sistemi particolari,
sarà sua premura applicare all'interno della _vertex shader_ una trasformazione,
che porti le coordinate dalla forma da lui scelta, a coordinate in _clip-space_.

== Clipping e rasterizzazione

Dopo aver eseguito la _vertex shader_ come da @chap:gpu-programming:vertex-shaders,
vi sono una serie di fasi non programmabili (in gergo vengono anche chiamate fasi "_fixed-function_",
riferendosi al fatto che la loro funzione è fissa e non scelta dall'utente)
che si occupano di prendere il risultato della _vertex shader_
(la quale, ricordiamo, opera su vertici presi singolarmente)
e di preparare l'_input_ per la _fragment shader_.

La prima fase è la fase di *primitive assembly*, che prende i vertici
e ne crea una lista di forme geometriche "primitive"
(solitamente triangoli, ma esistono _GPU_ che ne supportano anche altre).

Successivamente, vengono eliminate le primitive che risultano essere esterne al _clip space_.
Qualora una di esse fosse esterna solo parzialmente, allora
verrebbe sostituita con un poligono tale da esserne completamente inscritto.

// TODO: espandere tanto questo paragrafo, possibilmente addirittura in una sezione apposita
Infine, avviene la fase di *rasterizzazione*.
Questa è la fase più complicata di tutta la pipeline di _rendering_,
che si occupa di creare, per ogni primitiva che ha passato le fasi precedenti,
una lista di _fragment_, in quantità di (almeno) uno per pixel dello schermo coperto dalla primitiva.
Ognuno contiene una posizione in _device coordinates_
(coordinate comprese tra 0 e la dimensione dello schermo),
una profondità espressa in numero tra 0 e 1, e altri attributi utili.
Inoltre, per ogni attributo _user-defined_ (ossia annotato
con `@location(N)`) specificato dalla _vertex shader_,
il _fragment_ conterrà l'interpolazione tra i valori definiti
per i vertici della primitiva corrispondente.

== Fragment shader <chap:gpu-programming:fragment-shader>

Le _fragment shader_ sono dei piccoli programmi definiti dall'utente
con lo scopo di calcolare il colore di un particolare pixel delle primitive.
Come dice il nome, il loro ingresso è un _fragment_, una struttura dati
che rappresenta un "possibile" pixel, e contiene vari valori ottenuti interpolando
tra i corrispondenti valori nei vertici.

In @code:fragment-shader-noop è presente un esempio di una semplice _vertex shader_,
che ritorna sempre un colore rosso completamente opaco
(per una introduzione alla sintassi con cui essa è scritta,
fare riferimento a @chap:gpu-programming:vertex-shaders).
Rispetto alle _vertex shader_, possiamo far notare alcune differenze:
- L'ingresso della _fragment shader_ è marcato come `@builtin(position)`;
  tuttavia ha un significato molto diverso da quello del valore di ritorno della _vertex shader_.
  Nelle _vertex shader_, `@builtin(position)` viene interpretato come una coordinata nel _clip-space_,
  mentre nelle _fragment shader_ sono _framebuffer coordinates_, ossia coordinate relative allo schermo.
- L'uscita non è marcata come `@builtin`, ma è un _user-defined output_.
  Questo perché in fase di configurazione della _GPU_ è possibile definire una lista di
  _color attachment_, ossia descrizioni delle risorse su cui disegnare.
  Nel caso di @code:fragment-shader-noop, è stato definito un solo _render attachment_ (quindi con indice 0)
  dove i pixel sono stati rappresentati in formato _RGBA_.

#code(caption: [La più piccola _fragment shader_ valida])[
  ```wgsl
  @fragment
  fn fs_main(@builtin(position) coord_in: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(1.0, 0.0, 0.0, 1.0);
  }
  ```
] <code:fragment-shader-noop>

Può essere desiderabile, inoltre, applicare anche delle immagini alla superficie dei nostri triangoli;
fortunatamente, è un desiderio così comune che le _GPU_ presentano supporto specifico per esse.
In particolare, è possibile creare dei _buffer_, diversi dai _vertex buffer_ o dai _color attachment_,
a cui la _shader_ può accedere come se fossero variabili globali.
Questi _buffer_ prendono il nome di *_texture_*.
Possiamo quindi modificare la nostra _fragment shader_ per inserire due diverse variabili globali:
- `texBuffer` di tipo `texture_2d<f32>`, che conterrà i nostri pixel;
- `texSampler` di tipo `sampler`, utilizzata per interpretare i dati della texture.

L'utilizzo di una texture è relativamente semplice, come mostrato in @code:fragment-shader-texture.
Per ogni _fragment_, è sufficiente chiamare la funzione _built-in_ `textureSample`,
passando una _texture_, un _sampler_, e delle coordinate bidimensionali che indichino
da quale punto della texture recuperare il pixel
(o, qualora il punto non fosse esattamente all'interno di un pixel, la media tra i pixel adiacenti)
Queste coordinate saranno fornite dalla _vertex shader_
come un secondo attributo, `texcoord`, da aggiungere a `VertexOutput`.

Ovviamente, però, la _vertex shader_ verrà eseguita per ogni vertice,
e non per ogni _fragment_ all'interno della primitiva.
Di conseguenza, la _GPU_ eseguirà per ogni _fragment_ una interpolazione
tra i valori calcolati per ogni vertice,
e utilizzerà i valori calcolati come _input_ della _fragment shader_.

#code(caption: [Esempio di _shader_ che applicano una texture ad un rettangolo.])[
  #set par(leading: 0.68em)
  ```wgsl
  struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) texcoord: vec2f,
  };
  @group(0) @binding(0) var ourSampler: sampler;
  @group(0) @binding(1) var ourTexture: texture_2d<f32>;

  @vertex fn vert_main(
    @builtin(vertex_index) vertexIndex : u32
  ) -> VertexOutput {
    let pos = array(
      vec2f(0.0,  0.0),
      vec2f(1.0,  0.0),
      vec2f(0.0,  1.0),
      vec2f(0.0,  1.0),
      vec2f(1.0,  0.0),
      vec2f(1.0,  1.0),
    );

    var output: VertexOutput;
    let xy = pos[vertexIndex];
    output.position = vec4f(xy, 0.0, 1.0);
    output.texcoord = xy;
    return output;
  }

  @fragment fn fs_main(input: VertexOutput) -> @location(0) vec4f {
    return textureSample(ourTexture, ourSampler, input.texcoord);
  }
  ```
] <code:fragment-shader-texture>

// TODO: spostare in un appendix
// #code(caption: [Esempio di _vertex shader_])[
//   ```wgsl
//   struct Vertex {
//     @builtin(vertex_index) n_vertice: u32
//   }

//   struct Instance {
//     @location(0) color: vec4<f32>,
//     @location(1) pos: vec3<f32>,
//     @location(2) size: vec2<f32>,
//   }

//   struct VertexOutput {
//     @builtin(position) clip_position: vec4<f32>,
//     @location(0) color: vec3<f32>,
//   }

//   @vertex
//   fn vs_main(vert: Vertex, rect: Instance) -> VertexOutput {
//     var out: VertexOutput;
//     var size = rect.size * 2;

//     let vertices = array<vec2f, 6>(
//       vec2f(rect.pos.xy),                                     // a
//       vec2f(rect.pos.x + size.x, rect.pos.y),                 // b
//       vec2f(rect.pos.x, rect.pos.y + size.y),                 // c

//       vec2f(rect.pos.x + size.x, rect.pos.y),                 // b
//       vec2f(rect.pos.x + size.x, rect.pos.y + size.y),        // d
//       vec2f(rect.pos.x, rect.pos.y + size.y),                 // c
//     );

//     out.clip_position = vec4(vertices[vert.n_vertice], 0.0, 1.0);
//     out.clip_position *= 50;

//     out.color = rect.color.xyz;

//     return out;
//   }
//   ```
// ] <code:vertex-shader>

// === Tessellation

// La _tessellation_, anche conosciuta come _triangulation_,
// è una procedura che, dato una forma complessa, la trasforma in triangoli.

// == Pipeline compute

// La pipeline di compute è sostanzialmente un modo per
// eseguire calcoli arbitrari in maniera estremamente parallela.
