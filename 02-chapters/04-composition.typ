#import "/vis/sheets.typ": layer, sheet
#import "/vis/rotazione.typ": rotazione
#import "/vis/rect-with-tris.typ": rect-with-tris
#import "/vis/rototraslazione.typ": rototraslazione
#import "/common/variables.typ": chart, code, equation, flex-caption, my_point

#pagebreak(to: "odd")

= Composizione in GPU <chap:composition>

L'obiettivo dello _stage_ era quello di aumentare
le prestazioni del _renderer_ mediante l'utilizzo della _GPU_.
Almeno nelle fasi iniziali si è preferito limitare
l'ambito al solo stadio di Composizione,
lasciando potenzialmente _performance_ non sfruttate,
ma riducendo anche il numero di cambiamenti
da fare a codice preesistente.

Inizialmente, avevamo previsto di applicare un approccio
ispirato a quelli adottati per il _rendering_ 3D,
con l'obiettivo di migliorare l'efficienza;
successivamente, però, ci siamo accorti che questo miglioramento non era possibile
e abbiamo quindi cambiato approccio,
passando a una implementazione più semplice.

== Approccio iniziale: grafica 3D <chap:composition:approccio-3d>

Le _GPU_ sono state progettate per la grafica 3D,
e utilizzarle per produrre grafica 2D non è,
strettamente parlando, ciò per cui sono state inizialmente realizzate.
Abbiamo quindi, almeno inizialmente,
pensato di produrre una scena tridimensionale
che rappresentasse una specie di "pila" di _layer_,
in modo da successivamente implementare una "telecamera"
che riprendesse la scena dall'alto in proiezione ortografica,
producendo il risultato desiderato.
Un sistema simile a quello che stavamo implementando è mostrato in @grafico:composizione.

Per fare questo, avevamo scritto del codice che calcolava,
per ogni _layer_, la dimensione e la posizione;
questa informazione veniva inserita all'interno di un _vertex buffer_,
e una _vertex shader_ estremamente semplice successivamente
produceva i quattro vertici di ogni rettangolo.
Ogni rettangolo viene rappresentato con una coppia di triangoli rettangoli,
disposti in modo da avere le ipotenuse coincidenti,
e i cateti paralleli a uno dei due assi $X$ o $Y$.
Inoltre, abbiamo deciso di organizzare i vertici in maniera antioraria,
dato che _WebGPU_ usa il senso di rotazione per determinare
quale tra le due facce di un triangolo è visibile.
Un esempio di questa rappresentazione si può trovare in @grafico:trianoglizzazione-rettangolo.

#figure(rect-with-tris, caption: [Triangolizzazione di un rettangolo, con vertici in senso antiorario]) <grafico:trianoglizzazione-rettangolo>

Lo svantaggio di questo approccio è diventato evidente, però,
quando abbiamo provato a mostrare delle immagini all'interno di questi _layer_.
Infatti, in _WebGPU_,
non è per ora possibile associare un _array_ di _texture_
come variabile di ingresso per una _shader_.
Se fosse stato possibile, avremmo potuto disegnare tutti i _layer_
nello stesso comando per la _GPU_, utilizzando l'asse $Z$
per codificare l'ordine degli elementi.

#let graphic = {
  sheet(..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red))
  sheet(..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red), is-3d: false)
}
#figure(graphic, caption: [Esempio di composizione di layer (colorati) sullo schermo]) <grafico:composizione>

== Approccio semplificato

Nella sezione precedente abbiamo discusso di come
ci risultasse impossibile fornire un numero dinamico di _texture_
alla stessa _draw call_;
di conseguenza, è risultato necessario eseguire una _draw call_ per ogni _layer_.

Questo si è rivelato essere notevolmente più lento,
in quanto per ogni _layer_ è necessario,
prima di effettuare ogni _draw call_,
attendere che quella precedente sia terminata.

Il vantaggio, ovviamente, è che non è più necessario calcolare la coordinata $Z$,
ma risulta sufficiente effettuare le _draw call_ in maniera ordinata.

