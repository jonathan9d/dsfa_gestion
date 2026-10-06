import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/authentification_repository.dart';
import '../../../domain/statuts.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';
import '../../widgets/notification_ecran.dart';

/// Parcours « mot de passe oublié ».
///
/// 1. nom d'utilisateur du compte ;
/// 2. envoi d'un **code de vérification en notification sur l'ordinateur** ;
/// 3. saisie du code ;
/// 4. nouveau mot de passe + confirmation, puis connexion.
class MotDePasseOublieScreen extends ConsumerStatefulWidget {
  const MotDePasseOublieScreen({super.key});

  @override
  ConsumerState<MotDePasseOublieScreen> createState() =>
      _MotDePasseOublieScreenState();
}

class _MotDePasseOublieScreenState
    extends ConsumerState<MotDePasseOublieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiant = TextEditingController();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _motDePasse = TextEditingController();
  final _confirmation = TextEditingController();

  int _etape = 0;
  String? _erreur;
  String? _information;
  bool _enCours = false;
  bool _emailRequis = false;
  bool _afficherMotDePasse = false;
  String? _codeAffiche;

  @override
  void dispose() {
    for (final c in [
      _identifiant,
      _email,
      _code,
      _motDePasse,
      _confirmation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _continuer() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final compte = await ref
          .read(reinitialisationServiceProvider)
          .compte(_identifiant.text);
      if (compte == null) {
        setState(() {
          _erreur =
              'Aucun compte actif ne correspond à ce nom d\'utilisateur. '
              'Vérifiez la saisie puis réessayez.';
        });
        return;
      }
      final emailCompte = (compte.email ?? '').trim();
      setState(() {
        _emailRequis = emailCompte.isNotEmpty;
        _etape = 1;
        _information = emailCompte.isEmpty
            ? null
            : 'Une adresse email est enregistrée sur ce compte : saisissez-la '
                  'pour confirmer votre identité.';
      });
      if (!_emailRequis) await _envoyerCode();
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurLisible(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _envoyerCode() async {
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final demande = await ref
          .read(reinitialisationServiceProvider)
          .envoyerCode(identifiant: _identifiant.text, email: _email.text);
      if (!mounted) return;
      setState(() {
        _codeAffiche = demande.code;
        _information = demande.notificationEnvoyee
            ? 'Une notification contenant le code vient d\'être envoyée sur '
                  'cet ordinateur.'
            : 'Windows n\'a pas pu afficher la notification : le code vous est '
                  'donné ci-dessous.';
      });
      afficherNotificationEcran(
        context,
        titre: 'DSFA Gestion — code de vérification',
        message: 'Saisissez ce code dans l\'application pour définir un '
            'nouveau mot de passe.',
        code: demande.code,
      );
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurLisible(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _verifierCode() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      await ref.read(reinitialisationServiceProvider).verifierCode(_code.text);
      if (!mounted) return;
      setState(() {
        _etape = 2;
        _information = 'Code vérifié. Choisissez votre nouveau mot de passe.';
      });
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurLisible(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _enregistrerEtSeConnecter() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final utilisateur = await ref
          .read(reinitialisationServiceProvider)
          .definirNouveauMotDePasse(
            code: _code.text,
            nouveauMotDePasse: _motDePasse.text,
            confirmation: _confirmation.text,
          );
      await ref.read(sessionRepositoryProvider).enregistrer(utilisateur);
      if (!mounted) return;
      ref.read(sessionUtilisateurProvider.notifier).state = utilisateur;
      ref.read(roleProvider.notifier).state = utilisateur.role ==
              RoleUtilisateur.admin.code
          ? RoleUtilisateur.admin
          : utilisateur.role == RoleUtilisateur.gestionnaire.code
          ? RoleUtilisateur.gestionnaire
          : RoleUtilisateur.lecteur;
      notifier(
        context,
        'Mot de passe modifié. Vous êtes maintenant connecté.',
      );
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurLisible(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  void _generer() {
    final motDePasse = AuthentificationRepository.genererMotDePasse();
    setState(() {
      _motDePasse.text = motDePasse;
      _confirmation.text = motDePasse;
      _afficherMotDePasse = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Retour à la connexion',
                            onPressed: () => context.go(AppRoutes.connexion),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Mot de passe oublié',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Réinitialisez votre mot de passe en quelques étapes : '
                        'un code de vérification vous est envoyé par une '
                        'notification sur cet ordinateur.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Etapes(etape: _etape),
                      const SizedBox(height: 18),
                      if (_information != null && _erreur == null) ...[
                        _Bandeau(
                          icone: Icons.info_outline,
                          message: _information!,
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_erreur != null) ...[
                        _Bandeau(
                          icone: Icons.error_outline,
                          message: _erreur!,
                          erreur: true,
                        ),
                        const SizedBox(height: 14),
                      ],
                      ..._contenuEtape(),
                      const SizedBox(height: 22),
                      ..._actionsEtape(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _contenuEtape() {
    switch (_etape) {
      case 0:
        return [
          TextFormField(
            controller: _identifiant,
            autofocus: true,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            onFieldSubmitted: (_) => _continuer(),
            decoration: const InputDecoration(
              labelText: 'Nom d\'utilisateur',
              prefixIcon: Icon(Icons.person_outline),
              helperText: 'Le nom utilisé pour vous connecter à DSFA Gestion.',
            ),
            validator: (v) =>
                validateurObligatoire(v, champ: 'Le nom d\'utilisateur'),
          ),
        ];
      case 1:
        return [
          if (_emailRequis)
            TextFormField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              onFieldSubmitted: (_) => _envoyerCode(),
              decoration: const InputDecoration(
                labelText: 'Email enregistré sur le compte',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (v) => _emailRequis
                  ? validateurObligatoire(v, champ: 'L\'email du compte')
                  : null,
            ),
          if (_emailRequis) const SizedBox(height: 14),
          TextFormField(
            controller: _code,
            autofocus: !_emailRequis,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onFieldSubmitted: (_) => _verifierCode(),
            decoration: const InputDecoration(
              labelText: 'Code de vérification',
              hintText: '6 chiffres',
              prefixIcon: Icon(Icons.pin_outlined),
              helperText:
                  'Le code figure dans la notification reçue sur cet '
                  'ordinateur (validité : 15 minutes).',
            ),
            validator: (v) {
              final valeur = (v ?? '').trim();
              if (valeur.isEmpty) return 'Saisissez le code reçu.';
              if (valeur.length != 6) {
                return 'Le code comporte 6 chiffres.';
              }
              return null;
            },
          ),
          if (_codeAffiche != null) ...[
            const SizedBox(height: 10),
            _Bandeau(
              icone: Icons.notifications_active_outlined,
              message: 'Code envoyé : $_codeAffiche',
            ),
          ],
        ];
      default:
        final robustesse =
            AuthentificationRepository.robustesse(_motDePasse.text);
        return [
          TextFormField(
            controller: _motDePasse,
            autofocus: true,
            obscureText: !_afficherMotDePasse,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              helperText: 'Au moins 6 caractères.',
              suffixIcon: IconButton(
                tooltip: _afficherMotDePasse ? 'Masquer' : 'Afficher',
                icon: Icon(
                  _afficherMotDePasse
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(
                  () => _afficherMotDePasse = !_afficherMotDePasse,
                ),
              ),
            ),
            validator: (v) {
              final valeur = v ?? '';
              if (valeur.isEmpty) return 'Le mot de passe est obligatoire.';
              if (valeur.length <
                  AuthentificationRepository.longueurMotDePasseMinimum) {
                return 'Le mot de passe doit contenir au moins '
                    '${AuthentificationRepository.longueurMotDePasseMinimum} '
                    'caractères.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: robustesse.score / 4,
                  minHeight: 4,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Robustesse : ${robustesse.libelle}',
                style: const TextStyle(fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmation,
            obscureText: !_afficherMotDePasse,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _enregistrerEtSeConnecter(),
            decoration: const InputDecoration(
              labelText: 'Confirmer le nouveau mot de passe',
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
            validator: (v) {
              if ((v ?? '').isEmpty) return 'Confirmez le mot de passe.';
              if (v != _motDePasse.text) {
                return 'Les deux mots de passe ne sont pas identiques.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _generer,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Générer un mot de passe automatiquement'),
            ),
          ),
        ];
    }
  }

  List<Widget> _actionsEtape() {
    Widget bouton({required String label, required VoidCallback action}) =>
        FilledButton.icon(
          onPressed: _enCours ? null : action,
          icon: _enCours
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward),
          label: Text(label),
        );

    switch (_etape) {
      case 0:
        return [bouton(label: 'Continuer', action: _continuer)];
      case 1:
        return [
          bouton(
            label: _codeAffiche == null
                ? 'Recevoir le code de vérification'
                : 'Vérifier le code',
            action: _codeAffiche == null ? _envoyerCode : _verifierCode,
          ),
          if (_codeAffiche != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _enCours ? null : _envoyerCode,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Renvoyer un nouveau code'),
              ),
            ),
        ];
      default:
        return [
          bouton(
            label: 'Enregistrer et se connecter',
            action: _enregistrerEtSeConnecter,
          ),
        ];
    }
  }
}

/// Fil des étapes du parcours.
class _Etapes extends StatelessWidget {
  const _Etapes({required this.etape});
  final int etape;

  @override
  Widget build(BuildContext context) {
    const libelles = ['Compte', 'Code reçu', 'Nouveau mot de passe'];
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var i = 0; i < libelles.length; i++)
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i <= etape
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: i <= etape ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    libelles[i],
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: i == etape ? FontWeight.w700 : FontWeight.w400,
                      color: i <= etape
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (i < libelles.length - 1)
                  Expanded(
                    child: Divider(
                      color: i < etape ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Message d'information ou d'erreur, clairement lisible.
class _Bandeau extends StatelessWidget {
  const _Bandeau({
    required this.icone,
    required this.message,
    this.erreur = false,
  });

  final IconData icone;
  final String message;
  final bool erreur;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final couleur = erreur ? scheme.error : scheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: couleur),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              message,
              style: TextStyle(fontSize: 12.5, color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
