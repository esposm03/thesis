#import "@preview/cetz:0.4.0"
#import "@preview/touying:0.6.1": *
#import themes.stargazer: *

#import "/vis/sheets.typ": layer, sheet
#import "/vis/clip-space.typ": clip-space
#import "/vis/vertex-buffer.typ": instance-buffer

#set text(font: "Roboto")

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Ottimizzazione di un renderer 2D mediante GPU],
    author: [Samuele Esposito],
    date: datetime(
      year: 2025,
      month: 07,
      day: 22,
    ),
    institution: [Università degli Studi di Padova],
  ),
)

#title-slide()

= Introduzione

#slide(title: "L'azienda: UNOX S.p.A.")[
  UNOX produce forni per gastronomie, ristorazione, centri cottura...

  Multinazionale di Cadoneghe (PD),
  vanta più di 1300 dipendenti,
  e 42 filiali estere.
][
  #image("images/unox.jpg")
]

#slide(title: [Il sistema operativo Digital.ID#sym.trademark])[
  #grid(columns: 2, inset: (top: 1.5em), gutter: 1em)[
    #image("images/digital.id.jpg")
  ][
    I forni di fascia più alta includono un sistema operativo _smart_,
    denominato Digital.ID#sym.trademark,
    realizzato in React Native.

    L'azienda desidera però ridurre i costi per l'hardware,
    ma il sistema precedente era troppo lento;
    da qui è nata l'idea di creare una soluzione _in house_.

    Questa soluzione è tutt'ora in sviluppo, realizzata in Rust.
  ]
]

// = Architettura del renderer
//
// #slide(title: "Architettura del renderer")[
//   È stata presa l'architettura dei moderni browser come riferimento.
//
//   `AppUI::render_loop()` veniva chiamato una volta per ogni _frame_
// ]
//
// #slide(title: "Gestione dello stato condiviso tra più stadi")[
//   Esistono alcuni dati che devono essere accessibili da più stadi.
//   Per esempio:
//   - albero degli elementi;
//   #pause
//   - dimensione e posizione degli elementi;
//   #pause
//   - area dello schermo "danneggiata", che deve essere ridisegnata;
//   #pause
//   - buffer vari;
//   #pause
//   - ed altri.
//
//   #pause
//
//   Questi dati sono salvati in una struttura chiamata `Dom`.
// ]
//
// #slide(title: "Stadio di Layout", composer: grid.with(columns: 2, gutter: 1em))[
//   Si occupa di calcolare la posizione degli elementi,
//   data una descrizione "human-friendly" di essi.
//
//   #pause
//
//   ```html
//   <div id="p1">
//     <div id="p2">Hello world!</div>
//   </div>
//   <div id="p3"></div>
//   ```
//
//   ```css
//   #p1 { margin: 10px; padding-top: 20px; }
//   #p2 { width: 100px; height: 200px; margin: 10px; }
//   #p3 { width: 200px; }
//   ```
//
//   #uncover("4-")[
//     È stata implementata sfruttando la libreria `taffy`,
//     utilizzata anche da Servo.
//   ]
// ][
//   #uncover("3-", cetz.canvas({
//     import cetz.draw: *
//     scale(x: 0.03, y: -0.03)
//
//     let rel(anchor, x, y) = (rel: (x, y), to: anchor)
//     let size(x, y) = (rel: (x, y))
//
//     anchor("p1", (10, 10))
//
//     rect((0, 0), (250, 350), stroke: 0.3pt)
//
//     rect("p1", size(120, 230))
//     rect(rel("p1", 10, 20), size(100, 200), name: "p2")
//     rect((0, 240), (rel: (200, 50)))
//   }))
// ]
//
// #slide(title: "Stadio di Raster")[
//   Si occupa di disegnare a schermo una figura a partire da una sua descrizione.
//
//   #grid(columns: (23em, 1fr), gutter: 1em)[
//     ```rust
//       let paint1 = Paint::solid("#327f96c8");
//       let paint2 = Paint::solid("#dc8c4bb4");
//
//       let path1 = PathBuilder::new()
//         .move_to(60.0, 60.0).line_to(160.0, 940.0)
//         .line_to(940.0, 800.0).line_to(60.0, 60.0)
//         .close().fill(paint1);
//       let path2 = PathBuilder::new()
//         .move_to(940.0, 60.0).line_to(840.0, 940.0)
//         .line_to(60.0, 800.0).line_to(940.0, 60.0)
//         .close().fill(paint2);
//     ```][
//     #image("images/raster.png")
//   ]
// ]
//
// #slide(title: "Stadio di Layer")[
//   Si occupa di comporre assieme più elementi,
//   appartenenti allo stesso layer,
//   per formare un'unica immagine finale.
//
//   #show: align.with(center)
//   #cetz.canvas({
//     let typst-rect = rect
//     import cetz.draw: *
//     scale(y: -100%)
//
//     // 1st image
//     rect((0, 0), (rel: (3, 2)), fill: aqua, name: "background")
//
//     // 2nd image
//     content((5.5, 1), typst-rect[Start], name: "text")
//
//     // 3rd image
//     let transparent = rgb("#0000")
//     let black = rgb("#0008")
//     let shadow = ((transparent, 0%), (transparent, 90%), (black, 100%))
//     rect((8, 0), (rel: (3, 2)), fill: gradient.linear(..shadow), name: "gradient")
//     rect((8, 0), (rel: (3, 2)), fill: gradient.linear(angle: 90deg, ..shadow))
//
//     // Layered image
//     rect((13, 0), (rel: (3, 2)), fill: aqua, name: "result")
//     content("result", [Start])
//     rect((13, 0), (rel: (3, 2)), fill: gradient.linear(..shadow))
//     rect((13, 0), (rel: (3, 2)), fill: gradient.linear(angle: 90deg, ..shadow))
//
//     // Arithmethic symbols
//     hide(line("background", "text", name: "line1"))
//     content("line1", $+$)
//     hide(line("text", "gradient", name: "line2"))
//     content("line2", $+$)
//     hide(line("gradient", "result", name: "line3"))
//     content("line3", $=$)
//   })
// ]
//
// #slide(title: "Stadio di Composizione")[
//   Simile allo stadio di Layer,
//   si occupa di comporre assieme più Layer per produrre un'immagine finale.
//
//   #align(center, cetz.canvas({
//     import cetz.draw: *
//
//     let button(x, y, text, name: "") = {
//       let transparent = rgb("#0000")
//       let black = rgb("#0008")
//       let shadow = ((transparent, 0%), (transparent, 90%), (black, 100%))
//
//       rect((x, y), (rel: (3, 2)), fill: aqua, name: name)
//       content(name, text)
//       rect((x, y), (rel: (3, 2)), fill: gradient.linear(..shadow))
//       rect((x, y), (rel: (3, 2)), fill: gradient.linear(angle: 90deg, ..shadow))
//     }
//
//     button(0, 0, "Start", name: "start")
//     button(5, 0, "Stop", name: "stop")
//     rect((10, -2), (rel: (4, 5.5)), fill: orange, name: "background")
//
//     rect((17, -2), (rel: (4, 5.5)), fill: orange, name: "result")
//     button(17.5, 1, "Start")
//     button(17.5, -1.5, "Stop")
//
//     hide(line("start", "stop", name: "line1"))
//     content("line1", $+$)
//     hide(line("stop", "background", name: "line2"))
//     content("line2", $+$)
//     hide(line("background", "result", name: "line3"))
//     content("line3", $=$)
//   }))
// ]
//
// #slide(title: "Differenza tra Layering e Composizione")[
//   Durante la fase di Layering si compongono elementi,
//   durante la fase di composizione si compongono layer.
//   Perché questa distinzione?
//
//   #pause
//
//   Consente di implementare trasformazioni (traslazione, scala, ecc.)
//   senza dover ri-comporre più elementi che vengono trasformati assieme.
//
//   #pause
//
//   Ovviamente, ha lo svantaggio che il reraster di un componente è rallentato.
// ]

