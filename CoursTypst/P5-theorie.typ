// =============================================================================
//  P5 – Inférence bayésienne : théorie — version autonome (un seul fichier).
//  Contient la bibliothèque (styles, boîtes, figures) et le chapitre.
//  À compiler avec les images du dossier "figures/" placé à côté de ce fichier.
// Les réglages et le contenu ne commencent qu'à la ligne 370. Le début concerne la définition de fonctions, variables, thème. 
//
// =============================================================================
#import "@preview/cetz:0.3.4": canvas, draw

// ======================================================================
// BIBLIOTHÈQUE : base
// ======================================================================

// =============================================================================
//  Socle commun : identité visuelle, réglages typographiques, notations,
//  versions élève / complète / prof (#trou, #infoprof).
// =============================================================================

// ----- Identité visuelle -----------------------------------------------------

#let police = "New Computer Modern" 
//#let police = "Arial"

#let couleurs = (
  accent:     rgb("#1e3a8a"),  // titres de section, badges d'exercice
  definition: rgb("#00b0f0"),
  theoreme:   rgb("#b91c1c"),
  corrige:    rgb("#166534"),
  avance:     rgb("#b45309"),  // symbole « + » des exercices difficiles
  discret:    luma(35%),       // remarques, cercle trigo, traits secondaires
  filet:      luma(70%),
)

#let annee-defaut = [4#super[ème] année]

// ----- Réglages typographiques et mathématiques -------------------------------
//
//  Appelé par conf-theorie et par conf-exercices, qui ne diffèrent que
//  par le corps du texte (12 pt en théorie, 11 pt en exercices).

#let styles-communs(taille: 12pt, doc) = {
  set text(size: taille, font: police, lang: "fr")
  set par(justify: true)
  show math.equation.where(block: true): set align(left)
  show math.frac: math.display
  doc
}



#let lim = math.limits(math.op("lim", limits: true))

// ----- Titre de document ------------------------------------------------------

#let titre-doc(code, titre, sous-titre: none, taille: 17pt) = {
  let t = if sous-titre == none { [#code – #titre] } else { [#code – #titre – #sous-titre] }
  align(center, text(taille, weight: "bold", t))
  v(4pt)
  line(length: 100%, stroke: 0.5pt + couleurs.filet)
  v(6pt)
}

// ----- Notations mathématiques ------------------------------------------------

// Racine n-ième complexe : indice cerclé sous le radical.
// Remplace root(ⓝ, z) et root(②, Delta), qui dépendaient de glyphes
// absents de New Computer Modern et donc d'un fallback de police.
#let racine-complexe(n, z) = math.root(
  box(circle(
    radius: 0.35em, stroke: 0.5pt, inset: 0pt,
    align(center + horizon, text(0.7em, n)),
  )),
  z,
)

// Nombre décimal à la française à l'intérieur d'une équation : #nb("3,61")
// (sans quoi la virgule est composée comme un séparateur de liste).
#let nb(x) = math.text(x)

// Justification courte au-dessus d'un signe égal : $ a #egal[IPP] b $
// (aussi utilisable sur un autre relateur : #egal(rel: $<=>$)[déf])
#let egal(info, rel: sym.eq) = math.attach(
  math.limits(rel),
  t: text(0.55em, info),
)


//Système prof/élève blanc/élève complet
// ----- Versions : eleve / complete / prof ------------------------------------
//   #trou[…]      visible en complete + prof, masqué (espace réservé) en eleve
//   #infoprof[…]  visible en prof seulement, absent ailleurs (pas d'espace)
//
//   En tête de document :
//     #let mode = mode-actif("prof")            // ou "eleve" / "complete"
//     #let (trou, infoprof) = versions(mode)

// ----- Mode actif -------------------------------------------------------------
// La valeur écrite dans le fichier fixe le mode de l'aperçu dans l'éditeur
// (et reste celle que fait tourner la tâche « changer de mode »).
// Une compilation en ligne de commande peut l'imposer :
//     typst compile --input mode=prof "chapitres/A2-theorie.typ"
// C'est ce qu'utilise la tâche « exporter les 3 versions ».
#let mode-actif(defaut) = sys.inputs.at("mode", default: defaut)

