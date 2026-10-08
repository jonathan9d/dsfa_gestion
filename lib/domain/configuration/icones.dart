import 'package:flutter/material.dart';

/// Catalogue des **icônes** proposées par la configuration.
///
/// Chaque entrée possède une **clé stable** (écrite dans la configuration :
/// `dashboard`, `depenses`…) et une icône Material. Les clés ne changent
/// jamais : une icône choisie reste valable d'une version à l'autre.
///
/// Pour une icône absente du catalogue, deux solutions :
///  1. chercher le nom exact sur <https://fonts.google.com/icons> puis
///     demander son ajout au catalogue (nom Material, ex. `agriculture`) ;
///  2. **importer une image** au format exact décrit par [formatImport] :
///     elle est enregistrée dans la configuration (encodée en PNG) et
///     affichée telle quelle, sans recompiler l'application.
class IconesApp {
  const IconesApp._();

  /// Format d'import accepté pour une icône personnalisée.
  static const formatImport =
      'Format d\'import : PNG ou JPEG, carré, 512 × 512 pixels maximum, '
      'moins de 400 Ko, fond transparent de préférence. '
      'Les icônes Material se trouvent sur fonts.google.com/icons '
      '(chercher « agriculture », « storefront »…) ; '
      'les fichiers PNG sont acceptés tels quels (SVG et ICO non pris en charge).';

  /// Clé du catalogue la plus proche d'un libellé (recherche libre).
  static const defaut = 'tableau_de_bord';

  static const Map<String, IconData> catalogue = {
    // Général / navigation
    'tableau_de_bord': Icons.dashboard_outlined,
    'tableau_de_bord_plein': Icons.dashboard,
    'accueil': Icons.home_outlined,
    'liste': Icons.list_alt_outlined,
    'etiquette': Icons.label_outline,
    'marque_page': Icons.bookmark_border,
    'tableau': Icons.table_chart_outlined,
    'grille': Icons.grid_view_outlined,
    'dossier': Icons.folder_outlined,
    'document': Icons.description_outlined,
    'fichier': Icons.insert_drive_file_outlined,
    'archive': Icons.inventory_2_outlined,
    // Activités / terrain
    'activite': Icons.event_note_outlined,
    'calendrier': Icons.calendar_month_outlined,
    'date': Icons.event_outlined,
    'agenda': Icons.edit_calendar_outlined,
    'carte': Icons.map_outlined,
    'lieu': Icons.place_outlined,
    'itineraire': Icons.route_outlined,
    'equipe': Icons.groups_outlined,
    'personne': Icons.person_outline,
    'personnes': Icons.people_outline,
    'badge': Icons.badge_outlined,
    'sante': Icons.health_and_safety_outlined,
    'vaccin': Icons.vaccines_outlined,
    'sensibilisation': Icons.campaign_outlined,
    'formation': Icons.school_outlined,
    'agriculture': Icons.agriculture_outlined,
    'usine': Icons.factory_outlined,
    'commerce': Icons.storefront_outlined,
    'elevage': Icons.egg_outlined,
    'eau': Icons.water_drop_outlined,
    'environnement': Icons.eco_outlined,
    // Argent
    'budget': Icons.savings_outlined,
    'depense': Icons.receipt_long_outlined,
    'paiement': Icons.payments_outlined,
    'banque': Icons.account_balance_outlined,
    'caisse': Icons.point_of_sale_outlined,
    'portefeuille': Icons.account_balance_wallet_outlined,
    'monnaie': Icons.attach_money,
    'graphique': Icons.insert_chart_outlined,
    'tendance': Icons.trending_up,
    'rapport': Icons.assessment_outlined,
    'rapprochement': Icons.sync_alt_outlined,
    'facture': Icons.request_quote_outlined,
    // Suivi / contrôle
    'suivi': Icons.track_changes_outlined,
    'controle': Icons.rule_outlined,
    'verifie': Icons.verified_outlined,
    'alerte': Icons.warning_amber_rounded,
    'erreur': Icons.error_outline,
    'recherche': Icons.search,
    'filtre': Icons.filter_alt_outlined,
    'statistiques': Icons.bar_chart_outlined,
    'courbe': Icons.show_chart,
    'historique': Icons.history,
    'horloge': Icons.schedule_outlined,
    // Outils / administration
    'parametres': Icons.settings_outlined,
    'reglages': Icons.tune_outlined,
    'outils': Icons.build_outlined,
    'securite': Icons.security_outlined,
    'sauvegarde': Icons.backup_outlined,
    'utilisateur': Icons.manage_accounts_outlined,
    'journal': Icons.receipt_outlined,
    'note': Icons.sticky_note_2_outlined,
    'epingle': Icons.push_pin_outlined,
    'etoile': Icons.star_border,
    'marqueur': Icons.flag_outlined,
    'cible': Icons.gps_fixed,
    'ampoule': Icons.lightbulb_outline,
    'livraison': Icons.local_shipping_outlined,
    'carburant': Icons.local_gas_station_outlined,
    'restauration': Icons.restaurant_outlined,
    'salle': Icons.meeting_room_outlined,
    'fourniture': Icons.shopping_bag_outlined,
    'media': Icons.perm_media_outlined,
    'imprimante': Icons.print_outlined,
    'telephone': Icons.phone_iphone_outlined,
    'ordinateur': Icons.computer_outlined,
  };

  /// Icône Material correspondant à une clé, ou `null`.
  static IconData? parCle(String? cle) =>
      cle == null || cle.isEmpty ? null : catalogue[cle];

  /// Icône effective d'une entrée de configuration : image importée si elle
  /// existe, sinon icône du catalogue, sinon icône par défaut de l'application.
  static IconData iconeOuDefaut(String? cle) =>
      parCle(cle) ?? Icons.widgets_outlined;

  /// Toutes les clés, triées par libellé lisible.
  static List<String> clesTriees() {
    final cles = catalogue.keys.toList();
    cles.sort((a, b) => libelle(a).compareTo(libelle(b)));
    return cles;
  }

  /// Libellé lisible d'une clé (`tableau_de_bord` → « Tableau de bord »).
  static String libelle(String cle) {
    final texte = cle.replaceAll('_', ' ').trim();
    if (texte.isEmpty) return cle;
    return '${texte[0].toUpperCase()}${texte.substring(1)}';
  }

  /// Clés dont le libellé contient [recherche] (insensible à la casse).
  static List<String> rechercher(String recherche) {
    final terme = recherche.trim().toLowerCase();
    if (terme.isEmpty) return clesTriees();
    return clesTriees()
        .where(
          (c) =>
              libelle(c).toLowerCase().contains(terme) ||
              c.toLowerCase().contains(terme),
        )
        .toList();
  }
}
