#import "/vis/vertex-buffer.typ": vertex-buffer
#import "/vis/clip-space.typ": clip-space
#import "/common/variables.typ": code

#pagebreak(to: "odd")

= Programmazione di GPU <chap:gpu-programming>

Le _GPU_ sono dispositivi estremamente potenti e flessibili.
Agiscono sostanzialmente come un acceleratore o un coprocessore,
che agisce in maniera asincrona rispetto al processore principale,
il quale si occupa solamente di inviare comandi alla GPU,
che poi li eseguirà in autonomia.
La natura asincrona è estremamente importante,
dato che le _GPU_ presentano una memoria separata da quella principale,
e i trasferimenti da una all'altra sono relativamente lenti.

Inizialmente, le _GPU_ contenevano solamente una _pipeline_
esplicitamente progettata per il rendering di grafica 3D,
con l'obiettivo di consentire giochi con grafica sempre più avanzata.
Con il tempo, di conseguenza, si sono trasformate in veri e propri processori altamente paralleli.
Negli ultimi anni i progettisti si sono accorti, però,
che potevano esporre questo parallelismo direttamente agli utenti,
consentendo l'utilizzo di _GPU_ anche per operazioni non strettamente di grafica.

Al giorno d'oggi, le _GPU_ sono importantissime in ambiti scientifici o di intelligenza artificiale,
grazie alle elevate prestazioni raggiungibili negli algoritmi avanzati necessari per questi campi,
oltre che alla grafica. Segue una breve descrizione delle due _pipeline_ di una _GPU_ moderna.

== Pipeline grafica

In passato, le _GPU_ esponevano delle interfacce _fixed-function_ (a funzione fissa),
senza possibilità di programmare il comportamento della _GPU_.
Con il tempo, hanno preso piede interfacce programmabili,
in cui l'utente crea dei piccoli programmi chiamati _shader_,
che la _GPU_ esegue per generare i pixel a schermo.

=== Vertex buffer

La prima fase del rendering è la creazione e il popolamento di un _vertex buffer_.
Esso è semplicemente un array di strutture definite dal programmatore,
solitamente contenenti almeno un set di coordinate del vertice da disegnare.
Ogni vertice che si vuole disegnare sarà rappresentato da un elemento del _vertex buffer_.

Perché le _vertex shader_ (trattate in @chap:gpu-programming:vertex-shaderb)
riescano a interpretare questo buffer, tuttavia,
l'applicazione deve informare la _GPU_ di come le strutture al suo interno sono organizzate.

Supponiamo, per esempio, di voler definire una _vertex shader_
capace di creare dei rettangoli colorati a schermo.
Essa avrà bisogno dei seguenti input:
- Il *colore* con cui vogliamo rappresentare il rettangolo. Decidiamo di passarlo in rappresentazione RGB
  (ossia tre canali, rosso, verde e blu, ognuno salvato all'interno di un byte).
- La *posizione* nello spazio tridimensionale, rappresentata con
  tre interi con segno, ognuno da 1 byte;
- La *dimensione* del rettangolo, rappresentata con due interi con segno, sempre di 4 byte ciascuno.

Potremmo decidere, quindi, di organizzare il _buffer_ nella maniera seguente:

#figure(vertex-buffer, caption: [Possibile organizzazione di un vertex buffer])

Dove le celle viola contengono il colore del vertice
(_RGBA_ sta per _red_, _green_, _blue_, _alpha_),
le celle rosse contengono la sua posizione
(le tre assi _X_, _Y_, _Z_),
e le celle verdi la sua dimensione
(_W_ sta per _width_, mentre _H_ sta per _height_).
Notare che sono state inserite delle celle vuote (di "_padding_"),
per garantire l'allineamento del campo dimensione a 2 byte.

Per rendere questo buffer comprensibile alla _GPU_,
dobbiamo fornirgli il seguente oggetto, per descriverne il layout.
I campi sono i seguenti:
- `attributes`: un array di oggetti che descrivono gli attributi del _vertex buffer_.
  Ogni attributo viene descritto da:
  - `format`, che indica il tipo di dato (`sint8`, `uint8`),
    opzionalmente insieme a un numero di canali,
  - `offset`, ossia la distanza tra il primo byte del vertice e il primo byte dell'attributo;
  - `shaderLocation`, ossia quale "slot" la shader potrà utilizzare per accedere al valore.
- `arrayStride`: indica la dimensione di un singolo vertice.
  Notare che non è obbligatoriamente uguale alla somma delle dimensioni dei singoli attributi,
  per esempio se si decide di inserire byte di _padding_.
- `stepMode`: può avere come valori `"vertex"` (il default) oppure `"instance"`.
  Definisce se l'indice del buffer deve essere incrementato una volta per ogni vertice,
  oppure una volta per ogni oggetto nella scena
  (mantenendo quindi lo stesso indice per tutti i vertici dello stesso oggetto).
  Dato che noi dobbiamo disegnare quattro vertici a partire dallo stesso input,
  imposteremo `'instance'` come `stepMode`; il default è `'vertex'`,

#code(caption: [Esempio di un descrittore del layout di un _vertex buffer_])[
  ```js
  {
    attributes: [
      { format: 'unorm8x4', offset: 0, shaderLocation: 0 }, // colore
      { format: 'snorm8x4', offset: 4, shaderLocation: 1 }, // posizione
      { format: 'snorm8x2', offset: 8, shaderLocation: 2 }, // dimensione
    ];
    arrayStride: 10;
    stepMode: 'instance';
  }
  ```
] <code:vertex-buffer-layout>