#let versions(mode, couleur: red, largeur-max-trou: 4cm) = {
  assert(mode in ("eleve", "complete", "prof"),
    message: "mode invalide : \"" + mode + "\" (attendu : eleve / complete / prof)")
  let trou = body => {
    let t = text(fill: couleur, body)
    if mode == "eleve" {
      // Trou "court" (moins d'une ligne) : on remplace le texte caché par
      // un soulignement en traitillé pour que le vide à compléter reste
      // repérable — sinon un trou d'un mot au milieu d'une phrase passe
      // inaperçu (contrairement à un trou de plusieurs lignes, déjà visible
      // grâce à l'espace réservé). On approxime « moins d'une ligne » via
      // la largeur/hauteur naturelles (non contraintes) du contenu cachée :
      // au-delà de largeur-max-trou ou d'une ligne de haut, il s'agit d'un
      // trou étendu, déjà repérable grâce à l'espace vide qu'il laisse.
      context {
        let dim = measure(t)
        let ligne = measure(text(fill: couleur, "Ag")).height
        if dim.height <= ligne * 1.4 and dim.width <= largeur-max-trou {
          box(width: dim.width, height: dim.height,
            place(bottom + left,
              line(length: dim.width, stroke: (paint: couleur, thickness: 0.5pt, dash: "dashed"))))
        } else {
          hide(t)
        }
      }
    } else { t }
  }
  let infoprof(body, titre: "PROF") = if mode == "prof" {
    block(width: 100%, breakable: true, inset: 8pt, above: 0.8em, below: 0.8em,
      fill: rgb("#fffbeb"), stroke: (left: 3pt + couleurs.avance),
      text(fill: couleurs.avance)[#text(weight: "bold")[#titre - ]#body])
  }
  (trou: trou, infoprof: infoprof)
}

// ----- Repères « version prof » ----------------------------------------------
#let bandeau-prof(mode) = if mode == "prof" {
  block(width: 100%, inset: 6pt, above: 0pt, below: 10pt, radius: 3pt,
    fill: couleurs.theoreme,
    align(center, text(fill: white, weight: "bold", "VERSION PROF — ne pas distribuer")))
}
#let filigrane-prof(mode) = if mode == "prof" {
  /*let tuile = box(width: 4.2cm, height: 3.2cm, align(center + horizon,
    rotate(-30deg, text(26pt, weight: "bold",
      fill: couleurs.theoreme.transparentize(95%), "PROF"))))
  rect(width: 100%, height: 100%, stroke: none, fill: tiling(tuile))*/
}
// ======================================================================
// BIBLIOTHÈQUE : mise en page et boîtes de théorie
// ======================================================================






// ----- BOITES (styles du template Word : définition bleue, théorème rouge, exemple pointillé)
//-------------------
#let boite(couleur, fond, titre, body) = block(
  width: 100%,
  breakable: true,
  inset: 9pt,
  above: 1em,
  below: 1em,
  fill: fond,
  stroke: (left: 3pt + couleur, rest: 0.6pt + couleur),
  [#text(fill: couleur, weight: "bold")[#titre] \ #v(0.3em) #body],
)
#let defi = boite.with(couleurs.definition, rgb("#f2f9fe"))
#let theo = boite.with(couleurs.theoreme, rgb("#fff5f5"))
#let exemple(body) = block(
  width: 100%,
  breakable: true,
  inset: 9pt,
  above: 0.9em,
  below: 0.9em,
  stroke: (paint: couleurs.discret, thickness: 0.7pt, dash: "dashed"),
  body,
)

// ------bloc avec figure à droite : exfig(chemin-ou-contenu, largeur-figure, url: lien-optionnel)[corps]
// img peut être soit un chemin (string) vers une image, soit du contenu déjà prêt (ex. #module-arg-diagram())
#let exfig(img, w, url: none, body) = {
  let fig = if type(img) == str { image(img) } else { img }
  if url != none { fig = link(url, fig) }
  grid(
    columns: (1fr, w),
    column-gutter: 10pt,
    align: (left, top),
    body, fig,
  )
}



// Mise en page

#let conf(code: "code", titre: "titre", annee: annee-defaut, mode: "eleve", doc) = styles-communs(taille: 12pt, {
  set page(paper: "a4", margin: (x: 2cm, y: 2.2cm), header: context if counter(page).get().first() > 1 {
    text(9pt)[2026-2027 – FB - Mathématiques – #annee #h(1fr) #code – #titre]
  }, footer: context {
    let etiquette = if mode == "prof" { "prof" } else if mode == "complete" { "théorie complétée" } else { "" }
    set text(9pt)
    grid(columns: (1fr, 1fr, 1fr),
      align(left, etiquette),
      align(center, counter(page).display("1")),
      align(right, none),
    )
  }, background: filigrane-prof(mode),)
  set par(leading: 0.68em)

  //titres
  set heading(numbering: (..n) => {
    let l = n.pos()
    if l.len() == 1 { numbering("I.", l.at(0)) } // I, II, ... VI.
    else if l.len() == 2 { numbering("A.", l.at(1)) } // A. B. C.
    else { numbering("1.", l.at(2)) } // niveau 3
  })

  show heading.where(level: 1): set text(15pt)
  show heading: set block(above: 1.4em, below: 0.7em)
  show heading.where(level: 2): it => pad(left: 1.2cm, it)
  titre-doc(code, titre)
  doc
})


// ======================================================================
// BIBLIOTHÈQUE : figures
// ======================================================================

// ————— INFÉRENCE BAYÉSIENNE —————
// Jauge de croyance : demi-cercle en 6 secteurs rouge → vert.
// aiguille : none ou position entre 0 (rouge) et 1 (vert).
// Dessin de la jauge (centrée en (0, 0), base sur y = 0), réutilisable dans un canvas.
#let jauge-dessin(r, aiguille: none) = {
  import draw: *
  let cols = (rgb("#d62728"), rgb("#e8590c"), rgb("#fcb900"), rgb("#f1e740"), rgb("#8fbf26"), rgb("#5cb82a"))
  let n = cols.len()
  let pol(rad, t) = (rad * calc.cos(180deg * (1 - t)), rad * calc.sin(180deg * (1 - t)))
  for (i, c) in cols.enumerate() {
    let pts = ()
    for k in range(9) { pts.push(pol(r, (i + k / 8) / n)) }
    for k in range(9) { pts.push(pol(0.55 * r, (i + 1 - k / 8) / n)) }
    line(..pts, close: true, fill: c, stroke: 0.6pt + white)
  }
  if aiguille != none { line((0, 0), pol(0.95 * r, aiguille), stroke: 1.5pt + black) }
}