= Programmazione di GPU

#slide(title: "Introduzione alle GPU")[
  Le GPU (Graphical Processing Unit) sono coprocessori capaci di lavorare in maniera altamente parallela.

  #pause

  Al giorno d'oggi, presentano due _pipeline_ differenti, per due scopi differenti:
  - compute pipeline --- non verrà trattata oggi.
  - graphics pipeline.

  #pause

  Per accedere alla _GPU_ si possono utilizzare diverse _API_
  --- alcuni esempi sono OpenGL, Vulkan o DirectX. \
  Durante il progetto, abbiamo deciso di utilizzare _WebGPU_.
]

#slide(title: "Pipeline grafica")[
  L'elaborazione si divide in più fasi, eseguite in maniera sequenziale:

  - configurazione della pipeline (eseguita all'esterno della GPU);
  - esecuzione della _vertex shader_;
  - _primitive assembly_ e _clipping_;
  - rasterizzazione;
  - esecuzione della _fragment shader_.
]

#slide(title: "Configurazione della pipeline")[
  Oltre a caricare e compilare le _shader_,
  è necessario definire gli input della _vertex shader_
  e gli output della _fragment shader_.

  L'input principale delle _vertex shader_ è un _vertex buffer_,
  ossia un _array_ di input arbitrari,
  che la _vertex shader_ riceverà come input.

  #text(size: 16pt, instance-buffer)
]

#slide(title: "Vertex shader", composer: grid.with(columns: (16em, 1fr), gutter: 0.5em))[
  Le _vertex shader_ si occupano di generare i vertici.
  Possono essere utilizzate anche per modificarli.

  #uncover("2-")[
    In _WebGPU_ le _shader_ sono definite in un linguaggio
    appositamente sviluppato, chiamato _WGSL_.
  ]
][```wgsl
  @vertex
  fn vert_main(
    @builtin(vertex_index) vertexIndex : u32
  ) -> @builtin(position) vec4<f32> {
    let pos = array(
      vec2f(0, 0), vec2f(1, 0), vec2f(0, 1),
      vec2f(0, 1), vec2f(1, 0), vec2f(1, 1),
    );

    return vec4f(pos[vertexIndex], 1, 1);
  }
  ```]

