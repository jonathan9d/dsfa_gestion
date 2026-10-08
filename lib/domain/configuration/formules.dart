/// Petit **moteur de formules** utilisé par la configuration.
///
/// Il permet d'attribuer une valeur à un champ (montant, total, statut…)
/// calculée à partir des autres champs de la ligne :
///
/// ```text
/// quantite * frequence * pu * nb_jr_mois
/// si(montant > 1000000, "À vérifier", "OK")
/// arrondi(total * 0.2)
/// ```
///
/// * références : `[nom du champ]` ou un nom simple (`quantite`) ;
/// * opérateurs : `+ - * / % ^`, comparaisons `< <= > >= = == != <>`,
///   `et`/`ou`/`non` (`and`/`or`/`not`, `&&`/`||`/`!`) ;
/// * fonctions : `si`, `min`, `max`, `abs`, `arrondi`, `plafond`, `plancher`,
///   `racine`, `somme`, `moyenne`, `nombre` ;
/// * un booléen vaut `1` ou `0` : `si(condition, …)` en tire parti.
///
/// Le moteur ne fait **jamais** d'évaluation dynamique de code : la formule est
/// analysée puis interprétée, donc une formule erronée ne peut pas bloquer
/// l'application — elle produit un message d'erreur en français.
library;

/// Erreur de formule, avec un message directement affichable.
class ErreurFormule implements Exception {
  const ErreurFormule(this.message);

  final String message;

  @override
  String toString() => message;
}

class _Jeton {
  const _Jeton(this.type, this.texte, [this.nombre]);

  /// `nombre`, `reference`, `operateur`, `parenthese`, `virgule`, `fin`.
  final String type;
  final String texte;
  final double? nombre;
}

/// Analyse et évaluation des formules de la configuration.
class Formule {
  const Formule._();

  /// Noms de fonctions reconnues (sert à la liste d'aide de l'éditeur).
  static const fonctions = <String>[
    'si',
    'min',
    'max',
    'abs',
    'arrondi',
    'plafond',
    'plancher',
    'racine',
    'somme',
    'moyenne',
    'nombre',
  ];

  static const operateurs = <String>[
    '+',
    '-',
    '*',
    '/',
    '%',
    '^',
    '>',
    '<',
    '>=',
    '<=',
    '=',
    '!=',
    'et',
    'ou',
    'non',
  ];

  // --- Analyse lexicale ----------------------------------------------------

  static List<_Jeton> _jetons(String expression) {
    final jetons = <_Jeton>[];
    var i = 0;
    while (i < expression.length) {
      final c = expression[i];
      if (c.trim().isEmpty) {
        i++;
        continue;
      }
      if (c == '[') {
        final fin = expression.indexOf(']', i);
        if (fin < 0) {
          throw const ErreurFormule('Crochet « [ » non fermé.');
        }
        jetons.add(
          _Jeton('reference', expression.substring(i + 1, fin).trim()),
        );
        i = fin + 1;
        continue;
      }
      if (RegExp(r'[0-9]').hasMatch(c)) {
        final debut = i;
        while (i < expression.length && RegExp(r'[0-9.]').hasMatch(expression[i])) {
          i++;
        }
        // Virgule décimale : « 0,5 » n'est pas accepté (la virgule sépare les
        // arguments) — le message le dit clairement.
        if (i + 1 < expression.length &&
            expression[i] == ',' &&
            RegExp(r'[0-9]').hasMatch(expression[i + 1])) {
          throw const ErreurFormule(
            'Utilisez un point pour les décimales (ex. 0.5) : la virgule '
            'sépare les arguments des fonctions.',
          );
        }
        final brut = expression.substring(debut, i);
        final valeur = double.tryParse(brut);
        if (valeur == null) {
          throw ErreurFormule('Nombre invalide : « $brut ».');
        }
        jetons.add(_Jeton('nombre', brut, valeur));
        continue;
      }
      if (RegExp(r'[A-Za-zÀ-ÿ_]').hasMatch(c)) {
        final debut = i;
        while (i < expression.length &&
            RegExp(r'[A-Za-zÀ-ÿ0-9_]').hasMatch(expression[i])) {
          i++;
        }
        jetons.add(_Jeton('mot', expression.substring(debut, i)));
        continue;
      }
      if ('()'.contains(c)) {
        jetons.add(_Jeton('parenthese', c));
        i++;
        continue;
      }
      if (c == ',') {
        jetons.add(const _Jeton('virgule', ','));
        i++;
        continue;
      }
      final deux = i + 2 <= expression.length
          ? expression.substring(i, i + 2)
          : '';
      if (const ['<=', '>=', '!=', '<>', '==', '&&', '||'].contains(deux)) {
        jetons.add(
          _Jeton('operateur', deux == '<>' ? '!=' : deux),
        );
        i += 2;
        continue;
      }
      if ('+-*/%^<>=!'.contains(c)) {
        jetons.add(_Jeton('operateur', c));
        i++;
        continue;
      }
      throw ErreurFormule('Caractère inattendu : « $c ».');
    }
    jetons.add(const _Jeton('fin', ''));
    return jetons;
  }