#let jauge(r: 1.1, aiguille: none) = canvas(length: 1cm, jauge-dessin(r, aiguille: aiguille))

// Foule de n × n personnages (emoji). Avec cadre: true, on y superpose le diagramme bayésien :
// `gauche` colonnes pour H (à gauche), cadre, zones bleues (hg rangées en bas à gauche, hd à droite)
// et accolades étiquetées lab-g / lab-d. Par défaut : première colonne = malades M, T+.
#let foule(n: 10, cadre: false, rempli: true, emoji: "🧙", c: 0.55, gauche: 1, hg: 9, hd: 1, noms: ($M$, $overline(M)$), lab-g: $T +$, lab-d: $T +$, fond: true, accolades: true) = canvas(length: 1cm, {
  import draw: *
  let bleu = rgb("#b8d0f0")
  let L = n * c
  let xg = gauche * c
  if cadre and rempli and fond {
    rect((0, 0), (xg, hg * c), fill: bleu, stroke: none)
    rect((xg, 0), (L, hd * c), fill: bleu, stroke: none)
  }
  for i in range(n) {
    for j in range(n) {
      content(((i + 0.5) * c, (j + 0.5) * c), text(c * 0.8 * 1cm, emoji))
    }
  }
  if cadre {
    rect((0, 0), (L, L), stroke: 1.5pt)
    if rempli {
      line((xg, 0), (xg, L), stroke: 1.5pt)
      content((xg / 2, L + 0.3), text(10pt, noms.at(0)))
      content((xg + (L - xg) / 2, L + 0.3), text(10pt, noms.at(1)))
      if accolades {
        // accolade gauche
        let bx = -0.15
        line((bx + 0.1, 0.05), (bx, 0.15), (bx, hg * c - 0.15), (bx + 0.1, hg * c - 0.05), stroke: 0.8pt)
        content((bx - 0.1, hg * c / 2), text(10pt, lab-g), anchor: "east")
        // accolade droite
        let rx = L + 0.15
        line((rx - 0.1, 0.05), (rx, 0.15), (rx, hd * c - 0.15), (rx - 0.1, hd * c - 0.05), stroke: 0.8pt)
        content((rx + 0.1, hd * c / 2), text(10pt, lab-d), anchor: "west")
      }
    }
  }
})

// Diagramme bayésien : largeurs a : b (a priori), hauteurs v1, v2 ∈ [0;1] (vraisemblances).
// Étiquettes par défaut (auto) : vraisemblances v1, v2 en %, et a priori en % si a + b = 100.
#let bayes-diag(a, b, v1: none, v2: none, noms: ($H$, $overline(H)$), lab-a: auto, lab-b: auto, lab-v1: auto, lab-v2: auto, rempli: true, W: 5, H: 4, taille: 9pt) = canvas(length: 1cm, {
  import draw: *
  let pct(x) = $#calc.round(x * 100, digits: 1) %$
  let defaut(lab, val) = if lab != auto { lab } else { val }
  let lab-a = defaut(lab-a, if a + b == 100 { pct(a / (a + b)) } else { none })
  let lab-b = defaut(lab-b, if a + b == 100 { pct(b / (a + b)) } else { none })
  let lab-v1 = defaut(lab-v1, if v1 != none { pct(v1) } else { none })
  let lab-v2 = defaut(lab-v2, if v2 != none { pct(v2) } else { none })
  let x = W * a / (a + b)
  let bleu = rgb("#b8d0f0")
  if v1 != none and rempli {
    rect((0, 0), (x, v1 * H), fill: bleu, stroke: none)
    rect((x, 0), (W, v2 * H), fill: bleu, stroke: none)
  }
  rect((0, 0), (W, H), stroke: 1pt)
  if rempli {
    line((x, 0), (x, H), stroke: 1pt)
    content((x / 2, H + 0.3), text(taille, noms.at(0)))
    content(((x + W) / 2, H + 0.3), text(taille, noms.at(1)))
    if lab-a != none { content((x / 2, -0.3), text(taille, lab-a)) }
    if lab-b != none { content(((x + W) / 2, -0.3), text(taille, lab-b)) }
    if lab-v1 != none { content((-0.15, v1 * H / 2), text(taille, lab-v1), anchor: "east") }
    if lab-v2 != none { content((W + 0.15, v2 * H / 2), text(taille, lab-v2), anchor: "west") }
  }
})

