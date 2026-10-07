# DSFA Gestion 1.1.0

Deuxième version publique — cible **Windows 64 bits** uniquement.
Android n'est plus distribué.

## Dossier PJ, recentré sur l'essentiel

- L'onglet **Pièces justificatives** ne contient plus qu'une chose : la
  **checklist des PJ requises**, déduite de la matrice `PARAMETRES` et
  regroupée par rubrique budgétaire (reçue / date conforme, date de la PJ,
  contrôle automatique des délais, avancement global, état conservé par
  activité).
- Les onglets **Présences** et **Indemnités** sont **fusionnés** en un seul
  tableau, une ligne par participant. Les cartes de synthèse ont été
  supprimées.
- Le **nombre de jours d'activité** se modifie directement dans le tableau :
  la **fiche de présence du participant est mise à jour** dans la foulée.
- Les contrôles PJ détaillés (écarts, journal des dépenses) restent
  accessibles par l'action « Contrôles détaillés ».

## Rubriques réparées, aucune rubrique libre

- La **location de salle** relève désormais de la rubrique
  **RESTAURATION / FRAIS D'ORGANISATION** (et non des déplacements).
- Une ligne budgétaire n'a **plus jamais de rubrique libre** : la rubrique est
  retrouvée dans les **paramètres** (`REFERENTIEL_TARIFS`) à partir du libellé
  de la ligne, avec un marqueur explicite si le référentiel ne la contient pas.

## Pré-impression et exports par rubrique

- La pré-impression du budget est **regroupée par rubrique**, avec le **total
  de chaque rubrique** puis le total général.
- Les **fournitures** s'affichent en **post-it** (une ligne = une note).
- L'export Excel suit exactement le même regroupement : colonne « Rubrique »,
  blocs par rubrique et **sous-total par rubrique**.

## Lisibilité des tableaux

- Largeurs de colonnes **mesurées sur le contenu réel** : aucun mot, chiffre ni
  date n'est coupé, y compris dans le suivi.
- Les **chevrons de tri** ont été retirés ; le tri reste actif d'un clic sur
  l'en-tête.
- Espaces verticaux réduits (lignes et en-têtes plus compacts).
- Les **filtres sont masqués par défaut** et s'ouvrent via le bouton
  « Filtrer » ou le réglage « Filtres visibles dès l'ouverture ».
- Le **montant alloué déjà confirmé** est mis en évidence (pastille verte) par
  rapport à un montant encore à confirmer.

## Saisies et interface

- **Toutes les saisies sont vérifiées avant enregistrement** : champs
  obligatoires, valeurs choisies dans les listes de référence, années,
  montants et quantités positifs, dates cohérentes, absence de doublon de code.
- Écran d'accueil qui **salue l'utilisateur avant la connexion**.
- **Logo agrandi** dans le menu latéral (et dans le menu mobile).
- Corrections d'affichage : plus aucun débordement sur les fenêtres basses.

## Fichiers

- `DSFA_Gestion_Setup_1.1.0.exe` : installateur Windows 64 bits.

Aucun identifiant ni mot de passe n'est livré : le compte administrateur est
créé au premier démarrage.
