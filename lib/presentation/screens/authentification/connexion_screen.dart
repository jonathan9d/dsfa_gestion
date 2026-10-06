import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/statuts.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';

class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key});

  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiant = TextEditingController();
  final _nom = TextEditingController();
  final _motDePasse = TextEditingController();
  final _confirmation = TextEditingController();
  final _focusNom = FocusNode();
  final _focusMotDePasse = FocusNode();
  final _focusConfirmation = FocusNode();
  bool _afficherMotDePasse = false;
  bool _afficherConfirmationMotDePasse = false;
  bool _enCours = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    // Le dernier identifiant utilisé est pré-rempli : la reconnexion demande
    // donc seulement le mot de passe lorsque la session a expiré.
    Future.microtask(() async {
      final identifiant = await ref
          .read(sessionRepositoryProvider)
          .dernierIdentifiant();
      if (!mounted) return;
      if (identifiant != null && identifiant.isNotEmpty) {
        _identifiant.text = identifiant;
        _focusMotDePasse.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _identifiant.dispose();
    _nom.dispose();
    _motDePasse.dispose();
    _confirmation.dispose();
    _focusNom.dispose();
    _focusMotDePasse.dispose();
    _focusConfirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configuration = ref.watch(configurationCompteProvider);
    final chargement = configuration.isLoading;
    // On ne reconstruit pas tout le sous-arbre : les champs restent affichés
    // même pendant le chargement, ce qui évite toute perte de saisie.
    final compteConfigure = configuration.value ?? false;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: configuration.hasError
                    ? _erreurChargement(configuration.error!)
                    : _formulaire(
                        compteConfigure: compteConfigure,
                        chargement: chargement,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _erreurChargement(Object erreur) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 36, color: theme.colorScheme.error),
        const SizedBox(height: 12),
        Text(
          'Impossible de lire les comptes enregistrés sur cet ordinateur.\n'
          '${messageErreurLisible(erreur)}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ref.invalidate(configurationCompteProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ],
    );
  }

  Widget _formulaire({
    required bool compteConfigure,
    required bool chargement,
  }) {
    final theme = Theme.of(context);
    final creation = !compteConfigure;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              logoDsfa,
              width: 220,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'DSFA Gestion',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            creation
                ? 'Créez le compte administrateur initial.'
                : 'Connectez-vous pour accéder à votre espace.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 26),
          TextFormField(
            controller: _identifiant,
            autofocus: true,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            onFieldSubmitted: (_) => creation
                ? _focusNom.requestFocus()
                : _focusMotDePasse.requestFocus(),
            decoration: const InputDecoration(
              labelText: 'Identifiant',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) =>
                validateurObligatoire(value, champ: 'L’identifiant'),
          ),
          if (creation) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _nom,
              focusNode: _focusNom,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _focusMotDePasse.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Nom affiché',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (value) =>
                  validateurObligatoire(value, champ: 'Le nom affiché'),
            ),
          ],
          const SizedBox(height: 14),
          TextFormField(
            controller: _motDePasse,
            focusNode: _focusMotDePasse,
            obscureText: !_afficherMotDePasse,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            textInputAction: creation
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: (value) {
              if (creation) {
                _focusConfirmation.requestFocus();
              } else {
                _valider(compteConfigure);
              }
            },
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _afficherMotDePasse
                    ? 'Masquer le mot de passe'
                    : 'Afficher le mot de passe',
                onPressed: () =>
                    setState(() => _afficherMotDePasse = !_afficherMotDePasse),
                icon: Icon(
                  _afficherMotDePasse
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le mot de passe est obligatoire.';
              }
              return null;
            },
          ),
          if (creation) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmation,
              focusNode: _focusConfirmation,
              obscureText: !_afficherConfirmationMotDePasse,
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _valider(compteConfigure),
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  tooltip: _afficherConfirmationMotDePasse
                      ? 'Masquer le mot de passe'
                      : 'Afficher le mot de passe',
                  onPressed: () => setState(
                    () => _afficherConfirmationMotDePasse =
                        !_afficherConfirmationMotDePasse,
                  ),
                  icon: Icon(
                    _afficherConfirmationMotDePasse
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirmez le mot de passe.';
                }
                if (value != _motDePasse.text) {
                  return 'Les mots de passe ne correspondent pas.';
                }
                return null;
              },
            ),
          ],
          if (_erreur != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _erreur!,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: (_enCours || chargement)
                ? null
                : () => _valider(compteConfigure),
            icon: _enCours
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    creation ? Icons.person_add_alt_1 : Icons.login,
                  ),
            label: Text(
              _enCours
                  ? 'Vérification…'
                  : creation
                  ? 'Créer le compte administrateur'
                  : 'Se connecter',
            ),
          ),
          if (!creation) ...[
            const SizedBox(height: 4),
            Center(
              child: TextButton.icon(
                onPressed: _enCours
                    ? null
                    : () => context.go(AppRoutes.motDePasseOublie),
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('Mot de passe oublié ?'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Les identifiants sont conservés localement sur cet appareil : '
            'l\'application vous reconnecte automatiquement si vous l\'avez '
            'ouverte il y a moins de 2 jours.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _valider(bool compte) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final repository = ref.read(authentificationRepositoryProvider);
      final user = compte
          ? await repository.authentifier(
              identifiant: _identifiant.text,
              motDePasse: _motDePasse.text,
            )
          : await repository.creerAdministrateur(
              identifiant: _identifiant.text,
              nom: _nom.text,
              motDePasse: _motDePasse.text,
            );
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _erreur =
              'Identifiant ou mot de passe incorrect.\n'
              'Vérifiez la saisie (le mot de passe est sensible aux '
              'majuscules). Si vous l\'avez oublié, utilisez '
              '« Mot de passe oublié ? ».';
        });
        return;
      }
      ref.read(sessionUtilisateurProvider.notifier).state = user;
      ref.read(roleProvider.notifier).state = RoleUtilisateur.depuisCode(
        user.role,
      );
      // Session mémorisée : reconnexion automatique à la prochaine ouverture.
      await ref.read(sessionRepositoryProvider).enregistrer(user);
      if (!compte) ref.invalidate(configurationCompteProvider);
      // La redirection du routeur prend aussi le relais ; on force la
      // navigation pour un retour immédiat à l'application.
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (error) {
      if (mounted) {
        setState(
          () => _erreur = 'Connexion impossible.\n${messageErreurLisible(error)}',
        );
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }
}