#slide(title: "Clipping e Rasterizzazione ", composer: grid.with(columns: (14em, 1fr), gutter: 1em))[
  #image("/images/rasterization.png")
][
  Successivamente, viene eseguita una serie di fasi _fixed function_.

  La prima è il Clipping, in cui le primitive non visibili vengono rimosse.

  Successivamente avviene la rasterizzazione,
  in cui viene generato un _fragment_
  per ogni pixel coperto dalla primitiva.
]

#slide(title: "Il Clip Space", composer: grid.with(gutter: 1em, columns: (10em, 1fr)))[
  #scale(200%, pad(left: 15%, clip-space))
][
  Il clipping viene effettuato coordinate omogenee,
  un concetto derivato dalla geometria proiettiva.

  Tutte le coordinate (tridimensionali) vengono estese con un quarto componente, $w$.
  Viene definito un cubo, chiamato "clip volume", la cui dimensione dipende da $w$.
  Tutte le coordinate all'esterno di esso vengono considerate "invisibili".
]

#slide(title: "Fragment shader")[
  Si occupano di calcolare il colore di un _fragment_ che ricevono in ingresso.

  #pause

  I valori di un _fragment_ sono calcolati mediante interpolazione,
  usando le coordinate baricentriche del punto come coefficienti.

  #grid(columns: 2, gutter: -0.1em)[
    $"Posizione:" P = A dot t_A + B dot t_B + C dot t_C$

    #let color = $"color"$
    $"Colore:" color(P) = color(A) dot t_A + color(B) dot t_B + color(C) dot t_C$
  ][
    #cetz.canvas({
      import cetz.draw: *

      anchor("a", (0, 0))
      content((rel: (-0.3, -0.2)))[A]
      anchor("b", (4, 6))
      content((rel: (+0.0, +0.4)))[B]
      anchor("c", (6, 2))
      content((rel: (+0.3, -0.2)))[C]

      line("a", "b", "c", close: true)

      circle((bary: (a: 0.3, b: 0.2, c: 0.5)), radius: 0.2, fill: aqua, name: "p")
      content((rel: (-0.5, 0.4)), [P])

      line("a", "p", name: "ap", stroke: blue)
      line("b", "p", name: "bp", stroke: blue)
      line("c", "p", name: "cp", stroke: blue)

      content((rel: (-0.1, 0.4), to: "ap"), text(size: 15pt, $t_A$))
      content((rel: (-0.5, 0), to: "bp"), text(size: 15pt, $t_B$))
      content((rel: (0, 0.3), to: "cp"), text(size: 15pt, $t_C$))
    })
  ]
]

#slide(title: "Utilizzo di texture nelle fragment shader")[
  Come si possono creare i _vertex buffer_, si possono anche creare _texture buffer_.

  #pause

  Esse però possono solo essere lette mediante un _sampler_ il quale applica interpolazione tra i pixel più vicini.
][
  ```wgsl
  var ourSampler: sampler;
  var ourTexture: texture_2d<f32>;

  @fragment fn fs_main(
    @location(0) texcoord: vec2<f32>,
  ) -> @location(0) vec4f
  {
    return textureSample(
      ourTexture,
      ourSampler,
      texcoord,
    );
  }
  ```
]

= Lavoro svolto

#slide(title: "Composizione in GPU")[
  L'idea del progetto era effettuare solamente la composizione in GPU.

  #uncover(2)[
    Purtroppo, fare così ha lasciato potenziali prestazioni non sfruttate,
    riducendo però la quantità di codice da modificare.
  ]
][
  #sheet(is-3d: false, ..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red))
]

#slide(title: "L'approccio")[
  #show: pad.with(left: -6%)
  #sheet(is-3d: true, ..layer((0.5, 0.5), (5, 5), z: 1), ..layer((4, 4), (3, 4), z: 2, fill: red))
][
  Abbiamo scelto un approccio di grafica 3D:
  - Ogni layer è un rettangolo;
  - Una telecamera osserva la scena dall'alto;
  - L'altezza dei rettangoli, quindi, determina l'ordine in cui vengono mostrati a schermo.
]

#slide(title: "L'approccio semplificato")[
  Questo approccio è stato abbandonato quando abbiamo scoperto
  che non è attualmente possibile
  passare un numero dinamico di _texture_ alla _fragment shader_.

  Siamo passati ad eseguire una _draw call_ per _layer_,
  rimuovendo la tridimensionalità in quanto
  non era più necessario sfruttare l'altezza dei _layer_ per l'ordine di disegno.
]

#slide(title: "Trasformazioni di vettori")[]

#slide(title: "Combinazione di trasformazioni")[]
