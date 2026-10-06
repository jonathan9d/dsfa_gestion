# DSFA Gestion

Application Flutter de gestion des budgets, activités, présences, indemnités,
pièces justificatives, dépenses et opérations bancaires. Les données de travail
sont stockées localement sur l'appareil.

## Prerequis

- Flutter et le SDK Dart compatibles avec les contraintes de `pubspec.yaml`.
- Android Studio et le SDK Android pour compiler l'application Android.
- Windows et Visual Studio avec la charge de travail C++ pour compiler la
  version Windows.
- Inno Setup 6+ pour generer l'installateur Windows.

## Installation et développement

```powershell
flutter pub get
flutter analyze
flutter test
```

Lancer l'application sur un appareil ou émulateur configuré :

```powershell
flutter run
```

Au premier démarrage, créez un identifiant et un mot de passe administrateur.
Il n'y a pas de compte ni de mot de passe préconfiguré.

## Versions distribuables

Compiler l'APK Android :

```powershell
flutter build apk --release
```

Compiler l'application Windows :

```powershell
flutter build windows --release
```

Le script `build_installer.cmd` et `installer/dsfa_gestion.iss` permettent de
générer l'installateur Windows avec Inno Setup 6+.

## Fichier de parametres

`parametres.xlsx` est le classeur de référence embarqué nécessaire au démarrage,
à l'import initial et aux tests. Le classeur de gestion contenant les présences,
indemnités et autres données réelles n'est pas distribué. Les classeurs Excel,
exports, bases locales, journaux et fichiers de signature locaux sont ignorés
par Git, sauf ce fichier de reference.

## Plateformes

Le projet contient les cibles Android et Windows. Consultez la documentation
officielle Flutter pour les détails d'installation et de configuration des
outils de compilation : <https://docs.flutter.dev/>.