  /// Références (noms de champs) utilisées par une formule.
  static Set<String> references(String expression) {
    final noms = <String>{};
    try {
      for (final jeton in _jetons(expression)) {
        if (jeton.type == 'reference') {
          noms.add(jeton.texte);
        } else if (jeton.type == 'mot') {
          final minuscule = jeton.texte.toLowerCase();
          if (!fonctions.contains(minuscule) &&
              !const ['et', 'ou', 'non', 'and', 'or', 'not'].contains(
                minuscule,
              )) {
            noms.add(jeton.texte);
          }
        }
      }
    } catch (_) {
      // Formule incomplète : on renvoie ce qui a pu être lu.
    }
    return noms;
  }

  // --- Analyse syntaxique / évaluation ------------------------------------

  /// Évalue [expression] avec [variables] (nom du champ → valeur).
  ///
  /// Lève une [ErreurFormule] si la formule est invalide ou si une référence
  /// est absente (`variables` sert alors de liste de noms connus).
  static num evaluer(String expression, Map<String, num> variables) {
    if (expression.trim().isEmpty) {
      throw const ErreurFormule('La formule est vide.');
    }
    final analyseur = _Analyseur(_jetons(expression), expression, variables);
    final resultat = analyseur.expression();
    analyseur.attenduFin();
    return resultat;
  }

  /// Contrôle rapide d'une formule, sans l'évaluer.
  ///
  /// Retourne `null` si la formule est valide, sinon un message en français.
  static String? verifier(String expression, {Set<String>? champsConnus}) {
    if (expression.trim().isEmpty) return 'La formule est vide.';
    try {
      final variables = <String, num>{
        for (final nom in champsConnus ?? const <String>{}) nom: 1,
      };
      final connues = references(expression);
      for (final nom in connues) {
        variables.putIfAbsent(nom, () => 1);
      }
      evaluer(expression, variables);
      if (champsConnus != null) {
        for (final nom in connues) {
          if (!champsConnus.contains(nom)) {
            return 'Champ inconnu : « $nom ».';
          }
        }
      }
      return null;
    } on ErreurFormule catch (e) {
      return e.message;
    } catch (e) {
      return 'Formule invalide : $e';
    }
  }

  /// Valeur applicable : `null` quand la formule est invalide ou vide.
  static num? essayer(String? expression, Map<String, num> variables) {
    if (expression == null || expression.trim().isEmpty) return null;
    try {
      return evaluer(expression, variables);
    } catch (_) {
      return null;
    }
  }
}

class _Analyseur {
  _Analyseur(this.jetons, this.source, this.variables);

