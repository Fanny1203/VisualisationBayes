# Probabilités conditionnelles — fréquences naturelles

Outil interactif en une seule page HTML pour comprendre le théorème de Bayes en raisonnant sur des **effectifs** (une population de 100, 1 000 individus…) plutôt que sur des formules. Pensé pour l'enseignement de l'esprit critique : faux positifs, négligence des taux de base, confusion entre P(O|H) et P(H|O) (sophisme du procureur)…

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
Une grille d'individus (10 × 10 par défaut, jusqu'à 200 × 200).

- **Fond bleu** = individu H ; **cercle rouge** = individu O (case « Afficher O »).
- **Ordonné** : les H sont rangés en colonnes à gauche et les O empilés depuis le bas, comme dans le diagramme. Décoché : placement aléatoire (graine fixe, donc stable).
- **Isoler O / Isoler H** : regroupe et sépare les individus concernés ; « Isoler H » affiche en plus la comparaison P(O|H) ≠ P(H|O).
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