=== Vertex shader <chap:gpu-programming:vertex-shaderb>

Una volta definito il vertex buffer, è necessario scrivere una
_vertex shader_ capace di lavorare con questo buffer.
Una _shader_ è un piccolo programma, solitamente definito in un linguaggio apposito,
che la _GPU_ esegue tante volte durante la sua _pipeline_ grafica.
Le _vertex shader_ sono uno dei due tipi principali di _shader_,
dove l'altro è le _fragment shader_ (di cui discuteremo in @chap:gpu-programming:fragment-shader).

Le shader, in _WebGPU_, sono definite in un linguaggio apposito,
chiamato _WGSL_ (_WebGPU Shading Language_).
Per definire una vertex shader è sufficiente passare a _WebGPU_ il @code:vertex-shader-noop:
esso definisce una semplice funzione, chiamata `vs_main`,
che ritorna un valore di tipo `vec4<f32>`.
La funzione è annotata con l'attributo `@vertex`,
mentre il suo valore di ritorno è annotato con `@builtin(position)`.
All'interno del corpo della funzione, prima viene creata una costante
(`let` definisce una variabile non modificabile) con nome `out` e tipo `vec4<f32>`,
a cui viene assegnato un vettore contenente quattro volte 1.
Successivamente, il valore della variabile `out` viene ritornato.

#code(caption: [La più piccola _vertex shader_ valida], placement: bottom)[
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
- `array<E>`: un array con dimensione determinata a runtime, ed elementi di tipo `E`;
- `array<E, N>`: un array con dimensione `N`, ed elementi di tipo `E`;
- `struct Nome { field1: type1, field2: type2, ... }`, una struttura.

Gli argomenti di una funzione marcata `@vertex` possono essere tipi scalari o strutture;
se scalari, ognuno deve essere marcato con un attributo `@builtin` oppure con un attributo `@location`;
se strutture, la stessa cosa si applica a ognuno dei campi della stessa.
Questi due attributi specificano da dove la _GPU_ deve recuperare i valori.
`@builtin` indica uno tra vari significati "predefiniti" che un attributo può avere.
Per gli attributi specificati dall'utente, `@location` indica l'ordine in cui essi vengono passati alla shader.

==== Clip space coordinates

Una considerazione interessante da fare è notare che il tipo di ritorno della shader in @code:vertex-shader-noop
è un vettore con quattro componenti, nonostante si stia facendo rendering in tre dimensioni.
Questo è perché si assume che le _vertex shader_ ritornino vertici con coordinate espresse in *clip-space*.
In particolare, le coordinate in _clip-space_ sono espresse come un vettore a quattro componenti

$ vec(x_c, y_c, z_c, w_c) $

dove $x_c$, $y_c$ e $z_c$ definiscono una posizione nello spazio,
mentre $w_c$ definisce la dimensione di un cubo, chiamato _clip volume_,
in cui tutti i vertici devono essere contenuti per evitare che la _GPU_ li scarti.

#figure(clip-space, caption: [Esempio di clip space]) <grafico:clip-space>

L'utilità di questo _clip-space_ è semplicemente di consentire alla _GPU_
di implementare il _clipping_ in maniera efficiente,
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

=== Clipping e rasterizzazione

// TODO: spostare in un appendix
#code(caption: [Esempio di _vertex shader_])[
  ```wgsl
  struct Vertex {
    @builtin(vertex_index) n_vertice: u32
  }

  struct Instance {
    @location(0) color: vec4<f32>,
    @location(1) pos: vec3<f32>,
    @location(2) size: vec2<f32>,
  }

  struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec3<f32>,
  }

  @vertex
  fn vs_main(vert: Vertex, rect: Instance) -> VertexOutput {
    var out: VertexOutput;
    var size = rect.size * 2;

    let vertices = array<vec2f, 6>(
      vec2f(rect.pos.xy),                                     // a
      vec2f(rect.pos.x + size.x, rect.pos.y),                 // b
      vec2f(rect.pos.x, rect.pos.y + size.y),                 // c

      vec2f(rect.pos.x + size.x, rect.pos.y),                 // b
      vec2f(rect.pos.x + size.x, rect.pos.y + size.y),        // d
      vec2f(rect.pos.x, rect.pos.y + size.y),                 // c
    );

    out.clip_position = vec4(vertices[vert.n_vertice], 0.0, 1.0);
    out.clip_position *= 50;

    out.color = rect.color.xyz;

    return out;
  }
  ```
] <code:vertex-shader>

=== Fragment shader <chap:gpu-programming:fragment-shader>

=== Tessellation

La _tessellation_, anche conosciuta come _triangulation_,
è una procedura che, dato una forma complessa, la trasforma in triangoli.

== Pipeline compute

La pipeline di compute è sostanzialmente un modo per
eseguire calcoli arbitrari in maniera estremamente parallela.