  final List<_Jeton> jetons;
  final String source;
  final Map<String, num> variables;
  int _position = 0;

  _Jeton get _courant => jetons[_position];

  void _avancer() {
    if (_position < jetons.length - 1) _position++;
  }

  bool _accepter(String type, [String? texte]) {
    if (_courant.type == type &&
        (texte == null ||
            _courant.texte == texte ||
            (type == 'mot' && _courant.texte.toLowerCase() == texte))) {
      _avancer();
      return true;
    }
    return false;
  }

  void attenduFin() {
    if (_courant.type != 'fin') {
      throw ErreurFormule('Élément inattendu après la formule : « ${_courant.texte} ».');
    }
  }

  num expression() => _ou();

  num _ou() {
    var valeur = _et();
    while (true) {
      if (_accepter('mot', 'ou') || _accepter('mot', 'or') ||
          _accepter('operateur', '||')) {
        final droite = _et();
        valeur = (valeur != 0 || droite != 0) ? 1 : 0;
      } else {
        return valeur;
      }
    }
  }

  num _et() {
    var valeur = _comparaison();
    while (true) {
      if (_accepter('mot', 'et') || _accepter('mot', 'and') ||
          _accepter('operateur', '&&')) {
        final droite = _comparaison();
        valeur = (valeur != 0 && droite != 0) ? 1 : 0;
      } else {
        return valeur;
      }
    }
  }

  num _comparaison() {
    final gauche = _somme();
    final texte = _courant.texte;
    const comparaisons = ['<', '<=', '>', '>=', '=', '==', '!=', '<>'];
    if (_courant.type == 'operateur' && comparaisons.contains(texte)) {
      _avancer();
      final droite = _somme();
      final bool resultat;
      if (texte == '<') {
        resultat = gauche < droite;
      } else if (texte == '<=') {
        resultat = gauche <= droite;
      } else if (texte == '>') {
        resultat = gauche > droite;
      } else if (texte == '>=') {
        resultat = gauche >= droite;
      } else if (texte == '=' || texte == '==') {
        resultat = gauche == droite;
      } else {
        resultat = gauche != droite;
      }
      return resultat ? 1 : 0;
    }
    return gauche;
  }

  num _somme() {
    var valeur = _produit();
    while (true) {
      if (_accepter('operateur', '+')) {
        valeur += _produit();
      } else if (_accepter('operateur', '-')) {
        valeur -= _produit();
      } else {
        return valeur;
      }
    }
  }

  num _produit() {
    var valeur = _puissance();
    while (true) {
      if (_accepter('operateur', '*')) {
        valeur *= _puissance();
      } else if (_accepter('operateur', '/')) {
        final droite = _puissance();
        if (droite == 0) {
          throw const ErreurFormule('Division par zéro dans la formule.');
        }
        valeur /= droite;
      } else if (_accepter('operateur', '%')) {
        final droite = _puissance();
        if (droite == 0) {
          throw const ErreurFormule('Division par zéro dans la formule.');
        }
        valeur %= droite;
      } else {
        return valeur;
      }
    }
  }

  num _puissance() {
    final base = _unaire();
    if (_accepter('operateur', '^')) {
      final exposant = _puissance();
      return _puissance2(base, exposant);
    }
    return base;
  }

  static num _puissance2(num base, num exposant) {
    var resultat = 1.0;
    final entier = exposant.round();
    for (var i = 0; i < entier.abs(); i++) {
      resultat *= base;
    }
    return entier < 0 ? (resultat == 0 ? 0 : 1 / resultat) : resultat;
  }

  num _unaire() {
    if (_accepter('operateur', '-')) return -_unaire();
    if (_accepter('operateur', '+')) return _unaire();
    if (_accepter('operateur', '!') || _accepter('mot', 'non') ||
        _accepter('mot', 'not')) {
      return _unaire() == 0 ? 1 : 0;
    }
    return _primaire();
  }