// Échelle de crédence : probabilités ≈ 1 %, 10 %, 50 %, 90 %, 99 % et ratios correspondants.
#let echelle-credence() = canvas(length: 0.81cm, {
  import draw: *
  let vert = rgb("#12a870")
  let mauve = rgb("#9b59b6")
  let probas = ($approx 1 %$, $approx 10 %$, $approx 50 %$, $approx 90 %$, $approx 99 %$)
  let ratios = ($1 "vs" 100$, $1 "vs" 10$, $1 "vs" 1$, $10 "vs" 1$, $100 "vs" 1$)
  let dx = 2.6
  line((-0.6, 2.6), (4 * dx + 0.8, 2.6), mark: (end: ">"), stroke: 1pt)
  line((-0.6, 0), (4 * dx + 0.8, 0), mark: (end: ">"), stroke: 1pt)
  for i in range(5) {
    line((i * dx, 2.5), (i * dx, 2.7), stroke: 1pt + blue)
    line((i * dx, -0.1), (i * dx, 0.1), stroke: 1pt + blue)
    content((i * dx, 3.1), text(8pt, fill: vert, probas.at(i)))
    content((i * dx, -0.5), text(8pt, fill: vert, ratios.at(i)))
  }
  for i in range(4) {
    bezier((i * dx + 0.1, 0.2), ((i + 1) * dx - 0.1, 0.2), (i * dx + 0.8, 1.1), ((i + 1) * dx - 0.8, 1.1), mark: (end: ">"), stroke: 0.8pt + mauve)
    content(((i + 0.5) * dx, 1.05), text(8pt, fill: mauve, $dot 10$))
  }
  content((-0.9, 2.6), $P(H)$, anchor: "east")
  content((-0.9, 0), align(right)[_ratio_ :\ $P(H) \/ P(overline(H))$], anchor: "east")
})

// Danse bayésienne : la croyance (jauge) est confrontée à la réalité (article), puis mise à jour.
#let danse-fig() = canvas(length: 1cm, {
  import draw: *
  let bleu = rgb("#1e3a8a")
  let r = 1.4
  jauge-dessin(r)
  // document centré en x = 4,2, même base et même hauteur que la jauge
  let (x0, x1) = (3.5, 4.9)
  rect((x0, 0), (x1, r), stroke: 1pt, fill: white)
  rect((x0 + 0.15, r - 0.4), (x1 - 0.15, r - 0.15), fill: rgb("#6c8ebf"), stroke: 0.5pt)
  for y in (0.2, 0.5, 0.8) { line((x0 + 0.15, y), (x1 - 0.15, y), stroke: 0.8pt) }
  // flèches peu courbées
  bezier((0.4, 1.8), (4.0, 1.8), (1.2, 2.5), (3.2, 2.5), mark: (end: ">"), stroke: 0.7pt)
  bezier((4.0, -0.25), (0.3, -0.25), (3.1, -0.9), (1.2, -0.9), mark: (end: ">"), stroke: 0.7pt)
  content((2.2, 2.4), text(9pt, fill: bleu, emph[confrontation à la réalité]), anchor: "south")
  content((2.15, -0.9), text(9pt, fill: bleu, emph[mise à jour du degré de confiance]), anchor: "north")
})

// ======================================================================
// ======================================================================
// ======================================================================
// ======================================================================
// ======================================================================



// ======================================================================
// CHAPITRE
// ======================================================================


// ————— RÉGLAGES —————
#let mode = mode-actif("complete") //prof, complete ou eleve
#show: conf.with(code: "P5", titre: "Inférence bayésienne", mode: mode)

#let (trou, infoprof) = versions(mode)
#let noms-c = ($C$, $overline(C)$) // noms des hypothèses (coupable / pas coupable)
#let rempli = mode != "eleve" // diagrammes bayésiens des exemples : vides en mode élève

// Tableau de mise à jour : lignes a priori / vraisemblance / a posteriori (tout est à compléter).
#let tab-bayes(h, prior, vrais, post, lv: [Vraisemblance]) = align(center, table(
  columns: (auto, 6cm),
  align: (left, center),
  inset: 5pt,
  stroke: 0.5pt + luma(60),
  [], trou[#h],
  [Ratio a priori], trou[#prior],
  [Ratio #lv], trou[#vrais],
  [Ratio a posteriori], trou[#post],
))

// Jauge vierge suivie d'un commentaire à compléter.
#let jauge-proba(body) = grid(
  columns: (auto, 1fr),
  column-gutter: 10pt,
  align: horizon,
  jauge(), trou[#body],
)

#infoprof[TODO : ajouter une information sur les 3 types de probabilités :celles issues d'un raisonnement physique (les faces d'un dé), celles issues de données (la sensibilité d'un test) et celles qui portent sur un événement non répétable (la culpabilité d'une personne). Pour ce troisième cas, il suggère de parler de « degré de croyance ».]

= Degré de croyance

#exemple[
  #infoprof[l'exemple vient de monsieur Phi. Passer la vidéo si le temps le permet. https://youtu.be/3FOrWMDL8CY et  https://youtu.be/aU7EWwLtiOg .\
  "Visualisateur" https://espritcritique.fbfb.eu/bayes_visualisations/index.html]
  *Exemple 1 :* Un test pour diagnostiquer la dragoncelle est fiable à 90%, c'est-à-dire :\
  - Si une personne est malade, elle sera positive dans 90% des cas.
  - Si une personne n'est pas malade, elle sera négative dans 90% des cas.
  10% de la population est atteint de la dragoncelle.\
  Harry est testé positif.

  Quelle est la probabilité que Harry soit malade (répondez intuitivement) :

  Représenter la situation dans un diagramme et commenter

  #grid(
    columns: (1fr, 1fr),
    align: (left + horizon, center + horizon),
    foule(), foule(cadre: true, rempli: rempli),
  )

  #trou[Bien que le test soit fiable à 90%, Harry n'a que 50% de chances d'être malade. L'intuition nous trompe parce qu'on oublie que la maladie est rare au départ (la fréquence de base).]

  Au départ : #jauge()
  #h(1em)
  \ Après le test : #jauge()
]

