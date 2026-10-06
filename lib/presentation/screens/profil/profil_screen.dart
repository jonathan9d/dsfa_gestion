import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/authentification_repository.dart';
import '../../../domain/statuts.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';

/// Choix d'une photo de profil : renvoie une image encodée (data URI).
Future<String?> choisirPhotoProfil() async {
  final fichiers = await picker.FilePicker.pickFiles(
    type: picker.FileType.image,
    dialogTitle: 'Choisir une photo de profil',
  );
  final chemin = fichiers.isEmpty ? null : fichiers.single.path;
  if (chemin == null) return null;
  final octets = await File(chemin).readAsBytes();
  const tailleMaximale = 3 * 1024 * 1024;
  if (octets.length > tailleMaximale) {
    throw Exception(
      'La photo est trop volumineuse (maximum 3 Mo). '
      'Choisissez une image plus légère.',
    );
  }
  final extension = chemin.split('.').last.toLowerCase();
  final type = switch (extension) {
    'png' => 'image/png',
    'gif' => 'image/gif',
    'bmp' => 'image/bmp',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
  return 'data:$type;base64,${base64Encode(octets)}';
}

/// Décode une photo de profil (data URI) pour l'afficher.
ImageProvider? imageDepuisPhoto(String? photo) {
  if (photo == null || photo.isEmpty) return null;
  try {
    final base64Image = photo.contains(',') ? photo.split(',').last : photo;
    return MemoryImage(base64Decode(base64Image));
  } catch (_) {
    return null;
  }
}

/// Avatar d'un utilisateur : photo si disponible, sinon initiale colorée.
class AvatarUtilisateur extends StatelessWidget {
  const AvatarUtilisateur({
    required this.utilisateur,
    this.rayon = 18,
    super.key,
  });

  final Utilisateur? utilisateur;
  final double rayon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final image = imageDepuisPhoto(utilisateur?.photo);
    final initiale = (utilisateur?.nom.trim().isNotEmpty ?? false)
        ? utilisateur!.nom.trim().substring(0, 1).toUpperCase()
        : '?';
    if (image != null) {
      return CircleAvatar(
        radius: rayon,
        backgroundColor: scheme.primaryContainer,
        backgroundImage: image,
      );
    }
    return CircleAvatar(
      radius: rayon,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initiale,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: rayon * 0.9,
        ),
      ),
    );
  }
}

