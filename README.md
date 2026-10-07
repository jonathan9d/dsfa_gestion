# DSFA Gestion

Application **Windows** de gestion du cycle d'une activité DSFA / UNICEF :
activités, budgets alloués, participants, présences, indemnités, dossier des
pièces justificatives, dépenses, banque, rapprochement, rapports et paramètres.

Tout fonctionne **hors ligne** : la base de données est un fichier SQLite local,
et les exports sont écrits là où l'utilisateur le demande.

> Cible de distribution : **Windows 10 / 11 (64 bits)**. La cible Android est
> présente dans le dépôt mais n'est ni compilée ni distribuée.

---

## 1. Fonctionnalités

### Activités
- Création/modification avec code généré automatiquement, code budget
  auto-incrémenté (`bud_1`, `bud_2`, …), type, période, lieu (district du
  référentiel), source de financement (liste `FINANCEMENT`).
- Nombre de jours calculé automatiquement à partir des dates.
- Pré-remplissage des distances et du délai de route depuis
  `DISTANCES_DISTRICTS`.
- Suppression en cascade transactionnelle (présences, indemnités, lignes
  budgétaires, contrôles PJ et dépenses liées).

### Budgets
- **Type de budget déduit automatiquement** du libellé de la ligne
  (indemnités équipes/chauffeurs, carburant, location, restauration,
  fournitures, déplacement forfaitaire, transfert, taxi-brousse, billet
  d'avion).
- **Aucune rubrique libre** : la rubrique est retrouvée dans les paramètres
  (`REFERENTIEL_TARIFS`) à partir du libellé de la ligne. La **location de
  salle** relève de la rubrique **restauration / frais d'organisation**.
- Montant alloué **toujours calculé** selon les règles ; un montant
  explicitement **confirmé** est mis en évidence (pastille verte) et reste
  distinct du prévisionnel.
- Carburant : distance **aller-retour calculée automatiquement** depuis le
  district de destination, consommation par type de véhicule, nombre de
  véhicules et prix unitaire.
- Indemnités : règle d'or
  `délai de route × 100 % + jours d'activité × (85 % si déjeuner pris en charge, 100 % sinon)`.

### Dossier PJ
- **Onglet « Présences & indemnités »** : un **seul tableau**, une ligne par
  participant. Le **nombre de jours d'activité se modifie directement dans le
  tableau** et met à jour la fiche de présence du participant (les N premiers
  jours de l'activité sont « Présent », les suivants « Absent »).
- **Onglet « Pièces justificatives »** : uniquement la **checklist des PJ
  requises**, déduite mot pour mot de la matrice `PARAMETRES` et regroupée par
  rubrique, avec la date de PJ, le contrôle automatique des délais, et l'état
  conservé par activité.
- Les contrôles PJ détaillés (écarts, journal des dépenses) restent accessibles
  par l'action « Contrôles détaillés » de l'en-tête.

### Suivi, rapports et tableau de bord
- Suivi par activité : réception des fonds, montant alloué, dépenses
  réalisées, écart, réception des PJ, date de rapportage, statut de rapportage
  (seuils UNICEF / autres bailleurs).
- Rapport financier alloué / réalisé / écart, séries du tableau de bord.
- Rapprochement bancaire.

### Pré-impression et exports
- Pré-impression du budget **regroupée par rubrique**, avec le **total de
  chaque rubrique** puis le total général.
- Les **fournitures** sont présentées en **post-it** (une ligne = une note).
- Export Excel cohérent avec la pré-impression : colonne « Rubrique », blocs
  par rubrique, **sous-total par rubrique**, total général.
- Exports Excel/PDF des activités, présences, indemnités, dépenses, banque,
  rapprochement et contrôles PJ.

### Interface
- Écran d'accueil qui **salue l'utilisateur avant la connexion**.
- Thème clair/sombre/système, couleurs primaire et secondaire réglables,
  échelle de police.
- Tableaux : **largeurs de colonnes mesurées sur le contenu réel** (aucun mot,
  chiffre ni date coupé), défilement horizontal quand c'est nécessaire, tri par
  clic sur l'en-tête **sans chevron**, filtres **masqués par défaut** (bouton
  « Filtrer », ou réglage pour les ouvrir d'emblée), sélection multiple avec
  totaux, pagination et « Tout afficher ».
- Toutes les saisies sont **vérifiées avant enregistrement** (champs
  obligatoires, listes de référence, dates cohérentes, montants positifs).
- Journal d'audit des créations, modifications et suppressions.

---

## 2. Prérequis

- Flutter et le SDK Dart compatibles avec `pubspec.yaml`.
- **Windows** + Visual Studio avec la charge de travail *Développement
  Desktop en C++*.
- **Inno Setup 6+** pour générer l'installateur (par défaut :
  `C:\Program Files (x86)\Inno Setup 6\ISCC.exe`).

## 3. Développement

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Résultat attendu : `flutter analyze` **sans erreur** et l'intégralité des tests
au vert.

Au **premier démarrage**, l'application crée le compte administrateur : aucun
identifiant ni mot de passe n'est préconfiguré ni livré.

## 4. Compiler la version Windows et l'installateur

```powershell
flutter build windows --release
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\dsfa_gestion.iss
```

- Application : `build\windows\x64\runner\Release\dsfa_gestion.exe`
- Installateur : `build\installer\DSFA_Gestion_Setup_<version>.exe`

`build_installer.cmd` enchaîne les deux étapes (à lancer depuis une invite de
commandes Windows, l'ISCC n'étant pas accessible depuis les shells POSIX).

## 5. Fichier de paramètres

`parametres.xlsx` est le **classeur de référence** embarqué : il porte les
taux, les seuils de rapportage, le référentiel tarifaire, les distances des
districts, les listes de valeurs et la **matrice des PJ requises**. Il est
nécessaire à l'import initial.

Les classeurs de gestion contenant des données réelles (présences, indemnités,
dépenses…), les exports, les bases locales, les journaux et les fichiers de
signature **ne sont pas distribués** : ils sont ignorés par Git, à l'exception
de ce classeur de référence.

## 6. Organisation du code

```
lib/
  data/
    database/       tables Drift + base SQLite
    repositories/   accès aux données (activités, budget, présences, PJ…)
  domain/
    regles_metier.dart      règle d'or des indemnités, carburant, écarts
    regles_parametres.dart  lecture de la feuille PARAMETRES (matrice PJ)
    rubriques.dart          résolution des rubriques depuis les paramètres
    services/               contrôle PJ, rapprochement, rapports…
  presentation/
    screens/                écrans par domaine (activités, budgets, dossier PJ…)
    widgets/                tableau générique, composants communs, thème
    reglages/               préférences d'affichage persistées
  services/                 import Excel, exports Excel/PDF
test/                       tests unitaires et de widgets
installer/                  script Inno Setup
```

## 7. Plateformes

Seule la cible **Windows** est maintenue et publiée. Consultez la documentation
officielle Flutter pour l'installation des outils : <https://docs.flutter.dev/>.