#exemple[
  *Exemple 2 :* fera-t-il plus de 20° demain midi à Dakar ?

  #trou[Probablement, à … %]

  Comment le savez-vous ? En êtes-vous sûrs ?

  #grid(
    columns: (1fr, auto),
    column-gutter: 10pt,
    align: (left, horizon),
    trou[Il n'y aurait pas de sens à affirmer une réponse avec certitude. Mais on ne sait pas rien ! On sait qu'il fait probablement plus chaud à Dakar qu'à Genève. On peut penser en crédence],
    jauge(),
  )

  Comment pourriez-vous augmenter votre confiance ?

  #grid(
    columns: (1fr, auto),
    column-gutter: 10pt,
    align: (left, horizon),
    trou[En regardant la météo ! (Mais on ne sera pas sûrs non plus !)], jauge(),
  )
]

On n'est jamais sûr de rien, mais ça ne veut pas dire qu'on ne sait rien ! En pensant en _crédences,_ on évite de s'enfermer dans un tout ou rien.

#defi[Crédences][
  En inférence bayésienne, la *crédence* (ou degré de croyance, ou degré de confiance) est une probabilité subjective qui quantifie la confiance qu'un individu accorde à la véracité d'une hypothèse avant (a priori) et après (a posteriori) avoir observé des données.
]

Ce qui va nous intéresser particulièrement dans ce chapitre, c'est de comparer la crédence de $H$ _versus_ $overline(H)$ au fur et à mesure qu'on acquiert des informations.

#infoprof[exercices 1 et 2]

= Diagramme et tableau bayésiens

#exemple[
  Le riche Docteur Lenoir a été empoisonné hier. On soupçonne soit sa femme de ménage soit son associée. La femme de ménage était présente pendant 2 heures et l'associée pendant 8 heures.

  a) Est-il plus probable que la femme de ménage soit coupable ou pas coupable ?

   Imaginons 100 « petits mondes » de possibles : dans 20 d'entre eux la femme de ménage est coupable, dans 80 elle est innocente.

  #grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    foule(
      cadre: true,
      rempli: rempli,
      emoji: "🌍",
      gauche: 2,
      noms: noms-c,
      fond: false,
      accolades: false,
    ),
    bayes-diag(2, 8, noms: noms-c, lab-a: $2$, lab-b: $8$, rempli: rempli, W: 4.5, H: 4),
  )
   #trou[On a encore peu d'indices et c'est trop tôt pour affirmer qu'elle est coupable ou innocente. Mais on ne sait pas rien ! On sait qu'il est moins probable que ce soit la femme de ménage : 2 _contre_ 8 (on notera : $2 : 8$), ce qui donne une probabilité de $2\/10$.]



  b) On retrouve des empreintes digitales de la tueuse sur le verre empoisonné et on les compare aux deux suspectes. Les empreintes sont dégradées mais pourraient correspondre à 80% à la femme de ménage et à 10% à l'associée.

  #grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    foule(
      cadre: true,
      rempli: rempli,
      emoji: "🌍",
      gauche: 2,
      hg: 8,
      hd: 1,
      noms: noms-c,
      lab-g: $80 %$,
      lab-d: $10 %$,
    ),
    bayes-diag(
      2,
      8,
      v1: 0.8,
      v2: 0.1,
      noms: noms-c,
      lab-a: $2$,
      lab-b: $8$,
      rempli: rempli,
      W: 4.5,
      H: 4,
    ),
  )

  #trou[On doit comparer l'aire de gauche et l'aire de droite : $160% : 80%$ soit $2 : 1$. Il est donc deux fois plus probable que la femme de ménage soit coupable. Soit une crédence après indice de $2\/3$.]

  #grid(
    columns: (0.5fr, 1fr),
    align: left + horizon,
    [On peut aussi noter le raisonnement dans un tableau :\ \
      L'a priori #trou[a une grande importance]],

    tab-bayes(
      [Coupable vs Pas coupable],
      $2 : 8$,
      $80 : 10$,
      $160 : 80$,
      lv: [Vraisemblance (empreintes)],
    ),
  )


  c) La caméra de sécurité montre la femme de ménage qui sort très calmement et ne semble pas du tout angoissée. On sait qu'un coupable ne reste calme que dans 20% des cas. Au contraire un innocent a généralement l'air calme, dans 90% des cas. Mettez à jour votre degré de croyance.

  #grid(
    columns: (auto, 1fr),
    column-gutter: 10pt,
    align: center + horizon,
    tab-bayes(
      [Coupable vs Pas coupable],
      $2 : 1$,
      $20 % : 90 % = 2 : 9$,
      $4 : 9$,
      lv: [Vraisemblance \ (sortie calme)],
    ),
    bayes-diag(
      2,
      1,
      v1: 0.2,
      v2: 0.9,
      noms: noms-c,
      lab-a: $2$,
      lab-b: $1$,
      rempli: rempli,
      W: 3,
      H: 3,
    ),
  )

  Le ratio de « vraisemblance » consiste à #trou[comparer] à quel point il est plus probable d'avoir l'observation « femme de ménage sort calmement » #trou[sous l'hypothèse coupable] que #trou[sous l'hypothèse pas coupable].

  La « danse bayésienne » continue ! On estime maintenant #trou[plus probable que la femme de ménage soit innocente avec un ratio de $4 : 9$ (soit une proba de $4\/13$)]

  L'ordre dans lequel on tient compte des indices #trou[n'a pas d'importance.]

  d) L'inspecteur accumule les indices. Après avoir visionné les caméras de sécurité, nouveau coup de théâtre : on retrouve le poison chez la femme de ménage. Un coupable détient le poison dans 90% des cas. Un innocent dans 5% des cas.

  #tab-bayes(
    [Coupable vs Pas coupable],
    $4 : 9$,
    $90 : 5 = 18 : 1$,
    $72 : 9 = 8 : 1$,
    lv: [Vraisemblance (possession)],
  )

  #trou[On estime à nouveau plus probable que la femme de ménage soit coupable avec un ratio d'environ $8 : 1$.
    C'est-à-dire qu'il semble 8x plus probable qu'elle soit coupable. Crédence de $8\/9$]
]