== Trasformazioni degli elementi mediante matrici

Come discusso precedentemente,
i requisiti del progetto includevano la possibilità
di applicare trasformazioni agli elementi
senza dover eseguire nuovamente le fasi di _layout_,
rasterizzazione e _layering_, in quanto relativamente costose.

Le trasformazioni richieste sono:
- Traslazione, ovvero spostamento di un elemento in una posizione diversa;
- Rotazione, ovvero rotazione di un elemento attorno a un asse
  (nel nostro caso solamente l'asse $Z$, essendo il nostro spazio "utile" bidimensionale);
- Scala, ovvero ingrandimento o rimpicciolimento di un elemento.

Le trasformazioni di rotazione e scala sono trasformazioni lineari,
ossia trasformazioni che possono essere rappresentate mediante una matrice.

=== Trasformazioni lineari

Consideriamo il segmento bidimensionale $overline("AB")$, presente in @grafico:rotazione.
Se esso viene ruotato di 90 gradi attorno all'origine in senso orario,
allora il punto $A$ si sposterà in $A'$,
e il punto $B$ si sposterà in $B'$.
La trasformazione che ha portato da $A$ a $A'$ e da $B$ a $B'$
può essere espressa mediante una matrice, che chiameremo
$R_theta$, che ha come effetto quello di ruotare i punti
di $theta$ gradi attorno all'origine.

#import "@preview/cetz:0.4.0"
#figure(caption: [Esempio di rotazione di un segmento attorno all'origine], rotazione) <grafico:rotazione>

La matrice di rotazione in senso antiorario $R_theta$
è definita come segue, dove $theta$ è l'angolo di rotazione:

#equation(caption: [Matrice di rotazione di $theta$ gradi in senso antiorario])[$
    R_theta = mat(
      cos theta, - sin theta;
      sin theta, cos theta;
    )
  $]

Se esprimiamo i punti $A$ e $B$ come vettori colonna,
possiamo allora effettuare una moltiplicazione matrice-vettore
per ottenere i punti trasformati $A'$ e $B'$:

$
  A = vec(1, 1)
  space.quad
  B = vec(1, 3)
$

$
  A' = R_(-90°) dot A = mat(0, 1; -1, 0) dot vec(1, 1) = vec(1, -1)
$

$
  B' = R_(-90°) dot B = mat(0, 1; -1, 0) dot vec(1, 3) = vec(3, -1)
$

Questo tipo di trasformazione, ottenibile mediante un prodotto matrice-vettore,
è chiamata trasformazione lineare.

=== Trasformazioni affini

Mediante trasformazione lineare non è possibile effettuare
traslazioni, ossia spostamenti di un elemento in una posizione diversa.
Questo è dovuto al fatto che le trasformazioni lineari
sono, alla fine dei conti, delle moltiplicazioni;
se applichiamo una trasformazione lineare al vettore nullo che rappresenta l'origine,
otterremo ancora l'origine, dato che ogni numero moltiplicato per zero è zero.

Per poter effettuare anche le traslazioni,
è necessario estendere il concetto di trasformazione lineare
a quello di trasformazione affine.
Una trasformazione affine è una trasformazione ottenuta
sommando un vettore al risultato di una trasformazione lineare.
In @grafico:rototraslazione è presente un esempio di una
trasformazione affine, la rototraslazione.

#figure(
  caption: [Esempio di rototraslazione, ossia rotazione seguita da traslazione],
  rototraslazione,
) <grafico:rototraslazione>

La rototraslazione in @grafico:rototraslazione
è rappresentata dalla matrice di rotazione definita precedentemente,
seguita da una traslazione, come si vede in @eq:matrice-rototraslazione.

#equation(caption: [Esempio di applicazione della rototraslazione], [
  $
    R_(-90°) = mat(0, 1; -1, 0)
    quad
    quad
    t = vec(5, 3)
  $

  $
    A'' = A' + t = A dot R_(-90°) + t =
    mat(0, 1; -1, 0) dot vec(1, 1) + vec(5, 3) = vec(6, 2)
  $

  $
    B'' = B' + t = B dot R_(-90°) + t =
    mat(0, 1; -1, 0) dot vec(1, 3) + vec(5, 3) = vec(8, 2)
  $
]) <eq:matrice-rototraslazione>

