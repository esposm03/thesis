#import "/vis/rect-with-tris.typ": rect-with-tris
#import "/vis/sheets.typ": layer, sheet
#import "/common/variables.typ": equation, flex-caption

#pagebreak(to: "odd")

= Composizione <chap:composition>

L'obiettivo dello _stage_ era quello di aumentare
le prestazioni del _renderer_ mediante l'utilizzo della _GPU_.
Almeno nelle fasi iniziali si è preferito limitare
l'ambito al solo stadio di Composizione,
lasciando potenzialmente _performance_ non sfruttate,
ma riducendo anche il numero di cambiamenti
da fare a codice preesistente.

Inizialmente, avevamo previsto di applicare un approccio
ispirato a quelli adottati per il _rendering_ 3D,
con l'obiettivo migliorare l'efficienza;
successivamente, però, ci siamo accorti che questo miglioramento non era possibile
e abbiamo quindi cambiato approccio,
passando a una implementazione più semplice.

== Approccio iniziale: grafica 3D

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
e i cateti organizzati a forma rettangolare.
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
E proprio i tempi di attesa, combinati con i tempi di caricamento delle _texture_,
ha portato un grosso impatto sulle prestazioni:
// TODO: fare il benchmark tra N elementi per draw call con una texture,
// N elementi per draw call con N texture diverse,
// ed 1 elemento per draw call.

== Trasformazioni degli elementi mediante matrici

Come discusso precedentemente,
i requisiti del progetto includevano la possibilità
di applicare trasformazioni agli elementi
senza dover eseguire nuovamente le fasi di _layout_,
rasterizzazione e _layering_, in quanto relativamente costose.
Fortunatamente, tutte le trasformazioni richieste
sono facilmente implementabili con un po' di algebra lineare.

#set math.mat(delim: "[")
#set math.vec(delim: "[")

Ricordiamo che possiamo considerare ogni coordinata
del nostro spazio come un vettore colonna:
#equation(caption: [rappresentazione di coordinate come vettore colonna])[$ X = vec(x_c, y_c, z_c, w_c) $]

Ricordiamo, inoltre, che una matrice può essere interpretata come una
*trasformazione* da applicare a un vettore,
e che è possibile combinare più trasformazioni tra loro
moltiplicando la matrice della seconda trasformazione con quella della prima:

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
      a_(11), a_(12), a_(13), a_(14);
      a_(21), a_(22), a_(23), a_(24);
      a_(31), a_(32), a_(33), a_(34);
      a_(41), a_(42), a_(43), a_(44);
    )
    space.quad
    B = mat(
      b_(11), b_(12), b_(13), b_(14);
      b_(21), b_(22), b_(23), b_(24);
      b_(31), b_(32), b_(33), b_(34);
      b_(41), b_(42), b_(43), b_(44);
    )
  $

  $
    C = "BA" =
    mat(
      b_(11), b_(12), b_(13), b_(14);
      b_(21), b_(22), b_(23), b_(24);
      b_(31), b_(32), b_(33), b_(34);
      b_(41), b_(42), b_(43), b_(44);
    )
    dot
    mat(
      a_(11), a_(12), a_(13), a_(14);
      a_(21), a_(22), a_(23), a_(24);
      a_(31), a_(32), a_(33), a_(34);
      a_(41), a_(42), a_(43), a_(44);
    )
    =
    mat(
      c_(11), c_(12), c_(13), c_(14);
      c_(21), c_(22), c_(23), c_(24);
      c_(31), c_(32), c_(33), c_(34);
      c_(41), c_(42), c_(43), c_(44);
    )
  $
]

Successivamente, è possibile applicare la trasformazione ottenuta al vettore
semplicemente effettuando una moltiplicazione matrice-vettore:

#equation(caption: [Applicazione di una trasformazione ad un vettore])[$
    V' = "CV" =
    mat(
      c_(11), c_(12), c_(13), c_(14);
      c_(21), c_(22), c_(23), c_(24);
      c_(31), c_(32), c_(33), c_(34);
      c_(41), c_(42), c_(43), c_(44);
    )
    dot
    vec(x_c, y_c, z_c, w_c)
  $]

A questo punto, è semplicemente necessario definire
un insieme di matrici utili per effettuare le trasformazioni necessarie.
Segue una descrizione delle più importanti trasformazioni lineari,
ognuna con la matrice associata.

=== Trasformazione identità

La trasformazione di identità mappa ogni punto dello spazio a sé stesso:

#equation(caption: [Matrice per la trasformazione identità])[$
    I = mat(
      1, 0, 0, 0;
      0, 1, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
    )
  $]

=== Trasformazione di scala

La trasformazione di scala ingrandisce o rimpicciolisce gli elementi,
avvicinando o allontanando ogni punto all'origine:

#equation(caption: [Matrice per la trasformazione di scala])[$
    S = mat(
      s_x, 0, 0, 0;
      0, s_y, 0, 0;
      0, 0, s_z, 0;
      0, 0, 0, 1;
    )
  $]

Il quarto componente della diagonale della matrice è volutamente lasciato ad 1,
in quanto le trasformazioni che applichiamo non devono occuparsi della coordinata $w$.

=== Trasformazione di rotazione

La trasformazione di rotazione può essere implementata con la seguente matrice:

#equation(caption: [Matrice per la trasformazione di rotazione])[$
    R = mat(
      cos theta, sin theta, 0, 0;
      -sin theta, cos theta, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
    )
  $]

=== Trasformazione di traslazione

La trasformazione di traslazione può essere implementata con la seguente matrice:

#equation(caption: [Matrice per la trasformazione di traslazione])[$
    T = mat(
      1, 0, 0, t_x;
      0, 1, 0, t_y;
      0, 0, 1, t_z;
      0, 0, 0, 1;
    )
  $]

== Scorrimento all'interno di un elemento

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