= Manipuler des ratios

#defi[Ratios][
  Soit $H$ une hypothèse et $overline(H)$ le contraire.\
  Leur *ratio probabiliste* $H$ _vs_ $overline(H)$ est : $(P(H))/(P(overline(H)))$. \
  On le note $a : b$ pour tout $a, b$ positifs tels que $a / b = (P(H))/(P(overline(H)))$

  Ce ratio indique à quel point $H$ est plus probable que $overline(H)$
]

#exemple[
  Exemple : il est 3 fois plus probable qu'il fasse beau demain que pas beau.

  Écrire sous la forme d'un ratio : #trou[$B$ vs pas $B$ : $3 : 1$ (ou $6 : 2$, etc.)]

  Quelle est la probabilité qu'il fasse beau ?

  #trou[$
    P(B) = "« " ("#cas favorables")/("#cas total") " »" = ("poids hypothèse " B)/("poids total des possibles") = 3/(1+3)
  $]

  Par exemple pendant la coupe du monde, un commentateur sportif estime que les chances que la Suisse gagne sont de « 2 contre 1 », cela signifie :

  #trou[$ P(G) = ("poids hypothèse " G)/("poids total des possibles") = 2/(2+1) $]

  Le capitaine de la Suisse s'est blessé, la cote change pour 4 contre 3, cela signifie :

  #trou[$ P(G) = ("poids hypothèse " G)/("poids total des possibles") = 4/7 $]
]



#theo[Ratios vers probas][
  Si $H$ et $overline(H)$ ont un ratio $a : b$, alors $P(H) = a/(a+b)$
]

= Notion de vraisemblance

#defi[Vraisemblance][
  Soit $H$ une hypothèse, et $O$ une observation.
  - la *vraisemblance* de $O$ sachant $H$ est la probabilité que $O$ soit observée si $H$ est vraie, c'est à dire #trou[$P(O | H)$]
  - le *ratio de vraisemblance* de $O$ pour $H$ vs $overline(H)$ est : #trou[$P(O | H) : P(O | overline(H))$]. Il mesure à quel point il est plus probable de voir $O$ si $H$ est vraie que si $overline(H)$ est vraie.
]

#exemple[
  Exemple : Imaginons deux urnes distinctes :
  - L'urne 1 contient 8 boules bleues et 2 rouges
  - L'urne 2 contient 6 boules bleues et 9 rouges

  Un joueur qui a les yeux bandés effectue un tirage aléatoire d'une boule.

  Le joueur tire une boule rouge d'une des deux urnes.

  Quel est le ratio de vraisemblance de l'urne 1 vs l'urne 2 ? #trou[$2/10 : 9/15$ soit $1/5 : 3/5$ soit $1 : 3$]

  #trou[L'observation "tirer une boule rouge" soutient 3 fois plus l'hypothèse de l'urne 2 que celle de l'urne 1.]
]

= Raisonner sur un diagramme bayésien

#exfig(
  bayes-diag(
    2,
    3,
    v1: 0.7,
    v2: 0.15,
    lab-a: $P(H)$,
    lab-b: $P(overline(H))$,
    lab-v1: $P(O | H)$,
    lab-v2: $P(O | overline(H))$,
    W: 4.5,
    H: 3.6,
  ),
  45%,
)[
  #defi[Diagramme bayésien][
    Un *diagramme bayésien* permet de visualiser :
    - Les probabilités #trou[a priori] d'une hypothèse ou sa négation (avant observation des données).
    - Les #trou[vraisemblances] (probabilités des observations selon l'hypothèse ou sa négation).
    - Les probabilités #trou[a posteriori] (après mise à jour avec les observations).
  ]
]

#theo[Mise à jour bayésienne][
  Soient $H$ une hypothèse et $O$ une observation.
  $
    underbrace(P(H | O) colon P(overline(H) | O), "ratio a posteriori") = underbrace(P(H) colon P(overline(H)), "ratio a priori") dot underbrace(P(O | H) colon P(O | overline(H)), "ratio vraisemblance")
  $
]
#pagebreak()

#defi[Tableau de mise à jour bayésienne][
  #align(center, table(
    columns: (auto, 4cm),
    align: (left, center),
    inset: 5pt,
    stroke: 0.5pt + luma(60),
    [], [$H$ vs $overline(H)$],
    [A priori], [$a : b$],
    [Vraisemblance de $O$], [$v_1 : v_2$],
    [A posteriori], trou[$a dot v_1 : b dot v_2$],
  ))
]