=== Combinazione di trasformazioni

È possibile combinare più trasformazioni lineari insieme
per ottenerne una più complessa.
Questo è possibile effettuando un prodotto matrice-matrice,
dove la matrice destra è la rappresentazione della prima trasformazione,
e la matrice sinistra è la rappresentazione della seconda trasformazione.

Supponiamo, per esempio, di voler effettuare una trasformazione di rotazione,
seguita da una trasformazione di scala.
Oltre a poter applicare le due trasformazioni in sequenza
(quindi moltiplicare la coordinata prima con la matrice di rotazione, e poi con quella di scala),
è possibile moltiplicare le due matrici assieme,
ottenendo così una singola matrice che rappresenta entrambe le trasformazioni in un passo soltanto.

#equation(caption: flex-caption[
  #h(0pt, weak: true)
  Combinazione di trasformazioni mediante proprietà associativa.
  Applicare la trasformazione $C$ è equivalente ad applicare in sequenza $A$ e $B$.
][
  #h(0pt, weak: true)
  Combinazione di trasformazioni mediante proprietà associativa
])[
  $
    A = mat(
      a_(11), a_(12);
      a_(21), a_(22);
    )
    space.quad
    B = mat(
      b_(11), b_(12);
      b_(21), b_(22);
    )
    space.quad
    v = vec(v_x, v_y)
  $

  $
    B A v = (B A) v =
    (
      mat(
        b_(11), b_(12);
        b_(21), b_(22);
      )
      dot
      mat(
        a_(11), a_(12);
        a_(21), a_(22);
      )
    )
    dot
    v
  $
] <eq:combinazione-trasformazioni>

Ciò che si vede in @eq:combinazione-trasformazioni è possibile
perché il prodotto tra matrici gode della proprietà associativa,
che permette di raggruppare le operazioni in modo arbitrario
senza che il risultato cambi.

=== Trasformazioni nello spazio tridimensionale

Desideriamo ora estendere le trasformazioni elencate precedentemente
in modo da poterle applicare anche nello spazio tridimensionale.
È sufficiente, per questo, aggiungere un terzo componente ai vettori che rappresentano le coordinate,
e definire nuove matrici che abbiano dimensione $3 times 3$, al posto di $2 times 2$.

Come discusso in @chap:gpu-programming:clip-space, però,
le _GPU_ utilizzano uno spazio quadridimensionale
per rappresentare le coordinate dei vertici.
Questo ci è utile, in quanto possiamo sfruttare un trucco
per poter trasformare la traslazione tridimensionale (che, ricordiamo, non è lineare),
in una trasformazione lineare quadridimensionale con effetto simile.

=== Matrici di trasformazione

Segue una lista delle più importanti matrici di trasformazione.

==== Trasformazione identità

La trasformazione di identità mappa ogni punto dello spazio a sé stesso.
È rappresentata dalla matrice identità, mostrata in @eq:matrice-identita @geometria-analitica.

#equation(caption: [Matrice per la trasformazione identità])[$
    I = mat(
      1, 0, 0, 0;
      0, 1, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
    )
  $] <eq:matrice-identita>

==== Trasformazione di scala

La trasformazione di scala ingrandisce o rimpicciolisce gli elementi,
avvicinando o allontanando ogni punto all'origine.
Può essere implementata con la matrice in @eq:matrice-scala @geometria-analitica.

#equation(caption: [Matrice per la trasformazione di scala])[$
    S = mat(
      s_x, 0, 0, 0;
      0, s_y, 0, 0;
      0, 0, s_z, 0;
      0, 0, 0, 1;
    )
  $] <eq:matrice-scala>

Il quarto componente della diagonale della matrice è volutamente lasciato ad 1,
in quanto le trasformazioni che applichiamo non devono occuparsi della coordinata $w$.