/// Profil de l'utilisateur connecté, changement de mot de passe et, pour les
/// administrateurs, gestion des comptes.
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilisateur = ref.watch(sessionUtilisateurProvider);
    final admin = ref.watch(roleProvider).peutGererComptes;
    final onglets = [
      const OngletAnime(label: 'Mon profil', icon: Icons.person_outline),
      const OngletAnime(label: 'Mot de passe', icon: Icons.lock_outline),
      if (admin)
        const OngletAnime(
          label: 'Comptes utilisateurs',
          icon: Icons.manage_accounts_outlined,
        ),
    ];
    return DefaultTabController(
      length: onglets.length,
      child: Scaffold(
        body: Column(
          children: [
            EnTetePage(
              titre: 'Profil utilisateur',
              sousTitre:
                  'Informations personnelles, mot de passe et comptes de '
                  'l\'application',
              actions: [
                if (utilisateur != null)
                  Chip(
                    avatar: AvatarUtilisateur(utilisateur: utilisateur, rayon: 12),
                    label: Text(
                      RoleUtilisateur.depuisCode(utilisateur.role).libelle,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BarreOngletsAnimee(onglets: onglets),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  const _OngletMonProfil(),
                  const _OngletMotDePasse(),
                  if (admin) const OngletComptesUtilisateurs(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OngletMonProfil extends ConsumerWidget {
  const _OngletMonProfil();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilisateur = ref.watch(sessionUtilisateurProvider);
    if (utilisateur == null) {
      return const EtatVide(
        message: 'Aucun utilisateur connecté.',
        icone: Icons.person_off_outlined,
        titre: 'Profil indisponible',
      );
    }
    final role = RoleUtilisateur.depuisCode(utilisateur.role);
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarUtilisateur(utilisateur: utilisateur, rayon: 34),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nomComplet(utilisateur),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${utilisateur.identifiant}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Etiquette(
                            icone: Icons.verified_user_outlined,
                            texte: role.libelle,
                            couleur: scheme.primary,
                          ),
                          _Etiquette(
                            icone: utilisateur.actif
                                ? Icons.check_circle_outline
                                : Icons.block_outlined,
                            texte: utilisateur.actif ? 'Compte actif' : 'Compte désactivé',
                            couleur: utilisateur.actif
                                ? const Color(0xFF2E7D32)
                                : scheme.error,
                          ),
                          if ((utilisateur.fonction ?? '').trim().isNotEmpty)
                            _Etiquette(
                              icone: Icons.work_outline,
                              texte: utilisateur.fonction!,
                              couleur: scheme.tertiary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        role.description,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _ouvrirFormulaire(context, ref, utilisateur),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CarteSection(
          titre: 'Informations du compte',
          child: Column(
            children: [
              _LigneInfo(
                libelle: 'Nom',
                valeur: utilisateur.nom,
                obligatoire: true,
              ),
              _LigneInfo(
                libelle: 'Prénom',
                valeur: utilisateur.prenomUtilisateur ?? '',
                obligatoire: false,
              ),
              _LigneInfo(
                libelle: 'Nom d\'utilisateur',
                valeur: utilisateur.identifiant,
                obligatoire: true,
              ),
              _LigneInfo(
                libelle: 'Rôle',
                valeur: role.libelle,
                obligatoire: true,
              ),
              _LigneInfo(
                libelle: 'Fonction',
                valeur: utilisateur.fonction ?? '',
                obligatoire: false,
              ),
              _LigneInfo(
                libelle: 'Email',
                valeur: utilisateur.email ?? '',
                obligatoire: false,
              ),
              _LigneInfo(
                libelle: 'Téléphone',
                valeur: utilisateur.telephone ?? '',
                obligatoire: false,
              ),
              _LigneInfo(
                libelle: 'Photo de profil',
                valeur: (utilisateur.photo ?? '').isEmpty
                    ? ''
                    : 'Photo enregistrée',
                obligatoire: false,
              ),
              _LigneInfo(
                libelle: 'Compte créé le',
                valeur: formatDate(utilisateur.dateCreation),
                obligatoire: false,
              ),
              _LigneInfo(
                libelle: 'Dernière connexion',
                valeur: formatDate(utilisateur.derniereConnexion),
                obligatoire: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _ouvrirFormulaire(
    BuildContext context,
    WidgetRef ref,
    Utilisateur utilisateur,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DialogueUtilisateur(utilisateur: utilisateur),
    );
    if (ok == true && context.mounted) {
      notifier(context, 'Profil mis à jour');
    }
  }

  static String _nomComplet(Utilisateur u) {
    final prenom = (u.prenomUtilisateur ?? '').trim();
    return prenom.isEmpty ? u.nom : '${u.nom} $prenom';
  }
}

class _OngletMotDePasse extends ConsumerStatefulWidget {
  const _OngletMotDePasse();

  @override
  ConsumerState<_OngletMotDePasse> createState() => _OngletMotDePasseState();
}

class _OngletMotDePasseState extends ConsumerState<_OngletMotDePasse> {
  final _formKey = GlobalKey<FormState>();
  final _ancien = TextEditingController();
  final _nouveau = TextEditingController();
  final _confirmation = TextEditingController();
  bool _afficher = false;
  bool _enCours = false;
  String? _erreur;
  String? _succes;

  @override
  void dispose() {
    _ancien.dispose();
    _nouveau.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = ref.watch(sessionUtilisateurProvider);
    final robustesse = AuthentificationRepository.robustesse(_nouveau.text);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: CarteSection(
            titre: 'Modifier mon mot de passe',
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Saisissez votre mot de passe actuel puis le nouveau. '
                    'Un mot de passe généré automatiquement est proposé si '
                    'vous le souhaitez.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ancien,
                    obscureText: !_afficher,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe actuel *',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) =>
                        validateurObligatoire(v, champ: 'Le mot de passe actuel'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nouveau,
                    obscureText: !_afficher,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe *',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                    validator: (v) {
                      final valeur = v ?? '';
                      if (valeur.isEmpty) {
                        return 'Le nouveau mot de passe est obligatoire.';
                      }
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
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    obscureText: !_afficher,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe *',
                      prefixIcon: Icon(Icons.check_circle_outline),
                    ),
                    validator: (v) {
                      if ((v ?? '').isEmpty) {
                        return 'Confirmez le nouveau mot de passe.';
                      }
                      if (v != _nouveau.text) {
                        return 'Les deux mots de passe ne sont pas identiques.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          final motDePasse =
                              AuthentificationRepository.genererMotDePasse();
                          setState(() {
                            _nouveau.text = motDePasse;
                            _confirmation.text = motDePasse;
                            _afficher = true;
                          });
                        },
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Générer automatiquement'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _afficher = !_afficher),
                        icon: Icon(
                          _afficher
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        label: Text(
                          _afficher ? 'Masquer les mots de passe' : 'Afficher les mots de passe',
                        ),
                      ),
                    ],
                  ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 12),
                    _Bandeau(texte: _erreur!, erreur: true),
                  ],
                  if (_succes != null) ...[
                    const SizedBox(height: 12),
                    _Bandeau(texte: _succes!),
                  ],
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: utilisateur == null || _enCours
                          ? null
                          : () => _enregistrer(utilisateur),
                      icon: _enCours
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Enregistrer le nouveau mot de passe'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _enregistrer(Utilisateur utilisateur) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _erreur = null;
      _succes = null;
    });
    try {
      await ref
          .read(authentificationRepositoryProvider)
          .changerMotDePasse(
            id: utilisateur.id,
            ancienMotDePasse: _ancien.text,
            nouveauMotDePasse: _nouveau.text,
          );
      if (!mounted) return;
      setState(() {
        _succes = 'Votre mot de passe a bien été modifié.';
        _ancien.clear();
        _nouveau.clear();
        _confirmation.clear();
        _afficher = false;
      });
      notifier(context, 'Mot de passe modifié');
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurLisible(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }
}

/// Gestion des comptes utilisateurs (réservé aux administrateurs).
class OngletComptesUtilisateurs extends ConsumerWidget {
  const OngletComptesUtilisateurs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comptes = ref.watch(comptesUtilisateursProvider);
    final admin = ref.watch(roleProvider).peutGererComptes;
    if (!admin) {
      return const EtatVide(
        message:
            'La gestion des comptes est réservée aux administrateurs. '
            'Contactez un administrateur pour créer ou modifier un compte.',
        icone: Icons.lock_outline,
        titre: 'Accès réservé',
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: comptes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EtatErreur(
          erreur: e,
          onReessayer: () => ref.invalidate(comptesUtilisateursProvider),
        ),
        data: (liste) => TableauGestion<Utilisateur>(
          lignes: liste,
          cleLigne: (u) => u.id,
          messageVide:
              'Aucun compte utilisateur enregistré pour le moment.\n'
              'Créez un compte pour donner accès à l\'application.',
          resume: FilledButton.icon(
            onPressed: () => _ouvrirFormulaire(context, ref),
            icon: const Icon(Icons.person_add_alt, size: 18),
            label: const Text('Nouveau compte'),
          ),
          colonnes: [
            ColonneTableau(
              label: 'Utilisateur',
              flex: 3,
              valeur: (u) => _nomComplet(u),
              cellule: (_, u) => Row(
                children: [
                  AvatarUtilisateur(utilisateur: u, rayon: 12),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _nomComplet(u),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            ColonneTableau(
              label: 'Identifiant',
              flex: 3,
              valeur: (u) => u.identifiant,
            ),
            ColonneTableau(
              label: 'Rôle',
              flex: 3,
              valeur: (u) => RoleUtilisateur.depuisCode(u.role).libelle,
            ),
            ColonneTableau(
              label: 'Fonction',
              flex: 3,
              valeur: (u) => u.fonction ?? '',
            ),
            ColonneTableau(label: 'Email', flex: 4, valeur: (u) => u.email ?? ''),
            ColonneTableau(
              label: 'Dernière connexion',
              flex: 3,
              valeur: (u) => formatDate(u.derniereConnexion),
              cleTri: (u) => u.derniereConnexion,
            ),
            ColonneTableau(
              label: 'Actif',
              flex: 1,
              valeur: (u) => u.actif ? 'Actif' : 'Inactif',
              cellule: (_, u) => SwitchCompact(
                value: u.actif,
                infobulle: u.actif ? 'Désactiver ce compte' : 'Activer ce compte',
                onChanged: (v) async {
                  try {
                    await ref
                        .read(authentificationRepositoryProvider)
                        .mettreAJourCompte(u.id, actif: v);
                  } catch (e) {
                    if (context.mounted) {
                      notifier(context, messageErreurLisible(e), erreur: true);
                    }
                  }
                },
              ),
            ),
          ],
          actions: [
            ActionTableau<Utilisateur>(
              icone: Icons.edit_outlined,
              infobulle: 'Modifier le compte',
              onTap: (u) => _ouvrirFormulaire(context, ref, utilisateur: u),
            ),
            ActionTableau<Utilisateur>(
              icone: Icons.key_outlined,
              infobulle: 'Réinitialiser le mot de passe',
              onTap: (u) => _reinitialiserMotDePasse(context, ref, u),
            ),
            ActionTableau<Utilisateur>(
              icone: Icons.delete_outline,
              infobulle: 'Supprimer le compte',
              couleur: Theme.of(context).colorScheme.error,
              onTap: (u) async {
                final ok = await confirmer(
                  context,
                  titre: 'Supprimer le compte',
                  message:
                      'Supprimer définitivement le compte « ${_nomComplet(u)} » ? '
                      'Cette personne ne pourra plus se connecter.',
                );
                if (!ok) return;
                try {
                  await ref
                      .read(authentificationRepositoryProvider)
                      .supprimerCompte(
                        u.id,
                        demandeur: ref.read(sessionUtilisateurProvider)?.id,
                      );
                  if (context.mounted) notifier(context, 'Compte supprimé');
                } catch (e) {
                  if (context.mounted) {
                    notifier(context, messageErreurLisible(e), erreur: true);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ouvrirFormulaire(
    BuildContext context,
    WidgetRef ref, {
    Utilisateur? utilisateur,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DialogueUtilisateur(utilisateur: utilisateur),
    );
    if (ok == true && context.mounted) {
      notifier(
        context,
        utilisateur == null ? 'Compte créé' : 'Compte modifié',
      );
    }
  }

  Future<void> _reinitialiserMotDePasse(
    BuildContext context,
    WidgetRef ref,
    Utilisateur utilisateur,
  ) async {
    final nouveau = await showDialog<String>(
      context: context,
      builder: (_) => _DialogueMotDePasseUtilisateur(utilisateur: utilisateur),
    );
    if (nouveau == null || !context.mounted) return;
    try {
      await ref
          .read(authentificationRepositoryProvider)
          .definirMotDePasse(
            id: utilisateur.id,
            nouveauMotDePasse: nouveau,
          );
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const TitreDialogue(
              'Mot de passe réinitialisé',
              icone: Icons.lock_reset_outlined,
            ),
            content: SizedBox(
              width: largeurDialogue(ctx, 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Communiquez ce mot de passe à l\'utilisateur. '
                    'Il pourra le modifier depuis son profil.',
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    nouveau,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Terminé'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        notifier(context, messageErreurLisible(e), erreur: true);
      }
    }
  }

  static String _nomComplet(Utilisateur u) {
    final prenom = (u.prenomUtilisateur ?? '').trim();
    return prenom.isEmpty ? u.nom : '${u.nom} $prenom';
  }
}

/// Création / modification d'un compte utilisateur.
class DialogueUtilisateur extends ConsumerStatefulWidget {
  const DialogueUtilisateur({this.utilisateur, super.key});

  /// `null` : création d'un compte.
  final Utilisateur? utilisateur;

  @override
  ConsumerState<DialogueUtilisateur> createState() =>
      _DialogueUtilisateurState();
}

class _DialogueUtilisateurState extends ConsumerState<DialogueUtilisateur> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _identifiant;
  late final TextEditingController _fonction;
  late final TextEditingController _email;
  late final TextEditingController _telephone;
  late final TextEditingController _motDePasse;
  String _role = RoleUtilisateur.gestionnaire.code;
  bool _actif = true;
  bool _afficherMotDePasse = true;
  String? _photo;
  String? _erreur;
  bool _enCours = false;

  bool get _creation => widget.utilisateur == null;

  @override
  void initState() {
    super.initState();
    final u = widget.utilisateur;
    _nom = TextEditingController(text: u?.nom ?? '');
    _prenom = TextEditingController(text: u?.prenomUtilisateur ?? '');
    _identifiant = TextEditingController(text: u?.identifiant ?? '');
    _fonction = TextEditingController(text: u?.fonction ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _telephone = TextEditingController(text: u?.telephone ?? '');
    _motDePasse = TextEditingController(
      text: _creation ? AuthentificationRepository.genererMotDePasse() : '',
    );
    _role = u?.role ?? RoleUtilisateur.gestionnaire.code;
    _actif = u?.actif ?? true;
    _photo = u?.photo;
  }

  @override
  void dispose() {
    for (final c in [
      _nom,
      _prenom,
      _identifiant,
      _fonction,
      _email,
      _telephone,
      _motDePasse,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connecte = ref.watch(sessionUtilisateurProvider);
    final estSonPropreCompte = connecte?.id == widget.utilisateur?.id;
    final admin = ref.watch(roleProvider).peutGererComptes;
    final largeur = MediaQuery.sizeOf(context).width;
    final deux = largeur > 720;
    Widget paire(Widget a, Widget b) => deux
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          )
        : Column(
            children: [a, const SizedBox(height: 12), b],
          );

    return AlertDialog(
      title: TitreDialogue(
        _creation ? 'Nouveau compte utilisateur' : 'Modifier le compte',
        icone: Icons.manage_accounts_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 700),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AvatarUtilisateur(
                      utilisateur: widget.utilisateur?.copyWith(
                        photo: Value(_photo),
                      ),
                      rayon: 26,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Photo de profil',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _choisirPhoto,
                                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                                label: const Text('Choisir une photo'),
                              ),
                              if ((_photo ?? '').isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => setState(() => _photo = ''),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text('Retirer'),
                                ),
                            ],
                          ),
                          const Text(
                            'Facultatif — une initiale est affichée à défaut.',
                            style: TextStyle(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                paire(
                  ChampListe(
                    controller: _nom,
                    label: 'Nom *',
                    prefixIcon: Icons.person_outline,
                    valeurs: _valeursExistantes((u) => u.nom),
                    validator: (v) => validateurObligatoire(v, champ: 'Le nom'),
                  ),
                  ChampListe(
                    controller: _prenom,
                    label: 'Prénom',
                    prefixIcon: Icons.badge_outlined,
                    valeurs: _valeursExistantes((u) => u.prenomUtilisateur ?? ''),
                  ),
                ),
                const SizedBox(height: 12),
                paire(
                  ChampListe(
                    controller: _identifiant,
                    label: 'Nom d\'utilisateur *',
                    prefixIcon: Icons.alternate_email,
                    helperText: 'Sert à se connecter (sans espaces).',
                    valeurs: _valeursExistantes((u) => u.identifiant),
                    validator: (v) => validateurObligatoire(
                      v,
                      champ: 'Le nom d\'utilisateur',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: const InputDecoration(
                      labelText: 'Rôle *',
                      prefixIcon: Icon(Icons.verified_user_outlined),
                    ),
                    items: [
                      for (final r in RoleUtilisateur.values)
                        DropdownMenuItem(
                          value: r.code,
                          child: Text(r.libelle),
                        ),
                    ],
                    onChanged: admin && !estSonPropreCompte
                        ? (v) => setState(
                            () => _role = v ?? RoleUtilisateur.gestionnaire.code,
                          )
                        : null,
                  ),
                ),
                if (admin) ...[
                  const SizedBox(height: 6),
                  Text(
                    RoleUtilisateur.depuisCode(_role).description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                paire(
                  ChampListe(
                    controller: _fonction,
                    label: 'Fonction',
                    prefixIcon: Icons.work_outline,
                    valeurs: _valeursExistantes((u) => u.fonction ?? ''),
                  ),
                  ChampListe(
                    controller: _telephone,
                    label: 'Téléphone',
                    prefixIcon: Icons.phone_outlined,
                    valeurs: _valeursExistantes((u) => u.telephone ?? ''),
                  ),
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _email,
                  label: 'Email',
                  prefixIcon: Icons.mail_outline,
                  helperText:
                      'Facultatif — sert à vérifier l\'identité lors d\'une '
                      'réinitialisation de mot de passe.',
                  valeurs: _valeursExistantes((u) => u.email ?? ''),
                  validator: (v) {
                    final valeur = (v ?? '').trim();
                    if (valeur.isEmpty) return null;
                    final valide = RegExp(
                      r'^[\w\.\-+]+@[\w\-]+\.[\w\.\-]+$',
                    ).hasMatch(valeur);
                    return valide
                        ? null
                        : 'Adresse email invalide (exemple : nom@domaine.mg).';
                  },
                ),
                const SizedBox(height: 16),
                if (_creation) ...[
                  TextFormField(
                    controller: _motDePasse,
                    obscureText: !_afficherMotDePasse,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe initial *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      helperText:
                          'Communiquez-le à l\'utilisateur ; il pourra le '
                          'modifier depuis son profil.',
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
                      if ((v ?? '').isEmpty) {
                        return 'Le mot de passe initial est obligatoire.';
                      }
                      if (v!.length <
                          AuthentificationRepository.longueurMotDePasseMinimum) {
                        return 'Au moins '
                            '${AuthentificationRepository.longueurMotDePasseMinimum} '
                            'caractères.';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _motDePasse.text =
                            AuthentificationRepository.genererMotDePasse();
                        _afficherMotDePasse = true;
                      }),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Générer un mot de passe'),
                    ),
                  ),
                ],
                if (widget.utilisateur != null)
                  LigneBascule(
                    label: 'Compte actif',
                    sousTitre: estSonPropreCompte
                        ? 'Vous ne pouvez pas désactiver votre propre compte.'
                        : 'Un compte inactif ne peut plus se connecter.',
                    value: _actif,
                    onChanged: (estSonPropreCompte || !admin)
                        ? null
                        : (v) => setState(() => _actif = v),
                  ),
                if (_erreur != null) ...[
                  const SizedBox(height: 12),
                  _Bandeau(texte: _erreur!, erreur: true),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _enCours ? null : _enregistrer,
          icon: _enCours
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_creation ? 'Créer le compte' : 'Enregistrer'),
        ),
      ],
    );
  }

  List<String> _valeursExistantes(String Function(Utilisateur) f) {
    final liste = ref.watch(comptesUtilisateursProvider).value ?? const [];
    return liste
        .map(f)
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _choisirPhoto() async {
    try {
      final photo = await choisirPhotoProfil();
      if (photo == null) return;
      setState(() => _photo = photo);
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurLisible(e));
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final depot = ref.read(authentificationRepositoryProvider);
      final connecte = ref.read(sessionUtilisateurProvider);
      if (_creation) {
        await depot.creerUtilisateur(
          identifiant: _identifiant.text,
          nom: _nom.text,
          prenom: _prenom.text,
          role: _role,
          motDePasse: _motDePasse.text,
          fonction: _fonction.text,
          email: _email.text,
          telephone: _telephone.text,
          photo: _photo,
          actif: _actif,
        );
      } else {
        final id = widget.utilisateur!.id;
        await depot.mettreAJourCompte(
          id,
          identifiant: _identifiant.text,
          nom: _nom.text,
          prenom: _prenom.text,
          fonction: _fonction.text,
          email: _email.text,
          telephone: _telephone.text,
          role: _role,
          actif: _actif,
          photo: _photo,
        );
        // Le profil affiché (pied de page, écran profil) est actualisé
        // immédiatement si c'est le compte connecté.
        if (connecte != null && connecte.id == id) {
          ref.read(sessionUtilisateurProvider.notifier).state =
              await depot.parId(id);
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _erreur = messageErreurLisible(e));
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }
}

class _DialogueMotDePasseUtilisateur extends StatefulWidget {
  const _DialogueMotDePasseUtilisateur({required this.utilisateur});
  final Utilisateur utilisateur;

  @override
  State<_DialogueMotDePasseUtilisateur> createState() =>
      _DialogueMotDePasseUtilisateurState();
}

class _DialogueMotDePasseUtilisateurState
    extends State<_DialogueMotDePasseUtilisateur> {
  late final TextEditingController _motDePasse = TextEditingController(
    text: AuthentificationRepository.genererMotDePasse(),
  );
  bool _afficher = true;

  @override
  void dispose() {
    _motDePasse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const TitreDialogue(
        'Réinitialiser le mot de passe',
        icone: Icons.lock_outline,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Définissez un nouveau mot de passe pour « '
              '${widget.utilisateur.nom} » (@${widget.utilisateur.identifiant}).',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _motDePasse,
              obscureText: !_afficher,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  tooltip: _afficher ? 'Masquer' : 'Afficher',
                  icon: Icon(
                    _afficher
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _afficher = !_afficher),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _motDePasse.text =
                      AuthentificationRepository.genererMotDePasse();
                  _afficher = true;
                }),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Générer automatiquement'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final valeur = _motDePasse.text;
            if (valeur.length <
                AuthentificationRepository.longueurMotDePasseMinimum) {
              return;
            }
            Navigator.of(context).pop(valeur);
          },
          child: const Text('Réinitialiser'),
        ),
      ],
    );
  }
}

/// Ligne « libellé / valeur » du profil, avec mention obligatoire ou non.
class _LigneInfo extends StatelessWidget {
  const _LigneInfo({
    required this.libelle,
    required this.valeur,
    required this.obligatoire,
  });

  final String libelle;
  final String valeur;
  final bool obligatoire;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final vide = valeur.trim().isEmpty || valeur == '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    libelle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  obligatoire ? '*' : '',
                  style: TextStyle(color: scheme.error, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: vide
                ? Row(
                    children: [
                      Text(
                        'Non renseigné',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (obligatoire)
                        Text(
                          '  (obligatoire)',
                          style: TextStyle(fontSize: 12, color: scheme.error),
                        ),
                    ],
                  )
                : Text(
                    valeur,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Etiquette extends StatelessWidget {
  const _Etiquette({
    required this.icone,
    required this.texte,
    required this.couleur,
  });

  final IconData icone;
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 5),
          Text(
            texte,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.texte, this.erreur = false});
  final String texte;
  final bool erreur;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final couleur = erreur ? scheme.error : const Color(0xFF2E7D32);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            erreur ? Icons.error_outline : Icons.check_circle_outline,
            size: 18,
            color: couleur,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texte, style: const TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