#exemple[
  Exemple : mon ami a des dés pipés qui donnent 6 dans un cas sur deux. Je sais qu'il utilise ses dés pipés dans 10% des jeux. Il vient de faire 6 !

  #grid(
    columns: (auto, 1fr),
    column-gutter: 10pt,
    align: center + horizon,
  bayes-diag(
    1,
    9,
    v1: 0.5,
    v2: 1 / 6,
    noms: ([pipé], [non pipé]),
    lab-a: [10 %],
    lab-b: [90 %],
    lab-v1: [Fait 6],
    lab-v2: [Fait 6],
    rempli: rempli,
    W: 3.5,
    H: 3.5,
  ),

  tab-bayes(
    [Triche vs Pas triche],
    $10 % : 90 % = 1 : 9$,
    $1\/2 : 1\/6 = 3 : 1$,
    $3 : 9 = 1 : 3$,
    lv: [Vraisemblance (obtient 6)],
  ),
  )

  #trou[Ratio largeur (A priori) x ratio hauteurs (vraisemblance) = ratio aires (a posteriori).\
   Donc : il reste plus probable que mon ami n'ait pas utilisé un dé pipé.]
]

= Répéter

#exemple[
  #exfig(image("figures/dragoncelle.jpg"), 15%)[Un test pour diagnostiquer la dragoncelle est fiable à 90% :\
    Si une personne est malade, elle sera positive dans 90% des cas.\
    Si une personne n'est pas malade, elle sera négative dans 90% des cas.

    La dragoncelle touche 1% des gens

    Quelle est la probabilité a priori que Harry soit malade ?]

  #jauge()

  Harry est testé positif. Quelle est la nouvelle probabilité qu'il soit atteint de la dragoncelle ?

  #tab-bayes([Malade vs Pas malade], $1 : 99$, $90 : 10 = 9 : 1$, $9 : 99 = 1 : 11$, lv: [Vraisemblance test positif])

  #jauge-proba[ $P("malade") approx 10 %$ (arrondi grossier)]

  On fait un autre test à Harry, qui est également précis à 90%. Il est à nouveau testé positif.\
  (On suppose que les résultats sont indépendants !)\
  Quelle est la nouvelle probabilité qu'il soit malade ?

  #tab-bayes([Malade vs Pas malade], $1 : 11$, $9 : 1$, $9 : 11$, lv: [Vraisemblance test positif])

  #jauge-proba[$P("malade") approx 50 %$]

  On fait encore un autre test à Harry, qui est également précis à 90%. Il est à nouveau testé positif.\
  Quelle est la nouvelle probabilité qu'il soit malade ?

  #tab-bayes([Malade vs Pas malade], $9 : 11$, $9 : 1$, $81 : 11$, lv: [Vraisemblance test positif])

  #jauge-proba[En proba : $P("malade") approx 90 %$]
]

#defi[Danse bayésienne][
  La _"danse bayésienne"_ est une métaphore pour décrire le processus dynamique de mise à jour progressive de nos crédences à mesure que de nouvelles informations indépendantes arrivent.

  #exfig(danse-fig(), 40%)[A chaque observation, #trou[on ajuste notre crédence] : on part d'une probabilité #trou[a priori], on la fait "bouger" avec les preuves (#trou[vraisemblance]), et on obtient une nouvelle position (#trou[a posteriori]) qui devient le point de départ pour la prochaine mise à jour.]
]

IMPORTANT :
- les différentes preuves doivent être *indépendantes* entre elles pour pouvoir multiplier les ratios entre eux.
- pour l'a priori, on doit vraiment faire comme si on n'avait pas encore l'observation, sinon, on ne donne aucune chance aux explications alternatives !

#theo[Échelle de crédence][
  Quand une information est 10x plus vraisemblable sous l'hypothèse $H$ que sous l'hypothèse non $H$, la mise à jour de la croyance en $H$ suit l'échelle approximative : \
  #trou[1% - 10% - 50% - 90% - 99 %]

  #align(center, echelle-credence())
]

#exemple[
  Exemple :

  Vous croyez à 50% que les yétis existent. Vous avez accès à un article qui dément leur existence. Il vous parait 10x plus vraisemblable que cet article soit écrit sachant que les yétis n'existent pas, plutôt que s'ils existaient.

  A quel point devriez-vous maintenant croire en l'existence des Yéti ?

  #trou[On passe de 50% à 90% quand on a une observation 10x plus probable en faveur de la non-existence des yétis.
  \ En pensant en ratio, c'est assez évident : \
  - Balance a priori Pas Yeti vs Yeti: $1 : 1$
  - La partie de gauche est alourdie de 10x
  - Balance a posteriori Pas Yeti vs Yeti : $10 : 1$]

  #trou[$->$ probabilité d'environ 90% de non existence]
]


= Comparer différentes hypothèses

