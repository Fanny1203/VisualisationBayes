# Raisonnement bayésien : cours et visualisateur

Ce dépôt réunit 
- un cours sur le raisonnement bayésien (CoursTypst /)
- un visualisateur pour accompagner ce cours (bayes1000.html)

---

# Le cours (Typst)

Il s'agit d'un cours un peu original, à l'intersection de l'esprit critique et des maths. Il donne aux élèves des outils pour réfléchir de manière "bayésienne" :
- penser en crédence (plutôt qu'en binaire vrai ou faux)
- se souvenir de nos a priori (contre l'erreur de négligeance du taux de base)
- penser de manière contrefactuelle : « et si » ma théorie était fausse ? Pourrais-je quand même observer ce que j'observe ? (mettons nos croyances à l'épreuve !)
-	Mettons vos crédences à jour

L'approche est très visuelle (diagrammes) et facilitée par l'utilisation de tableaux.

## Inspiration et sources
- Je dois ma rencontre du « bayésianisme » à deux vidéos de Monsieur Phi sur le théorème de Bayes (https://youtu.be/3FOrWMDL8CY et  https://youtu.be/aU7EWwLtiOg. C'est de ses vidéos que je tire la première question qui défie notre intuition. 
- Je suis retombée sur le bayésianisme plusieurs fois ensuite, notamment dans le livre « The Art of Statistics » de David Spiegelhalter que j’ai beaucoup aimé et m'a poussée à creuser l' "épistémologie bayésienne".
- Grâce au livre "Think Bayes" de Allen B. Downey (accessible en ligne : https://allendowney.github.io/ThinkBayes2/index.html), j'ai pu avoir une approche informatique des raisonnements bayésiens et mieux me les approprier. Dans ce livre, on manipule beaucoup de tableaux de ratios, que j’ai repris dans le cours car ils me semblaient particulièrement clairs.
- Enfin, c'est Julia Galef, via plusieurs vidéos sur le théorème de Bayes, qui m'a convaincue que c'est accessible (https://youtu.be/za7RqnT7CM0 et https://youtu.be/BrK7X_XlGB8 ). Je tiens de cette dernière vidéo la présentation en « diagramme bayésien ».
- J’avais d’abord fait une première version du cours très différente, se basant essentiellement sur la formule de bayes écrite sous la forme : P(T/O)=P(T) x P(O/T)/P(O) qui était plus proche de la vision proposée par la chaîne Rational Animations : https://www.youtube.com/watch?v=4hHA-oqpNig.

## Fichiers

Chapitre **P5 - Inférence bayésienne**, dans [`CoursTypst/`](CoursTypst/) :

- [`P5-theorie.typ`](CoursTypst/P5-theorie.typ) : la théorie : crédence, diagramme et tableau bayésiens, manipulation de ratios, vraisemblance, répétition des observations, comparaison de plusieurs hypothèses, conséquences épistémiques, démonstrations.
- [`P5-exercices.typ`](CoursTypst/P5-exercices.typ) : une série de 24 exercices (dont des enquêtes et des exercices supplémentaires).
- [`figures/`](CoursTypst/figures/) : images utilisées par les deux documents.

Chaque fichier est autonome (bibliothèque de styles incluse en tête, contenu du chapitre plus bas). Il existe trois "modes" pour chaque document : **élève** (les réponses sont à compléter), **complète** et **prof** (avec les remarques pour l'enseignant).

## Compilation
Avec la [CLI Typst](https://github.com/typst/typst) (les paquets `cetz` et `exercise-bank` sont téléchargés automatiquement) ; le dossier `figures/` doit rester à côté des fichiers `.typ` :

```
cd CoursTypst
typst compile P5-theorie.typ
typst compile --input mode=eleve P5-theorie.typ P5-theorie-eleve.pdf
typst compile --input mode=prof  P5-exercices.typ P5-exercices-prof.pdf
```

---

# Le visualisateur

Exemple par défaut : un test de dépistage (`Test +`) pour une maladie (`Malade`), avec 10 % de malades, 90 % de tests positifs chez les malades et 5 % de tests positifs chez les non-malades.

## Utilisation

Aucune installation : ouvrir `bayes1000.html` dans un navigateur récent.

> La page charge la police IBM Plex et KaTeX depuis un CDN (jsDelivr / Google Fonts) : une connexion internet est nécessaire pour l'affichage complet des formules et des polices.

## Paramètres (panneau de gauche)

| Rubrique | Contenu |
|---|---|
| **Noms des événements** | Nom de l'hypothèse **H** (ex. « Malade ») et de l'observation **O** (ex. « Test + »). |
| **Paramètres (en %)** | P(H) (P(non H) est complété automatiquement), puis les vraisemblances P(O\|H) et P(O\|non H). |
| **Symbole des individus** | Émoji utilisé dans la visualisation, avec une petite galerie. Champ vide = simples ronds. |

## Les trois onglets

### Visualisation
Une grille d'individus (10 × 10 par défaut, jusqu'à 200 × 200). Les très grandes grilles servent peu en pratique, mais elles aident à passer à une visualisation **continue** (le diagramme) ; elles peuvent être un peu lentes à afficher avec des émojis.

- **Fond bleu** = individu H ; **cercle rouge** = individu O (case « Afficher O »).
- **Ordonné** : les H sont rangés en colonnes à gauche et les O empilés depuis le bas, comme dans le diagramme. Décoché : placement aléatoire (graine fixe, donc stable).
- Un tableau d'effectifs (H et O, H et non O, etc.) et le calcul de P(H|O) en effectifs : `P(Malade | Test +) = 9 / (9 + 5) = 9 / 14 = 66,7 %`.

### Arbre
Arbre de probabilités pondéré (largeur max. ≈ 10 cm).

- Les branches de premier niveau sont épaisses selon leur probabilité ; celles du second niveau selon la **probabilité jointe**, pour repérer d'un coup d'œil les cas les plus fréquents.
- Chaque feuille indique sa probabilité jointe et son effectif.
- Bouton **Renverser l'arbre** : O d'abord, puis H (affiche P(H|O) et P(H|non O)).

### Diagramme
Diagramme en aires continu (colonnes H / non H, puis hauteur O) avec, à côté, le tableau de raisonnement par **rapports (odds)** :

| | Malade *versus* non Malade |
|---|---|
| A priori | 10 : 90 = 1 : 9 |
| Vraisemblance (Test +) | 90 : 5 = 18 : 1 |
| A posteriori | (1·18) : 9 = 18 : 9 → 2 : 1 |

La case « Afficher O » révèle la vraisemblance, l'a posteriori et les formules de Bayes.

## Partager une configuration par URL

L'adresse se met à jour automatiquement :

```
bayes1000.html?variables=Malade,Test%20%2B,10,90,5,10,10,%F0%9F%A7%8D%E2%80%8D%E2%99%82%EF%B8%8F
```

Ordre des champs, séparés par des virgules (chacun encodé en URL) :

1. nom de H
2. nom de O
3. P(H) en %
4. P(O|H) en %
5. P(O|non H) en %
6. nombre de colonnes
7. nombre de lignes
8. symbole (émoji)

Les champs manquants gardent leur valeur par défaut.

## Accessibilité

Palette adaptée au daltonisme (couleurs d'Okabe et Ito pour les branches de l'arbre et les catégories) ; dans la grille, l'information passe aussi par la forme (cercle) et la position, pas seulement par la couleur.

## Technique

- Un seul fichier HTML, sans build : JavaScript natif et `<canvas>` pour l'arbre, la grille et le diagramme.
- [KaTeX](https://katex.org/) pour les formules.

---

# Auteurs et licence

- **Auteurice** : Fanny Boitard, enseignante de mathématiques à Genève
- **Licence** : [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.fr) pour un usage pédagogique. 
- Visualisateur html largement vibe-codé dans VS Code avec Claude

N'hésitez pas à me faire part de vos suggestions
