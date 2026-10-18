// =============================================================================
//  P5 – Inférence bayésienne : exercices — version autonome (un seul fichier).
//  Contient la bibliothèque (styles, boîtes, figures) et le chapitre.
//  À compiler avec les images du dossier "figures/" placé à côté de ce fichier.
// Les réglages et le contenu ne commencent qu'à la ligne 470. Le début concerne la définition de fonctions, variables, thème. 
//
//  Utilise le paquet @preview/exercise-bank et cetz (téléchargés automatiquement par Typst).
// =============================================================================
#import "@preview/cetz:0.3.4": canvas, draw
#import "@preview/exercise-bank:0.5.2": *

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
// BIBLIOTHÈQUE : mise en page des exercices
// ======================================================================


#let intermede(titre: "", body) = {
  v(0.5em)
  block(
    fill: luma(228),
    inset: 1em,
    radius: 0.5em,
    width: 100%,
    breakable: false,
  )[
    #text(weight: "bold", fill: couleurs.accent)[#titre] \
    #v(0.5em)
    #body
  ]
  v(0.5em)
}


//Mise en page



#let conf-exercices(
  code: "C1",
  titre: "",
  annee: annee-defaut,
  avec-corrige: true,
  doc,
  mode:"eleve"
) = styles-communs(taille: 11pt, {
  let marge = (x: 1.8cm, y: 2cm)
  let hauteur-page = 29.7cm // a4
  let largeur-corps = 21cm - 2 * marge.x // a4

  // Contenu du titre, mesuré ci-dessous pour ne pas faire passer le trait
  // de séparation des colonnes à travers le titre sur la première page.
  let titre-contenu = titre-doc(code, titre, sous-titre: [Exercices], taille: 16pt)

  let ligne-colonnes = context {
    let dy-ligne = if counter(page).get().first() == 1 {
      marge.y + measure(titre-contenu, width: largeur-corps).height
    } else {
      marge.y
    }
    place(
      top + center, dy: dy-ligne,
      line(length: hauteur-page - marge.y - dy-ligne, angle: 90deg, stroke: 0.4pt + couleurs.filet),
    )
  }

  set page(paper: "a4", margin: marge, numbering: "1",
    background: { filigrane-prof(mode); ligne-colonnes },
    header: [
      #set text(size: 9pt)
      2026-2027 – FB - Mathématiques – #annee #h(1fr) #code – #titre
      #line(length: 100%, stroke: 0.4pt + couleurs.filet)
    ])
  //set enum(numbering: "1)", spacing: 0.6em)
  set enum(numbering: "1)",spacing: 1.5em)
  // Les titres « = Exercice n » ne servent qu'à la navigation dans l'éditeur.
  // Un titre « == Pour aller plus loin » est affiché comme titre de section
  // dans la série (pas dans le corrigé).
  show heading.where(level: 1): none
  show heading.where(level: 2): it => block(
    above: 2.2em, below: 0.4em, width: 100%, breakable: false,
    {
      text(size: 13pt, weight: "bold", fill: couleurs.accent, it.body)
      v(0.25em)
      line(length: 100%, stroke: 0.6pt + couleurs.accent)
    },
  )

  exo-setup(
    display: if avec-corrige { "both" } else { "ex" },
    corr-display: "solution", corr-loc: "end-chapter",
    exercise-label: "Exercice", solution-label: "Corrigé",
    counter-reset: "global", badge-style: "underline",
    badge-color: couleurs.accent, solution-color: couleurs.corrige,
    advanced-symbol: text(fill: couleurs.avance)[+],
    exercise-above: 1.8em,
    solution-above: 1.8em,
  )

  titre-contenu

  columns(2, gutter: 4em, doc)

  if avec-corrige {
    set page(background: filigrane-prof(mode))
    pagebreak()
    exo-print-solutions()
  }
})


// ======================================================================
// BIBLIOTHÈQUE : exfig
// ======================================================================

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




// ======================================================================
// BIBLIOTHÈQUE : figures
// ======================================================================

// ————— ARBRE À DEUX BRANCHES (succès / échec) —————
// Étiquettes et probabilités sont du contenu quelconque : arbre-se(p: $0.99$, q: $0.01$).
#let arbre-se(s: $S$, e: $E$, p: $p$, q: $1-p$, taille: 9pt) = canvas(length: 1cm, {
  import draw: *
  let st = 0.8pt
  let L = 1.3 // longueur horizontale des branches
  let H = 0.9 // demi-hauteur

  line((0, 0), (L, H), stroke: st)
  line((0, 0), (L, -H), stroke: st)
  content((L + 0.12, H), text(taille, s), anchor: "west")
  content((L + 0.12, -H), text(taille, e), anchor: "west")
  content((L / 2 - 0.15, H / 2 + 0.3), text(taille, p))
  content((L / 2 - 0.15, -H / 2 - 0.3), text(taille, q))
})

// ————— ARBRE À DEUX ÉTAGES (deux épreuves successives, deux issues chacune) —————
// p : (pA, pB) au 1er étage ; q : ((pAA, pAB), (pBA, pBB)) au 2e étage (conditionnelles).
// issues : 4 contenus facultatifs écrits au bout des feuilles (ex. produits des probabilités).
// arbre2(a: $O$, b: $V$, p: ($5/12$, $7/12$), q: (($4/11$, $7/11$), ($5/11$, $6/11$)))
#let arbre2(a: $A$, b: $B$, p: ($p$, $1-p$), q: (($p$, $1-p$), ($p$, $1-p$)), issues: none, taille: 9pt) = canvas(length: 1cm, {
  import draw: *
  let st = 0.8pt
  let L = 1.5  // longueur horizontale d'une branche
  let H1 = 1.3 // demi-hauteur du 1er étage
  let H2 = 0.65 // demi-hauteur du 2e étage
  let x1 = L + 0.55 // départ du 2e étage (après l'étiquette du nœud)

  // étiquette de probabilité au milieu d'une branche, au-dessus (haut) ou en dessous
  let proba(xa, ya, xb, yb, haut, c) = content(
    ((xa + xb) / 2 - 0.15, (ya + yb) / 2 + (if haut { 0.3 } else { -0.3 })),
    text(taille, c),
  )

  let noms = (a, b)
  let k = 0
  for (i, s) in (1, -1).enumerate() {
    let y = s * H1
    line((0, 0), (L, y), stroke: st)
    content((L + 0.12, y), text(taille, noms.at(i)), anchor: "west")
    proba(0, 0, L, y, s > 0, p.at(i))
    for (j, t) in (1, -1).enumerate() {
      let yy = y + t * H2
      line((x1, y), (x1 + L, yy), stroke: st)
      content((x1 + L + 0.12, yy), text(taille, noms.at(j)), anchor: "west")
      proba(x1, y, x1 + L, yy, t > 0, q.at(i).at(j))
      if issues != none {
        content((x1 + L + 0.9, yy), text(taille, issues.at(k)), anchor: "west")
      }
      k += 1
    }
  }
})

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


// ————— RÉGLAGES LOCAUX —————
#let mode = "complete" //prof, complete ou eleve
#show: conf-exercices.with(code: "P5", titre: "Inférence bayésienne", avec-corrige: true, mode: mode)
#let (trou, infoprof) = versions(mode)

// Tableau de ratios : tb(en-tête, (étiquette, ratio[, commentaire]), ...)
#let tb(h, ..rows, coin: []) = {
  let r = rows.pos()
  let note = r.any(x => x.len() > 2)
  let cellules = r
    .map(x => if note { (x.at(0), x.at(1), if x.len() > 2 { x.at(2) } else { [] }) } else { (x.at(0), x.at(1)) })
    .flatten()
  align(center, table(
    columns: if note { (1fr, 4.2cm, 1.3fr) } else { (auto, auto) },
    align: (left + horizon, center + horizon, left + horizon),
    inset: 5pt,
    stroke: 0.5pt + luma(60),
    coin, h, ..(if note { ([],) } else { () }),
    ..cellules,
  ))
}
#let ap = [Ratio a priori]
#let po = [Ratio a posteriori]
#let rv = [Ratio vraisemblance]




= Exercice 1
#exo(
  exercise: [
    
    + Vous savez que 20% de vos concombres sont probablement pourris.\
      Quand un concombre est pourri, il est mou dans 90% des cas.\
      Quand un concombre n'est pas pourri, il lui arrive aussi d'être mou, dans 10% des cas.\
      Dessinez la situation ci-dessous :
      #align(center, foule(emoji: "🥒", c: 0.45))
    + Hermione rate son bus 10% des jours.\
      Quand elle rate son bus, elle n'a que 20% de chances d'être à l'heure en cours\
      Si elle ne rate pas son bus, elle a 90% de chances d'être à l'heure en cours.\
      Dessinez la situation ci-dessous :
      #align(center, foule(emoji: "📅", c: 0.45))
  ],
  solution: [
    #grid(
      columns: (1fr, 1fr),
      align: center + horizon,
      foule(emoji: "🥒", cadre: true, c: 0.5, gauche: 2, hg: 9, hd: 1, noms: ($P$, $overline(P)$), lab-g: $M$, lab-d: $M$),
      foule(emoji: "📅", cadre: true, c: 0.5, gauche: 9, hg: 9, hd: 2, noms: ($B$, $overline(B)$), lab-g: $H$, lab-d: $H$),
    )
  ],
)