Le tableau de ratio est utilisable pour comparer des hypothèses $H_1$ et $H_2$ non exhaustives. 
#exemple[
  Exemple : Vous vous sentez fiévreux.\
  Actuellement : 
  $P("angine")=30% "(a priori)" quad P("grippe")=5%"(a priori)" $ \
  - En cas d'angine, on ne se sent fiévreux que dans 20% des cas.\
  - En cas de grippe en revanche, on ressent toujours de la fièvre.

  A quel point est-il plus probable que vous ayez une angine que la grippe ?

  #tab-bayes([$A$ vs $G$], $30 % : 5 % = 6 : 1$, $20 % : 100 % = 1 : 5$, $6 : 5$, lv: [Vraisemblance fièvre])
]
Le diagramme ne représenterait plus « tout l'univers » mais seulement les deux hypothèses en compétition. Le passage aux probas ne fonctionne donc plus.


= Conséquences épistémiques

#theo[Le guide du petit bayésien][
  + Pensez en #trou[crédences]
  + Souvenez-vous de #trou[vos a priori] (ne pas négliger le taux de base)
  + Pensez de manière contrefactuelle : #trou[« et si »] votre théorie était fausse ? Est-ce que vous pourriez quand même observer ce que vous observez ? (mettez vos croyances à l'épreuve !)
  + Mettez vos crédences #trou[à jour]
]

L'épistémologie bayésienne permet de « retrouver » certaines maximes de l'esprit critique :
- L'alternative est enrichissante
- Toutes les explications ne se valent pas
- Plus une affirmation est extraordinaire ou importante, plus elle nécessite des preuves fiables
- Ce n'est pas parce qu'on n'est pas sûrs qu'on ne sait rien

Dans ce cours, on a privilégié une écriture en ratio plutôt qu'en probabilités. Mais il est possible de réfléchir directement en probabilité, avec la formule de Bayes, qui est parfois appelée « formule du savoir ».

#theo[Formule du savoir][
  #let vert = rgb("#2ec4a0")
  #let mauve = rgb("#b48cd8")
  // étiquette centrée sous la boîte, accrochée à celle-ci
  #let etiquette(col, larg, corps) = place(
    top + center,
    dy: 100% + 0.6em,
    block(width: larg, text(8pt, fill: col, corps)),
  )
  #align(center)[
    $
      P("Hypothèse" | "Observation") #h(0.4cm) = #h(0.4cm) #box(stroke: 2pt + vert, inset: 5pt, [$P(H)$ #etiquette(vert, 3cm)[A quel point $H$ était probable a priori]]) #h(1cm) dot #h(1cm) #box(stroke: 2pt + mauve, inset: 5pt, [$(P(O | H))/(P(O))$ #etiquette(mauve, 3.6cm)[A quel point $H$ explique mieux ce qu'on observe]])
    $
    #v(2.2em)
  ]
]

#pagebreak()
= Démonstrations

#theo[Ratios vers probas][
  Si $H$ et $overline(H)$ ont un ratio $a : b$, alors $P(H) = a/(a+b)$
]

#exemple[
  Démonstration :

 #trou[ $a/b = (P(H))/(P(overline(H))) = (P(H))/(1 - P(H))$ donc $a (1 - P(H)) = b P(H)$

  donc $a - a P(H) = b P(H)$ et : $a = P(H)(a + b)$ soit finalement : $P(H) = a/(a+b)$]
]

#theo[Formule du savoir][
  $ P("Hypothèse" | "Observation") = P(H) dot (P(O | H))/(P(O)) $
]

#exemple[
  Démonstration :

 #trou[ Rappel : $P(A | B) eq.def (P(A inter B))/(P(B))$ donc $P(A inter B) = P(A) dot P(B | A)$

  Donc : $P(H inter O) = P(H) dot P(O | H) = P(O) dot P(H | O)$ et

  $P(H | O) = (P(H) dot P(O | H))/(P(O))$

  (Il s'agit simplement du théorème de Bayes)]
]

#theo[Mise à jour bayésienne][
  Soient $H_1$ et $H_2$ deux hypothèses exclusives et $O$ une observation.
  $
    underbrace(P(H_1 | O) colon P(H_2 | O), "a posteriori") = underbrace(P(H_1) colon P(H_2), "a priori") dot underbrace(P(O | H_1) colon P(O | H_2), "vraisemblance")
  $
]

#exemple[
  Démonstration :

  #trou[$
    (P(H_1 | O))/(P(H_2 | O)) #egal[th. de Bayes] ((P(O | H_1) P(H_1))/(P(O)))/((P(O | H_2) P(H_2))/(P(O))) = (P(O | H_1))/(P(O | H_2)) dot (P(H_1))/(P(H_2))
  $

  Ce qui s'écrit en notation ratio :

  $ P(H_1 | O) colon P(H_2 | O) = [P(H_1) colon P(H_2)] times [P(O | H_1) colon P(O | H_2)] $]
]


#infoprof[ Sources :
- Deux vidéos de Monsieur Phi sur le théorème de Bayes (https://youtu.be/3FOrWMDL8CY et  https://youtu.be/aU7EWwLtiOg. 
- « The Art of Statistics » de David Spiegelhalter
- "Think Bayes" de Allen B. Downey (accessible en ligne : https://allendowney.github.io/ThinkBayes2/index.html), 
- Julia Galef, plusieurs vidéos sur le théorème de Baye (https://youtu.be/za7RqnT7CM0 et https://youtu.be/BrK7X_XlGB8 )
- Rational Animations : https://www.youtube.com/watch?v=4hHA-oqpNig .
]