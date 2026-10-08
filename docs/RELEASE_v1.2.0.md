# DSFA Gestion 1.2.0

Distribution **Windows 10 / 11 64 bits** uniquement.

---

## Dépenses : la saisie du budget, plus 3 champs

- La saisie d'une dépense reprend **exactement la même forme que le budget** :
  désignation, unité, quantité, fréquence, prix unitaire, observation, et
  **rubrique déduite automatiquement des paramètres** (jamais saisie librement).
- Trois champs supplémentaires : **Référence PJ**, **Bénéficiaire** et
  **Mode de paiement**.
- Le **montant reste calculé automatiquement** ; si une formule est définie
  dans la configuration, c'est elle qui est utilisée (le bandeau l'indique).
- Les colonnes bénéficiaire sont ajoutées à l'export Excel et reprises par
  l'import ; il est stocké en base (migration `schemaVersion 6`).

---

## Paramètres ▸ onglet « Configuration »

Toute l'application devient personnalisable **sans jamais casser les
automatismes**.

### Onglets & présentation
- Titre, sous-titre, **icône** et **couleur** de chaque écran.
- Réorganisation (monter / descendre), masquage, suppression.
- **Création d'un nouvel onglet** : on choisit le **contenu du tableau** et les
  **actions autorisées** (ajouter, modifier, supprimer, rechercher, filtrer,
  sélectionner, configuration).
- Pour l'icône : **catalogue d'environ 90 icônes Material**, ou **import** d'une
  image au format exact — **PNG ou JPEG, carré, 512 × 512 maximum, moins de
  400 Ko**. Indice : <https://fonts.google.com/icons> propose des icônes
  gratuites et libres de droits.

### Champs & colonnes
- Renommer un champ (le titre de la colonne suit), changer son **type** et sa
  **largeur**, le **masquer**, le rendre **obligatoire**, le **déplacer**,
  en **ajouter** un nouveau.
- **Suppression** : si le champ est un **parent**, une **confirmation** liste
  les conséquences et les modifications s'appliquent **en cascade** (champs
  enfants retirés, formules qui le référencient **vidées**).

### Formules
- Écriture d'une formule avec **vérification en direct** et **aperçu du résultat**.
- Références entre crochets `[montant]`, opérateurs `+ - * / ( )` et fonctions
  `si`, `min`, `max`, `abs`, `arrondi`, `plafond`, `plancher`, `racine`,
  `somme`, `moyenne`, `nombre`.
- Toute erreur est expliquée **en français** : champ inconnu, expression
  incomplète, division par zéro, virgule décimale refusée (« Utilisez un point
  pour les décimales »).

### Statuts & couleurs
- La **couleur et l'icône de chaque statut** sont modifiables ; de **nouvelles
  valeurs** peuvent être ajoutées.
- Les automatismes continuent de fonctionner : contrôle PJ, rapprochement,
  suivi, présences, indemnités.

### Rubriques & lignes budgétaires
- **CRUD complet** des rubriques.
- **Classement** des lignes budgétaires : ligne par ligne, ou
  « **Classer automatiquement** » depuis le référentiel des tarifs.
- **Copie des règles PJ** d'une rubrique vers une autre (avec compteurs de
  lignes et de règles PJ liés).
- Renommer ou supprimer une rubrique agit **en cascade** sur les lignes
  budgétaires, les règles PJ et les affectations enregistrées.

### Bouton « Configuration »
- Un bouton **en haut de chaque onglet** ouvre directement la configuration de
  l'écran courant (largeur ≥ 900 px : bouton libellé, sinon bouton compact).

---

## Ce qui reste verrouillé

Les **règles & matrices PJ**, les **districts** et les **tarifs** du classeur
`parametres.xlsx` restent la **source de vérité** : la configuration
personnalise l'affichage, les titres, les colonnes et les calculs, **sans
jamais les contourner**.

La configuration est enregistrée dans la base (clé `configuration_app`) puis
**fusionnée avec les valeurs livrées** : une mise à jour ajoute les nouveautés
**sans écraser vos personnalisations**.

---

## Interface et flux de travail

- Redimensionnement à la souris des colonnes et de la hauteur des tableaux,
  dimensions conservées par écran.
- Parcours de démarrage animé, salutation avant la connexion et changement de
  thème avec transition douce.
- Checklist des pièces justificatives simplifiée ; sélection individuelle des
  dates de présence au calendrier.
- Couleurs personnalisées ou choisies parmi trois accords prédéfinis, son
  d'interaction désactivable et motif géométrique discret facultatif.
- Compteur gris des modifications journalisées dans le menu latéral et ruban
  animé des partenaires.
- Sauvegardes manuelles `save_1.db`, `save_2.db`, etc. ; sauvegarde automatique
  remplacée uniquement à la fermeture de l'application.
- Suppression du projet Android : la seule plateforme prise en charge est
  Windows.

---

## Qualité

- `flutter analyze` : **0 erreur et 0 avertissement** (infos de lint existantes).
- `flutter test` : **106 tests** au vert, dont les nouveaux
  `configuration_test.dart` et `depenses_saisie_test.dart`.
- `flutter build windows --release` : réussi.

---

## Fichiers

- `DSFA_Gestion_Setup_1.2.0.exe` : installateur Windows 64 bits.

Aucun identifiant ni mot de passe n'est livré : le compte administrateur est
créé au premier démarrage.