= Exercice 2
#exo(
  exercise: [
    Un test pour diagnostiquer la dragoncelle est fiable à 90% :\
    - Si une personne est malade, elle sera positive dans 90% des cas.\
    - Si une personne n'est pas malade, elle sera négative dans 90% des cas.\
    Harry est testé positif. 
    + Quelle est la probabilité que Harry soit malade dans les cas suivants :
      - La dragoncelle ne touche que les femmes.
      - La dragoncelle touche tous les hommes.
    + Si on ne précise rien, quelle est la probabilité qu'il soit atteint de la dragoncelle ?
  ],
  solution: [
    
    +
      - Puisque Harry n'est pas une fille (à notre connaissance), la probabilité pour qu'il soit malade est nulle, le test ne change rien.
      - Puisque Harry est un garçon (à notre connaissance), la probabilité pour qu'il soit malade est 100%, le test ne change rien.
    + On ne peut pas répondre sans connaître le taux de maladie de départ !
  ],
)

= Exercice 3
#exo(
  exercise: [
    #exfig(image("figures/taxi.jpg"), 20%)[La nuit d'un accident, un taxi a renversé un piéton et a pris la fuite. Dans cette ville, 85 % des taxis sont jaunes, 15 % sont verts.]
    Un témoin déclare avoir vu un taxi vert. On teste sa vue de nuit : il identifie correctement la couleur dans 80 % des cas.
    
    + Dessiner un diagramme bayésien
    + Remplir un tableau des ratios :
      #align(center, table(
        columns: (auto, 3cm),
        align: (left + horizon, center),
        inset: 5pt,
        stroke: 0.5pt + luma(60),
        [], [$"Vert" "vs" overline("Vert")$],
        [#ap], [],
        [#rv (le témoin a vu vert)], [],
        [#po], [],
      ))
    + Quelle est la probabilité que le taxi impliqué soit effectivement vert ?
  ],
  solution: [
     #grid(
      columns: (1fr, 1fr),
      align: center + horizon,
    align(center, bayes-diag(15, 85, v1: 0.8, v2: 0.2, noms: ([Vert], [non Vert]))),
    tb(
      [Vert _versus_ non Vert],
      (ap, $15 : 85 = 3 : 17$),
      ([#rv (Vu vert)], $80 : 20 = 4 : 1$),
      (po, $12 : 17$),)
    )
    $P("Vert" | "Vu vert") = 12/(12 + 17) = 12/29 approx 41 %$
  ],
)

= Exercice 4
#exo(
  exercise: [
    Une maladie touche 1 personne sur 100 dans la population générale.\
    Un test de dépistage est disponible :\
    - s'il est appliqué à un malade, il est positif dans 99 % des cas
    - s'il est appliqué à une personne saine, il est positif dans 5 % des cas
    Ron passe le test. Résultat : positif.
    
    + Dessiner un diagramme bayésien
    + Recopier et remplir le tableau des ratios :
      #align(center, table(
        columns: (auto, 3cm),
        align: (left + horizon, center),
        inset: 5pt,
        stroke: 0.5pt + luma(60),
        [], [$"M" "vs" overline("M")$],
        [A priori], [],
        [Vraisemblance (Test+)], [],
        [A posteriori], [],
      ))
    + Est-il plus probable que Ron soit malade ou pas malade ? A quel point ?
    + Quelle est la probabilité qu'il soit malade ?
  ],
  solution: [
    
    + Diagramme
      #bayes-diag(1, 99, v1: 0.99, v2: 0.05, noms: ([Malade], [non Malade]))
    + Tableau :
    #tb(
        [Malade _versus_ non Malade],
        ([A priori], $1 : 99$),
        ([Vraisemblance (Test+)], $99 : 5$),
        ([A posteriori], $99 : (5 dot 99) = 1 : 5$),
      )
    + Il est 5 fois plus probable que Ron ne soit pas malade que malade
    + $P("Malade" | "Test+") = 1/(1 + 5) = 1/6 approx 17 %$
  ],
)

= Exercice 5
#exo(
  exercise: [
    Un détecteur de mensonges (polygraphe) est utilisé dans une affaire judiciaire. Ses caractéristiques sont :
    - Taux de vrai positif : 80 % (si le suspect ment, le test le détecte dans 80 % des cas).
    - Taux de faux positif : 10 % (si le suspect dit la vérité, le test indique un mensonge dans 10 % des cas).
    On estime que 5 % des suspects mentent lors d'un interrogatoire.
    
    + Harry passe le test qui se révèle positif. Quelle est la probabilité qu'il mente réellement ?
    + Un juge considère que Harry a 80 % de chances de mentir. Pourquoi est-ce incorrect ?
  ],
  solution: [
    
    + #tb(
        [Ment _versus_ ne ment pas],
        (ap, $5 : 95$),
        ([#rv (détecteur positif)], $80 : 10$),
        (po, $400 : 950 = 8 : 19$),
      )
      $P("ment" | "détecteur positif") approx 8/27 approx 30 %$
    + Le juge confond $P("observation" | "coupable")$ et $P("coupable" | "observation")$. On appelle cela « biais du procureur »
  ],
)

#intermede(titre : "Le biais du procureur")[
  Le biais du procureur consiste à confondre la probabilité d'observer une preuve si l'accusé est coupable ($P("observation" | "coupable")$), avec la probabilité que l'accusé soit coupable étant donné cette preuve. $P("coupable" | "observation")$
]

