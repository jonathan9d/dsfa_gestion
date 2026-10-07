import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../domain/regles_parametres.dart';
import '../../../domain/statuts.dart';
import '../../../services/excel_import_service.dart';
import '../../providers/app_providers.dart';
import '../../providers/providers.dart';
import '../../reglages/reglages_affichage.dart';
import '../../reglages/raccourcis.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/tableau.dart';
import '../profil/profil_screen.dart';

/// Paramètres : référentiels (tarifs, distances), listes de valeurs,
/// paramètres généraux.
class ParametresScreen extends ConsumerStatefulWidget {
  const ParametresScreen({super.key});

  @override
  ConsumerState<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends ConsumerState<ParametresScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        body: Column(
          children: [
            const EnTetePage(
              titre: 'Paramètres',
              sousTitre: 'Référentiels, listes de valeurs et configuration',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: BarreOngletsAnimee(
                onglets: [
                  OngletAnime(
                    label: 'Tarifs',
                    icon: Icons.price_change_outlined,
                  ),
                  OngletAnime(
                    label: 'Distances & districts',
                    icon: Icons.map_outlined,
                  ),
                  OngletAnime(
                    label: 'Listes de valeurs',
                    icon: Icons.list_alt_outlined,
                  ),
                  OngletAnime(
                    label: 'Règles & matrice PJ',
                    icon: Icons.rule_folder_outlined,
                  ),
                  OngletAnime(
                    label: 'Comptes',
                    icon: Icons.manage_accounts_outlined,
                  ),
                  OngletAnime(label: 'Général', icon: Icons.tune_outlined),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: TabBarView(
                children: [
                  _OngletTarifs(),
                  _OngletDistances(),
                  _OngletListes(),
                  _OngletRegles(),
                  _OngletComptes(),
                  _OngletGeneral(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gestion de compte : informations utilisateur, mots de passe, création de
/// comptes. Les droits dépendent du rôle (administrateur ou autre).
class _OngletComptes extends ConsumerWidget {
  const _OngletComptes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilisateur = ref.watch(sessionUtilisateurProvider);
    final admin = ref.watch(roleProvider).peutGererComptes;
    final role = RoleUtilisateur.depuisCode(utilisateur?.role);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AvatarUtilisateur(utilisateur: utilisateur, rayon: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${utilisateur?.nom ?? 'Utilisateur'} — ${role.libelle}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          admin
                              ? 'Vous pouvez modifier votre profil, changer '
                                    'votre mot de passe et gérer tous les '
                                    'comptes.'
                              : 'Vous pouvez modifier votre profil et changer '
                                    'votre mot de passe. La création et la '
                                    'modification des autres comptes sont '
                                    'réservées aux administrateurs.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.profil),
                    icon: const Icon(Icons.badge_outlined, size: 18),
                    label: const Text('Mon profil'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Expanded(child: OngletComptesUtilisateurs()),
      ],
    );
  }
}

class _OngletTarifs extends ConsumerStatefulWidget {
  const _OngletTarifs();

  @override
  ConsumerState<_OngletTarifs> createState() => _OngletTarifsState();
}

class _OngletTarifsState extends ConsumerState<_OngletTarifs> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tarifs = ref.watch(tarifsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: ChampRecherche(
                  controller: _recherche,
                  hint: 'Rechercher un taux',
                  onChanged: (v) =>
                      ref.read(filtreRechercheProvider.notifier).state = v,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau taux'),
              ),
            ],
          ),
        ),
        Expanded(
          child: tarifs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EtatErreur(erreur: e),
            data: (liste) {
              final visibles = liste.where((t) {
                final billet =
                    t.ligneBudgetaire.toUpperCase().contains('BILLET') &&
                    t.ligneBudgetaire.toUpperCase().contains('AVION');
                return billet || t.tarif == 0 || t.tarif >= 20000;
              }).toList();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TableauGestion<TarifReferentiel>(
                  lignes: visibles,
                  cleLigne: (t) => t.id,
                  messageVide: 'Aucun taux enregistré.',
                  colonnes: [
                    ColonneTableau(
                      label: 'Rubrique',
                      flex: 3,
                      valeur: (t) => t.rubrique,
                    ),
                    ColonneTableau(
                      label: 'Ligne budgétaire',
                      flex: 4,
                      valeur: (t) => _libelleLigne(t.ligneBudgetaire),
                    ),
                    ColonneTableau(
                      label: 'Type de taux',
                      flex: 3,
                      valeur: (t) => t.typeActivite.isEmpty
                          ? 'Taux indemnité'
                          : t.typeActivite,
                    ),
                    ColonneTableau(
                      label: 'Unité',
                      flex: 2,
                      valeur: (t) => t.unite,
                    ),
                    ColonneTableau(
                      label: 'Zone',
                      flex: 2,
                      valeur: (t) => t.zone,
                    ),
                    ColonneTableau(
                      label: 'Taux (Ar)',
                      flex: 2,
                      numerique: true,
                      valeur: (t) =>
                          t.tarif <= 0 ? '—' : formatMontant(t.tarif),
                      cleTri: (t) => t.tarif,
                    ),
                  ],
                  actions: [
                    ActionTableau<TarifReferentiel>(
                      icone: Icons.edit_outlined,
                      infobulle: 'Modifier',
                      onTap: (t) => _ouvrirFormulaire(tarif: t),
                    ),
                    ActionTableau<TarifReferentiel>(
                      icone: Icons.delete_outline,
                      infobulle: 'Supprimer',
                      couleur: Theme.of(context).colorScheme.error,
                      onTap: (t) async {
                        final ok = await confirmer(
                          context,
                          titre: 'Supprimer le taux',
                          message:
                              'Supprimer « ${_libelleLigne(t.ligneBudgetaire)} » ?',
                        );
                        if (!ok) return;
                        await ref.read(tarifsRepositoryProvider).delete(t.id);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _libelleLigne(String ligne) {
    final normalise = ligne.toUpperCase().trim();
    if (normalise.contains('DEPLACEMENT PAR AVION') ||
        normalise.contains('DÉPLACEMENT PAR AVION')) {
      return 'Billet d’avion';
    }
    return ligne;
  }

  Future<void> _ouvrirFormulaire({TarifReferentiel? tarif}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _TarifDialog(tarif: tarif),
    );
    if (ok == true && mounted) notifier(context, 'Taux enregistré');
  }
}

class _TarifDialog extends ConsumerStatefulWidget {
  const _TarifDialog({this.tarif});
  final TarifReferentiel? tarif;

  @override
  ConsumerState<_TarifDialog> createState() => _TarifDialogState();
}

class _TarifDialogState extends ConsumerState<_TarifDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rubrique;
  late final TextEditingController _ligne;
  late final TextEditingController _typeTaux;
  late final TextEditingController _unite;
  late final TextEditingController _zone;
  late final TextEditingController _tarif;
  late final TextEditingController _observation;

  static const _typesTaux = [
    'Taux indemnité',
    'Taux frais de déplacement forfaitaire',
    'Taux frais de transfert aéroport',
    'Taux frais taxi-brousse',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.tarif;
    _rubrique = TextEditingController(text: t?.rubrique ?? '');
    _ligne = TextEditingController(
      text: _normaliserLigne(t?.ligneBudgetaire ?? ''),
    );
    _typeTaux = TextEditingController(
      text: t?.typeActivite?.isNotEmpty == true
          ? t!.typeActivite
          : _typesTaux.first,
    );
    _unite = TextEditingController(text: t?.unite ?? 'personne/jour');
    _zone = TextEditingController(text: t?.zone ?? 'Tous');
    _tarif = TextEditingController(
      text: (t?.tarif ?? 0) == 0 ? '' : t!.tarif.toString(),
    );
    _observation = TextEditingController(text: t?.observation ?? '');
  }

  static String _normaliserLigne(String ligne) {
    final u = ligne.toUpperCase();
    if (u.contains('DEPLACEMENT PAR AVION') ||
        u.contains('DÉPLACEMENT PAR AVION')) {
      return 'Billet d’avion';
    }
    return ligne;
  }

  bool get _billetAvion =>
      _ligne.text.toUpperCase().contains('BILLET') &&
      _ligne.text.toUpperCase().contains('AVION');

  @override
  void dispose() {
    for (final c in [
      _rubrique,
      _ligne,
      _typeTaux,
      _unite,
      _zone,
      _tarif,
      _observation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final valeur = _billetAvion
        ? 0.0
        : (double.tryParse(_tarif.text.replaceAll(',', '.')) ?? 0);
    if (!_billetAvion && valeur < 20000) {
      notifier(
        context,
        'Un taux doit être supérieur ou égal à 20 000 Ar.',
        erreur: true,
      );
      return;
    }
    final companion = ReferentielTarifsCompanion(
      rubrique: drift.Value(_rubrique.text.trim()),
      ligneBudgetaire: drift.Value(_normaliserLigne(_ligne.text.trim())),
      // Colonne historique réutilisée comme stockage du « type de taux ».
      typeActivite: drift.Value(_typeTaux.text.trim()),
      unite: drift.Value(_unite.text.trim()),
      zone: drift.Value(_zone.text.trim()),
      tarif: drift.Value(valeur),
      actif: const drift.Value(true),
      observation: drift.Value(_observation.text.trim()),
    );
    final repo = ref.read(tarifsRepositoryProvider);
    if (widget.tarif == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.tarif!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final existants =
        ref.watch(tousTarifsProvider).value ?? const <TarifReferentiel>[];
    List<String> distinctes(String Function(TarifReferentiel) f) =>
        existants.map(f).where((v) => v.trim().isNotEmpty).toSet().toList();
    final rubriques = distinctes((t) => t.rubrique);
    final lignes = distinctes((t) => _normaliserLigne(t.ligneBudgetaire));
    final unites = distinctes((t) => t.unite);
    final zones = distinctes((t) => t.zone);
    final observations = distinctes((t) => t.observation ?? '');

    return AlertDialog(
      title: TitreDialogue(
        widget.tarif == null ? 'Nouveau taux' : 'Modifier le taux',
        icone: Icons.price_check_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChampListe(
                  controller: _rubrique,
                  label: 'Rubrique *',
                  valeurs: rubriques,
                  prefixIcon: Icons.category_outlined,
                  validator: (v) =>
                      validateurObligatoire(v, champ: 'La rubrique'),
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _ligne,
                  label: 'Ligne budgétaire *',
                  valeurs: lignes,
                  prefixIcon: Icons.receipt_outlined,
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      validateurObligatoire(v, champ: 'La ligne budgétaire'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _typeTaux,
                        label: 'Type de taux *',
                        valeurs: _typesTaux,
                        prefixIcon: Icons.tune_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampListe(
                        controller: _zone,
                        label: 'Zone',
                        valeurs: zones,
                        prefixIcon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _unite,
                        label: 'Unité',
                        valeurs: unites,
                        prefixIcon: Icons.straighten_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _billetAvion
                          ? const InputDecorator(
                              decoration: InputDecoration(labelText: 'Taux'),
                              child: Text('Non défini pour un billet d’avion'),
                            )
                          : ChampNombre(
                              controller: _tarif,
                              label: 'Taux (Ar) *',
                              step: 1000,
                              validator: (v) =>
                                  validateurMontant(v, obligatoire: true),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ChampListe(
                  controller: _observation,
                  label: 'Observation',
                  valeurs: observations,
                  prefixIcon: Icons.notes_outlined,
                ),
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
          onPressed: _enregistrer,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _OngletDistances extends ConsumerStatefulWidget {
  const _OngletDistances();

  @override
  ConsumerState<_OngletDistances> createState() => _OngletDistancesState();
}

class _OngletDistancesState extends ConsumerState<_OngletDistances> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final districts = ref.watch(districtsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: ChampRecherche(
                  controller: _recherche,
                  hint: 'Rechercher un district',
                  onChanged: (v) =>
                      ref.read(filtreRechercheProvider.notifier).state = v,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _ouvrirFormulaire(),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau district'),
              ),
            ],
          ),
        ),
        Expanded(
          child: districts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EtatErreur(erreur: e),
            data: (liste) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TableauGestion<District>(
                lignes: liste,
                cleLigne: (d) => d.id,
                messageVide:
                    'Aucun district enregistré pour le moment.\n'
                    'Les districts proviennent du référentiel DISTANCES_DISTRICTS '
                    'du classeur de référence.',
                colonnes: [
                  ColonneTableau(
                    label: 'Région',
                    flex: 3,
                    valeur: (d) => d.region,
                  ),
                  ColonneTableau(
                    label: 'District',
                    flex: 3,
                    valeur: (d) => d.nom,
                    cellule: (_, d) => Text(
                      d.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  ColonneTableau(
                    label: 'Chef-lieu',
                    flex: 3,
                    valeur: (d) => d.chefLieuRegion,
                  ),
                  ColonneTableau(
                    label: 'Distance aller (km)',
                    flex: 2,
                    numerique: true,
                    valeur: (d) => d.distanceAllerKm.toStringAsFixed(0),
                    cleTri: (d) => d.distanceAllerKm,
                  ),
                  ColonneTableau(
                    label: 'Distance carburant (km)',
                    flex: 2,
                    numerique: true,
                    valeur: (d) => d.distanceCarburantKm.toStringAsFixed(0),
                    cleTri: (d) => d.distanceCarburantKm,
                  ),
                  ColonneTableau(
                    label: 'Délai A/R',
                    flex: 2,
                    numerique: true,
                    valeur: (d) => d.delaiRouteTotal.toStringAsFixed(0),
                    cleTri: (d) => d.delaiRouteTotal,
                  ),
                ],
                actions: [
                  ActionTableau<District>(
                    icone: Icons.edit_outlined,
                    infobulle: 'Modifier ce district',
                    onTap: (d) => _ouvrirFormulaire(district: d),
                  ),
                  ActionTableau<District>(
                    icone: Icons.delete_outline,
                    infobulle: 'Supprimer',
                    couleur: Theme.of(context).colorScheme.error,
                    onTap: (d) async {
                      final ok = await confirmer(
                        context,
                        titre: 'Supprimer le district',
                        message:
                            'Supprimer le district « ${d.nom} » (${d.region}) ? '
                            'Les distances associées seront perdues.',
                      );
                      if (!ok) return;
                      await ref.read(districtsRepositoryProvider).delete(d.id);
                      if (context.mounted) {
                        notifier(context, 'District supprimé');
                      }
                    },
                  ),
                ],
                onSupprimer: (lignes) async {
                  final repo = ref.read(districtsRepositoryProvider);
                  for (final d in lignes) {
                    await repo.delete(d.id);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _ouvrirFormulaire({District? district}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DistrictDialog(district: district),
    );
    if (ok == true && mounted) {
      notifier(
        context,
        district == null ? 'District ajouté' : 'District modifié',
      );
    }
  }
}

/// Formulaire d'ajout / de modification d'un district et de ses distances.
class _DistrictDialog extends ConsumerStatefulWidget {
  const _DistrictDialog({this.district});
  final District? district;

  @override
  ConsumerState<_DistrictDialog> createState() => _DistrictDialogState();
}

class _DistrictDialogState extends ConsumerState<_DistrictDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numero;
  late final TextEditingController _nom;
  late final TextEditingController _region;
  late final TextEditingController _chefLieu;
  late final TextEditingController _distanceAller;
  late final TextEditingController _distanceCarburant;
  late final TextEditingController _delaiAller;
  late final TextEditingController _delaiRetour;
  final _delaiTotal = TextEditingController(text: '0');
  late bool _estChefLieu;

  static String _nb(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    final d = widget.district;
    _numero = TextEditingController(
      text: d?.numero == null ? '' : '${d!.numero}',
    );
    _nom = TextEditingController(text: d?.nom ?? '');
    _region = TextEditingController(text: d?.region ?? '');
    _chefLieu = TextEditingController(text: d?.chefLieuRegion ?? '');
    _distanceAller = TextEditingController(text: _nb(d?.distanceAllerKm ?? 0));
    _distanceCarburant = TextEditingController(
      text: _nb(d?.distanceCarburantKm ?? 0),
    );
    _delaiAller = TextEditingController(text: _nb(d?.delaiRouteAller ?? 0));
    _delaiRetour = TextEditingController(text: _nb(d?.delaiRouteRetour ?? 0));
    _delaiTotal.text = _nb(d?.delaiRouteTotal ?? 0);
    _estChefLieu = d?.estChefLieuRegion ?? false;
    _delaiAller.addListener(_recalculerDelai);
    _delaiRetour.addListener(_recalculerDelai);
  }

  double _val(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  void _recalculerDelai() {
    final texte = _nb(_val(_delaiAller) + _val(_delaiRetour));
    if (_delaiTotal.text != texte) _delaiTotal.text = texte;
  }

  @override
  void dispose() {
    _delaiAller.removeListener(_recalculerDelai);
    _delaiRetour.removeListener(_recalculerDelai);
    for (final c in [
      _numero,
      _nom,
      _region,
      _chefLieu,
      _distanceAller,
      _distanceCarburant,
      _delaiAller,
      _delaiRetour,
      _delaiTotal,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final companion = DistrictsCompanion(
      numero: drift.Value(int.tryParse(_numero.text.trim())),
      nom: drift.Value(_nom.text.trim()),
      region: drift.Value(_region.text.trim()),
      chefLieuRegion: drift.Value(_chefLieu.text.trim()),
      estChefLieuRegion: drift.Value(_estChefLieu),
      distanceAllerKm: drift.Value(_val(_distanceAller)),
      distanceCarburantKm: drift.Value(_val(_distanceCarburant)),
      delaiRouteAller: drift.Value(_val(_delaiAller)),
      delaiRouteRetour: drift.Value(_val(_delaiRetour)),
      delaiRouteTotal: drift.Value(_val(_delaiAller) + _val(_delaiRetour)),
    );
    final repo = ref.read(districtsRepositoryProvider);
    if (widget.district == null) {
      await repo.insert(companion);
    } else {
      await repo.update(widget.district!.id, companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final existants =
        ref.watch(tousDistrictsProvider).value ?? const <District>[];
    List<String> distinctes(String Function(District) f) {
      final liste = existants
          .map(f)
          .where((v) => v.trim().isNotEmpty)
          .toSet()
          .toList();
      return liste..sort();
    }

    return AlertDialog(
      title: TitreDialogue(
        widget.district == null ? 'Nouveau district' : 'Modifier le district',
        icone: Icons.map_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 640),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _nom,
                        label: 'District *',
                        valeurs: existants.map((d) => d.nom).toList(),
                        prefixIcon: Icons.location_city_outlined,
                        validator: (v) =>
                            validateurObligatoire(v, champ: 'Le district'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _numero,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'N°',
                          isDense: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return int.tryParse(v.trim()) == null
                              ? 'Nombre entier attendu'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _region,
                        label: 'Région *',
                        valeurs: distinctes((d) => d.region),
                        prefixIcon: Icons.map_outlined,
                        validator: (v) =>
                            validateurObligatoire(v, champ: 'La région'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampListe(
                        controller: _chefLieu,
                        label: 'Chef-lieu de région *',
                        valeurs: distinctes((d) => d.chefLieuRegion),
                        prefixIcon: Icons.flag_outlined,
                        validator: (v) => validateurObligatoire(
                          v,
                          champ: 'Le chef-lieu de région',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LigneBascule(
                  label: 'Est un chef-lieu de région',
                  sousTitre:
                      'Utilisé pour le calcul des indemnités et forfaits.',
                  value: _estChefLieu,
                  onChanged: (v) => setState(() => _estChefLieu = v),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ChampNombre(
                        controller: _distanceAller,
                        label: 'Distance aller (km)',
                        step: 10,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampNombre(
                        controller: _distanceCarburant,
                        label: 'Distance carburant (km)',
                        step: 10,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampNombre(
                        controller: _delaiAller,
                        label: 'Délai route aller (h)',
                        step: 1,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampNombre(
                        controller: _delaiRetour,
                        label: 'Délai route retour (h)',
                        step: 1,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampNombre(
                        controller: _delaiTotal,
                        label: 'Délai A/R (auto)',
                        step: 1,
                        validator: (v) => validateurMontant(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Le délai total aller-retour est recalculé '
                  'automatiquement à partir des délais aller et retour.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
          onPressed: _enregistrer,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _OngletListes extends ConsumerStatefulWidget {
  const _OngletListes();

  @override
  ConsumerState<_OngletListes> createState() => _OngletListesState();
}

class _OngletListesState extends ConsumerState<_OngletListes> {
  String _categorie = 'TYPE_ACTIVITE';

  static const _categories = [
    'TYPE_ACTIVITE',
    'FINANCEMENT',
    'RUBRIQUE',
    'LIGNE_BUDGETAIRE',
    'INDEMNITE',
    'DEJEUNER',
    'PJ_RECUE',
    'PJ_CONFORME',
    'TYPE_PJ',
    'STATUT_PRESENCE',
  ];

  @override
  Widget build(BuildContext context) {
    final listes = ref.watch(listesProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  initialValue: _categorie,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: [
                    for (final c in _categories)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) =>
                      setState(() => _categorie = v ?? _categorie),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _ajouter(),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une valeur'),
              ),
            ],
          ),
        ),
        Expanded(
          child: listes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EtatErreur(erreur: e),
            data: (liste) {
              final filtrees = liste
                  .where((e) => e.categorie == _categorie)
                  .toList();
              if (filtrees.isEmpty) {
                return const EtatVide(
                  message: 'Aucune valeur dans cette catégorie.',
                  icone: Icons.list_alt_outlined,
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Card(
                    child: Column(
                      children: [
                        for (final v in filtrees)
                          ListTile(
                            title: Text(v.valeur),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () async {
                                final ok = await confirmer(
                                  context,
                                  titre: 'Supprimer la valeur',
                                  message: 'Supprimer « ${v.valeur} » ?',
                                );
                                if (!ok) return;
                                await ref
                                    .read(listesRepositoryProvider)
                                    .delete(v.id);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _ajouter() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: TitreDialogue(
          'Ajouter dans $_categorie',
          icone: Icons.playlist_add_outlined,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Valeur'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (ok == true && controller.text.trim().isNotEmpty) {
      await ref
          .read(listesRepositoryProvider)
          .insert(
            ReferenceValeursCompanion.insert(
              categorie: _categorie,
              valeur: controller.text.trim(),
            ),
          );
    }
    controller.dispose();
  }
}

/// Règles consolidées de la feuille `PARAMETRES` de `parametres.xlsx`.
///
/// Toutes les sections (taux, consommations, seuils, sources et matrice des
/// PJ requises) sont **modifiables** : les changements sont persistés dans le
/// classeur local sous la clé `regles_parametres` (JSON) puis relus par les
/// contrôles PJ.
class _OngletRegles extends ConsumerStatefulWidget {
  const _OngletRegles();

  @override
  ConsumerState<_OngletRegles> createState() => _OngletReglesState();
}

class _OngletReglesState extends ConsumerState<_OngletRegles> {
  /// Jalon de règle de date proposés dans les listes déroulantes.
  static const jalonsDate = <String>[
    'Avant activité',
    'Pendant activité',
    'Après activité',
    'Après date PV',
    'Après date de demande de cotation',
    'Selon nature de dépense',
  ];

  Future<void> _persister(ReglesParametres r) async {
    await ref
        .read(parametresRepositoryProvider)
        .ecrire(ExcelImportService.cleParametres, jsonEncode(r.toJson()));
    ref.invalidate(reglesParametresProvider);
    ref.invalidate(parametresProvider);
    if (mounted) notifier(context, 'Règles et matrice enregistrées');
  }

  ReglesParametres _avec(
    ReglesParametres r, {
    Map<String, double>? taux,
    Map<String, double>? carburant,
    Map<String, double>? transferts,
    Map<String, double>? forfaitaires,
    Map<String, int>? seuils,
    List<String>? sources,
    List<ReglePJRequise>? matrice,
  }) => ReglesParametres(
    tauxIndemnites: taux ?? r.tauxIndemnites,
    consommationCarburant: carburant ?? r.consommationCarburant,
    transferts: transferts ?? r.transferts,
    forfaitaires: forfaitaires ?? r.forfaitaires,
    seuilsRapportage: seuils ?? r.seuilsRapportage,
    sourcesFinancement: sources ?? r.sourcesFinancement,
    matricePJ: matrice ?? r.matricePJ,
  );

  Future<void> _editerMap({
    required String titre,
    required Map<String, double> valeurs,
    required bool entier,
    required String suffixe,
    required ReglesParametres Function(ReglesParametres, Map<String, double>)
    fusion,
  }) async {
    final resultat = await showDialog<Map<String, double>>(
      context: context,
      builder: (_) => _EditeurValeurs(
        titre: titre,
        valeurs: valeurs,
        entier: entier,
        suffixe: suffixe,
      ),
    );
    if (resultat == null) return;
    final regles = ref.read(reglesParametresProvider).value;
    if (regles == null) return;
    await _persister(fusion(regles, resultat));
  }

  @override
  Widget build(BuildContext context) {
    final regles = ref.watch(reglesParametresProvider);
    return regles.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EtatErreur(
        erreur: e,
        onReessayer: () => ref.invalidate(reglesParametresProvider),
      ),
      data: (r) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BandeauEdition(
              message:
                  'Ces règles pilotent les contrôles PJ et les calculs. Elles sont '
                  'modifiables : chaque changement est enregistré immédiatement.',
            ),
            if (r.estVide)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Aucune règle importée : les sections ci-dessous sont vides, '
                  'vous pouvez les compléter manuellement.',
                ),
              ),
            _CarteRegles(
              titre: 'Taux d’indemnités',
              icone: Icons.payments_outlined,
              entrees: {
                for (final e in r.tauxIndemnites.entries)
                  e.key: (e.value >= 1 && e.value == e.value.roundToDouble())
                      ? formatMontant(e.value)
                      : '${(e.value * 100).toStringAsFixed(0)} %',
              },
              onEditer: () => _editerMap(
                titre: 'Taux d’indemnités',
                valeurs: r.tauxIndemnites,
                entier: false,
                suffixe: 'Ar / jour',
                fusion: (base, v) => _avec(base, taux: v),
              ),
            ),
            _CarteRegles(
              titre: 'Consommation carburant (par km)',
              icone: Icons.local_gas_station_outlined,
              entrees: {
                for (final e in r.consommationCarburant.entries)
                  e.key: e.value.toString(),
              },
              onEditer: () => _editerMap(
                titre: 'Consommation carburant',
                valeurs: r.consommationCarburant,
                entier: false,
                suffixe: 'L / km',
                fusion: (base, v) => _avec(base, carburant: v),
              ),
            ),
            _CarteRegles(
              titre: 'Transfert aéroport',
              icone: Icons.flight_takeoff_outlined,
              entrees: {
                for (final e in r.transferts.entries)
                  e.key: formatMontant(e.value),
              },
              onEditer: () => _editerMap(
                titre: 'Transfert aéroport',
                valeurs: r.transferts,
                entier: false,
                suffixe: 'Ar',
                fusion: (base, v) => _avec(base, transferts: v),
              ),
            ),
            _CarteRegles(
              titre: 'Déplacement forfaitaire',
              icone: Icons.directions_car_outlined,
              entrees: {
                for (final e in r.forfaitaires.entries)
                  e.key: formatMontant(e.value),
              },
              onEditer: () => _editerMap(
                titre: 'Déplacement forfaitaire',
                valeurs: r.forfaitaires,
                entier: false,
                suffixe: 'Ar',
                fusion: (base, v) => _avec(base, forfaitaires: v),
              ),
            ),
            _CarteRegles(
              titre: 'Seuils de rapportage',
              icone: Icons.timer_outlined,
              entrees: {
                for (final e in r.seuilsRapportage.entries)
                  e.key: '${e.value} jours',
              },
              onEditer: () => _editerMap(
                titre: 'Seuils de rapportage',
                valeurs: {
                  for (final e in r.seuilsRapportage.entries)
                    e.key: e.value.toDouble(),
                },
                entier: true,
                suffixe: 'jours',
                fusion: (base, v) => _avec(
                  base,
                  seuils: {for (final e in v.entries) e.key: e.value.round()},
                ),
              ),
            ),
            _CarteRegles(
              titre: 'Sources de financement',
              icone: Icons.account_balance_outlined,
              entrees: {for (final s in r.sourcesFinancement) s: ''},
              onEditer: () async {
                final resultat = await showDialog<List<String>>(
                  context: context,
                  builder: (_) => _EditeurListe(
                    titre: 'Sources de financement',
                    valeurs: r.sourcesFinancement,
                  ),
                );
                if (resultat == null) return;
                await _persister(_avec(r, sources: resultat));
              },
            ),
            _CarteMatricePJ(
              regles: r,
              onEditer: () async {
                final resultat = await showDialog<List<ReglePJRequise>>(
                  context: context,
                  builder: (_) =>
                      _EditeurMatricePJ(regles: r, jalons: jalonsDate),
                );
                if (resultat == null) return;
                await _persister(_avec(r, matrice: resultat));
              },
            ),
          ],
        );
      },
    );
  }
}

/// Bandeau d'information signalant que la section est éditable.
class _BandeauEdition extends StatelessWidget {
  const _BandeauEdition({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _CarteRegles extends StatelessWidget {
  const _CarteRegles({
    required this.titre,
    required this.entrees,
    this.icone,
    this.onEditer,
  });

  final String titre;
  final Map<String, String> entrees;
  final IconData? icone;
  final VoidCallback? onEditer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icone ?? Icons.tune,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onEditer != null)
                  TextButton.icon(
                    onPressed: onEditer,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Modifier'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (entrees.isEmpty)
              Text('Aucune valeur définie.', style: theme.textTheme.bodySmall)
            else
              for (final e in entrees.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(e.key, style: theme.textTheme.bodyMedium),
                      ),
                      if (e.value.isNotEmpty)
                        Text(
                          e.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Matrice des pièces justificatives requises, groupée par rubrique.
class _CarteMatricePJ extends StatelessWidget {
  const _CarteMatricePJ({required this.regles, this.onEditer});
  final ReglesParametres regles;
  final VoidCallback? onEditer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rule_folder_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Matrice des PJ requises',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                if (onEditer != null)
                  TextButton.icon(
                    onPressed: onEditer,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Modifier'),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${regles.matricePJ.length} pièce(s) pour ${regles.rubriques.length} rubrique(s)',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (regles.matricePJ.isEmpty)
              Text(
                'Aucune pièce définie. Cliquez sur « Modifier » pour en ajouter.',
                style: theme.textTheme.bodySmall,
              ),
            for (final rubrique in regles.rubriques) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  rubrique,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              for (final p in regles.piecesPour(rubrique))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        p.obligatoire
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        size: 15,
                        color: p.obligatoire
                            ? AppTheme.vert
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.sousRubrique.isEmpty
                                  ? p.piece
                                  : '${p.sousRubrique} — ${p.piece}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (p.regleDate.isNotEmpty)
                              Text(
                                p.regleDate.replaceAll(';', ' · '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Éditeur générique d'une table clé → valeur numérique.
class _EditeurValeurs extends StatefulWidget {
  const _EditeurValeurs({
    required this.titre,
    required this.valeurs,
    required this.entier,
    required this.suffixe,
  });

  final String titre;
  final Map<String, double> valeurs;
  final bool entier;
  final String suffixe;

  @override
  State<_EditeurValeurs> createState() => _EditeurValeursState();
}

class _EditeurValeursState extends State<_EditeurValeurs> {
  final _lignes =
      <({TextEditingController cle, TextEditingController valeur})>[];

  @override
  void initState() {
    super.initState();
    for (final e in widget.valeurs.entries) {
      _lignes.add((
        cle: TextEditingController(text: e.key),
        valeur: TextEditingController(
          text: widget.entier ? e.value.round().toString() : _nombre(e.value),
        ),
      ));
    }
    if (_lignes.isEmpty) _ajouter();
  }

  static String _nombre(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  void dispose() {
    for (final l in _lignes) {
      l.cle.dispose();
      l.valeur.dispose();
    }
    super.dispose();
  }

  void _ajouter() => setState(
    () => _lignes.add((
      cle: TextEditingController(),
      valeur: TextEditingController(),
    )),
  );

  void _supprimer(int i) => setState(() {
    _lignes[i].cle.dispose();
    _lignes[i].valeur.dispose();
    _lignes.removeAt(i);
  });

  void _enregistrer() {
    final resultat = <String, double>{};
    for (final l in _lignes) {
      final cle = l.cle.text.trim();
      if (cle.isEmpty) continue;
      final n = double.tryParse(l.valeur.text.replaceAll(',', '.')) ?? 0;
      resultat[cle] = widget.entier ? n.roundToDouble() : n;
    }
    Navigator.of(context).pop(resultat);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitreDialogue(
        'Modifier — ${widget.titre}',
        icone: Icons.tune_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _lignes.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _lignes[i].cle,
                          decoration: const InputDecoration(
                            labelText: 'Libellé',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _lignes[i].valeur,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: widget.suffixe.isEmpty
                                ? 'Valeur'
                                : widget.suffixe,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Supprimer la ligne',
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () => _supprimer(i),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _ajouter,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une ligne'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _enregistrer,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Éditeur d'une liste de valeurs simples (sources de financement…).
class _EditeurListe extends StatefulWidget {
  const _EditeurListe({required this.titre, required this.valeurs});
  final String titre;
  final List<String> valeurs;

  @override
  State<_EditeurListe> createState() => _EditeurListeState();
}

class _EditeurListeState extends State<_EditeurListe> {
  final _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    for (final v in widget.valeurs) {
      _controllers.add(TextEditingController(text: v));
    }
    if (_controllers.isEmpty) _ajouter();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _ajouter() => setState(() => _controllers.add(TextEditingController()));

  void _supprimer(int i) => setState(() {
    _controllers[i].dispose();
    _controllers.removeAt(i);
  });

  void _enregistrer() {
    final resultat = _controllers
        .map((c) => c.text.trim())
        .where((v) => v.isNotEmpty)
        .toList();
    Navigator.of(context).pop(resultat);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitreDialogue(
        'Modifier — ${widget.titre}',
        icone: Icons.tune_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _controllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[i],
                          decoration: const InputDecoration(
                            labelText: 'Valeur',
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () => _supprimer(i),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _ajouter,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une valeur'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _enregistrer,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Éditeur de la matrice des PJ requises (ajout / modification / suppression).
class _EditeurMatricePJ extends StatefulWidget {
  const _EditeurMatricePJ({required this.regles, required this.jalons});
  final ReglesParametres regles;
  final List<String> jalons;

  @override
  State<_EditeurMatricePJ> createState() => _EditeurMatricePJState();
}

class _EditeurMatricePJState extends State<_EditeurMatricePJ> {
  late List<ReglePJRequise> _matrice;

  @override
  void initState() {
    super.initState();
    _matrice = List.of(widget.regles.matricePJ);
  }

  Future<void> _editer({ReglePJRequise? regle, int? index}) async {
    final resultat = await showDialog<ReglePJRequise>(
      context: context,
      builder: (_) => _ReglePJDialog(
        regle: regle,
        rubriques: widget.regles.rubriques,
        pieces: widget.regles.matricePJ.map((e) => e.piece).toSet().toList(),
        jalons: widget.jalons,
      ),
    );
    if (resultat == null) return;
    setState(() {
      if (index == null) {
        _matrice.add(resultat);
      } else {
        _matrice[index] = resultat;
      }
    });
  }

  void _supprimer(int index) => setState(() => _matrice.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const TitreDialogue(
        'Modifier — Matrice des PJ requises',
        icone: Icons.rule_folder_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 760),
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${_matrice.length} pièce(s)',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _editer(),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une pièce'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _matrice.isEmpty
                  ? const EtatVide(
                      message: 'Aucune pièce. Ajoutez-en une.',
                      icone: Icons.rule_folder_outlined,
                    )
                  : ListView.builder(
                      itemCount: _matrice.length,
                      itemBuilder: (context, i) {
                        final p = _matrice[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              p.obligatoire
                                  ? Icons.check_circle_outline
                                  : Icons.radio_button_unchecked,
                              color: p.obligatoire
                                  ? AppTheme.vert
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              '${p.rubrique} · ${p.libelle}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              [
                                if (p.regleDate.isNotEmpty) p.regleDate,
                                p.typeControle,
                                if (!p.actif) 'inactif',
                              ].join(' · '),
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Modifier',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () => _editer(regle: p, index: i),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  onPressed: () => _supprimer(i),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_matrice),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Formulaire d'une ligne de la matrice des PJ.
class _ReglePJDialog extends StatefulWidget {
  const _ReglePJDialog({
    required this.regle,
    required this.rubriques,
    required this.pieces,
    required this.jalons,
  });

  final ReglePJRequise? regle;
  final List<String> rubriques;
  final List<String> pieces;
  final List<String> jalons;

  @override
  State<_ReglePJDialog> createState() => _ReglePJDialogState();
}

class _ReglePJDialogState extends State<_ReglePJDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rubrique;
  late final TextEditingController _sousRubrique;
  late final TextEditingController _piece;
  late final TextEditingController _regleDate;
  late final TextEditingController _remarque;
  bool _obligatoire = true;
  bool _actif = true;
  String _typeControle = 'DATE';

  @override
  void initState() {
    super.initState();
    final p = widget.regle;
    _rubrique = TextEditingController(text: p?.rubrique ?? '');
    _sousRubrique = TextEditingController(text: p?.sousRubrique ?? '');
    _piece = TextEditingController(text: p?.piece ?? '');
    _regleDate = TextEditingController(text: p?.regleDate ?? '');
    _remarque = TextEditingController(text: p?.remarque ?? '');
    _obligatoire = p?.obligatoire ?? true;
    _actif = p?.actif ?? true;
    _typeControle = p?.typeControle ?? 'DATE';
  }

  @override
  void dispose() {
    for (final c in [_rubrique, _sousRubrique, _piece, _regleDate, _remarque]) {
      c.dispose();
    }
    super.dispose();
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ReglePJRequise(
        rubrique: _rubrique.text.trim(),
        sousRubrique: _sousRubrique.text.trim(),
        piece: _piece.text.trim(),
        obligatoire: _obligatoire,
        regleDate: _regleDate.text.trim(),
        typeControle: _typeControle,
        remarque: _remarque.text.trim(),
        actif: _actif,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitreDialogue(
        widget.regle == null
            ? 'Nouvelle pièce requise'
            : 'Modifier la pièce requise',
        icone: Icons.description_outlined,
      ),
      content: SizedBox(
        width: largeurDialogue(context, 640),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _rubrique,
                        label: 'Rubrique *',
                        valeurs: widget.rubriques,
                        validator: (v) =>
                            validateurObligatoire(v, champ: 'La rubrique'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampListe(
                        controller: _sousRubrique,
                        label: 'Sous-rubrique',
                        valeurs: const [],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _piece,
                  label: 'Pièce justificative *',
                  valeurs: widget.pieces,
                  prefixIcon: Icons.attach_file_outlined,
                  validator: (v) => validateurObligatoire(v, champ: 'La pièce'),
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _regleDate,
                  label: 'Règle de date',
                  valeurs: widget.jalons,
                  helperText: 'Combinez plusieurs jalons avec « ; »',
                  prefixIcon: Icons.event_available_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _typeControle,
                        decoration: const InputDecoration(
                          labelText: 'Type de contrôle',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'DATE', child: Text('DATE')),
                          DropdownMenuItem(
                            value: 'MANUEL',
                            child: Text('MANUEL'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _typeControle = v ?? 'DATE'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          LigneBascule(
                            label: 'Pièce obligatoire',
                            value: _obligatoire,
                            onChanged: (v) => setState(() => _obligatoire = v),
                          ),
                          LigneBascule(
                            label: 'Règle active',
                            value: _actif,
                            onChanged: (v) => setState(() => _actif = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _remarque,
                  label: 'Remarque',
                  valeurs: const [],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _enregistrer,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Valider'),
        ),
      ],
    );
  }
}

class _OngletGeneral extends ConsumerStatefulWidget {
  const _OngletGeneral();

  @override
  ConsumerState<_OngletGeneral> createState() => _OngletGeneralState();
}

class _OngletGeneralState extends ConsumerState<_OngletGeneral> {
  /// Couleurs proposées pour la personnalisation de l'interface.
  static const _palette = <Color>[
    AppTheme.rose,
    AppTheme.violet,
    AppTheme.vert,
    Color(0xFF283593),
    Color(0xFF1565C0),
    Color(0xFF00695C),
    Color(0xFFEF6C00),
    Color(0xFFC62828),
    Color(0xFF5D4037),
    Color(0xFF37474F),
  ];

  late final TextEditingController _banque;
  late final TextEditingController _compte;
  late final TextEditingController _devise;
  late final TextEditingController _exercice;
  late final TextEditingController _dureeJours;
  late final TextEditingController _raccourciMenu;
  late final TextEditingController _raccourciDashboard;
  bool _charge = false;

  @override
  void initState() {
    super.initState();
    _banque = TextEditingController();
    _compte = TextEditingController();
    _devise = TextEditingController();
    _exercice = TextEditingController();
    _dureeJours = TextEditingController();
    _raccourciMenu = TextEditingController(text: RaccourcisApp.defaut.menu);
    _raccourciDashboard = TextEditingController(
      text: RaccourcisApp.defaut.dashboard,
    );
    _charger();
  }

  Future<void> _charger() async {
    final repo = ref.read(parametresRepositoryProvider);
    _banque.text = await repo.lire('banque') ?? 'BNI';
    _compte.text = await repo.lire('compte') ?? '';
    _devise.text = await repo.lire('devise') ?? 'MGA';
    _exercice.text = await repo.lire('exercice') ?? '2026';
    _dureeJours.text =
        '${await ref.read(sessionRepositoryProvider).dureeJours()}';
    final raccourcis = await ref
        .read(parametresRepositoryProvider)
        .lire('raccourcis.app');
    final config = RaccourcisApp.fromJson(raccourcis);
    _raccourciMenu.text = config.menu;
    _raccourciDashboard.text = config.dashboard;
    if (mounted) setState(() => _charge = true);
  }

  @override
  void dispose() {
    for (final c in [
      _banque,
      _compte,
      _devise,
      _exercice,
      _dureeJours,
      _raccourciMenu,
      _raccourciDashboard,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final repo = ref.read(parametresRepositoryProvider);
    await repo.ecrire('banque', _banque.text.trim());
    await repo.ecrire('compte', _compte.text.trim());
    await repo.ecrire('devise', _devise.text.trim());
    await repo.ecrire('exercice', _exercice.text.trim());
    final jours =
        (int.tryParse(_dureeJours.text.trim()) ??
                SessionRepository.dureeMaximaleSansOuvertureJours)
            .clamp(1, 30);
    await repo.ecrire(SessionRepository.cleDureeJours, '$jours');
    final config = RaccourcisApp(
      menu: normaliserRaccourci(_raccourciMenu.text),
      dashboard: normaliserRaccourci(_raccourciDashboard.text),
    );
    await repo.ecrire('raccourcis.app', jsonEncode(config.toJson()));
    ref.invalidate(raccourcisProvider);
    if (mounted) {
      ref.invalidate(parametresProvider);
      notifier(context, 'Paramètres enregistrés');
    }
  }

  // --- Réglages d'affichage (tableaux, couleurs, police) ------------------

  /// Met à jour les réglages en mémoire (application immédiate) et, par
  /// défaut, les persiste dans la table `parametres`.
  void _modifierReglages(
    ReglagesAffichage Function(ReglagesAffichage) modifier, {
    bool persister = true,
  }) {
    final nouveau = modifier(ref.read(reglagesAffichageProvider));
    ref.read(reglagesAffichageProvider.notifier).state = nouveau;
    if (persister) _persisterReglages(nouveau);
  }

  Future<void> _persisterReglages(ReglagesAffichage r) async {
    final repo = ref.read(parametresRepositoryProvider);
    for (final e in r.versParametres().entries) {
      await repo.ecrire(e.key, e.value);
    }
  }

  Widget _paletteChoix({
    required Color actuelle,
    required ValueChanged<Color> onChoisir,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in _palette)
          Tooltip(
            message:
                '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            child: InkWell(
              onTap: () => onChoisir(c),
              customBorder: const CircleBorder(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c == actuelle
                        ? scheme.onSurface
                        : scheme.outlineVariant,
                    width: c == actuelle ? 3 : 1,
                  ),
                ),
                child: c == actuelle
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: c.computeLuminance() > 0.55
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_charge) {
      return const Center(child: CircularProgressIndicator());
    }
    final mode = ref.watch(themeModeProvider);
    final menuReduit = ref.watch(sidebarReduiteProvider);
    final reglages = ref.watch(reglagesAffichageProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Préférences de l\'application',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ces réglages s\'appliquent immédiatement et sont conservés '
                  'd\'une session à l\'autre.',
                  style: TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: mode,
                  decoration: const InputDecoration(
                    labelText: 'Thème de l\'interface',
                    prefixIcon: Icon(Icons.brightness_6_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Clair'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Sombre'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Selon le système'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(themeModeProvider.notifier).state = v;
                    // Le choix du thème est conservé d'une session à l'autre.
                    ref
                        .read(parametresRepositoryProvider)
                        .ecrire(
                          ReglagesAffichage.cleTheme,
                          ReglagesAffichage.themeVersTexte(v),
                        );
                  },
                ),
                const SizedBox(height: 8),
                LigneBascule(
                  label: 'Menu latéral replié au démarrage',
                  sousTitre:
                      'Affiche le menu sous forme d\'icônes pour agrandir la zone de travail.',
                  value: menuReduit,
                  onChanged: (v) =>
                      ref.read(sidebarReduiteProvider.notifier).state = v,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Raccourcis clavier',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Modifiez les raccourcis Windows utilisés dans l’application.',
                  style: TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _raccourciMenu,
                        label: 'Déployer / replier le menu',
                        valeurs: const ['CTRL+B', 'CTRL+M', 'CTRL+2'],
                        prefixIcon: Icons.menu_open_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampListe(
                        controller: _raccourciDashboard,
                        label: 'Ouvrir le tableau de bord',
                        valeurs: const ['CTRL+1', 'CTRL+D', 'CTRL+0'],
                        prefixIcon: Icons.dashboard_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _enregistrer,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer les raccourcis'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Affichage des tableaux et de l\'interface',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ces réglages s\'appliquent immédiatement à tous les '
                  'tableaux et sont conservés d\'une session à l\'autre.',
                  style: TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                LigneBascule(
                  label: 'Défilement horizontal des tableaux',
                  sousTitre:
                      'Quand un nom est très long, le tableau peut glisser '
                      'vers la gauche et la droite. Désactivé, les colonnes '
                      'sont simplement resserrées.',
                  value: reglages.defilementHorizontal,
                  onChanged: (v) => _modifierReglages(
                    (r) => r.copyWith(defilementHorizontal: v),
                  ),
                ),
                LigneBascule(
                  label: 'Filtres visibles dès l’ouverture',
                  sousTitre:
                      'Par défaut les barres de filtres sont **masquées** : '
                      'chaque tableau se contente d’un bouton « Filtrer ». '
                      'Activez ce réglage pour les afficher d’emblée.',
                  value: reglages.filtresOuverts,
                  onChanged: (v) =>
                      _modifierReglages((r) => r.copyWith(filtresOuverts: v)),
                ),
                LigneBascule(
                  label: 'Sauvegarde automatique',
                  sousTitre:
                      'Crée automatiquement une copie de sécurité de la base '
                      'à chaque ouverture (une par jour maximum).',
                  value: reglages.sauvegardeAutomatique,
                  onChanged: (v) => _modifierReglages(
                    (r) => r.copyWith(sauvegardeAutomatique: v),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Couleur principale',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _paletteChoix(
                  actuelle: reglages.couleurPrimaire,
                  onChoisir: (c) =>
                      _modifierReglages((r) => r.copyWith(couleurPrimaire: c)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Couleur secondaire',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _paletteChoix(
                  actuelle: reglages.couleurSecondaire,
                  onChoisir: (c) => _modifierReglages(
                    (r) => r.copyWith(couleurSecondaire: c),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.format_size, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Slider(
                        value: reglages.echellePolice,
                        min: 0.85,
                        max: 1.30,
                        divisions: 9,
                        label: '${(reglages.echellePolice * 100).round()} %',
                        onChanged: (v) => _modifierReglages(
                          (r) => r.copyWith(echellePolice: v),
                          persister: false,
                        ),
                        onChangeEnd: (v) => _persisterReglages(
                          ref.read(reglagesAffichageProvider),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '${(reglages.echellePolice * 100).round()} %',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sécurité',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Au-delà de ce délai sans ouverture, le mot de passe est '
                  'redemandé (l\'identifiant reste pré-rempli).',
                  style: TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 280,
                  child: ChampNombre(
                    controller: _dureeJours,
                    label: 'Reconnexion automatique (jours)',
                    prefixIcon: Icons.lock_clock_outlined,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n < 1 || n > 30) {
                        return 'Saisissez un nombre de jours entre 1 et 30.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _enregistrer,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer les réglages'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations bancaires',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                ChampListe(
                  controller: _banque,
                  label: 'Banque',
                  valeurs: const [
                    'BNI',
                    'BOA',
                    'BMOI',
                    'BFV-SG',
                    'BRED',
                    'BGFI',
                    'AFG',
                    'Accès Banque',
                    'Baobab',
                    'MBC',
                    'SIPEM',
                    'BANQUE CENTRALE',
                  ],
                  prefixIcon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: 12),
                ChampListe(
                  controller: _compte,
                  label: 'Compte N°',
                  valeurs: const [],
                  prefixIcon: Icons.numbers_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChampListe(
                        controller: _devise,
                        label: 'Devise',
                        valeurs: const ['MGA', 'EUR', 'USD'],
                        prefixIcon: Icons.currency_exchange_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChampListe(
                        controller: _exercice,
                        label: 'Exercice',
                        valeurs: [
                          for (var a = DateTime.now().year + 1; a >= 2020; a--)
                            '$a',
                        ],
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _enregistrer,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer les paramètres'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rôles et utilisateurs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'L\'architecture prend en charge les rôles ADMIN, GESTIONNAIRE et LECTEUR. '
                  'Le rôle actif contrôle les droits de modification dans l\'application.',
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final role = ref.watch(roleProvider);
                    return DropdownButtonFormField<RoleUtilisateur>(
                      initialValue: role,
                      decoration: const InputDecoration(
                        labelText: 'Rôle actif',
                      ),
                      items: [
                        for (final r in RoleUtilisateur.values)
                          DropdownMenuItem(value: r, child: Text(r.code)),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(roleProvider.notifier).state = v;
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historique des modifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final audit = ref.watch(auditProvider);
                    return audit.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Erreur : $e'),
                      data: (entrees) {
                        if (entrees.isEmpty) {
                          return const Text('Aucune modification enregistrée.');
                        }
                        return Column(
                          children: [
                            for (final e in entrees.take(30))
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.history, size: 18),
                                title: Text('${e.action} · ${e.entite}'),
                                subtitle: Text(
                                  '${e.utilisateur} — ${e.ancienneValeur ?? ''} → ${e.nouvelleValeur ?? ''}',
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
