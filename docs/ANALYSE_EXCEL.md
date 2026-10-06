# Analyse du classeur `Controle_PJ_DSFa_UNICEF_avec_presences_indemnites.xlsx`

Source fonctionnelle de référence. Ne jamais modifier le fichier original.

## 1. Feuilles identifiées

| Feuille | Rôle | Nature |
|---|---|---|
| `ACCUEIL` | Menu de navigation | Présentation |
| `BUDGET` | Générateur automatique de budget / PTA pour une activité | Saisie + calculs |
| `DISTANCES_DISTRICTS` | Référentiel géographique (région/district, distances, délais route) | Référentiel |
| `LISTES` | Listes de valeurs (types d'activité, rubriques, lignes budgétaires, PJ, statuts) | Référentiel |
| `REFERENTIEL_TARIFS` | Tarifs unitaires par rubrique / ligne / zone | Référentiel |
| `LISTES ACTIVITES` | Activités (référence, description, code budget, année, période) | Données source |
| `J.Banque` | Journal de banque (recettes / dépenses / solde progressif) | Données source |
| `J.Depenses` | Journal des dépenses | Données source |
| `Rappr Banc ` | État de rapprochement bancaire (journal vs relevé) | Données source + calculs |
| `REFERENTIEL_BUDGET` | Budget alloué par activité et par ligne budgétaire | Données source + calculs |
| `CONTROLE_PJ` | Contrôle des pièces justificatives | Données source + calculs |
| `PRESENCES_INDEMNITES` | Présences des participants et indemnités | Données source + calculs |
| `RAPPORT FINANCIER` | Rapport financier (alloué / réalisé / écart) | Rapport |
| `TABLEAU_DE_BORD` | Indicateurs de synthèse | Dashboard |

## 2. Colonnes par feuille

### DISTANCES_DISTRICTS
`N°`, `CHEF-LIEU DE RÉGION`, `REGION`, `DISTRICT`, `EST CHEF-LIEU RÉGION`,
`DISTANCE TANA ALLER (km)`, `DISTANCE TANA ALLER (km) CARBURANT` (= aller × 2),
`DÉLAI ROUTE ALLER`, `DÉLAI ROUTE RETOUR`, `DÉLAI ROUTE ALLER ET RETOUR` (= aller + retour).

Règles :
- `EST CHEF-LIEU RÉGION` = `OUI` si `DISTRICT == CHEF-LIEU DE RÉGION` (comparaison insensible à la casse).
- `DISTANCE ... CARBURANT` = `DISTANCE ALLER × 2`.
- `DÉLAI ALLER ET RETOUR` = `DÉLAI ALLER + DÉLAI RETOUR`.

### REFERENTIEL_TARIFS
`RUBRIQUE`, `Ligne budgétaire`, `Type activité`, `Unité`, `Zone`, `Tarif (Ar)`, `Actif`, `Observation`.
Tarifs clés : Indemnité région 200 000, district 150 000, chauffeur 200 000, AC (formation) 60 000,
déplacement forfaitaire centraux 50 000, régionaux région 30 000, district 20 000.

### LISTES
`Type de saisie` (Atelier/Réunion, Supervision, Formation, Acquisition, Mission extérieur),
`RUBRIQUE`, `LIGNE BUDGETAIRE`, `INDEMNITES` (Delai de route / Pendant activité),
`Avec Déjeuner ou sans Déjeuner`, `PJ reçue`, `PJ conforme`, `Type de PJ`, `Statut présence`.

### LISTES ACTIVITES
`Référence activité`, `Description`, `Code budget`, `Année`, `Période`.

### REFERENTIEL_BUDGET
`Code activité`, `Activité` (=VLOOKUP sur LISTES ACTIVITES), `Date début prévue`, `Date fin prévue`,
`Ligne budgétaire`, `Unité`, `Quantité prévue`, `Nombre de jour`, `Taux / Montant unitaire`,
`Montant alloué`, `Observations`.

**Règle : `Montant alloué = Quantité prévue × Taux unitaire × Nombre de jour`**
(lorsque le nombre de jours est renseigné, sinon `Quantité × Taux`).

### PRESENCES_INDEMNITES
`N°`, `Code activité`, `Participant`, `Fonction / Structure`, `Date activité`,
`Présence1..Présence5`, `Signature / preuve`, `Taux journalier prévu`,
`Indemnité théorique`, `Indemnité reçue`, `Écart indemnité`,
`Date dans période ?`, `Présence justifie paiement ?`, `Montant conforme ?`,
`Résultat contrôle`, `Observation`.

**Règles métier (formules Excel transformées en règles Dart) :**
- `Indemnité théorique = NB_PRÉSENTS × Taux journalier prévu`
  (Excel : `COUNTIF(F:J,"Présent")*L`).
- `Écart indemnité = Indemnité reçue − Indemnité théorique`.
- `Date dans période ?` = `OUI` si `Date activité ∈ [Date début, Date fin]` de l'activité (REFERENTIEL_BUDGET).
- `Présence justifie paiement ?` = `OUI` si dernier jour `Présent` et `Signature / preuve` non vide ;
  `NON` si dernier jour `Absent` ; sinon `À vérifier`.
- `Montant conforme ?` = `OUI` si `Écart indemnité = 0`.
- `Résultat contrôle` (priorité) :
  1. `DATE HORS PÉRIODE` si date hors période,
  2. `PAIEMENT SANS PRÉSENCE` si présence ne justifie pas,
  3. `PRÉSENCE À VÉRIFIER` si à vérifier,
  4. `MONTANT NON CONFORME` si montant non conforme,
  5. sinon `CONFORME`.

### CONTROLE_PJ
`N°`, `Code activité`, `Activité` (VLOOKUP), `Date début activité`, `Date fin activité`, `Date PJ`,
`Ligne budgétaire`, `Bénéficiaire / Fournisseur`, `Type de PJ`, `Montant alloué`, `Montant payé`,
`Montant PJ`, `Écart Budget`, `Écart PJ`, `PJ reçue`, `PJ conforme`, `Date PJ cohérente ?`,
`Montant contrôlées`, `Budget indemnités disponible`, `Contrôle présence/indemnité`,
`Observation`, `Statut final`.

**Règles métier :**
- `Écart Budget = Montant payé − Montant alloué`.
- `Écart PJ = Montant PJ − Montant payé`.
- `Date PJ cohérente ?` = `OUI` si `Date début ≤ Date PJ` **et** `Date fin ≤ Date PJ`.
- `Budget indemnités disponible` = somme des montants alloués (REFERENTIEL_BUDGET) de l'activité pour la ligne.
- `Montant contrôlées` = somme des indemnités théoriques conformes (PRESENCES_INDEMNITES) de l'activité
  lorsque la ligne est une ligne d'indemnités.
- `Contrôle présence/indemnité` :
  1. `Anomalie détectée` si l'activité a des lignes de présence/indemnité non `CONFORME`,
  2. `Dépassement budget indemnités` si `Montant contrôlées > Budget indemnités disponible`,
  3. sinon `Conforme`.
- `Statut final` (priorité) :
  1. `PJ non reçue` si `PJ reçue = Non`,
  2. `Date PJ non conforme` si `Date PJ cohérente ? = Non`,
  3. `Non conforme` si `Écart Budget > 0` **ou** `Écart PJ ≠ 0` **ou** `PJ conforme = Non`
     **ou** contrôle présence = `Anomalie détectée`/`Dépassement budget indemnités`,
  4. `À vérifier` si `PJ conforme = À vérifier`,
  5. sinon `Conforme`.

### J.Banque
En-tête : `BANQUE`, `COMPTE N.`, `DEVISE`.
Colonnes : `Date`, `Ref Pieces Jrnl`, `Type`, `Ref chq/OV/…`, `Description`, `Recettes`, `Depenses`,
`Solde progressif`, `BAILLEURS`, `BENEFICIAIRES`.
- Ligne `SOLDE` initiale = report de solde (recette).
- `Solde progressif` = recettes cumulées − dépenses cumulées.

### J.Depenses
`Date d'enregistrement`, `Date Pieces comptables`, `Periode autorisee`, `Fonds: caisse ou banque`,
`REF Decaismnt`, `Ref pieces de depense`, `DCT N°`, `Code Activite`, `Code Budget`, `Désignation`,
`Unite`, `Nbr Jr/Mois`, `Quantité`, `Fréquence`, `P.U.`, `Montant`.

**Règle : `Montant = Nbr Jr/Mois × Quantité × Fréquence × P.U.`**

### Rappr Banc
`JOURNAL DE BANQUE` (DATE, REF, LIBELLE, DEBIT, CREDIT) vs `RELEVE BANCAIRE` (DATE, REF, LIBELLE, DEBIT, CREDIT, SOLDE).
- `SOLDE RAPPROCHÉ journal = solde initial − débit + crédit + total en circulation (débit/crédit)`.
- `SOLDE RAPPROCHÉ relevé = crédit initial − débit initial + crédit circulation − débit circulation`.
- `ÉCART = Solde rapproché journal − Solde rapproché relevé`.

### RAPPORT FINANCIER
Par rubrique : `BUDGET ALLOUÉ A`, `Unité`, `Quantité a`, `Fréquence b`, `PU c`,
`Montant Total d = a×b×c`, `ECART A−B`.
En-tête : `Montant alloué`, `Dépense réalisée`, `Reliquat = alloué − réalisé`.

### TABLEAU_DE_BORD
- Montant total alloué / payé / PJ, écart budget total, écart PJ total.
- Dossiers conformes / non conformes / PJ non reçues / dates PJ non conformes.
- Anomalies présence/indemnité.

## 3. Modèle relationnel retenu (SQLite / Drift)

```
districts            (référentiel géographique)
referentiel_tarifs   (tarifs)
reference_valeurs    (listes déroulantes, PJ, statuts)
activites            (LISTES ACTIVITES + paramètres REFERENTIEL_BUDGET)
lignes_budget        (REFERENTIEL_BUDGET + générateur BUDGET)
participants
activite_participants
presences            (une ligne par participant et par date)
controle_pj
depenses             (J.Depenses)
banque_operations    (J.Banque)
releve_bancaire      (relevé pour rapprochement)
utilisateurs
journal_audit        (historique)
parametres           (clé/valeur)
```

Relations :
- `activites.code` ← `lignes_budget.activite_code`, `presences.activite_code`,
  `controle_pj.activite_code`, `depenses.code_activite`, `activite_participants.activite_code`.
- `participants.id` ← `presences.participant_id`, `activite_participants.participant_id`.
- Les valeurs calculées (écarts, indemnités théoriques, statuts, soldes, totaux) ne sont **pas**
  stockées : elles sont recalculées par les services métier (source unique de vérité).

## 4. Hypothèses documentées
- Les colonnes `Présence1..Présence5` de l'Excel correspondent aux jours de l'activité ; dans
  l'application une ligne de présence = (activité, participant, date). Le nombre de jours présents
  est recalculé par comptage.
- `Montant alloué` est stocké car saisi dans REFERENTIEL_BUDGET ; il est recalculé et comparé à la
  règle `quantité × taux × jours` pour détecter les incohérences.
- Les tarifs à `0` dans le référentiel sont considérés comme « à renseigner » et ne sont pas bloquants.