= Exercice 6
#exo(
  exercise: [
    Un meurtre est commis dans une ville de 100'000 habitants. On suppose qu'un seul habitant est coupable, sans suspect particulier a priori.\
    Les enquêteurs analysent l'ADN prélevé sur la scène. Ils le comparent au profil ADN d'Hermione, une habitante de la ville et trouvent une correspondance.\
    On admet que si l'on compare deux prélèvements ADN de la même personne, le test les identifiera comme correspondantes à 100 % (risque d'erreur négligeable).\
    En revanche, la probabilité que les profils ADN de deux personnes différentes correspondent par hasard est de 1 sur 1 000 000.\
    Le procureur affirme : _"La probabilité que Hermione soit innocente est de 1 sur 1'000'000"_
    
    + Calculer la probabilité que Hermione soit réellement coupable.
    + Identifier l'erreur de raisonnement du procureur.
    + Comment cette probabilité (calculée en a) évoluerait-elle si la ville comptait 1 million d'habitants ? Et à l'échelle d'un pays d'1 milliard d'habitants ?
  ],
  solution: [
    
    + #tb(
        [Coupable _versus_ non Coupable],
        (ap, $1 : #nb("99'999")$),
        ([Ra#rv (ADN correspond)], $1 : 1/(#nb("1'000'000")) = #nb("1'000'000") : 1$),
        (po, $#nb("1'000'000") : #nb("99'999") approx 10 : 1$),
      )
      $P("Coupable" | "ADN correspond") approx 10/11 approx 91 %$
    + Le procureur confond $P("observation" | "coupable")$ et $P("coupable" | "observation")$. C'est le (bien nommé !)  « biais du procureur »
    + #underline[Ville d'1 million d'habitants]
      #tb(
        [Coupable _versus_ non Coupable],
        (ap, $1 : #nb("999'999")$),
        ([#rv (ADN correspond)], $#nb("1'000'000") : 1$),
        (po, $#nb("1'000'000") : #nb("999'999") approx 1 : 1$),
      )
      $P("Coupable" | "ADN correspond") = 1/2$

      #underline[Pays d'1 milliard d'habitants]
      #tb(
        [Coupable _versus_ non Coupable],
        (ap, $1 : #nb("999'999'999")$),
        ([#rv (ADN correspond)], $#nb("1'000'000") : 1$),
        (po, $#nb("1'000'000") : #nb("999'999'999") approx 1 : 1000$),
      )
      $P("Coupable" | "ADN correspond") approx 1/1000$
  ],
)

= Exercice 7
#exo(
  exercise: [
    Un test antidopage est fiable à 99 % :
    - Si l'athlète est dopé, il est détecté avec 99 % de chances.
    - S'il ne l'est pas, le test donne à tort un résultat positif dans 1 % des cas.
    Dans une compétition, seulement 3 % des athlètes sont dopés.\
    Hermione, une des athlètes, est testée positive.
    
    + Dessiner un diagramme bayésien
    + Est-il plus probable qu'Hermione soit dopée ou non dopée ?
    + Quelle erreur ferait-on si l'on disait "le test est fiable à 99 %, donc Hermione est dopée avec une probabilité de 99 %" ?
    + L'arbitre décide de faire passer le test antidopage 10 fois. Le test est à chaque fois positif. Quelle est la probabilité qu'Hermione soit dopée, si on suppose que ces tests sont indépendants ?\
      _Indication : ne faites qu'un tableau_ 😊
  ],
  solution: [
    
    + Diagramme:
      #bayes-diag(3, 97, v1: 0.99, v2: 0.01, noms: ([Dopée], [non Dopée]))
    + Sur le diagramme, on voit que Dopée vs Non dopée $approx 3 : 1$\
      ($P("dopée") approx 75 %$)
    + On confondrait $P("observation" | "dopée")$, $P("dopée" | "observation")$. C'est le « biais du procureur »
    + #tb(
        [Dopée _versus_ non dopée],
        (ap, $3 : 97$),
        ([#rv (détecteur positif 1)], $99 : 1$),
        ([#rv (détecteur positif 2)], $99 : 1$),
        ([#rv (détecteur positif 3)], $99 : 1$),
        ([Etc.], []),
        (po, $3 dot 99^10 : 97 approx 2","8 dot 10^18 : 1$),
      )
      Il est environ 3 milliards de milliards de fois plus probable qu'Hermione soit dopée que pas dopée !\
      $P("dopée") approx 100 %$ (mais pas tout à fait ! On n'est jamais sûrs à 100% !)\
      Et, attention : si Hermione a par défaut un taux élevé de ce qui est recherché, on aura des faux positifs à répétition ! (les tests ne seraient alors pas indépendants)
  ],
)

= Exercice 8
#exo(
  exercise: [
    Steve est très timide et renfermé, toujours serviable mais avec très peu d'intérêt pour les gens ou pour le monde réel. Une âme douce et ordonnée, il a besoin d'ordre et de structure, et une passion pour le détail. Steve est-il plutôt libraire ou agriculteur ?
  ],
  solution: [
    #tb(
      [Libraire _versus_ Agriculteur],
      (ap, $1 : 100$, [(si on estime qu'il y a 100x plus d'agriculteurs que de libraires)]),
      ([#rv (timide, renfermé, etc.)], $50 % : 10 %$, [(si on estime que la description correspond à 50% des libraires et à 10% des agriculteurs. Autrement dit, la description correspond 5x mieux à un libraire qu'à un agriculteur)]),
      (po, $5 : 100 = 1 : 20$, []),
    )

    Avec nos estimations, il est 20x plus probable que Steve soit agriculteur !\
    Il ne faut pas oublier nos a priori !

    NB : pour le nombre d'agriculteurs, on peut trouver des estimations fiables, par exemple sur l'OFS. Pour le nombre de libraires, on peut trouver le nombre de librairies puis utiliser une estimation du nombre d'employés par librairie (évidemment très variable selon la taille de la librairie).\
    Pour la vraisemblance, c'est ici assez subjectif.

    Si vous êtes gênés de mettre des pourcentages dans ces conditions, vous pouvez travailler avec des « +++ » qui montrent mieux que l'idée ici est d'avoir une impression générale plutôt qu'un résultat exact.

    #tb(
      [Libraire _versus_ Agriculteur],
      (ap, [ \+ : + + + + +], [(si on estime qu'il y a « beaucoup » plus d'agriculteurs que de libraires)]),
      ([#rv (timide, renfermé, etc.)], [++ : +], [(si on estime que la description correspond « nettement » mieux à des libraires qu'à des fermiers)]),
      (po, [++ : + + + + +], [Finalement, la vraisemblance ne compense pas l'a priori, et il reste plus probable que Steve soit agriculteur.]),
    )

    _Cet exemple célèbre est tiré de « Thinking fast and slow » de Daniel Kahneman (#link("https://www.goodreads.com/quotes/10198601-an-individual-has-been-described-by-a-neighbor-as-follows")[https://www.goodreads.com/quotes/10198601-an-individual-has-been-described-by-a-neighbor-as-follows])_
  ],
)

#intermede(titre:"Négligence du taux de base")[
  La négligence du taux de base est un biais cognitif : on oublie souvent de considérer la fréquence de base de l'occurrence d'un événement quand on cherche à en évaluer une probabilité.

  Dans les années 1970, les psychologues et économistes Daniel Kahneman et Amos Tversky ont mené une série d'expériences (dont le problème qui précède) mettant en évidence les erreurs dues à l'oubli de la fréquence de base, courantes même chez des personnes ayant fait des études universitaires.

  $arrow.r$ N'oubliez pas vos a priori
]

= Exercice 9

#exo(
  exercise: [
    #infoprof[exercice avec 3 hypothèses en concurrence]
    Un feu d'artifice a été lancé illégalement depuis la tour de Poudlard. Les enquêteurs ont trois suspects a priori :\
    Fred, un élève farceur (5 chances sur 10), le professeur Flitwick qui était dans la tour à ce moment-là pour préparer les examens (1 chance sur 10) et un touriste vu à proximité ce jour-là (4 chances sur 10). Tous prétendent n'avoir jamais touché de feux.\
    Sur les feux d'artifice, on trouve une empreinte de pouce qui correspond au professeur Flitwick et pas aux deux autres. Mais l'analyse des empreintes n'est pas fiable à 100%. Voici les données du laboratoire :
    - Si deux empreintes appartiennent à la même personne, il y a 99% de chance qu'on le détecte correctement
    - Si deux empreintes n'appartiennent pas à la même personne, il y a 5% de risque qu'on les trouve correspondantes par erreur (faux positif)
    Pensez-vous que le professeur Flitwick est le lanceur de feu d'artifice ?
  ],
  solution: [
    #tb(
      [Fred _vs_ Flitwick _vs_ Le touriste],
      (ap, $5 : 1 : 4$),
      ([#rv (empreintes)], $5 % : 99 % : 5 % = 5 : 99 : 5$),
      (po, $25 : 99 : 20$),
    )

    Mr Flitwick est plus probablement coupable que les autres ($P("Flitwick") = 99\/144 approx 69 %$) mais l'incertitude reste importante (99 contre 25 pour le suivant, soit environ 4 contre 1)\
    On peut discuter de la pertinence de condamner une personne dans un cas si incertain. C'est une question politique-morale.
  ],
)

/*
= Exercice 10
#exo(
  exercise: [
    Un citoyen s'interroge sur l'efficacité de l'homéopathie au-delà de l'effet placebo. Il fixe sa probabilité a priori à 50 % (Ratio 1:1).\
    En naviguant sur internet pour se faire un avis, il lit successivement trois informations :
    - Un article de blog citant une petite étude isolée sur 50 patients montrant une légère amélioration. (ratio de vraisemblance 3:2).
    - Une méta-analyse australienne de grande ampleur (n'incluant pas l'étude précédente) concluant à l'absence d'effet. (ratio de vraisemblance 1:10).
    - Un avis de l'OMS, qui s'appuie sur d'autres comités d'experts internationaux, déconseillant son usage comme traitement médical. (ratio de vraisemblance : 1:5).
    
    + Que signifie « ratio de vraisemblance », dans ces consignes ? Faites une phrase en français.
    + Comment la crédence va-t-elle se mettre à jour après chaque nouvelle information ?
    + Conclure.

    NB : Les valeurs utilisées dans cet exercice sont des exemples. Cependant, elles illustrent la réalité de la recherche : face à l'accumulation de méta-analyses rigoureuses, les autorités sanitaires concluent à l'absence d'efficacité propre de l'homéopathie.
  ],
  solution: [
    
    + Un ratio de vraisemblance 3:2 signifie que l'observation (légère amélioration vs placebo) est 1,5 fois plus probable si l'homéopathie fonctionne que si elle ne fonctionne pas.
    + #tb(
        [Marche vs Marche pas],
        (ap, $1 : 1$),
        ([#rv (étude 1)], $3 : 2$, [$arrow.r.dashed$ A posteriori après étude 1 : 3 : 2]),
        ([#rv (étude 2)], $1 : 10$, [$arrow.r.dashed$ A posteriori après étude 2 : 3 : 20]),
        ([#rv (étude 3)], $1 : 5$, [$arrow.r.dashed$ A posteriori après étude 3 : 3 : 100]),
        (po, $3 : 100$, []),
      )
      $P("efficace") = 3/103 approx 3 %$
    + Face à l'accumulation de preuves contraires (la méta-analyse et l'OMS pesant beaucoup plus lourd que l'article de blog), la croyance en l'efficacité de l'homéopathie baisse, passant de 50% à environ 3%\
      Remarques :
      - Le ratio a priori (ici 1 :1) a de moins en moins d'importance au fur et à mesure qu'on accumule des preuves.
      - Un tel tableau n'a de sens que si les études sont indépendantes entre elles (sinon, on surestime leur importance)
      - Les vraisemblances sont admises ici. Dans la réalité, les estimer correctement nécessite de lire et d'évaluer les études elles-mêmes, c'est un travail difficile plutôt réservé à des experts du domaine.
  ],
)
*/


= Exercice 11
#exo(
  exercise: [
    Lors d'un procès, une infirmière est accusée des meurtres de patients parce qu'elle était présente dans les salles lors de chaque décès, lors des neuf derniers mois.\
    On note les événements suivants :\
    - H (hypothèse) : « l'accusée est coupable »\
    - O (observation) : « l'infirmière était présente lors de chaque décès du service »\
    On donne les probabilités suivantes :\
    - $P(H) = 1\/#nb("1'000'000")$ (peu d'infirmiers tuent leur patient) ;\
    - $P(O | H) = 100 %$ (si l'accusée est coupable, on est - presque - certain que le fait s'est produit).\
    - $P(O | "non" H) = 1\/#nb("10'000")$ (il est peu probable qu'une infirmière soit dans la salle à chaque décès de patients).
    + Calculer la probabilité a posteriori que l'infirmière soit coupable.
    + Des considérations personnelles de l'infirmière (passé douteux, un caractère peu avenant...) amènent à considérer $P(H) = 1\/#nb("10'000")$. Que pensez-vous de cette nouvelle hypothèse a priori ?\
      Calculer maintenant la probabilité a posteriori que l'infirmière soit coupable.
  ],
  solution: [
    + #tb(
        [Coupable _versus_ Pas coupable],
        (ap, $approx 1 : italic("million")$),
        ([#rv (patients qui meurent)], $100/100 : 1/(#nb("10'000"))$),
        (po, $1 : 100$),
      )
      $P(italic("coupable")) = 1/101 approx 1/100 approx 1 %$
    + Augmenter l'a priori sous prétexte d'un caractère peu avenant est très contestable. Rappelons que l'a priori doit être estimé en faisant « comme si » on n'avait encore rien observé. Sinon, on ne met pas vraiment nos hypothèses à l'épreuve !\
      Si on tient compte de ce nouvel a priori (contestable, redisons-le !)
      #tb(
        [Coupable _versus_ Pas coupable],
        (ap, $approx 1 : #nb("10'000")$),
        ([#rv (patients qui meurent)], $100% : 1/(#nb("10'000"))"   =   10'000:1"$),
        (po, $1 : 1$),
      )
      $P(italic("coupable")) = 50 %$
  ],
)

#intermede(titre:"L'affaire Lucia de Berk")[
  Cet exercice est basé sur l'histoire vraie d'une infirmière néerlandaise.

  #grid(columns: (1fr, 3.2cm), column-gutter: 8pt, align: (left, top), [En 2001, des responsables d'un hôpital pédiatrique Juliana remarquent que, lors de plusieurs décès ou réanimations, Lucia de Berk était de service lors de 8 événements suspects sur 9 mois, tous supposément durant ses gardes.], image("figures/lucia.jpg"))

  L'expertise statistique fut confiée non à un statisticien professionnel mais à un professeur de droit titulaire d'une licence de statistiques, dont le calcul (notamment un produit de probabilités non indépendantes) était erroné.

  Le procès finit par tourner principalement autour de quelques chiffres. Présente 13,8% du temps, Lucia de Berk était dans les parages lors de 100% des incidents.\
  Parmi les éléments marquants non pris en compte : durant les 9 mois précédant ceux où Lucia de Berk a travaillé à l'hôpital Juliana, il y a eu un mort _de plus_ que lorsqu'elle y travaillait ! D'un point de vue bayésien, c'est un indice en faveur de l'innocence car c'est une observation plus vraisemblable en cas d'innocence. (A priori ET vraisemblance comptent !)

  Condamnée à perpétuité en 2003, elle fut finalement innocentée en 2010 grâce à des statisticiens professionnels qui soulevèrent des éléments à décharge suffisants pour provoquer la révision du jugement.

  D'autres erreurs judiciaires liées aux probabilités par Leila Schneps : #link("https://youtu.be/8zdZnNcjPW4")[https://youtu.be/8zdZnNcjPW4]
]
#v(1em)
= Exercice 12
#exo(
  exercise: [
    Appliquez un raisonnement bayésien aux situations suivantes :
    
    + Vous avez laissé un gros morceau de fromage sorti. Quand vous rentrez, le morceau de fromage a disparu (mais pas votre chat). Votre chat a-t-il mangé le fromage ? Vous observez à présent que votre chat n'a pas faim, ce qui est rare. Remplissez un tableau bayésien.\
      _NB : aucun chiffre n'étant indiqué ici, vous allez proposer des « estimations ». Elles seront très grossières, mais elles vous permettront d'accompagner votre raisonnement. Plus tard, vous n'aurez plus besoin d'estimations pour conduire un raisonnement bayésien._
    + Hermione arrive en retard à l'école. A priori, vous pensez qu'elle a simplement oublié de mettre son réveil (Hypothèse $H_1$). Mais soudain, vous remarquez que son pantalon est déchiré au niveau du genou et qu'elle boite. Remplissez un tableau bayésien évaluant l'hypothèse $H_1$ _versus_ "un accident de vélo".
  ],
  solution: [
    
    + #tb(
        [Chat _versus_ Autre explication],
        (ap, $80 % : 20 % = 4 : 1$),
        ([#rv (chat pas faim)], $80 % : 10 % = 8 : 1$),
        (po, $32 : 1$),
      )
      J'estime à 32 contre 1 que le chat a mangé le fromage
    + #tb(
        [Panne de réveil _versus_ Accident],
        (ap, $10 : 1$, [A priori, les pannes de réveil sont très courantes chez les ados, les accidents beaucoup moins.]),
        ([#rv (Hermione boite.)], $1 % : 90 % = 1 : 90$, [S'il s'agit d'une simple panne de réveil, il y a très peu de chances (ex: 1%) d'arriver blessé et le pantalon déchiré. Si elle a fait une chute à vélo, il est très probable (ex: 90%) d'avoir ces observations.]),
        (po, $10 : 90 = 1 : 9$, []),
      )
      L'observation des vêtements déchirés est une preuve tellement forte qu'elle fait basculer l'a priori. Il est maintenant 9 fois plus probable qu'il lui soit arrivé un accident de vélo plutôt qu'une simple panne de réveil.

      Notez qu'il y a d'autres explications possibles : Hermione a raté son bus, Hermione a traîné au réveil, Hermione est espionne et avait une mission à accomplir avant d'arriver, Hermione pourrait avoir été transportée temporairement dans un univers parallèle, etc. Impossible de penser à toutes les explications possibles : il y en a une infinité !
  ],
)

#intermede(titre:"Le biais du procureur revisité")[
  Dans le livre « _la science incomprise_ », Florian Cova et Cédric Paternotte présentent cette situation amusante : « _La probabilité qu'une personne soit mouillée si elle vient de prendre un bain de lait d'ânesse est très haute (disons 100 %,puisque le lait d'ânesse mouille et ne sèche pas instantanément). Mais la probabilité qu'une personne vienne de prendre un bain de lait d'ânesse si elle est mouillée est extrêmement faible, car il existe de nombreuses façons, beaucoup plus fréquentes, de se retrouver mouillé (par exemple, prendre une douche avec de l'eau du robinet)._»
]

#v(5em)

= Exercice 13
#exo(
  exercise: [
    Pendant des décennies, les médecins ont observé que leurs patients souffrant d'ulcères gastriques étaient souvent stressés. Ils en concluaient que le stress était la cause des ulcères (hypothèse $H_1$).
    
    + Le raisonnement des médecins vous semble-t-il solide ?
    + En 1982, Barry Marshall, médecin australien, propose une autre hypothèse $H_2$: "l'ulcère est causé par une bactérie". Pourtant l'estomac est un milieu très acide où il semblerait qu'aucune bactérie ne pourrait survivre.\
      Marshall traite des patients avec un simple antibiotique (qui tue les bactéries mais n'a aucun effet calmant sur le stress) et observe qu'ils guérissent définitivement de leurs ulcères.\
      Mettez-vous dans la peau d'un médecin en 1982, (sans donner de valeur numérique, juste une évaluation qualitative)
      - quel serait votre a priori sur le ratio $H_1 : H_2$.
      - que diriez-vous du ratio de vraisemblance ?
      - que concluriez-vous ?
    + Quelle leçon tirer sur les limites du raisonnement bayésien ?
  ],
  solution: [
    
    + Il est normal de se poser la question d'un lien. Mais on doit se rappeler que : « corrélation n'est pas causalité » et qu'il pourrait y avoir un facteur de confusion. Par exemple, les personnes qui sont débordées pourraient avoir à la fois du stress et une mauvaise alimentation entraînant des ulcères, sans que l'un soit directement la cause de l'autre.
    + - A priori l'hypothèse $H_2$ semble peu convaincante par rapport à $H_1$. On a un fort a priori en faveur de $H_1$
      - La guérison par antibiotique est une preuve très forte car elle colle mal à l'hypothèse du stress (un antibiotique ne soigne pas le stress !), mais elle est très _vraisemblable_ sous l'hypothèse de la bactérie.\
        Le ratio de vraisemblance est donc largement en faveur de $H_2$ par rapport à $H_1$
      - A quel point la balance du ratio de l'a priori est compensé par la balance du ratio de la vraisemblance ? Qualitativement, on peut se dire que le ratio de vraisemblance compense plus que largement le ratio de l'a priori.

      Dans « la vraie vie », on remplit rarement des tableaux bayésiens, notamment parce qu'on n'a pas de données chiffrées précises. Mais on voit qu'il n'est pas nécessaire de passer par des chiffres pour raisonner de manière bayésienne.

      Ici, si on modélise cette situation pour la chiffrer, on aurait quelque chose du genre :
      #tb(
        [H1 _versus_ H2],
        (ap, $99 : 1$),
        ([#rv (guéri par antibio)], $0,1 % : 90 % = 1 : 900$),
        (po, $99 : 900 approx 1 : 10$),
      )
    + Le raisonnement bayésien ne peut mettre à jour que les hypothèses qu'on a pensé à poser. Si la bonne explication n'est pas dans le tableau, aucune observation ne peut y mener. C'est une des limites de la méthode.
  ],
)

#intermede(titre:"Passer à côté de la bonne explication")[
  Le raisonnement bayésien ne peut mettre à jour que les hypothèses qu'on a pensé à poser. Si la bonne explication n'est pas dans le tableau, vous ne la traiterez pas. C'est une des limites de la méthode.
]

= Exercice 14
#exo(
  exercise: [
    C'est la nuit, vous êtes seul chez vous et vous entendez un bruit dans le salon. Vous posez l'hypothèse $H_1$ : "C'est une souris".
    
    + Listez au moins cinq autres hypothèses alternatives (des plus banales aux plus absurdes).
    + Pourquoi est-il mathématiquement impossible de construire un tableau bayésien comparant $H_1$ à "Toutes les autres hypothèses de l'univers" ?
    + Quelle leçon tirer sur les limites du raisonnement bayésien ?
  ],
  solution: [
    
    + Hypothèses possibles :
      - C'est un cambrioleur,
      - c'est un objet qui est tombé,
      - j'ai cru entendre un bruit mais c'était une illusion,
      - c'était un fantôme d'un ancien locataire,
      - c'était un voisin qui s'est trompé de porte et nous avons par hasard la même serrure,
      - etc.
    + Pour remplir un tableau, il faut évaluer le ratio a priori et le ratio de vraisemblance. Or, il est impossible d'attribuer une probabilité a priori à une catégorie "Autre" qui regroupe une infinité de scénarios ! De même, on ne peut pas calculer la probabilité d'entendre ce bruit spécifique (vraisemblance) sous un nombre infini d'hypothèses. La catégorie « Autre » est trop grosse.
    + Bayes fonctionne surtout pour comparer un petit nombre d'hypothèses précises. Il faut donc les avoir sélectionnées au préalable. Le choix dépendra fortement de notre expertise du sujet.\
      Comme on l'a déjà vu, le théorème de Bayes ne "génère" pas de nouvelles idées. Il trie seulement parmi un nombre limité d'hypothèses qu'on choisit d'observer. Le calcul bayésien permet de progresser en déterminant une "moins mauvaise" hypothèse, parmi les hypothèses sélectionnées. L'expertise est indispensable pour le choix des hypothèses.
  ],
)

= Exercice 15
#exo(
  exercise: [
    Dans une enquête, un suspect avoue sous la pression. On sait que :\
    - 10 % des suspects innocents avouent des crimes qu'ils n'ont pas commis.\
    - 50 % des coupables avouent leurs crimes.\
    - 20 % des suspects sont réellement coupables (et 80 % sont innocents).
    
    + Dessiner un diagramme bayésien
    + Quelle est la probabilité que le suspect soit coupable sachant qu'il a avoué ?
  ],
  solution: [
    
    + #bayes-diag(20, 80, v1: 0.5, v2: 0.1, noms: ([Coupable], [non Coupable]))
    + On s'intéresse à $P("coupable" | "aveu")$\
      Ici, il s'agit donc de restreindre l'univers aux rectangles « aveu » :
      $ P("coupable" | "aveu") = ("aveu et coupable")/("aveu") = (50 % dot 20 %)/(50 % dot 20 % + 80 % dot 10 %) = 10/18 = 5/9 $
      (Avec un tableau : )
      #tb(
        [Coupable _versus_ Pas coupable],
        (ap, $20 % : 80 % = 1 : 4$),
        ([#rv (a avoué)], $50 % : 10 % = 5 : 1$),
        (po, $5 : 4$),
      )
      $P("coupable") = 5\/9$
  ],
)

= Exercice 16
#exo(
  exercise: [
    Vous souvenez-vous du paradoxe de Monty Hall ? Abordons-le sous l'angle de la mise à jour des crédences !\
    Dans cette célèbre émission télévisée, le candidat fait face à trois portes fermées. Derrière l'une se trouve une voiture, derrière les deux autres se trouvent des chèvres.
    - Le candidat choisit une porte à l'aveugle.
    - L'animateur (Monty Hall), qui sait parfaitement où se trouve la voiture, ouvre toujours une des deux autres portes pour révéler une chèvre.
    - L'animateur propose alors au candidat de changer son choix initial pour la dernière porte fermée.
    Vous jouez et vous choisissez la porte 3. Monty Hall ouvre alors la porte 1, derrière laquelle se trouve une chèvre.
    #align(center, image("figures/montyhall.png", width: 70%))

    On souhaite évaluer les deux hypothèses suivantes :\
    - $H_1$: « La voiture est derrière la porte 3 » (Mon choix initial)\
    - $H_2$: « La voiture est derrière la porte 2 » (La porte restante)\
    L'observation $O$ est : « L'animateur a choisi d'ouvrir la porte 1 ».\
    Vaut-il mieux rester sur la porte 3 ou changer ?
  ],
  solution: [
    #tb(
      [Voiture derrière porte 3 _versus_ Voiture derrière porte 2],
      (ap, $1 : 1$, [Au départ, les deux portes ont chacune 1 chance sur 3]),
      ([#rv (chèvre derrière porte 1)], $50 % : 100 % = 1 : 2$, [\*]),
      (po, $1 : 2$, []),
    )

    \* Explications :\
    - Si la voiture est derrière la porte 3 (mon choix) : Monty Hall a le choix d'ouvrir la porte 1 ou la porte 2 pour révéler une chèvre. Il choisit au hasard. La probabilité qu'il ouvre la porte 1 est donc de 1/2 (50 %).
    - Si la voiture est derrière la porte 2 : Monty Hall n'a pas le choix. Je bloque la porte 3, et la voiture est derrière la porte 2. Il est donc obligé d'ouvrir la porte 1. La probabilité qu'il ouvre la porte 1 dans ce scénario est de 1 (100 %).

    Conclusion\
    Il est 2x plus probable que la voiture soit derrière la porte 2 -> on a intérêt à changer !\
    ($P("porte 2") = 2\/3$ )
  ],
)

#intermede(titre:"Le paradoxe des corbeaux noirs")[
  #grid(columns: (1fr, 2.6cm), column-gutter: 8pt, align: (left, top), [Le paradoxe des corbeaux noirs part de la phrase : « Tous les corbeaux sont noirs », qui est logiquement équivalente à « Tout objet non noir n'est pas un corbeau ».], image("figures/corbeau.png"))
  Observer un corbeau noir confirme directement la première formulation. Mais, en logique pure, voir une chaussure blanche confirme aussi la seconde formulation (et donc la première), car c'est bien un objet non noir qui n'est pas un corbeau.\
  Le paradoxe vient du fait qu'intuitivement, une chaussure blanche ne nous semble rien apprendre sur la couleur des corbeaux.

  Dans une logique bayésienne, il n'y a pas de paradoxe : la chaussure blanche augmente effectivement, très très faiblement, la probabilité de l'hypothèse « les corbeaux sont noirs ».
]

== Enquêtes

= Exercice 17
#exo(
  exercise: [
    *La décorporation*
    #align(center, image("figures/nicolasfraisse.jpg", width: 75%))
    
    + A priori, quelle est votre crédence sur la possibilité qu'on puisse se « décorporer » ?
    + Visionnez ensuite ce documentaire sur les expériences de décorporation de Nicolas Fraisse :\
      #link("https://www.youtube.com/watch?v=ElvLzXoy0EU")[https://www.youtube.com/watch?v=ElvLzXoy0EU]
    + Expliciter des explications alternatives à ce qu'on observe et estimez leur plausibilité.
    + Si des personnes pouvaient sortir de leurs corps, imaginez l'impact qu'elles pourraient avoir sur le monde : que pourrait-on observer ?
    + A posteriori, après avoir vu le documentaire et après avoir réfléchi aux conséquences possibles de la décorporation, indiquez comment a évolué votre crédence sur la décorporation.

    _Si vous voulez aller plus loin, une analyse courte de « méta de choc » :_ #link("https://www.youtube.com/watch?v=jhV0nN2ekxA")[https://www.youtube.com/watch?v=jhV0nN2ekxA]
  ],
  solution: [
    
    + Réponse personnelle : dépend de votre représentation du monde actuelle.\
      Probablement faible entre 1/1 million et 1/100 car la décorporation contredit les lois physiques qu'on connaît et qu'on a expérimenté depuis la naissance.
    #enum.item(3)[Explications alternatives plausibles :
      - Montage ou mise en scène : assez plausible, média sérieux mais on n'a qu'un extrait
      - Tricherie (assistant et montre connectée, par exemple) : assez plausible
      - Lecture à froid : peu plausible (de tomber exactement sur Frida Kahlo)
      - Hasard, toutes les fois où ça n'a pas marché n'ont pas donné de reportage : peu plausible (car très improbable de tomber par hasard sur des descriptions aussi précises)
      - Autre sorte de magie que la décorporation : très peu plausible]
    #enum.item(4)[Si la décorporation était réelle, on pourrait observer : des super espions, peut-être la paix dans le monde grâce aux renseignements obtenus ? En tous cas, on s'attendrait à ce que Nicolas Fraisse ne se contente pas de regarder ce qu'il y a à la boulangerie 😉 Or on n'observe rien de tel… Cette non observation est en soi une observation, peu vraisemblable en cas de décorporation réelle. On peut aussi trouver bizarre que Nicolas Fraisse soit étonné d'avoir vu juste.]
    #enum.item(5)[Le documentaire présente une expérience non contrôlée, explicable par les alternatives de c). La vraisemblance de ces observations sous "décorporation réelle" n'est pas supérieure à celle sous "suggestion + biais de confirmation". Le curseur ne devrait pas bouger significativement.\
      Si on veut s'amuser à « chiffrer », voici une proposition]

    #tb(
      [H _versus_ non H],
      (ap, $1 : #nb("1'000")$, [(cf a) )]),
      ([#rv 1\ observations dans documentaire.], $100 % : 30 % = 10 : 3$, [(si la décorporation existe, ça explique parfaitement ce qu'on voit dans le doc. Si elle n'existe pas, ce qu'on voit est moins vraisemblable – mais pas impossible, cf c) )]),
      ([#rv 2\ non observation d'effets spectaculaires], $1 % : 100 % = 1 : 100$, [Si la décorporation existe, on ne comprend pas pourquoi pas d'effets spectaculaires (cf d) ) mais si elle n'existe pas, c'est très vraisemblable.\ *Attention, si ça a déjà joué dans notre a priori il ne faut pas le recompter ici !*]),
      ([#rv 3\ NF s'étonne d'avoir vu juste], $1 : 2$, []),
      (po, $10 : #nb("600'000") = 1 : #nb("60'000")$, []),
      coin: [H : décorporation existe],
    )

    Même un documentaire troublant ne compense pas l'a priori et les ratios de vraisemblance de toutes les autres observations.

    Remarques :
    - On parle de « non H » mais en réalité, non H comprendrait une infinité d'explications alternatives. Ici, on ne tient compte que des hypothèses listées dans c)
    - Vous ne partirez pas tous du même ratio a priori (ça dépendra de votre éducation, de vos expériences). C'est normal ! Mais au fur et à mesure qu'on fera ensemble des observations, on mettra à jour notre crédence et on « se rapprochera » les uns des autres. C'est beau, non ?!
    - Dans cet exercice de « la vraie vie », on n'a pas de valeurs exactes. Les nombres utilisés dans nos tableaux sont des « ordres de grandeur ». On peut mettre des fourchettes pour mieux tenir compte de l'incertitude. Et surtout, on l'a déjà vu, on n'a pas forcément besoin de chiffrer le raisonnement. Ce qui compte, c'est de se poser les questions :
      - « Quel est mon a priori sur la décorporation ? »
      - « Cette observation est-elle plus vraisemblable si la décorporation existe, ou s'il s'agit d'une erreur/supercherie ? »

    Une vidéo de décryptage plus longue : #link("https://youtu.be/rZG8v1UQWhI?si=uknoXCJCPgf15tcR")[https://youtu.be/rZG8v1UQWhI?si=uknoXCJCPgf15tcR]
  ],
)

#intermede(titre:"Une affaire de souplesse")[
  Un ratio de croyance de 1:1'000'000 ou de 1 :1'000 correspondent tous deux à un « je ne crois pas » et pourtant la différence est énorme!

  Dans les débats, il est peut-être plus fructueux de chercher à faire « bouger ses curseurs de croyance » (et à bouger les siens !) que de convaincre.
]

= Exercice 18
#exo(
  exercise: [
    *La pub canal+*

    Visionnez cette publicité puis appliquez un raisonnement bayésien à la situation !\
    #link("https://www.youtube.com/watch?v=VEiLGJrCxSY")[https://www.youtube.com/watch?v=VEiLGJrCxSY]\
    Toutes les explications ne se valent pas !
  ],
  solution: [
    Dans cette publicité, le cerveau du mari devrait évaluer deux hypothèses :\
    $H_1$ : Cet homme en caleçon est l'amant de ma femme (scénario banal).\
    $H_2$ : Cet homme a survécu à une guérilla, aux chutes du Niagara, à un broyeur industriel et a été livré par hasard dans mon placard (scénario extraordinaire).

    Ici, complétons le tableau sans valeurs numériques, comme on le ferait dans la vraie vie

    #tb(
      [$H_1$ _versus_ $H_2$],
      (ap, [Très en faveur de $H_1$], [Tromper son mari est peut-être rare mais vivre les aventures extra-ordinaires du personnage de la pub l'est beaucoup plus !]),
      ([#rv (observation de la scène : un homme en caleçon derrière la porte du placard, femme au lit)], [A peu près équivalent], [On pourrait dire que chaque hypothèse rend la situation très vraisemblable et donc ne les départage pas.]),
      (po, [Très en faveur de $H_1$ 😊], []),
    )
  ],
)

= Exercice 19
#exo(
  exercise: [
    *L'affaire Omar Raddad*

    *Contexte*\
    Le 24 juin 1991, Ghislaine Marchal, riche veuve de 65 ans, est retrouvée morte dans la cave de sa villa à Mougins. Elle a été frappée à mort. Sur la porte de la cave, écrit avec son propre sang :\
    #align(center)[_Omar m'a tuer_]
    (avec la faute d'orthographe). \
    Omar Raddad est son jardinier marocain, employé depuis plusieurs années. Il est le dernier à l'avoir vue vivante ce jour-là.\
    Vous vous dites que c'est le coupable ? Mais est-ce si sûr ?

    *Les faits*\
    AP : Omar avait accès à la propriété. Trois autres personnes également : un autre employé, le fils de Ghislaine, un ami de la famille.\
    A : Le corps a été trouvé dans une cave fermée de l'intérieur.\
    B : L'inscription désigne Omar nommément.\
    C : Il y a une faute d'orthographe dans le message.\
    D : Omar est quasi-analphabète en français.\
    E : Ghislaine était agonisante et perdait son sang. Écrire une phrase longue dans ces conditions est très difficile.\
    F : Omar n'avait aucun mobile connu.\
    G : Des analyses ADN réalisées vingt ans plus tard révèlent des traces sous les ongles de Ghislaine qui ne correspondent pas à Omar.\
    H : Après avoir été gracié, Omar Raddad a continué à lutter pour que son innocence soit reconnue

    *Questions*
    
    + Sachant que 4 personnes seulement avaient accès à la propriété, fixez un ratio coupable vs non coupable a priori (attention ! on doit vraiment faire comme si on n'avait pas encore d'autres observations, sinon, on ne donne aucune chance aux explications alternatives)
    + Pour chaque fait, estimez le ratio de vraisemblance. Justifiez vos chiffres (pas de « mauvaises réponses », justifiez vos choix).
    + Construisez le tableau complet et concluez.
    + Certains faits vous semblent-ils plus décisifs que d'autres ? Pourquoi ?

    *Jugements rendus*\
    Omar Raddad a été condamné en 1994 à 18 ans de réclusion. Il a toujours clamé son innocence. Partiellement gracié en 1996 par Chirac, il est sorti après 7 ans de prison. La révision de son procès a été refusée à plusieurs reprises malgré les nouvelles analyses ADN qui correspondent à un profil masculin non identifié à ce jour.

    *Remarque :*\
    Un jury d'assise a écouté toute l'affaire et a estimé qu'Omar Raddad était coupable. Il est probable que d'autres faits, non connus ici, aient eu une importance. Ceci reste un exercice !
    #align(center, image("figures/omar.png", width: 90%))
  ],
  solution: [
    Pas de mauvaise réponse, dépend de vos estimations.

    - Il y a une première grande difficulté dans cet exercice : *les « preuves » ne sont pas indépendantes*. Par exemple le fait que Ghislaine Marchal (GM) soit enfermée de l'intérieur est intéressant parce qu'il y a une inscription. On ne peut donc pas évaluer séparément les vraisemblances de chaque item.

    - Autre difficulté : on pourrait proposer deux hypothèses très précises, par exemple\
      $H_1$ : Omar est coupable, l'inscription a été écrite par Ghislaine Marchal après qu'elle se soit enfermée dans sa cave. Elle est morte ensuite.\
      $H_2$ : Omar est innocent. Le ou les tueurs ont écrit l'inscription puis ils ont fait en sorte de donner l'impression que Ghislaine Marchal s'était enfermée de l'intérieur.\
      Mais dans ce cas, chaque observation sera parfaitement vraisemblable (n'aidera pas à discriminer) et c'est l'a priori qui sera difficile à déterminer !

    Voici une proposition tenant compte de ces difficultés.\
    $H_1$ : Omar a tué GM et GM a écrit le message.\
    $H_2$ : Une autre personne a tué GM et a tenté de faire accuser Omar.

    #align(center, table(
      columns: (3.8cm, 1.4cm, 1.8cm, 1fr),
      align: (left + horizon, center + horizon, center + horizon, left + horizon),
      inset: 5pt,
      stroke: 0.5pt + luma(60),
      [], [*H1*], [*H2*], [],
      [#ap \ 4 suspects équiprobables], [1], [3], [],
      [#rv 1\ A+B+E\ Scène de crime : Huis clos + inscription + inscription nominative], [500], [1], [Sous H1, la victime s'enferme et dénonce son tueur (Très vraisemblable), en même temps, pas facile d'écrire en agonisant !\ Sous H2, le tueur doit… tuer, écrire, fuir, barricader de l'extérieur sans laisser de traces.],
      [#rv 2\ faute d'orthographe (C)], [1], [5], [GM aurait tout à fait pu faire une faute d'orthographe étant données les conditions exceptionnelles. La faute semble encore plus vraisemblable car écrite par une personne possiblement peu instruite. Mais on peut supposer que cette personne aurait fait attention à ne pas faire de faute, voulant se faire passer pour GM ?],
      [#rv 3\ quasi-analphabète (D)], [1], [1], [Tout autant vraisemblable sous H1 que H2 car dans tous les cas, il semble très improbable qu'Omar ait écrit le message !],
      [#rv 4\ aucun mobile (F)], [1], [3], [Un meurtre perpétré par un employé de longue date sans aucun mobile apparent est rare par rapport à un meurtre perpétré par un véritable assassin (qui, lui, avait sûrement un mobile qui nous échappe).],
      [#rv 5\ ADN inconnu sous les ongles (G)], [1], [500], [Les traces d'ADN pointent très fortement vers un tiers H2 ! Mais à l'époque du crime, les contaminations ADN étaient courantes (puisqu'on n'y faisait pas attention)],
      [#rv 6\ lutte pour innocence après grâce (H)], [1], [10], [Si Omar était coupable, il est moins vraisemblable qu'il ne se « contente » pas de la grâce partielle.],
      [#po], [500], [#nb("225'000")], [],
    ))

    $P("coupable") = 500/(#nb("225'500")) approx 0","2 %$

    Bien sûr avec d'autres approximations, vous avez pu obtenir un résultat potentiellement très différent. Ici, ce qui est surtout frappant, c'est que l'incertitude est très grande (et on pourrait estimer qu'elle devrait être en faveur de la présomption d'innocence).
  ],
)

== Exercices supplémentaires

= Exercice 20
#exo(
  exercise: [
    #infoprof[nécessite loi de Bernoulli. Inspiré de #link("https://www.youtube.com/watch?v=NQqWgnNXRiI")[https://www.youtube.com/watch?v=NQqWgnNXRiI] ]
    Le professeur Rogue fait passer un QCM Vrai/Faux de 10 questions à sa classe. Harry et Hermione ont exactement les mêmes réponses. Le professeur Rogue estime que la probabilité d'une bonne réponse est 2/3.
    
    + Calculer la probabilité que Harry et Hermione donnent la même réponse, par hasard, sur une question donnée.
    + Calculer la probabilité que Harry et Hermione aient toutes leurs réponses identiques.
    + Le professeur Rogue devrait-il les sanctionner ?
  ],
  solution: [
    
    + On peut faire un arbre
      #align(center, arbre2(a: $B$, b: $F$, p: ($2/3$, $1/3$), q: (($2/3$, $1/3$), ($2/3$, $1/3$))))
      Harry et Hermione auront la même réponse s'ils ont tous les deux répondu juste ou tous les deux répondu faux :\
      $P("même réponse") = 2/3 dot 2/3 + 1/3 dot 1/3 = 5/9$ et $P("réponse différente") = 1 - 5/9 = 4/9$
    + $P(10 italic("réponses identiques")) = (5/9)^10 approx 0.28 %$\
      Autre rédaction possible en remarquant qu'on est dans le cas d'un schéma de Bernoulli.\
      On répète 10 fois l'expérience suivante :
      #align(center, arbre-se(s: [Même réponse], e: [Réponse différente], p: $5/9$, q: $4/9$))
      Et on suppose que chaque nouvel essai est indépendant du précédent.\
      $P(10 italic("réponses identiques")) = C_10^10 (5/9)^10 dot (4/9)^0 approx 0,28 %$
    #enum.item(4)[Ça dépend de l'a priori du professeur sur la possibilité qu'Harry et Hermione aient triché !

      Par exemple, si cet a priori est 1 :1 (autant de chance qu'ils aient triché que non)
      #tb(
        [Triche : Pas triche],
        (ap, $1 : 1$),
        ([#rv (10 réponses identiques)], $100 % : 0,28 % = 2500 : 7$),
        (po, $2500 : 7$),
      )
      Il est environ 350 fois plus probable qu'ils aient triché

      Si cet a priori est de 1 :50 :
      #tb(
        [Triche : Pas triche],
        (ap, $1 : 50$),
        ([#rv (10 réponses identiques)], $100 % : 0,28 % = 2500 : 7$),
        (po, $2500 : 350 = 50 : 7$),
      )
      Il est à peu près 7 fois plus probable a posteriori que Harry et Hermione aient triché que pas triché.]
  ],
)

= Exercice 21
#exo(
  exercise: [
    Vous avez envoyé un message important à votre ami Fred à 14h00 pour lui demander s'il venait à votre fête ce soir. Il est 17h00. Vous voyez que le message a été affiché comme « *Vu* » à 14h05, mais que Fred n'a toujours pas répondu.
    #align(center, image("figures/fredfete.png", width: 80%))
    
    + Quelle est l'explication que vous imaginez ?
    + Imaginez au moins deux autres explications.
    + Voici trois explications possibles, avec leur probabilité a priori :\
      *Hypothèse 1 (Ignoré) :* Il a vu le message, a décidé de l'ignorer (10 % des situations passées avec lui).\
      *Hypothèse 2 (Oubli/Occupé) :* Il a ouvert l'application en marchant, a été distrait par un prof, un parent ou un cours, et a oublié de répondre (60 % des cas).\
      *Hypothèse 3 (Problème technique) :* Il a posé son téléphone déverrouillé dans son sac, l'écran a frotté, ouvrant l'application par accident sans qu'il le voie (30 % des cas).\ \
      Quelle est votre crédence que Fred est en train de vous ignorer délibérément ?
    + À 17h15, vous ouvrez un groupe de discussion commun. Vous vous apercevez que Fred a posté un mème amusant sur ce groupe à 16h30. Il a donc utilisé son téléphone après 14h05.\
      Comment réajustez-vous votre crédence ?
    + Vous vous souvenez soudain que la veille, vous avez fait une remarque un peu ironique à Fred sur sa nouvelle coupe de cheveux. Il n'a pas souri\
      Comment réajustez-vous votre crédence ?
    + À 17h30, la sœur de Fred vous envoie un message pour autre chose. Vous lui demandez au passage si Fred va bien. Elle vous répond : « _Oui, il est en train de réviser son examen de physique de demain matin non-stop depuis 14h, il a coupé ses notifications mais il s'est accordé une pause de 5 minutes à 16h30 pour souffler._ »\
      Comment réajustez-vous votre crédence ?
  ],
  solution: [
    
    + Son téléphone est cassé, il n'a plus de batterie, plus de connexion Internet, il y a un bug, 
    + Fred est fâché, Fred est malade, Fred est parti sans son téléphone, etc.
    + 10% sans autres informations (subjectif)
    + 
      #tb(
        [H1 (ignoré) : H2 (oubli) : H3 (technique)],
        (ap, $1 : 6 : 3$),
        ([#rv (Post de Fred à 16h30)], $50 % : 50 % : 1 % = 50 : 50 : 1$),
        (po, $50 : 300 : 3$),
      )
      Ca remonte beaucoup les explications ignoré et oublié. L'explication d'un bug technique est presque invalidée par l'observation.
    +
      #tb(
        [H1 (ignoré) : H2 (oubli) : H3 (technique)],
        (ap, $50 : 300 : 3$, []),
        ([#rv (Blague vexante)], $10 : 1 : 1$, [Ici, la blague ayant eu lieu avant, c'est plutôt qu'on révise notre a priori. Mais ça revient toujours à réviser un ratio en y appliquant des facteurs de poids.]),
        (po, $500 : 300 : 3$, []),
      )
      La probabilité qu'il ignore remonte fortement
    +
      #tb(
        [H1 (ignoré) : H2 (oubli) : H3 (technique)],
        (ap, $500 : 300 : 3$),
        ([#rv (Révisions)], $5 : 10 : 1$),
        (po, $2500 : 3000 : 3$),
      )
      $P("ignoré") = 2500/5503 approx 45 %$
  ],
)

= Exercice 22
#exo(
  exercise: [
    *Sally Clark*

    En Grande-Bretagne, à la fin des années 1990, Sally Clark, une jeune avocate issue d'un milieu aisé, perd son premier bébé de la mort subite du nourrisson (MSN). Treize mois plus tard, son deuxième bébé meurt exactement de la même cause. La police, trouvant cette répétition suspecte, l'accuse d'avoir étouffé ses deux enfants.\
    Lors du procès, l'accusation fait appel à un éminent pédiatre, Sir Roy Meadow. Celui-ci présente le calcul suivant aux jurés :
    - Dans une famille aisée et non-fumeuse comme les Clark, le risque de mort subite du nourrisson est de 1 sur 8 500.
    - Puisqu'il y a eu deux morts, la probabilité d'observer ce drame est de $1/8500 dot 1/8500$, soit environ $1/(#nb("73'000'000"))$.
    Le pédiatre conclut devant le jury glacé : « Il y a donc 1 chance sur 73 millions que cette femme soit innocente. » Sally Clark est condamnée à la prison à perpétuité.\ \
    Pourtant, ce pédiatre a fait plusieurs erreurs mathématiques. L'inférence bayésienne aurait pu sauver Sally Clark…
    
    + Le pédiatre a multiplié les probabilités pour obtenir $1/(#nb("73'000'000"))$. Avait-il le "droit" ?
    + La phrase finale du pédiatre (« 1 chance sur 73 millions qu'elle soit innocente ») est une erreur. Quel est le nom de cette erreur et quelle est la véritable signification de ce chiffre de 1 / 73 000 000 ?
    + En corrigeant l'erreur en 1), les statisticiens ont évalué la vraie probabilité de subir deux MSN autour de 1 sur 100'000.\
      Par ailleurs, ils ont estimé que la probabilité pour qu'une mère de 2 enfants les tue est de $1/(#nb("650'000"))$\
      Construisez le tableau bayésien pour évaluer la situation.
    + Refaites le raisonnement en partant d'une population de $#nb("650'000")$ mères.
  ],
  solution: [
    
    + Pour multiplier deux probabilités, les événements doivent être *indépendants* (comme des lancers de dés). Or la mort subite du nourrisson a des facteurs environnementaux et génétiques : si un premier enfant en meurt, le risque pour le deuxième enfant de la même famille augmente fortement.\
      Par ailleurs, le pédiatre a commis un biais de sélection (cherry-picking) pour obtenir son 1 sur 8 500: il a choisi un groupe de référence restrictif (famille aisée, groupe qui a moins de MSN) mais il aurait pu choisir un autre groupe, par exemple famille avec des bébés garçons (il aurait trouvé une probabilité plus élevée car les garçons sont statistiquement bien plus touchés par la MSN que les filles).
    + Il s'agit d'un biais du procureur. Le pédiatre a confondu\
      $P(italic("observer 2 MSN") | italic("mère innocente"))$ qui est très très faible (heureusement !) et\
      $P(italic("mère innocente") | italic("on a observé 2 MSN"))$ qui est nettement moins faible, comme on va le calculer.
    + #tb(
        [Coupable : Innocente],
        (ap, $1 : #nb("650'000")$, [Selon les statistiques d'homicides effectuées par Ray Hill.\ Ce n'est pas surprenant : les mères de 2 enfants tuent très très rarement leurs deux enfants, _a priori_ !]),
        ([#rv (deux MSN)], $#nb("100'000") : 1$, []),
        (po, $#nb("100'000") : #nb("650'000") approx 1 : 6,5$, []),
      )

      Note : après la mobilisation des statisticiens, la condamnation de Sally Clark a été annulée et elle a été libérée.\
      Par ailleurs, sur le deuxième enfant, on a observé une infection à S. aureus qui augmente énormément la probabilité d'une mort par MSN.
    + Repartir d'une population complète :\
      Prenons 65 millions de mères de deux enfants (nombre choisi pour tomber rond) :
      - Coupables : $#nb("65'000'000") div #nb("650'000") = 100$ mères. Dans ce cas, leurs deux enfants meurent tués.
      - Innocentes : $approx$ 65'000'000 dont $#nb("65'000'000") dot 1/(#nb("100'000")) = 650$ mères dont les deux enfants meurent de MSN
      - Total de mères ayant perdu leurs deux enfants : $100 + 650 = 750$.

      Sur ces 750 mères endeuillées, 100 sont coupables ($approx$ 13 %) et 650 sont innocentes ($approx$ 87 %). Soit 1:6,5.

      Une coïncidence très rare (la double MSN) peut sembler une preuve très forte, mais si l'accusation portée est encore plus rare (une mère qui tue ses deux enfants), c'est elle qui reste la moins crédible.
  ],
)
/*
= Exercice 23
#exo(
  exercise: [
    L'angine chez l'être humain est provoquée soit par une bactérie (angine bactérienne), soit par un virus (angine virale).\
    On admet qu'un malade ne peut pas être à la fois porteur du virus et de la bactérie.\
    L'angine est bactérienne dans 20% des cas.\
    Pour déterminer si une angine est bactérienne, on dispose d'un test. Le résultat du test peut être positif ou négatif. Le test est conçu pour être positif lorsque l'angine est bactérienne, mais il présente des risques d'erreur :
    - si l'angine est bactérienne, le test est négatif dans 30% des cas;
    - si l'angine est virale, le test est positif dans 10% des cas.
    On choisit au hasard un malade atteint d'angine. On note :\
    B l'événement : “l'angine du malade est bactérienne” ;\
    T l'événement : “le test effectué sur le malade est positif”.
    + Représenter la situation par un arbre de probabilité
    + Un malade est choisi au hasard parmi ceux dont le test est positif. Quelle est la probabilité pour que son angine soit bactérienne ?
    + On choisit au hasard cinq malades atteints d'une angine.
      #enum(
        numbering: "a.",
        [Calculer la probabilité qu'au moins l'un des cinq malades ait un test positif.],
        [\* En moyenne, sur ces 5 malades, combien seront positifs ?],
      )
    #link("https://www.youtube.com/watch?v=Wnn5BVlQfNI")[https://www.youtube.com/watch?v=Wnn5BVlQfNI]
  ],
)

#intermede(titre:"Comment évalue-t-on l'efficacité d'un médicament ?")[
  Pour déterminer si un médicament est réellement efficace, les scientifiques utilisent en général des essais cliniques randomisés en double aveugle :
  - Randomisation : Les patients sont répartis aléatoirement en deux groupes (l'un recevant le médicament, l'autre un placebo).
  - Double aveugle : Ni les patients ni les médecins ne savent qui reçoit quoi, pour éviter les biais psychologiques.
  - Comparaison : On mesure si le groupe traité guérit significativement plus que le groupe placebo.
  - Analyse statistique : On vérifie que l'effet observé n'est pas dû au hasard.

  En homéopathie, les études ne montrent souvent aucun effet supérieur au placebo, ce qui explique pourquoi les autorités sanitaires (OMS, ANSM) ne la reconnaissent pas comme une médecine efficace.
]

= Exercice 24
#exo(
  exercise: [
    Un hôpital teste l'efficacité des _coupeurs de feu_ (fiction):
    - 30 % des patients brûlés consultent un coupeur de feu.
    - 70 % des patients guérissent en une semaine sans intervention (guérison naturelle).
    - 80 % des patients guérissent en une semaine après avoir vu un coupeur de feu.
    Si un patient guérit en une semaine, quelle est la probabilité qu'il ait consulté un coupeur de feu ?
  ],
)

#intermede(titre:" Pseudo médecines ")[
  Quand une pratique comme la coupure de feu ou l'homéopathie semble "marcher" , c'est souvent la guérison naturelle qu'on observe plutôt qu'un effet réel. Ce biais, appelé régression vers la moyenne, pousse à attribuer la guérison au traitement pris juste avant.

  Les risques concrets sont réels :
  - Retard de soins : un patient qui consulte un coupeur de feu avant un médecin perd un temps précieux. Pour une brûlure profonde, une infection, ou un cancer, ce délai peut être critique.
  - Arrêt d'un traitement efficace : certains patients abandonnent leur traitement conventionnel en faveur d'une alternative, avec des conséquences graves documentées, notamment en oncologie.
  - Coût financier : ces pratiques sont souvent payantes et non remboursées.
]
*/