  num _primaire() {
    if (_courant.type == 'nombre') {
      final valeur = _courant.nombre!;
      _avancer();
      return valeur;
    }
    if (_accepter('parenthese', '(')) {
      final valeur = expression();
      if (!_accepter('parenthese', ')')) {
        throw const ErreurFormule('Parenthèse fermante manquante.');
      }
      return valeur;
    }
    if (_courant.type == 'reference') {
      final nom = _courant.texte;
      _avancer();
      return _valeur(nom);
    }
    if (_courant.type == 'mot') {
      final nom = _courant.texte;
      final minuscule = nom.toLowerCase();
      _avancer();
      if (_accepter('parenthese', '(')) {
        final arguments = <num>[];
        if (!(_courant.type == 'parenthese' && _courant.texte == ')')) {
          arguments.add(expression());
          while (_accepter('virgule', ',')) {
            arguments.add(expression());
          }
        }
        if (!_accepter('parenthese', ')')) {
          throw const ErreurFormule('Parenthèse fermante manquante.');
        }
        return _fonction(minuscule, arguments);
      }
      return _valeur(nom);
    }
    throw ErreurFormule(
      'Formule incomplète près de « ${_courant.texte} » (dans « $source »).',
    );
  }

  num _valeur(String nom) {
    final directe = variables[nom];
    if (directe != null) return directe;
    final minuscule = nom.toLowerCase();
    for (final entree in variables.entries) {
      if (entree.key.toLowerCase() == minuscule) return entree.value;
    }
    throw ErreurFormule('Champ inconnu : « $nom ».');
  }

  num _fonction(String nom, List<num> args) {
    switch (nom) {
      case 'si':
      case 'if':
        if (args.length != 3) {
          throw const ErreurFormule('si() attend trois arguments.');
        }
        return args[0] != 0 ? args[1] : args[2];
      case 'min':
        _auMoins(nom, args, 1);
        return args.reduce((a, b) => a < b ? a : b);
      case 'max':
        _auMoins(nom, args, 1);
        return args.reduce((a, b) => a > b ? a : b);
      case 'abs':
        _auMoins(nom, args, 1);
        return args.first.abs();
      case 'arrondi':
      case 'round':
        _auMoins(nom, args, 1);
        final decimales = args.length > 1 ? args[1].round().clamp(0, 6) : 0;
        var facteur = 1.0;
        for (var i = 0; i < decimales; i++) {
          facteur *= 10;
        }
        return (args.first * facteur).round() / facteur;
      case 'plafond':
      case 'ceil':
        _auMoins(nom, args, 1);
        return args.first.ceilToDouble();
      case 'plancher':
      case 'floor':
        _auMoins(nom, args, 1);
        return args.first.floorToDouble();
      case 'racine':
      case 'sqrt':
        _auMoins(nom, args, 1);
        if (args.first < 0) {
          throw const ErreurFormule('racine() d\'un nombre négatif.');
        }
        return _racineCarree(args.first);
      case 'somme':
      case 'sum':
        return args.fold<num>(0, (a, b) => a + b);
      case 'moyenne':
      case 'average':
        _auMoins(nom, args, 1);
        return args.fold<num>(0, (a, b) => a + b) / args.length;
      case 'nombre':
        return args.isEmpty || args.first == 0 ? 0 : 1;
      default:
        throw ErreurFormule('Fonction inconnue : « $nom ».');
    }
  }

  static void _auMoins(String nom, List<num> args, int minimum) {
    if (args.length < minimum) {
      throw ErreurFormule('$nom() attend au moins $minimum argument(s).');
    }
  }

  static num _racineCarree(num valeur) {
    var estimation = valeur.toDouble();
    if (estimation <= 0) return 0;
    for (var i = 0; i < 40; i++) {
      estimation = (estimation + valeur / estimation) / 2;
    }
    return estimation;
  }
}