==== Trasformazione di rotazione attorno all'asse Z

La trasformazione di rotazione attorno all'asse $Z$ può essere implementata
con la matrice mostrata in @eq:matrice-rotazione, dove $theta$
rappresenta l'angolo di rotazione espresso in radianti @geometria-analitica.

#equation(caption: [Matrice per la trasformazione di rotazione])[$
    R = mat(
      cos theta, sin theta, 0, 0;
      -sin theta, cos theta, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
    )
  $] <eq:matrice-rotazione>

==== Trasformazione di traslazione

La trasformazione di traslazione può essere implementata con la matrice in @eq:matrice-traslazione,
dove $t_x, t_y, t_z$ rappresentano la quantità di cui traslare su ogni asse @geometria-analitica.

#equation(caption: [Matrice per la trasformazione di traslazione])[$
    T = mat(
      1, 0, 0, t_x;
      0, 1, 0, t_y;
      0, 0, 1, t_z;
      0, 0, 0, 1;
    )
  $] <eq:matrice-traslazione>

== Scorrimento all'interno di un elemento

Oltre ad avere trasformazioni di tutto l'elemento,
è necessario fornire a un elemento la possibilità di "scorrere".
Pensiamo, per esempio, a un componente che rappresenti
una lista potenzialmente molto grande di elementi.
Sarà necessario che questo componente abbia una dimensione fissa,
in modo da poterlo inserire a schermo in una posizione determinata,
però gli elementi al suo interno devono scorrere con esso.

Questa trasformazione, non è combinabile con le trasformazioni elencate precedentemente,
in quanto non desideriamo spostare i vertici di un elemento ma la texture all'interno dello stesso.
Il principio generale resta comunque lo stesso,
ossia fornire alla _vertex shader_ una matrice
che lei applicherà alle coordinate della _texture_.
In questo caso, abbiamo optato di utilizzare una trasformazione affine,
dato che le coordinate della _texture_ sono bidimensionali.

Un esempio di una _vertex shader_ che implementa questa trasformazione
è mostrato in @code:vertex-shader-scorrimento.

#code(caption: [_vertex shader_ che applica uno scorrimento alle coordinate della _texture_])[
  ```wgsl
  @vertex
  fn vs_main(
      model: VertexInput,
      instance: InstanceInput,
  ) -> VertexOutput {
      let model_matrix = mat4x4<f32>(
          instance.model_matrix_0,
          instance.model_matrix_1,
          instance.model_matrix_2,
          instance.model_matrix_3,
      );
      var out: VertexOutput;
      out.tex_coords = model.tex_coords + instance.view_origin;
      out.clip_position = model_matrix * vec4<f32>(model.position, 1.0);
      return out;
  }
  ```] <code:vertex-shader-scorrimento>

== Codice finale della shader

```wgsl
struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) tex_coords: vec2<f32>,
}
struct InstanceInput {
    @location(2) view_origin: vec2<f32>,
    @location(3) view_size: vec2<f32>,
    @location(4) model_matrix_0: vec4<f32>,
    @location(5) model_matrix_1: vec4<f32>,
    @location(6) model_matrix_2: vec4<f32>,
    @location(7) model_matrix_3: vec4<f32>,
}
struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) tex_coords: vec2<f32>,
}

@vertex
fn vs_main(vert: VertexInput, inst: InstanceInput) -> VertexOutput {
    let model_matrix = mat4x4<f32>(
        inst.model_matrix_0,
        inst.model_matrix_1,
        inst.model_matrix_2,
        inst.model_matrix_3,
    );
    var out: VertexOutput;
    out.tex_coords = vert.tex_coords * inst.view_size + inst.view_origin;
    out.clip_position = model_matrix * vec4<f32>(vert.position, 1.0);
    return out;
}

@group(0) @binding(0) var texture: texture_2d<f32>;
@group(0) @binding(1) var texture_sampler: sampler;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
  return textureSample(
    texture,
    texture_sampler,
    in.tex_coords
  );
}
```
