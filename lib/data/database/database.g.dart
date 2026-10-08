// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DistrictsTable extends Districts
    with TableInfo<$DistrictsTable, District> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DistrictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chefLieuRegionMeta = const VerificationMeta(
    'chefLieuRegion',
  );
  @override
  late final GeneratedColumn<String> chefLieuRegion = GeneratedColumn<String>(
    'chef_lieu_region',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estChefLieuRegionMeta = const VerificationMeta(
    'estChefLieuRegion',
  );
  @override
  late final GeneratedColumn<bool> estChefLieuRegion = GeneratedColumn<bool>(
    'est_chef_lieu_region',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("est_chef_lieu_region" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _distanceAllerKmMeta = const VerificationMeta(
    'distanceAllerKm',
  );
  @override
  late final GeneratedColumn<double> distanceAllerKm = GeneratedColumn<double>(
    'distance_aller_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceCarburantKmMeta =
      const VerificationMeta('distanceCarburantKm');
  @override
  late final GeneratedColumn<double> distanceCarburantKm =
      GeneratedColumn<double>(
        'distance_carburant_km',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _delaiRouteAllerMeta = const VerificationMeta(
    'delaiRouteAller',
  );
  @override
  late final GeneratedColumn<double> delaiRouteAller = GeneratedColumn<double>(
    'delai_route_aller',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _delaiRouteRetourMeta = const VerificationMeta(
    'delaiRouteRetour',
  );
  @override
  late final GeneratedColumn<double> delaiRouteRetour = GeneratedColumn<double>(
    'delai_route_retour',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _delaiRouteTotalMeta = const VerificationMeta(
    'delaiRouteTotal',
  );
  @override
  late final GeneratedColumn<double> delaiRouteTotal = GeneratedColumn<double>(
    'delai_route_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    numero,
    chefLieuRegion,
    region,
    nom,
    estChefLieuRegion,
    distanceAllerKm,
    distanceCarburantKm,
    delaiRouteAller,
    delaiRouteRetour,
    delaiRouteTotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'districts';
  @override
  VerificationContext validateIntegrity(
    Insertable<District> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    }
    if (data.containsKey('chef_lieu_region')) {
      context.handle(
        _chefLieuRegionMeta,
        chefLieuRegion.isAcceptableOrUnknown(
          data['chef_lieu_region']!,
          _chefLieuRegionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chefLieuRegionMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('est_chef_lieu_region')) {
      context.handle(
        _estChefLieuRegionMeta,
        estChefLieuRegion.isAcceptableOrUnknown(
          data['est_chef_lieu_region']!,
          _estChefLieuRegionMeta,
        ),
      );
    }
    if (data.containsKey('distance_aller_km')) {
      context.handle(
        _distanceAllerKmMeta,
        distanceAllerKm.isAcceptableOrUnknown(
          data['distance_aller_km']!,
          _distanceAllerKmMeta,
        ),
      );
    }
    if (data.containsKey('distance_carburant_km')) {
      context.handle(
        _distanceCarburantKmMeta,
        distanceCarburantKm.isAcceptableOrUnknown(
          data['distance_carburant_km']!,
          _distanceCarburantKmMeta,
        ),
      );
    }
    if (data.containsKey('delai_route_aller')) {
      context.handle(
        _delaiRouteAllerMeta,
        delaiRouteAller.isAcceptableOrUnknown(
          data['delai_route_aller']!,
          _delaiRouteAllerMeta,
        ),
      );
    }
    if (data.containsKey('delai_route_retour')) {
      context.handle(
        _delaiRouteRetourMeta,
        delaiRouteRetour.isAcceptableOrUnknown(
          data['delai_route_retour']!,
          _delaiRouteRetourMeta,
        ),
      );
    }
    if (data.containsKey('delai_route_total')) {
      context.handle(
        _delaiRouteTotalMeta,
        delaiRouteTotal.isAcceptableOrUnknown(
          data['delai_route_total']!,
          _delaiRouteTotalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  District map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return District(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      ),
      chefLieuRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chef_lieu_region'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      estChefLieuRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}est_chef_lieu_region'],
      )!,
      distanceAllerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_aller_km'],
      )!,
      distanceCarburantKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_carburant_km'],
      )!,
      delaiRouteAller: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delai_route_aller'],
      )!,
      delaiRouteRetour: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delai_route_retour'],
      )!,
      delaiRouteTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delai_route_total'],
      )!,
    );
  }

  @override
  $DistrictsTable createAlias(String alias) {
    return $DistrictsTable(attachedDatabase, alias);
  }
}

class District extends DataClass implements Insertable<District> {
  final int id;
  final int? numero;
  final String chefLieuRegion;
  final String region;
  final String nom;
  final bool estChefLieuRegion;
  final double distanceAllerKm;
  final double distanceCarburantKm;
  final double delaiRouteAller;
  final double delaiRouteRetour;
  final double delaiRouteTotal;
  const District({
    required this.id,
    this.numero,
    required this.chefLieuRegion,
    required this.region,
    required this.nom,
    required this.estChefLieuRegion,
    required this.distanceAllerKm,
    required this.distanceCarburantKm,
    required this.delaiRouteAller,
    required this.delaiRouteRetour,
    required this.delaiRouteTotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || numero != null) {
      map['numero'] = Variable<int>(numero);
    }
    map['chef_lieu_region'] = Variable<String>(chefLieuRegion);
    map['region'] = Variable<String>(region);
    map['nom'] = Variable<String>(nom);
    map['est_chef_lieu_region'] = Variable<bool>(estChefLieuRegion);
    map['distance_aller_km'] = Variable<double>(distanceAllerKm);
    map['distance_carburant_km'] = Variable<double>(distanceCarburantKm);
    map['delai_route_aller'] = Variable<double>(delaiRouteAller);
    map['delai_route_retour'] = Variable<double>(delaiRouteRetour);
    map['delai_route_total'] = Variable<double>(delaiRouteTotal);
    return map;
  }

  DistrictsCompanion toCompanion(bool nullToAbsent) {
    return DistrictsCompanion(
      id: Value(id),
      numero: numero == null && nullToAbsent
          ? const Value.absent()
          : Value(numero),
      chefLieuRegion: Value(chefLieuRegion),
      region: Value(region),
      nom: Value(nom),
      estChefLieuRegion: Value(estChefLieuRegion),
      distanceAllerKm: Value(distanceAllerKm),
      distanceCarburantKm: Value(distanceCarburantKm),
      delaiRouteAller: Value(delaiRouteAller),
      delaiRouteRetour: Value(delaiRouteRetour),
      delaiRouteTotal: Value(delaiRouteTotal),
    );
  }

  factory District.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return District(
      id: serializer.fromJson<int>(json['id']),
      numero: serializer.fromJson<int?>(json['numero']),
      chefLieuRegion: serializer.fromJson<String>(json['chefLieuRegion']),
      region: serializer.fromJson<String>(json['region']),
      nom: serializer.fromJson<String>(json['nom']),
      estChefLieuRegion: serializer.fromJson<bool>(json['estChefLieuRegion']),
      distanceAllerKm: serializer.fromJson<double>(json['distanceAllerKm']),
      distanceCarburantKm: serializer.fromJson<double>(
        json['distanceCarburantKm'],
      ),
      delaiRouteAller: serializer.fromJson<double>(json['delaiRouteAller']),
      delaiRouteRetour: serializer.fromJson<double>(json['delaiRouteRetour']),
      delaiRouteTotal: serializer.fromJson<double>(json['delaiRouteTotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'numero': serializer.toJson<int?>(numero),
      'chefLieuRegion': serializer.toJson<String>(chefLieuRegion),
      'region': serializer.toJson<String>(region),
      'nom': serializer.toJson<String>(nom),
      'estChefLieuRegion': serializer.toJson<bool>(estChefLieuRegion),
      'distanceAllerKm': serializer.toJson<double>(distanceAllerKm),
      'distanceCarburantKm': serializer.toJson<double>(distanceCarburantKm),
      'delaiRouteAller': serializer.toJson<double>(delaiRouteAller),
      'delaiRouteRetour': serializer.toJson<double>(delaiRouteRetour),
      'delaiRouteTotal': serializer.toJson<double>(delaiRouteTotal),
    };
  }

  District copyWith({
    int? id,
    Value<int?> numero = const Value.absent(),
    String? chefLieuRegion,
    String? region,
    String? nom,
    bool? estChefLieuRegion,
    double? distanceAllerKm,
    double? distanceCarburantKm,
    double? delaiRouteAller,
    double? delaiRouteRetour,
    double? delaiRouteTotal,
  }) => District(
    id: id ?? this.id,
    numero: numero.present ? numero.value : this.numero,
    chefLieuRegion: chefLieuRegion ?? this.chefLieuRegion,
    region: region ?? this.region,
    nom: nom ?? this.nom,
    estChefLieuRegion: estChefLieuRegion ?? this.estChefLieuRegion,
    distanceAllerKm: distanceAllerKm ?? this.distanceAllerKm,
    distanceCarburantKm: distanceCarburantKm ?? this.distanceCarburantKm,
    delaiRouteAller: delaiRouteAller ?? this.delaiRouteAller,
    delaiRouteRetour: delaiRouteRetour ?? this.delaiRouteRetour,
    delaiRouteTotal: delaiRouteTotal ?? this.delaiRouteTotal,
  );
  District copyWithCompanion(DistrictsCompanion data) {
    return District(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      chefLieuRegion: data.chefLieuRegion.present
          ? data.chefLieuRegion.value
          : this.chefLieuRegion,
      region: data.region.present ? data.region.value : this.region,
      nom: data.nom.present ? data.nom.value : this.nom,
      estChefLieuRegion: data.estChefLieuRegion.present
          ? data.estChefLieuRegion.value
          : this.estChefLieuRegion,
      distanceAllerKm: data.distanceAllerKm.present
          ? data.distanceAllerKm.value
          : this.distanceAllerKm,
      distanceCarburantKm: data.distanceCarburantKm.present
          ? data.distanceCarburantKm.value
          : this.distanceCarburantKm,
      delaiRouteAller: data.delaiRouteAller.present
          ? data.delaiRouteAller.value
          : this.delaiRouteAller,
      delaiRouteRetour: data.delaiRouteRetour.present
          ? data.delaiRouteRetour.value
          : this.delaiRouteRetour,
      delaiRouteTotal: data.delaiRouteTotal.present
          ? data.delaiRouteTotal.value
          : this.delaiRouteTotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('District(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('chefLieuRegion: $chefLieuRegion, ')
          ..write('region: $region, ')
          ..write('nom: $nom, ')
          ..write('estChefLieuRegion: $estChefLieuRegion, ')
          ..write('distanceAllerKm: $distanceAllerKm, ')
          ..write('distanceCarburantKm: $distanceCarburantKm, ')
          ..write('delaiRouteAller: $delaiRouteAller, ')
          ..write('delaiRouteRetour: $delaiRouteRetour, ')
          ..write('delaiRouteTotal: $delaiRouteTotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    numero,
    chefLieuRegion,
    region,
    nom,
    estChefLieuRegion,
    distanceAllerKm,
    distanceCarburantKm,
    delaiRouteAller,
    delaiRouteRetour,
    delaiRouteTotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is District &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.chefLieuRegion == this.chefLieuRegion &&
          other.region == this.region &&
          other.nom == this.nom &&
          other.estChefLieuRegion == this.estChefLieuRegion &&
          other.distanceAllerKm == this.distanceAllerKm &&
          other.distanceCarburantKm == this.distanceCarburantKm &&
          other.delaiRouteAller == this.delaiRouteAller &&
          other.delaiRouteRetour == this.delaiRouteRetour &&
          other.delaiRouteTotal == this.delaiRouteTotal);
}

class DistrictsCompanion extends UpdateCompanion<District> {
  final Value<int> id;
  final Value<int?> numero;
  final Value<String> chefLieuRegion;
  final Value<String> region;
  final Value<String> nom;
  final Value<bool> estChefLieuRegion;
  final Value<double> distanceAllerKm;
  final Value<double> distanceCarburantKm;
  final Value<double> delaiRouteAller;
  final Value<double> delaiRouteRetour;
  final Value<double> delaiRouteTotal;
  const DistrictsCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.chefLieuRegion = const Value.absent(),
    this.region = const Value.absent(),
    this.nom = const Value.absent(),
    this.estChefLieuRegion = const Value.absent(),
    this.distanceAllerKm = const Value.absent(),
    this.distanceCarburantKm = const Value.absent(),
    this.delaiRouteAller = const Value.absent(),
    this.delaiRouteRetour = const Value.absent(),
    this.delaiRouteTotal = const Value.absent(),
  });
  DistrictsCompanion.insert({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    required String chefLieuRegion,
    required String region,
    required String nom,
    this.estChefLieuRegion = const Value.absent(),
    this.distanceAllerKm = const Value.absent(),
    this.distanceCarburantKm = const Value.absent(),
    this.delaiRouteAller = const Value.absent(),
    this.delaiRouteRetour = const Value.absent(),
    this.delaiRouteTotal = const Value.absent(),
  }) : chefLieuRegion = Value(chefLieuRegion),
       region = Value(region),
       nom = Value(nom);
  static Insertable<District> custom({
    Expression<int>? id,
    Expression<int>? numero,
    Expression<String>? chefLieuRegion,
    Expression<String>? region,
    Expression<String>? nom,
    Expression<bool>? estChefLieuRegion,
    Expression<double>? distanceAllerKm,
    Expression<double>? distanceCarburantKm,
    Expression<double>? delaiRouteAller,
    Expression<double>? delaiRouteRetour,
    Expression<double>? delaiRouteTotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (chefLieuRegion != null) 'chef_lieu_region': chefLieuRegion,
      if (region != null) 'region': region,
      if (nom != null) 'nom': nom,
      if (estChefLieuRegion != null) 'est_chef_lieu_region': estChefLieuRegion,
      if (distanceAllerKm != null) 'distance_aller_km': distanceAllerKm,
      if (distanceCarburantKm != null)
        'distance_carburant_km': distanceCarburantKm,
      if (delaiRouteAller != null) 'delai_route_aller': delaiRouteAller,
      if (delaiRouteRetour != null) 'delai_route_retour': delaiRouteRetour,
      if (delaiRouteTotal != null) 'delai_route_total': delaiRouteTotal,
    });
  }

  DistrictsCompanion copyWith({
    Value<int>? id,
    Value<int?>? numero,
    Value<String>? chefLieuRegion,
    Value<String>? region,
    Value<String>? nom,
    Value<bool>? estChefLieuRegion,
    Value<double>? distanceAllerKm,
    Value<double>? distanceCarburantKm,
    Value<double>? delaiRouteAller,
    Value<double>? delaiRouteRetour,
    Value<double>? delaiRouteTotal,
  }) {
    return DistrictsCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      chefLieuRegion: chefLieuRegion ?? this.chefLieuRegion,
      region: region ?? this.region,
      nom: nom ?? this.nom,
      estChefLieuRegion: estChefLieuRegion ?? this.estChefLieuRegion,
      distanceAllerKm: distanceAllerKm ?? this.distanceAllerKm,
      distanceCarburantKm: distanceCarburantKm ?? this.distanceCarburantKm,
      delaiRouteAller: delaiRouteAller ?? this.delaiRouteAller,
      delaiRouteRetour: delaiRouteRetour ?? this.delaiRouteRetour,
      delaiRouteTotal: delaiRouteTotal ?? this.delaiRouteTotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (chefLieuRegion.present) {
      map['chef_lieu_region'] = Variable<String>(chefLieuRegion.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (estChefLieuRegion.present) {
      map['est_chef_lieu_region'] = Variable<bool>(estChefLieuRegion.value);
    }
    if (distanceAllerKm.present) {
      map['distance_aller_km'] = Variable<double>(distanceAllerKm.value);
    }
    if (distanceCarburantKm.present) {
      map['distance_carburant_km'] = Variable<double>(
        distanceCarburantKm.value,
      );
    }
    if (delaiRouteAller.present) {
      map['delai_route_aller'] = Variable<double>(delaiRouteAller.value);
    }
    if (delaiRouteRetour.present) {
      map['delai_route_retour'] = Variable<double>(delaiRouteRetour.value);
    }
    if (delaiRouteTotal.present) {
      map['delai_route_total'] = Variable<double>(delaiRouteTotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DistrictsCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('chefLieuRegion: $chefLieuRegion, ')
          ..write('region: $region, ')
          ..write('nom: $nom, ')
          ..write('estChefLieuRegion: $estChefLieuRegion, ')
          ..write('distanceAllerKm: $distanceAllerKm, ')
          ..write('distanceCarburantKm: $distanceCarburantKm, ')
          ..write('delaiRouteAller: $delaiRouteAller, ')
          ..write('delaiRouteRetour: $delaiRouteRetour, ')
          ..write('delaiRouteTotal: $delaiRouteTotal')
          ..write(')'))
        .toString();
  }
}

class $ReferentielTarifsTable extends ReferentielTarifs
    with TableInfo<$ReferentielTarifsTable, TarifReferentiel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferentielTarifsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rubriqueMeta = const VerificationMeta(
    'rubrique',
  );
  @override
  late final GeneratedColumn<String> rubrique = GeneratedColumn<String>(
    'rubrique',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ligneBudgetaireMeta = const VerificationMeta(
    'ligneBudgetaire',
  );
  @override
  late final GeneratedColumn<String> ligneBudgetaire = GeneratedColumn<String>(
    'ligne_budgetaire',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeActiviteMeta = const VerificationMeta(
    'typeActivite',
  );
  @override
  late final GeneratedColumn<String> typeActivite = GeneratedColumn<String>(
    'type_activite',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Tous'),
  );
  static const VerificationMeta _uniteMeta = const VerificationMeta('unite');
  @override
  late final GeneratedColumn<String> unite = GeneratedColumn<String>(
    'unite',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('personne'),
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Tous'),
  );
  static const VerificationMeta _tarifMeta = const VerificationMeta('tarif');
  @override
  late final GeneratedColumn<double> tarif = GeneratedColumn<double>(
    'tarif',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
    'actif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("actif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rubrique,
    ligneBudgetaire,
    typeActivite,
    unite,
    zone,
    tarif,
    actif,
    observation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'referentiel_tarifs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TarifReferentiel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rubrique')) {
      context.handle(
        _rubriqueMeta,
        rubrique.isAcceptableOrUnknown(data['rubrique']!, _rubriqueMeta),
      );
    } else if (isInserting) {
      context.missing(_rubriqueMeta);
    }
    if (data.containsKey('ligne_budgetaire')) {
      context.handle(
        _ligneBudgetaireMeta,
        ligneBudgetaire.isAcceptableOrUnknown(
          data['ligne_budgetaire']!,
          _ligneBudgetaireMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ligneBudgetaireMeta);
    }
    if (data.containsKey('type_activite')) {
      context.handle(
        _typeActiviteMeta,
        typeActivite.isAcceptableOrUnknown(
          data['type_activite']!,
          _typeActiviteMeta,
        ),
      );
    }
    if (data.containsKey('unite')) {
      context.handle(
        _uniteMeta,
        unite.isAcceptableOrUnknown(data['unite']!, _uniteMeta),
      );
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    }
    if (data.containsKey('tarif')) {
      context.handle(
        _tarifMeta,
        tarif.isAcceptableOrUnknown(data['tarif']!, _tarifMeta),
      );
    }
    if (data.containsKey('actif')) {
      context.handle(
        _actifMeta,
        actif.isAcceptableOrUnknown(data['actif']!, _actifMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TarifReferentiel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TarifReferentiel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rubrique: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rubrique'],
      )!,
      ligneBudgetaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ligne_budgetaire'],
      )!,
      typeActivite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_activite'],
      )!,
      unite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unite'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      )!,
      tarif: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tarif'],
      )!,
      actif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}actif'],
      )!,
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
    );
  }

  @override
  $ReferentielTarifsTable createAlias(String alias) {
    return $ReferentielTarifsTable(attachedDatabase, alias);
  }
}

class TarifReferentiel extends DataClass
    implements Insertable<TarifReferentiel> {
  final int id;
  final String rubrique;
  final String ligneBudgetaire;
  final String typeActivite;
  final String unite;
  final String zone;
  final double tarif;
  final bool actif;
  final String? observation;
  const TarifReferentiel({
    required this.id,
    required this.rubrique,
    required this.ligneBudgetaire,
    required this.typeActivite,
    required this.unite,
    required this.zone,
    required this.tarif,
    required this.actif,
    this.observation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rubrique'] = Variable<String>(rubrique);
    map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire);
    map['type_activite'] = Variable<String>(typeActivite);
    map['unite'] = Variable<String>(unite);
    map['zone'] = Variable<String>(zone);
    map['tarif'] = Variable<double>(tarif);
    map['actif'] = Variable<bool>(actif);
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    return map;
  }

  ReferentielTarifsCompanion toCompanion(bool nullToAbsent) {
    return ReferentielTarifsCompanion(
      id: Value(id),
      rubrique: Value(rubrique),
      ligneBudgetaire: Value(ligneBudgetaire),
      typeActivite: Value(typeActivite),
      unite: Value(unite),
      zone: Value(zone),
      tarif: Value(tarif),
      actif: Value(actif),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
    );
  }

  factory TarifReferentiel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TarifReferentiel(
      id: serializer.fromJson<int>(json['id']),
      rubrique: serializer.fromJson<String>(json['rubrique']),
      ligneBudgetaire: serializer.fromJson<String>(json['ligneBudgetaire']),
      typeActivite: serializer.fromJson<String>(json['typeActivite']),
      unite: serializer.fromJson<String>(json['unite']),
      zone: serializer.fromJson<String>(json['zone']),
      tarif: serializer.fromJson<double>(json['tarif']),
      actif: serializer.fromJson<bool>(json['actif']),
      observation: serializer.fromJson<String?>(json['observation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rubrique': serializer.toJson<String>(rubrique),
      'ligneBudgetaire': serializer.toJson<String>(ligneBudgetaire),
      'typeActivite': serializer.toJson<String>(typeActivite),
      'unite': serializer.toJson<String>(unite),
      'zone': serializer.toJson<String>(zone),
      'tarif': serializer.toJson<double>(tarif),
      'actif': serializer.toJson<bool>(actif),
      'observation': serializer.toJson<String?>(observation),
    };
  }

  TarifReferentiel copyWith({
    int? id,
    String? rubrique,
    String? ligneBudgetaire,
    String? typeActivite,
    String? unite,
    String? zone,
    double? tarif,
    bool? actif,
    Value<String?> observation = const Value.absent(),
  }) => TarifReferentiel(
    id: id ?? this.id,
    rubrique: rubrique ?? this.rubrique,
    ligneBudgetaire: ligneBudgetaire ?? this.ligneBudgetaire,
    typeActivite: typeActivite ?? this.typeActivite,
    unite: unite ?? this.unite,
    zone: zone ?? this.zone,
    tarif: tarif ?? this.tarif,
    actif: actif ?? this.actif,
    observation: observation.present ? observation.value : this.observation,
  );
  TarifReferentiel copyWithCompanion(ReferentielTarifsCompanion data) {
    return TarifReferentiel(
      id: data.id.present ? data.id.value : this.id,
      rubrique: data.rubrique.present ? data.rubrique.value : this.rubrique,
      ligneBudgetaire: data.ligneBudgetaire.present
          ? data.ligneBudgetaire.value
          : this.ligneBudgetaire,
      typeActivite: data.typeActivite.present
          ? data.typeActivite.value
          : this.typeActivite,
      unite: data.unite.present ? data.unite.value : this.unite,
      zone: data.zone.present ? data.zone.value : this.zone,
      tarif: data.tarif.present ? data.tarif.value : this.tarif,
      actif: data.actif.present ? data.actif.value : this.actif,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TarifReferentiel(')
          ..write('id: $id, ')
          ..write('rubrique: $rubrique, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('typeActivite: $typeActivite, ')
          ..write('unite: $unite, ')
          ..write('zone: $zone, ')
          ..write('tarif: $tarif, ')
          ..write('actif: $actif, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rubrique,
    ligneBudgetaire,
    typeActivite,
    unite,
    zone,
    tarif,
    actif,
    observation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TarifReferentiel &&
          other.id == this.id &&
          other.rubrique == this.rubrique &&
          other.ligneBudgetaire == this.ligneBudgetaire &&
          other.typeActivite == this.typeActivite &&
          other.unite == this.unite &&
          other.zone == this.zone &&
          other.tarif == this.tarif &&
          other.actif == this.actif &&
          other.observation == this.observation);
}

class ReferentielTarifsCompanion extends UpdateCompanion<TarifReferentiel> {
  final Value<int> id;
  final Value<String> rubrique;
  final Value<String> ligneBudgetaire;
  final Value<String> typeActivite;
  final Value<String> unite;
  final Value<String> zone;
  final Value<double> tarif;
  final Value<bool> actif;
  final Value<String?> observation;
  const ReferentielTarifsCompanion({
    this.id = const Value.absent(),
    this.rubrique = const Value.absent(),
    this.ligneBudgetaire = const Value.absent(),
    this.typeActivite = const Value.absent(),
    this.unite = const Value.absent(),
    this.zone = const Value.absent(),
    this.tarif = const Value.absent(),
    this.actif = const Value.absent(),
    this.observation = const Value.absent(),
  });
  ReferentielTarifsCompanion.insert({
    this.id = const Value.absent(),
    required String rubrique,
    required String ligneBudgetaire,
    this.typeActivite = const Value.absent(),
    this.unite = const Value.absent(),
    this.zone = const Value.absent(),
    this.tarif = const Value.absent(),
    this.actif = const Value.absent(),
    this.observation = const Value.absent(),
  }) : rubrique = Value(rubrique),
       ligneBudgetaire = Value(ligneBudgetaire);
  static Insertable<TarifReferentiel> custom({
    Expression<int>? id,
    Expression<String>? rubrique,
    Expression<String>? ligneBudgetaire,
    Expression<String>? typeActivite,
    Expression<String>? unite,
    Expression<String>? zone,
    Expression<double>? tarif,
    Expression<bool>? actif,
    Expression<String>? observation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rubrique != null) 'rubrique': rubrique,
      if (ligneBudgetaire != null) 'ligne_budgetaire': ligneBudgetaire,
      if (typeActivite != null) 'type_activite': typeActivite,
      if (unite != null) 'unite': unite,
      if (zone != null) 'zone': zone,
      if (tarif != null) 'tarif': tarif,
      if (actif != null) 'actif': actif,
      if (observation != null) 'observation': observation,
    });
  }

  ReferentielTarifsCompanion copyWith({
    Value<int>? id,
    Value<String>? rubrique,
    Value<String>? ligneBudgetaire,
    Value<String>? typeActivite,
    Value<String>? unite,
    Value<String>? zone,
    Value<double>? tarif,
    Value<bool>? actif,
    Value<String?>? observation,
  }) {
    return ReferentielTarifsCompanion(
      id: id ?? this.id,
      rubrique: rubrique ?? this.rubrique,
      ligneBudgetaire: ligneBudgetaire ?? this.ligneBudgetaire,
      typeActivite: typeActivite ?? this.typeActivite,
      unite: unite ?? this.unite,
      zone: zone ?? this.zone,
      tarif: tarif ?? this.tarif,
      actif: actif ?? this.actif,
      observation: observation ?? this.observation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rubrique.present) {
      map['rubrique'] = Variable<String>(rubrique.value);
    }
    if (ligneBudgetaire.present) {
      map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire.value);
    }
    if (typeActivite.present) {
      map['type_activite'] = Variable<String>(typeActivite.value);
    }
    if (unite.present) {
      map['unite'] = Variable<String>(unite.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (tarif.present) {
      map['tarif'] = Variable<double>(tarif.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferentielTarifsCompanion(')
          ..write('id: $id, ')
          ..write('rubrique: $rubrique, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('typeActivite: $typeActivite, ')
          ..write('unite: $unite, ')
          ..write('zone: $zone, ')
          ..write('tarif: $tarif, ')
          ..write('actif: $actif, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }
}

class $ReferenceValeursTable extends ReferenceValeurs
    with TableInfo<$ReferenceValeursTable, ReferenceValeur> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceValeursTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categorieMeta = const VerificationMeta(
    'categorie',
  );
  @override
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
    'categorie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valeurMeta = const VerificationMeta('valeur');
  @override
  late final GeneratedColumn<String> valeur = GeneratedColumn<String>(
    'valeur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
    'actif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("actif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, categorie, valeur, ordre, actif];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_valeurs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReferenceValeur> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('categorie')) {
      context.handle(
        _categorieMeta,
        categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta),
      );
    } else if (isInserting) {
      context.missing(_categorieMeta);
    }
    if (data.containsKey('valeur')) {
      context.handle(
        _valeurMeta,
        valeur.isAcceptableOrUnknown(data['valeur']!, _valeurMeta),
      );
    } else if (isInserting) {
      context.missing(_valeurMeta);
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
    }
    if (data.containsKey('actif')) {
      context.handle(
        _actifMeta,
        actif.isAcceptableOrUnknown(data['actif']!, _actifMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReferenceValeur map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceValeur(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categorie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie'],
      )!,
      valeur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valeur'],
      )!,
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
      )!,
      actif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}actif'],
      )!,
    );
  }

  @override
  $ReferenceValeursTable createAlias(String alias) {
    return $ReferenceValeursTable(attachedDatabase, alias);
  }
}

class ReferenceValeur extends DataClass implements Insertable<ReferenceValeur> {
  final int id;
  final String categorie;
  final String valeur;
  final int ordre;
  final bool actif;
  const ReferenceValeur({
    required this.id,
    required this.categorie,
    required this.valeur,
    required this.ordre,
    required this.actif,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['categorie'] = Variable<String>(categorie);
    map['valeur'] = Variable<String>(valeur);
    map['ordre'] = Variable<int>(ordre);
    map['actif'] = Variable<bool>(actif);
    return map;
  }

  ReferenceValeursCompanion toCompanion(bool nullToAbsent) {
    return ReferenceValeursCompanion(
      id: Value(id),
      categorie: Value(categorie),
      valeur: Value(valeur),
      ordre: Value(ordre),
      actif: Value(actif),
    );
  }

  factory ReferenceValeur.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceValeur(
      id: serializer.fromJson<int>(json['id']),
      categorie: serializer.fromJson<String>(json['categorie']),
      valeur: serializer.fromJson<String>(json['valeur']),
      ordre: serializer.fromJson<int>(json['ordre']),
      actif: serializer.fromJson<bool>(json['actif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categorie': serializer.toJson<String>(categorie),
      'valeur': serializer.toJson<String>(valeur),
      'ordre': serializer.toJson<int>(ordre),
      'actif': serializer.toJson<bool>(actif),
    };
  }

  ReferenceValeur copyWith({
    int? id,
    String? categorie,
    String? valeur,
    int? ordre,
    bool? actif,
  }) => ReferenceValeur(
    id: id ?? this.id,
    categorie: categorie ?? this.categorie,
    valeur: valeur ?? this.valeur,
    ordre: ordre ?? this.ordre,
    actif: actif ?? this.actif,
  );
  ReferenceValeur copyWithCompanion(ReferenceValeursCompanion data) {
    return ReferenceValeur(
      id: data.id.present ? data.id.value : this.id,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      valeur: data.valeur.present ? data.valeur.value : this.valeur,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
      actif: data.actif.present ? data.actif.value : this.actif,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceValeur(')
          ..write('id: $id, ')
          ..write('categorie: $categorie, ')
          ..write('valeur: $valeur, ')
          ..write('ordre: $ordre, ')
          ..write('actif: $actif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categorie, valeur, ordre, actif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceValeur &&
          other.id == this.id &&
          other.categorie == this.categorie &&
          other.valeur == this.valeur &&
          other.ordre == this.ordre &&
          other.actif == this.actif);
}

class ReferenceValeursCompanion extends UpdateCompanion<ReferenceValeur> {
  final Value<int> id;
  final Value<String> categorie;
  final Value<String> valeur;
  final Value<int> ordre;
  final Value<bool> actif;
  const ReferenceValeursCompanion({
    this.id = const Value.absent(),
    this.categorie = const Value.absent(),
    this.valeur = const Value.absent(),
    this.ordre = const Value.absent(),
    this.actif = const Value.absent(),
  });
  ReferenceValeursCompanion.insert({
    this.id = const Value.absent(),
    required String categorie,
    required String valeur,
    this.ordre = const Value.absent(),
    this.actif = const Value.absent(),
  }) : categorie = Value(categorie),
       valeur = Value(valeur);
  static Insertable<ReferenceValeur> custom({
    Expression<int>? id,
    Expression<String>? categorie,
    Expression<String>? valeur,
    Expression<int>? ordre,
    Expression<bool>? actif,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categorie != null) 'categorie': categorie,
      if (valeur != null) 'valeur': valeur,
      if (ordre != null) 'ordre': ordre,
      if (actif != null) 'actif': actif,
    });
  }

  ReferenceValeursCompanion copyWith({
    Value<int>? id,
    Value<String>? categorie,
    Value<String>? valeur,
    Value<int>? ordre,
    Value<bool>? actif,
  }) {
    return ReferenceValeursCompanion(
      id: id ?? this.id,
      categorie: categorie ?? this.categorie,
      valeur: valeur ?? this.valeur,
      ordre: ordre ?? this.ordre,
      actif: actif ?? this.actif,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (valeur.present) {
      map['valeur'] = Variable<String>(valeur.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceValeursCompanion(')
          ..write('id: $id, ')
          ..write('categorie: $categorie, ')
          ..write('valeur: $valeur, ')
          ..write('ordre: $ordre, ')
          ..write('actif: $actif')
          ..write(')'))
        .toString();
  }
}

class $ActivitesTable extends Activites
    with TableInfo<$ActivitesTable, Activite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Atelier/Réunion'),
  );
  static const VerificationMeta _codeBudgetMeta = const VerificationMeta(
    'codeBudget',
  );
  @override
  late final GeneratedColumn<String> codeBudget = GeneratedColumn<String>(
    'code_budget',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceFinancementMeta = const VerificationMeta(
    'sourceFinancement',
  );
  @override
  late final GeneratedColumn<String> sourceFinancement =
      GeneratedColumn<String>(
        'source_financement',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _anneeMeta = const VerificationMeta('annee');
  @override
  late final GeneratedColumn<int> annee = GeneratedColumn<int>(
    'annee',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodeMeta = const VerificationMeta(
    'periode',
  );
  @override
  late final GeneratedColumn<String> periode = GeneratedColumn<String>(
    'periode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDebutMeta = const VerificationMeta(
    'dateDebut',
  );
  @override
  late final GeneratedColumn<DateTime> dateDebut = GeneratedColumn<DateTime>(
    'date_debut',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateFinMeta = const VerificationMeta(
    'dateFin',
  );
  @override
  late final GeneratedColumn<DateTime> dateFin = GeneratedColumn<DateTime>(
    'date_fin',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lieuMeta = const VerificationMeta('lieu');
  @override
  late final GeneratedColumn<String> lieu = GeneratedColumn<String>(
    'lieu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zoneIndemniteMeta = const VerificationMeta(
    'zoneIndemnite',
  );
  @override
  late final GeneratedColumn<String> zoneIndemnite = GeneratedColumn<String>(
    'zone_indemnite',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responsableMeta = const VerificationMeta(
    'responsable',
  );
  @override
  late final GeneratedColumn<String> responsable = GeneratedColumn<String>(
    'responsable',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreJoursMeta = const VerificationMeta(
    'nombreJours',
  );
  @override
  late final GeneratedColumn<int> nombreJours = GeneratedColumn<int>(
    'nombre_jours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nombreParticipantsMeta =
      const VerificationMeta('nombreParticipants');
  @override
  late final GeneratedColumn<int> nombreParticipants = GeneratedColumn<int>(
    'nombre_participants',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nombreMissionnairesMeta =
      const VerificationMeta('nombreMissionnaires');
  @override
  late final GeneratedColumn<int> nombreMissionnaires = GeneratedColumn<int>(
    'nombre_missionnaires',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceAllerKmMeta = const VerificationMeta(
    'distanceAllerKm',
  );
  @override
  late final GeneratedColumn<double> distanceAllerKm = GeneratedColumn<double>(
    'distance_aller_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _restaurationMeta = const VerificationMeta(
    'restauration',
  );
  @override
  late final GeneratedColumn<bool> restauration = GeneratedColumn<bool>(
    'restauration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("restauration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('En cours'),
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
    'cree_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    description,
    type,
    codeBudget,
    sourceFinancement,
    annee,
    periode,
    dateDebut,
    dateFin,
    lieu,
    district,
    zoneIndemnite,
    responsable,
    nombreJours,
    nombreParticipants,
    nombreMissionnaires,
    distanceAllerKm,
    restauration,
    statut,
    observation,
    creeLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('code_budget')) {
      context.handle(
        _codeBudgetMeta,
        codeBudget.isAcceptableOrUnknown(data['code_budget']!, _codeBudgetMeta),
      );
    }
    if (data.containsKey('source_financement')) {
      context.handle(
        _sourceFinancementMeta,
        sourceFinancement.isAcceptableOrUnknown(
          data['source_financement']!,
          _sourceFinancementMeta,
        ),
      );
    }
    if (data.containsKey('annee')) {
      context.handle(
        _anneeMeta,
        annee.isAcceptableOrUnknown(data['annee']!, _anneeMeta),
      );
    }
    if (data.containsKey('periode')) {
      context.handle(
        _periodeMeta,
        periode.isAcceptableOrUnknown(data['periode']!, _periodeMeta),
      );
    }
    if (data.containsKey('date_debut')) {
      context.handle(
        _dateDebutMeta,
        dateDebut.isAcceptableOrUnknown(data['date_debut']!, _dateDebutMeta),
      );
    }
    if (data.containsKey('date_fin')) {
      context.handle(
        _dateFinMeta,
        dateFin.isAcceptableOrUnknown(data['date_fin']!, _dateFinMeta),
      );
    }
    if (data.containsKey('lieu')) {
      context.handle(
        _lieuMeta,
        lieu.isAcceptableOrUnknown(data['lieu']!, _lieuMeta),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('zone_indemnite')) {
      context.handle(
        _zoneIndemniteMeta,
        zoneIndemnite.isAcceptableOrUnknown(
          data['zone_indemnite']!,
          _zoneIndemniteMeta,
        ),
      );
    }
    if (data.containsKey('responsable')) {
      context.handle(
        _responsableMeta,
        responsable.isAcceptableOrUnknown(
          data['responsable']!,
          _responsableMeta,
        ),
      );
    }
    if (data.containsKey('nombre_jours')) {
      context.handle(
        _nombreJoursMeta,
        nombreJours.isAcceptableOrUnknown(
          data['nombre_jours']!,
          _nombreJoursMeta,
        ),
      );
    }
    if (data.containsKey('nombre_participants')) {
      context.handle(
        _nombreParticipantsMeta,
        nombreParticipants.isAcceptableOrUnknown(
          data['nombre_participants']!,
          _nombreParticipantsMeta,
        ),
      );
    }
    if (data.containsKey('nombre_missionnaires')) {
      context.handle(
        _nombreMissionnairesMeta,
        nombreMissionnaires.isAcceptableOrUnknown(
          data['nombre_missionnaires']!,
          _nombreMissionnairesMeta,
        ),
      );
    }
    if (data.containsKey('distance_aller_km')) {
      context.handle(
        _distanceAllerKmMeta,
        distanceAllerKm.isAcceptableOrUnknown(
          data['distance_aller_km']!,
          _distanceAllerKmMeta,
        ),
      );
    }
    if (data.containsKey('restauration')) {
      context.handle(
        _restaurationMeta,
        restauration.isAcceptableOrUnknown(
          data['restauration']!,
          _restaurationMeta,
        ),
      );
    }
    if (data.containsKey('statut')) {
      context.handle(
        _statutMeta,
        statut.isAcceptableOrUnknown(data['statut']!, _statutMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    if (data.containsKey('cree_le')) {
      context.handle(
        _creeLeMeta,
        creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      codeBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_budget'],
      ),
      sourceFinancement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_financement'],
      ),
      annee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annee'],
      ),
      periode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}periode'],
      ),
      dateDebut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_debut'],
      ),
      dateFin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_fin'],
      ),
      lieu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lieu'],
      ),
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      zoneIndemnite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_indemnite'],
      ),
      responsable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responsable'],
      ),
      nombreJours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_jours'],
      )!,
      nombreParticipants: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_participants'],
      )!,
      nombreMissionnaires: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_missionnaires'],
      )!,
      distanceAllerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_aller_km'],
      )!,
      restauration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}restauration'],
      )!,
      statut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut'],
      )!,
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
      creeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cree_le'],
      )!,
    );
  }

  @override
  $ActivitesTable createAlias(String alias) {
    return $ActivitesTable(attachedDatabase, alias);
  }
}

class Activite extends DataClass implements Insertable<Activite> {
  final int id;
  final String code;
  final String description;
  final String type;
  final String? codeBudget;

  /// Source de financement (UNICEF, UNFPA, …) — liste `FINANCEMENT`.
  final String? sourceFinancement;
  final int? annee;
  final String? periode;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? lieu;
  final String? district;
  final String? zoneIndemnite;
  final String? responsable;
  final int nombreJours;
  final int nombreParticipants;
  final int nombreMissionnaires;
  final double distanceAllerKm;
  final bool restauration;
  final String statut;
  final String? observation;
  final DateTime creeLe;
  const Activite({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    this.codeBudget,
    this.sourceFinancement,
    this.annee,
    this.periode,
    this.dateDebut,
    this.dateFin,
    this.lieu,
    this.district,
    this.zoneIndemnite,
    this.responsable,
    required this.nombreJours,
    required this.nombreParticipants,
    required this.nombreMissionnaires,
    required this.distanceAllerKm,
    required this.restauration,
    required this.statut,
    this.observation,
    required this.creeLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || codeBudget != null) {
      map['code_budget'] = Variable<String>(codeBudget);
    }
    if (!nullToAbsent || sourceFinancement != null) {
      map['source_financement'] = Variable<String>(sourceFinancement);
    }
    if (!nullToAbsent || annee != null) {
      map['annee'] = Variable<int>(annee);
    }
    if (!nullToAbsent || periode != null) {
      map['periode'] = Variable<String>(periode);
    }
    if (!nullToAbsent || dateDebut != null) {
      map['date_debut'] = Variable<DateTime>(dateDebut);
    }
    if (!nullToAbsent || dateFin != null) {
      map['date_fin'] = Variable<DateTime>(dateFin);
    }
    if (!nullToAbsent || lieu != null) {
      map['lieu'] = Variable<String>(lieu);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || zoneIndemnite != null) {
      map['zone_indemnite'] = Variable<String>(zoneIndemnite);
    }
    if (!nullToAbsent || responsable != null) {
      map['responsable'] = Variable<String>(responsable);
    }
    map['nombre_jours'] = Variable<int>(nombreJours);
    map['nombre_participants'] = Variable<int>(nombreParticipants);
    map['nombre_missionnaires'] = Variable<int>(nombreMissionnaires);
    map['distance_aller_km'] = Variable<double>(distanceAllerKm);
    map['restauration'] = Variable<bool>(restauration);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    map['cree_le'] = Variable<DateTime>(creeLe);
    return map;
  }

  ActivitesCompanion toCompanion(bool nullToAbsent) {
    return ActivitesCompanion(
      id: Value(id),
      code: Value(code),
      description: Value(description),
      type: Value(type),
      codeBudget: codeBudget == null && nullToAbsent
          ? const Value.absent()
          : Value(codeBudget),
      sourceFinancement: sourceFinancement == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFinancement),
      annee: annee == null && nullToAbsent
          ? const Value.absent()
          : Value(annee),
      periode: periode == null && nullToAbsent
          ? const Value.absent()
          : Value(periode),
      dateDebut: dateDebut == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDebut),
      dateFin: dateFin == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFin),
      lieu: lieu == null && nullToAbsent ? const Value.absent() : Value(lieu),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      zoneIndemnite: zoneIndemnite == null && nullToAbsent
          ? const Value.absent()
          : Value(zoneIndemnite),
      responsable: responsable == null && nullToAbsent
          ? const Value.absent()
          : Value(responsable),
      nombreJours: Value(nombreJours),
      nombreParticipants: Value(nombreParticipants),
      nombreMissionnaires: Value(nombreMissionnaires),
      distanceAllerKm: Value(distanceAllerKm),
      restauration: Value(restauration),
      statut: Value(statut),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
      creeLe: Value(creeLe),
    );
  }

  factory Activite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activite(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      codeBudget: serializer.fromJson<String?>(json['codeBudget']),
      sourceFinancement: serializer.fromJson<String?>(
        json['sourceFinancement'],
      ),
      annee: serializer.fromJson<int?>(json['annee']),
      periode: serializer.fromJson<String?>(json['periode']),
      dateDebut: serializer.fromJson<DateTime?>(json['dateDebut']),
      dateFin: serializer.fromJson<DateTime?>(json['dateFin']),
      lieu: serializer.fromJson<String?>(json['lieu']),
      district: serializer.fromJson<String?>(json['district']),
      zoneIndemnite: serializer.fromJson<String?>(json['zoneIndemnite']),
      responsable: serializer.fromJson<String?>(json['responsable']),
      nombreJours: serializer.fromJson<int>(json['nombreJours']),
      nombreParticipants: serializer.fromJson<int>(json['nombreParticipants']),
      nombreMissionnaires: serializer.fromJson<int>(
        json['nombreMissionnaires'],
      ),
      distanceAllerKm: serializer.fromJson<double>(json['distanceAllerKm']),
      restauration: serializer.fromJson<bool>(json['restauration']),
      statut: serializer.fromJson<String>(json['statut']),
      observation: serializer.fromJson<String?>(json['observation']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'codeBudget': serializer.toJson<String?>(codeBudget),
      'sourceFinancement': serializer.toJson<String?>(sourceFinancement),
      'annee': serializer.toJson<int?>(annee),
      'periode': serializer.toJson<String?>(periode),
      'dateDebut': serializer.toJson<DateTime?>(dateDebut),
      'dateFin': serializer.toJson<DateTime?>(dateFin),
      'lieu': serializer.toJson<String?>(lieu),
      'district': serializer.toJson<String?>(district),
      'zoneIndemnite': serializer.toJson<String?>(zoneIndemnite),
      'responsable': serializer.toJson<String?>(responsable),
      'nombreJours': serializer.toJson<int>(nombreJours),
      'nombreParticipants': serializer.toJson<int>(nombreParticipants),
      'nombreMissionnaires': serializer.toJson<int>(nombreMissionnaires),
      'distanceAllerKm': serializer.toJson<double>(distanceAllerKm),
      'restauration': serializer.toJson<bool>(restauration),
      'statut': serializer.toJson<String>(statut),
      'observation': serializer.toJson<String?>(observation),
      'creeLe': serializer.toJson<DateTime>(creeLe),
    };
  }

  Activite copyWith({
    int? id,
    String? code,
    String? description,
    String? type,
    Value<String?> codeBudget = const Value.absent(),
    Value<String?> sourceFinancement = const Value.absent(),
    Value<int?> annee = const Value.absent(),
    Value<String?> periode = const Value.absent(),
    Value<DateTime?> dateDebut = const Value.absent(),
    Value<DateTime?> dateFin = const Value.absent(),
    Value<String?> lieu = const Value.absent(),
    Value<String?> district = const Value.absent(),
    Value<String?> zoneIndemnite = const Value.absent(),
    Value<String?> responsable = const Value.absent(),
    int? nombreJours,
    int? nombreParticipants,
    int? nombreMissionnaires,
    double? distanceAllerKm,
    bool? restauration,
    String? statut,
    Value<String?> observation = const Value.absent(),
    DateTime? creeLe,
  }) => Activite(
    id: id ?? this.id,
    code: code ?? this.code,
    description: description ?? this.description,
    type: type ?? this.type,
    codeBudget: codeBudget.present ? codeBudget.value : this.codeBudget,
    sourceFinancement: sourceFinancement.present
        ? sourceFinancement.value
        : this.sourceFinancement,
    annee: annee.present ? annee.value : this.annee,
    periode: periode.present ? periode.value : this.periode,
    dateDebut: dateDebut.present ? dateDebut.value : this.dateDebut,
    dateFin: dateFin.present ? dateFin.value : this.dateFin,
    lieu: lieu.present ? lieu.value : this.lieu,
    district: district.present ? district.value : this.district,
    zoneIndemnite: zoneIndemnite.present
        ? zoneIndemnite.value
        : this.zoneIndemnite,
    responsable: responsable.present ? responsable.value : this.responsable,
    nombreJours: nombreJours ?? this.nombreJours,
    nombreParticipants: nombreParticipants ?? this.nombreParticipants,
    nombreMissionnaires: nombreMissionnaires ?? this.nombreMissionnaires,
    distanceAllerKm: distanceAllerKm ?? this.distanceAllerKm,
    restauration: restauration ?? this.restauration,
    statut: statut ?? this.statut,
    observation: observation.present ? observation.value : this.observation,
    creeLe: creeLe ?? this.creeLe,
  );
  Activite copyWithCompanion(ActivitesCompanion data) {
    return Activite(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      codeBudget: data.codeBudget.present
          ? data.codeBudget.value
          : this.codeBudget,
      sourceFinancement: data.sourceFinancement.present
          ? data.sourceFinancement.value
          : this.sourceFinancement,
      annee: data.annee.present ? data.annee.value : this.annee,
      periode: data.periode.present ? data.periode.value : this.periode,
      dateDebut: data.dateDebut.present ? data.dateDebut.value : this.dateDebut,
      dateFin: data.dateFin.present ? data.dateFin.value : this.dateFin,
      lieu: data.lieu.present ? data.lieu.value : this.lieu,
      district: data.district.present ? data.district.value : this.district,
      zoneIndemnite: data.zoneIndemnite.present
          ? data.zoneIndemnite.value
          : this.zoneIndemnite,
      responsable: data.responsable.present
          ? data.responsable.value
          : this.responsable,
      nombreJours: data.nombreJours.present
          ? data.nombreJours.value
          : this.nombreJours,
      nombreParticipants: data.nombreParticipants.present
          ? data.nombreParticipants.value
          : this.nombreParticipants,
      nombreMissionnaires: data.nombreMissionnaires.present
          ? data.nombreMissionnaires.value
          : this.nombreMissionnaires,
      distanceAllerKm: data.distanceAllerKm.present
          ? data.distanceAllerKm.value
          : this.distanceAllerKm,
      restauration: data.restauration.present
          ? data.restauration.value
          : this.restauration,
      statut: data.statut.present ? data.statut.value : this.statut,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activite(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('codeBudget: $codeBudget, ')
          ..write('sourceFinancement: $sourceFinancement, ')
          ..write('annee: $annee, ')
          ..write('periode: $periode, ')
          ..write('dateDebut: $dateDebut, ')
          ..write('dateFin: $dateFin, ')
          ..write('lieu: $lieu, ')
          ..write('district: $district, ')
          ..write('zoneIndemnite: $zoneIndemnite, ')
          ..write('responsable: $responsable, ')
          ..write('nombreJours: $nombreJours, ')
          ..write('nombreParticipants: $nombreParticipants, ')
          ..write('nombreMissionnaires: $nombreMissionnaires, ')
          ..write('distanceAllerKm: $distanceAllerKm, ')
          ..write('restauration: $restauration, ')
          ..write('statut: $statut, ')
          ..write('observation: $observation, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    code,
    description,
    type,
    codeBudget,
    sourceFinancement,
    annee,
    periode,
    dateDebut,
    dateFin,
    lieu,
    district,
    zoneIndemnite,
    responsable,
    nombreJours,
    nombreParticipants,
    nombreMissionnaires,
    distanceAllerKm,
    restauration,
    statut,
    observation,
    creeLe,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activite &&
          other.id == this.id &&
          other.code == this.code &&
          other.description == this.description &&
          other.type == this.type &&
          other.codeBudget == this.codeBudget &&
          other.sourceFinancement == this.sourceFinancement &&
          other.annee == this.annee &&
          other.periode == this.periode &&
          other.dateDebut == this.dateDebut &&
          other.dateFin == this.dateFin &&
          other.lieu == this.lieu &&
          other.district == this.district &&
          other.zoneIndemnite == this.zoneIndemnite &&
          other.responsable == this.responsable &&
          other.nombreJours == this.nombreJours &&
          other.nombreParticipants == this.nombreParticipants &&
          other.nombreMissionnaires == this.nombreMissionnaires &&
          other.distanceAllerKm == this.distanceAllerKm &&
          other.restauration == this.restauration &&
          other.statut == this.statut &&
          other.observation == this.observation &&
          other.creeLe == this.creeLe);
}

class ActivitesCompanion extends UpdateCompanion<Activite> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> description;
  final Value<String> type;
  final Value<String?> codeBudget;
  final Value<String?> sourceFinancement;
  final Value<int?> annee;
  final Value<String?> periode;
  final Value<DateTime?> dateDebut;
  final Value<DateTime?> dateFin;
  final Value<String?> lieu;
  final Value<String?> district;
  final Value<String?> zoneIndemnite;
  final Value<String?> responsable;
  final Value<int> nombreJours;
  final Value<int> nombreParticipants;
  final Value<int> nombreMissionnaires;
  final Value<double> distanceAllerKm;
  final Value<bool> restauration;
  final Value<String> statut;
  final Value<String?> observation;
  final Value<DateTime> creeLe;
  const ActivitesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.codeBudget = const Value.absent(),
    this.sourceFinancement = const Value.absent(),
    this.annee = const Value.absent(),
    this.periode = const Value.absent(),
    this.dateDebut = const Value.absent(),
    this.dateFin = const Value.absent(),
    this.lieu = const Value.absent(),
    this.district = const Value.absent(),
    this.zoneIndemnite = const Value.absent(),
    this.responsable = const Value.absent(),
    this.nombreJours = const Value.absent(),
    this.nombreParticipants = const Value.absent(),
    this.nombreMissionnaires = const Value.absent(),
    this.distanceAllerKm = const Value.absent(),
    this.restauration = const Value.absent(),
    this.statut = const Value.absent(),
    this.observation = const Value.absent(),
    this.creeLe = const Value.absent(),
  });
  ActivitesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.codeBudget = const Value.absent(),
    this.sourceFinancement = const Value.absent(),
    this.annee = const Value.absent(),
    this.periode = const Value.absent(),
    this.dateDebut = const Value.absent(),
    this.dateFin = const Value.absent(),
    this.lieu = const Value.absent(),
    this.district = const Value.absent(),
    this.zoneIndemnite = const Value.absent(),
    this.responsable = const Value.absent(),
    this.nombreJours = const Value.absent(),
    this.nombreParticipants = const Value.absent(),
    this.nombreMissionnaires = const Value.absent(),
    this.distanceAllerKm = const Value.absent(),
    this.restauration = const Value.absent(),
    this.statut = const Value.absent(),
    this.observation = const Value.absent(),
    this.creeLe = const Value.absent(),
  }) : code = Value(code);
  static Insertable<Activite> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? codeBudget,
    Expression<String>? sourceFinancement,
    Expression<int>? annee,
    Expression<String>? periode,
    Expression<DateTime>? dateDebut,
    Expression<DateTime>? dateFin,
    Expression<String>? lieu,
    Expression<String>? district,
    Expression<String>? zoneIndemnite,
    Expression<String>? responsable,
    Expression<int>? nombreJours,
    Expression<int>? nombreParticipants,
    Expression<int>? nombreMissionnaires,
    Expression<double>? distanceAllerKm,
    Expression<bool>? restauration,
    Expression<String>? statut,
    Expression<String>? observation,
    Expression<DateTime>? creeLe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (codeBudget != null) 'code_budget': codeBudget,
      if (sourceFinancement != null) 'source_financement': sourceFinancement,
      if (annee != null) 'annee': annee,
      if (periode != null) 'periode': periode,
      if (dateDebut != null) 'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
      if (lieu != null) 'lieu': lieu,
      if (district != null) 'district': district,
      if (zoneIndemnite != null) 'zone_indemnite': zoneIndemnite,
      if (responsable != null) 'responsable': responsable,
      if (nombreJours != null) 'nombre_jours': nombreJours,
      if (nombreParticipants != null) 'nombre_participants': nombreParticipants,
      if (nombreMissionnaires != null)
        'nombre_missionnaires': nombreMissionnaires,
      if (distanceAllerKm != null) 'distance_aller_km': distanceAllerKm,
      if (restauration != null) 'restauration': restauration,
      if (statut != null) 'statut': statut,
      if (observation != null) 'observation': observation,
      if (creeLe != null) 'cree_le': creeLe,
    });
  }

  ActivitesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? description,
    Value<String>? type,
    Value<String?>? codeBudget,
    Value<String?>? sourceFinancement,
    Value<int?>? annee,
    Value<String?>? periode,
    Value<DateTime?>? dateDebut,
    Value<DateTime?>? dateFin,
    Value<String?>? lieu,
    Value<String?>? district,
    Value<String?>? zoneIndemnite,
    Value<String?>? responsable,
    Value<int>? nombreJours,
    Value<int>? nombreParticipants,
    Value<int>? nombreMissionnaires,
    Value<double>? distanceAllerKm,
    Value<bool>? restauration,
    Value<String>? statut,
    Value<String?>? observation,
    Value<DateTime>? creeLe,
  }) {
    return ActivitesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      codeBudget: codeBudget ?? this.codeBudget,
      sourceFinancement: sourceFinancement ?? this.sourceFinancement,
      annee: annee ?? this.annee,
      periode: periode ?? this.periode,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      lieu: lieu ?? this.lieu,
      district: district ?? this.district,
      zoneIndemnite: zoneIndemnite ?? this.zoneIndemnite,
      responsable: responsable ?? this.responsable,
      nombreJours: nombreJours ?? this.nombreJours,
      nombreParticipants: nombreParticipants ?? this.nombreParticipants,
      nombreMissionnaires: nombreMissionnaires ?? this.nombreMissionnaires,
      distanceAllerKm: distanceAllerKm ?? this.distanceAllerKm,
      restauration: restauration ?? this.restauration,
      statut: statut ?? this.statut,
      observation: observation ?? this.observation,
      creeLe: creeLe ?? this.creeLe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (codeBudget.present) {
      map['code_budget'] = Variable<String>(codeBudget.value);
    }
    if (sourceFinancement.present) {
      map['source_financement'] = Variable<String>(sourceFinancement.value);
    }
    if (annee.present) {
      map['annee'] = Variable<int>(annee.value);
    }
    if (periode.present) {
      map['periode'] = Variable<String>(periode.value);
    }
    if (dateDebut.present) {
      map['date_debut'] = Variable<DateTime>(dateDebut.value);
    }
    if (dateFin.present) {
      map['date_fin'] = Variable<DateTime>(dateFin.value);
    }
    if (lieu.present) {
      map['lieu'] = Variable<String>(lieu.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (zoneIndemnite.present) {
      map['zone_indemnite'] = Variable<String>(zoneIndemnite.value);
    }
    if (responsable.present) {
      map['responsable'] = Variable<String>(responsable.value);
    }
    if (nombreJours.present) {
      map['nombre_jours'] = Variable<int>(nombreJours.value);
    }
    if (nombreParticipants.present) {
      map['nombre_participants'] = Variable<int>(nombreParticipants.value);
    }
    if (nombreMissionnaires.present) {
      map['nombre_missionnaires'] = Variable<int>(nombreMissionnaires.value);
    }
    if (distanceAllerKm.present) {
      map['distance_aller_km'] = Variable<double>(distanceAllerKm.value);
    }
    if (restauration.present) {
      map['restauration'] = Variable<bool>(restauration.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('codeBudget: $codeBudget, ')
          ..write('sourceFinancement: $sourceFinancement, ')
          ..write('annee: $annee, ')
          ..write('periode: $periode, ')
          ..write('dateDebut: $dateDebut, ')
          ..write('dateFin: $dateFin, ')
          ..write('lieu: $lieu, ')
          ..write('district: $district, ')
          ..write('zoneIndemnite: $zoneIndemnite, ')
          ..write('responsable: $responsable, ')
          ..write('nombreJours: $nombreJours, ')
          ..write('nombreParticipants: $nombreParticipants, ')
          ..write('nombreMissionnaires: $nombreMissionnaires, ')
          ..write('distanceAllerKm: $distanceAllerKm, ')
          ..write('restauration: $restauration, ')
          ..write('statut: $statut, ')
          ..write('observation: $observation, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }
}

class $LignesBudgetTable extends LignesBudget
    with TableInfo<$LignesBudgetTable, LigneBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LignesBudgetTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _activiteCodeMeta = const VerificationMeta(
    'activiteCode',
  );
  @override
  late final GeneratedColumn<String> activiteCode = GeneratedColumn<String>(
    'activite_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activiteLibelleMeta = const VerificationMeta(
    'activiteLibelle',
  );
  @override
  late final GeneratedColumn<String> activiteLibelle = GeneratedColumn<String>(
    'activite_libelle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDebutPrevueMeta = const VerificationMeta(
    'dateDebutPrevue',
  );
  @override
  late final GeneratedColumn<DateTime> dateDebutPrevue =
      GeneratedColumn<DateTime>(
        'date_debut_prevue',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateFinPrevueMeta = const VerificationMeta(
    'dateFinPrevue',
  );
  @override
  late final GeneratedColumn<DateTime> dateFinPrevue =
      GeneratedColumn<DateTime>(
        'date_fin_prevue',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ligneBudgetaireMeta = const VerificationMeta(
    'ligneBudgetaire',
  );
  @override
  late final GeneratedColumn<String> ligneBudgetaire = GeneratedColumn<String>(
    'ligne_budgetaire',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeBudgetMeta = const VerificationMeta(
    'typeBudget',
  );
  @override
  late final GeneratedColumn<String> typeBudget = GeneratedColumn<String>(
    'type_budget',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Libre'),
  );
  static const VerificationMeta _uniteMeta = const VerificationMeta('unite');
  @override
  late final GeneratedColumn<String> unite = GeneratedColumn<String>(
    'unite',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('jour-personne'),
  );
  static const VerificationMeta _quantitePrevueMeta = const VerificationMeta(
    'quantitePrevue',
  );
  @override
  late final GeneratedColumn<double> quantitePrevue = GeneratedColumn<double>(
    'quantite_prevue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nombreJoursMeta = const VerificationMeta(
    'nombreJours',
  );
  @override
  late final GeneratedColumn<double> nombreJours = GeneratedColumn<double>(
    'nombre_jours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tauxUnitaireMeta = const VerificationMeta(
    'tauxUnitaire',
  );
  @override
  late final GeneratedColumn<double> tauxUnitaire = GeneratedColumn<double>(
    'taux_unitaire',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _montantAlloueMeta = const VerificationMeta(
    'montantAlloue',
  );
  @override
  late final GeneratedColumn<double> montantAlloue = GeneratedColumn<double>(
    'montant_alloue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activiteCode,
    activiteLibelle,
    dateDebutPrevue,
    dateFinPrevue,
    ligneBudgetaire,
    typeBudget,
    unite,
    quantitePrevue,
    nombreJours,
    tauxUnitaire,
    montantAlloue,
    details,
    observation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lignes_budget';
  @override
  VerificationContext validateIntegrity(
    Insertable<LigneBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activite_code')) {
      context.handle(
        _activiteCodeMeta,
        activiteCode.isAcceptableOrUnknown(
          data['activite_code']!,
          _activiteCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activiteCodeMeta);
    }
    if (data.containsKey('activite_libelle')) {
      context.handle(
        _activiteLibelleMeta,
        activiteLibelle.isAcceptableOrUnknown(
          data['activite_libelle']!,
          _activiteLibelleMeta,
        ),
      );
    }
    if (data.containsKey('date_debut_prevue')) {
      context.handle(
        _dateDebutPrevueMeta,
        dateDebutPrevue.isAcceptableOrUnknown(
          data['date_debut_prevue']!,
          _dateDebutPrevueMeta,
        ),
      );
    }
    if (data.containsKey('date_fin_prevue')) {
      context.handle(
        _dateFinPrevueMeta,
        dateFinPrevue.isAcceptableOrUnknown(
          data['date_fin_prevue']!,
          _dateFinPrevueMeta,
        ),
      );
    }
    if (data.containsKey('ligne_budgetaire')) {
      context.handle(
        _ligneBudgetaireMeta,
        ligneBudgetaire.isAcceptableOrUnknown(
          data['ligne_budgetaire']!,
          _ligneBudgetaireMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ligneBudgetaireMeta);
    }
    if (data.containsKey('type_budget')) {
      context.handle(
        _typeBudgetMeta,
        typeBudget.isAcceptableOrUnknown(data['type_budget']!, _typeBudgetMeta),
      );
    }
    if (data.containsKey('unite')) {
      context.handle(
        _uniteMeta,
        unite.isAcceptableOrUnknown(data['unite']!, _uniteMeta),
      );
    }
    if (data.containsKey('quantite_prevue')) {
      context.handle(
        _quantitePrevueMeta,
        quantitePrevue.isAcceptableOrUnknown(
          data['quantite_prevue']!,
          _quantitePrevueMeta,
        ),
      );
    }
    if (data.containsKey('nombre_jours')) {
      context.handle(
        _nombreJoursMeta,
        nombreJours.isAcceptableOrUnknown(
          data['nombre_jours']!,
          _nombreJoursMeta,
        ),
      );
    }
    if (data.containsKey('taux_unitaire')) {
      context.handle(
        _tauxUnitaireMeta,
        tauxUnitaire.isAcceptableOrUnknown(
          data['taux_unitaire']!,
          _tauxUnitaireMeta,
        ),
      );
    }
    if (data.containsKey('montant_alloue')) {
      context.handle(
        _montantAlloueMeta,
        montantAlloue.isAcceptableOrUnknown(
          data['montant_alloue']!,
          _montantAlloueMeta,
        ),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LigneBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LigneBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activiteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activite_code'],
      )!,
      activiteLibelle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activite_libelle'],
      ),
      dateDebutPrevue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_debut_prevue'],
      ),
      dateFinPrevue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_fin_prevue'],
      ),
      ligneBudgetaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ligne_budgetaire'],
      )!,
      typeBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_budget'],
      )!,
      unite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unite'],
      )!,
      quantitePrevue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite_prevue'],
      )!,
      nombreJours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nombre_jours'],
      )!,
      tauxUnitaire: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taux_unitaire'],
      )!,
      montantAlloue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_alloue'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
    );
  }

  @override
  $LignesBudgetTable createAlias(String alias) {
    return $LignesBudgetTable(attachedDatabase, alias);
  }
}

class LigneBudget extends DataClass implements Insertable<LigneBudget> {
  final int id;
  final String activiteCode;
  final String? activiteLibelle;
  final DateTime? dateDebutPrevue;
  final DateTime? dateFinPrevue;
  final String ligneBudgetaire;

  /// Type de la ligne (indemnités, carburant, location, restauration…).
  final String typeBudget;
  final String unite;
  final double quantitePrevue;
  final double nombreJours;
  final double tauxUnitaire;
  final double montantAlloue;

  /// Paramètres saisis par le générateur (JSON) : personnes, délai de route,
  /// provenance/destination, nombre de véhicules, PU, fréquence…
  final String? details;
  final String? observation;
  const LigneBudget({
    required this.id,
    required this.activiteCode,
    this.activiteLibelle,
    this.dateDebutPrevue,
    this.dateFinPrevue,
    required this.ligneBudgetaire,
    required this.typeBudget,
    required this.unite,
    required this.quantitePrevue,
    required this.nombreJours,
    required this.tauxUnitaire,
    required this.montantAlloue,
    this.details,
    this.observation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activite_code'] = Variable<String>(activiteCode);
    if (!nullToAbsent || activiteLibelle != null) {
      map['activite_libelle'] = Variable<String>(activiteLibelle);
    }
    if (!nullToAbsent || dateDebutPrevue != null) {
      map['date_debut_prevue'] = Variable<DateTime>(dateDebutPrevue);
    }
    if (!nullToAbsent || dateFinPrevue != null) {
      map['date_fin_prevue'] = Variable<DateTime>(dateFinPrevue);
    }
    map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire);
    map['type_budget'] = Variable<String>(typeBudget);
    map['unite'] = Variable<String>(unite);
    map['quantite_prevue'] = Variable<double>(quantitePrevue);
    map['nombre_jours'] = Variable<double>(nombreJours);
    map['taux_unitaire'] = Variable<double>(tauxUnitaire);
    map['montant_alloue'] = Variable<double>(montantAlloue);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    return map;
  }

  LignesBudgetCompanion toCompanion(bool nullToAbsent) {
    return LignesBudgetCompanion(
      id: Value(id),
      activiteCode: Value(activiteCode),
      activiteLibelle: activiteLibelle == null && nullToAbsent
          ? const Value.absent()
          : Value(activiteLibelle),
      dateDebutPrevue: dateDebutPrevue == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDebutPrevue),
      dateFinPrevue: dateFinPrevue == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFinPrevue),
      ligneBudgetaire: Value(ligneBudgetaire),
      typeBudget: Value(typeBudget),
      unite: Value(unite),
      quantitePrevue: Value(quantitePrevue),
      nombreJours: Value(nombreJours),
      tauxUnitaire: Value(tauxUnitaire),
      montantAlloue: Value(montantAlloue),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
    );
  }

  factory LigneBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LigneBudget(
      id: serializer.fromJson<int>(json['id']),
      activiteCode: serializer.fromJson<String>(json['activiteCode']),
      activiteLibelle: serializer.fromJson<String?>(json['activiteLibelle']),
      dateDebutPrevue: serializer.fromJson<DateTime?>(json['dateDebutPrevue']),
      dateFinPrevue: serializer.fromJson<DateTime?>(json['dateFinPrevue']),
      ligneBudgetaire: serializer.fromJson<String>(json['ligneBudgetaire']),
      typeBudget: serializer.fromJson<String>(json['typeBudget']),
      unite: serializer.fromJson<String>(json['unite']),
      quantitePrevue: serializer.fromJson<double>(json['quantitePrevue']),
      nombreJours: serializer.fromJson<double>(json['nombreJours']),
      tauxUnitaire: serializer.fromJson<double>(json['tauxUnitaire']),
      montantAlloue: serializer.fromJson<double>(json['montantAlloue']),
      details: serializer.fromJson<String?>(json['details']),
      observation: serializer.fromJson<String?>(json['observation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activiteCode': serializer.toJson<String>(activiteCode),
      'activiteLibelle': serializer.toJson<String?>(activiteLibelle),
      'dateDebutPrevue': serializer.toJson<DateTime?>(dateDebutPrevue),
      'dateFinPrevue': serializer.toJson<DateTime?>(dateFinPrevue),
      'ligneBudgetaire': serializer.toJson<String>(ligneBudgetaire),
      'typeBudget': serializer.toJson<String>(typeBudget),
      'unite': serializer.toJson<String>(unite),
      'quantitePrevue': serializer.toJson<double>(quantitePrevue),
      'nombreJours': serializer.toJson<double>(nombreJours),
      'tauxUnitaire': serializer.toJson<double>(tauxUnitaire),
      'montantAlloue': serializer.toJson<double>(montantAlloue),
      'details': serializer.toJson<String?>(details),
      'observation': serializer.toJson<String?>(observation),
    };
  }

  LigneBudget copyWith({
    int? id,
    String? activiteCode,
    Value<String?> activiteLibelle = const Value.absent(),
    Value<DateTime?> dateDebutPrevue = const Value.absent(),
    Value<DateTime?> dateFinPrevue = const Value.absent(),
    String? ligneBudgetaire,
    String? typeBudget,
    String? unite,
    double? quantitePrevue,
    double? nombreJours,
    double? tauxUnitaire,
    double? montantAlloue,
    Value<String?> details = const Value.absent(),
    Value<String?> observation = const Value.absent(),
  }) => LigneBudget(
    id: id ?? this.id,
    activiteCode: activiteCode ?? this.activiteCode,
    activiteLibelle: activiteLibelle.present
        ? activiteLibelle.value
        : this.activiteLibelle,
    dateDebutPrevue: dateDebutPrevue.present
        ? dateDebutPrevue.value
        : this.dateDebutPrevue,
    dateFinPrevue: dateFinPrevue.present
        ? dateFinPrevue.value
        : this.dateFinPrevue,
    ligneBudgetaire: ligneBudgetaire ?? this.ligneBudgetaire,
    typeBudget: typeBudget ?? this.typeBudget,
    unite: unite ?? this.unite,
    quantitePrevue: quantitePrevue ?? this.quantitePrevue,
    nombreJours: nombreJours ?? this.nombreJours,
    tauxUnitaire: tauxUnitaire ?? this.tauxUnitaire,
    montantAlloue: montantAlloue ?? this.montantAlloue,
    details: details.present ? details.value : this.details,
    observation: observation.present ? observation.value : this.observation,
  );
  LigneBudget copyWithCompanion(LignesBudgetCompanion data) {
    return LigneBudget(
      id: data.id.present ? data.id.value : this.id,
      activiteCode: data.activiteCode.present
          ? data.activiteCode.value
          : this.activiteCode,
      activiteLibelle: data.activiteLibelle.present
          ? data.activiteLibelle.value
          : this.activiteLibelle,
      dateDebutPrevue: data.dateDebutPrevue.present
          ? data.dateDebutPrevue.value
          : this.dateDebutPrevue,
      dateFinPrevue: data.dateFinPrevue.present
          ? data.dateFinPrevue.value
          : this.dateFinPrevue,
      ligneBudgetaire: data.ligneBudgetaire.present
          ? data.ligneBudgetaire.value
          : this.ligneBudgetaire,
      typeBudget: data.typeBudget.present
          ? data.typeBudget.value
          : this.typeBudget,
      unite: data.unite.present ? data.unite.value : this.unite,
      quantitePrevue: data.quantitePrevue.present
          ? data.quantitePrevue.value
          : this.quantitePrevue,
      nombreJours: data.nombreJours.present
          ? data.nombreJours.value
          : this.nombreJours,
      tauxUnitaire: data.tauxUnitaire.present
          ? data.tauxUnitaire.value
          : this.tauxUnitaire,
      montantAlloue: data.montantAlloue.present
          ? data.montantAlloue.value
          : this.montantAlloue,
      details: data.details.present ? data.details.value : this.details,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LigneBudget(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('activiteLibelle: $activiteLibelle, ')
          ..write('dateDebutPrevue: $dateDebutPrevue, ')
          ..write('dateFinPrevue: $dateFinPrevue, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('typeBudget: $typeBudget, ')
          ..write('unite: $unite, ')
          ..write('quantitePrevue: $quantitePrevue, ')
          ..write('nombreJours: $nombreJours, ')
          ..write('tauxUnitaire: $tauxUnitaire, ')
          ..write('montantAlloue: $montantAlloue, ')
          ..write('details: $details, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activiteCode,
    activiteLibelle,
    dateDebutPrevue,
    dateFinPrevue,
    ligneBudgetaire,
    typeBudget,
    unite,
    quantitePrevue,
    nombreJours,
    tauxUnitaire,
    montantAlloue,
    details,
    observation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LigneBudget &&
          other.id == this.id &&
          other.activiteCode == this.activiteCode &&
          other.activiteLibelle == this.activiteLibelle &&
          other.dateDebutPrevue == this.dateDebutPrevue &&
          other.dateFinPrevue == this.dateFinPrevue &&
          other.ligneBudgetaire == this.ligneBudgetaire &&
          other.typeBudget == this.typeBudget &&
          other.unite == this.unite &&
          other.quantitePrevue == this.quantitePrevue &&
          other.nombreJours == this.nombreJours &&
          other.tauxUnitaire == this.tauxUnitaire &&
          other.montantAlloue == this.montantAlloue &&
          other.details == this.details &&
          other.observation == this.observation);
}

class LignesBudgetCompanion extends UpdateCompanion<LigneBudget> {
  final Value<int> id;
  final Value<String> activiteCode;
  final Value<String?> activiteLibelle;
  final Value<DateTime?> dateDebutPrevue;
  final Value<DateTime?> dateFinPrevue;
  final Value<String> ligneBudgetaire;
  final Value<String> typeBudget;
  final Value<String> unite;
  final Value<double> quantitePrevue;
  final Value<double> nombreJours;
  final Value<double> tauxUnitaire;
  final Value<double> montantAlloue;
  final Value<String?> details;
  final Value<String?> observation;
  const LignesBudgetCompanion({
    this.id = const Value.absent(),
    this.activiteCode = const Value.absent(),
    this.activiteLibelle = const Value.absent(),
    this.dateDebutPrevue = const Value.absent(),
    this.dateFinPrevue = const Value.absent(),
    this.ligneBudgetaire = const Value.absent(),
    this.typeBudget = const Value.absent(),
    this.unite = const Value.absent(),
    this.quantitePrevue = const Value.absent(),
    this.nombreJours = const Value.absent(),
    this.tauxUnitaire = const Value.absent(),
    this.montantAlloue = const Value.absent(),
    this.details = const Value.absent(),
    this.observation = const Value.absent(),
  });
  LignesBudgetCompanion.insert({
    this.id = const Value.absent(),
    required String activiteCode,
    this.activiteLibelle = const Value.absent(),
    this.dateDebutPrevue = const Value.absent(),
    this.dateFinPrevue = const Value.absent(),
    required String ligneBudgetaire,
    this.typeBudget = const Value.absent(),
    this.unite = const Value.absent(),
    this.quantitePrevue = const Value.absent(),
    this.nombreJours = const Value.absent(),
    this.tauxUnitaire = const Value.absent(),
    this.montantAlloue = const Value.absent(),
    this.details = const Value.absent(),
    this.observation = const Value.absent(),
  }) : activiteCode = Value(activiteCode),
       ligneBudgetaire = Value(ligneBudgetaire);
  static Insertable<LigneBudget> custom({
    Expression<int>? id,
    Expression<String>? activiteCode,
    Expression<String>? activiteLibelle,
    Expression<DateTime>? dateDebutPrevue,
    Expression<DateTime>? dateFinPrevue,
    Expression<String>? ligneBudgetaire,
    Expression<String>? typeBudget,
    Expression<String>? unite,
    Expression<double>? quantitePrevue,
    Expression<double>? nombreJours,
    Expression<double>? tauxUnitaire,
    Expression<double>? montantAlloue,
    Expression<String>? details,
    Expression<String>? observation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activiteCode != null) 'activite_code': activiteCode,
      if (activiteLibelle != null) 'activite_libelle': activiteLibelle,
      if (dateDebutPrevue != null) 'date_debut_prevue': dateDebutPrevue,
      if (dateFinPrevue != null) 'date_fin_prevue': dateFinPrevue,
      if (ligneBudgetaire != null) 'ligne_budgetaire': ligneBudgetaire,
      if (typeBudget != null) 'type_budget': typeBudget,
      if (unite != null) 'unite': unite,
      if (quantitePrevue != null) 'quantite_prevue': quantitePrevue,
      if (nombreJours != null) 'nombre_jours': nombreJours,
      if (tauxUnitaire != null) 'taux_unitaire': tauxUnitaire,
      if (montantAlloue != null) 'montant_alloue': montantAlloue,
      if (details != null) 'details': details,
      if (observation != null) 'observation': observation,
    });
  }

  LignesBudgetCompanion copyWith({
    Value<int>? id,
    Value<String>? activiteCode,
    Value<String?>? activiteLibelle,
    Value<DateTime?>? dateDebutPrevue,
    Value<DateTime?>? dateFinPrevue,
    Value<String>? ligneBudgetaire,
    Value<String>? typeBudget,
    Value<String>? unite,
    Value<double>? quantitePrevue,
    Value<double>? nombreJours,
    Value<double>? tauxUnitaire,
    Value<double>? montantAlloue,
    Value<String?>? details,
    Value<String?>? observation,
  }) {
    return LignesBudgetCompanion(
      id: id ?? this.id,
      activiteCode: activiteCode ?? this.activiteCode,
      activiteLibelle: activiteLibelle ?? this.activiteLibelle,
      dateDebutPrevue: dateDebutPrevue ?? this.dateDebutPrevue,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
      ligneBudgetaire: ligneBudgetaire ?? this.ligneBudgetaire,
      typeBudget: typeBudget ?? this.typeBudget,
      unite: unite ?? this.unite,
      quantitePrevue: quantitePrevue ?? this.quantitePrevue,
      nombreJours: nombreJours ?? this.nombreJours,
      tauxUnitaire: tauxUnitaire ?? this.tauxUnitaire,
      montantAlloue: montantAlloue ?? this.montantAlloue,
      details: details ?? this.details,
      observation: observation ?? this.observation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activiteCode.present) {
      map['activite_code'] = Variable<String>(activiteCode.value);
    }
    if (activiteLibelle.present) {
      map['activite_libelle'] = Variable<String>(activiteLibelle.value);
    }
    if (dateDebutPrevue.present) {
      map['date_debut_prevue'] = Variable<DateTime>(dateDebutPrevue.value);
    }
    if (dateFinPrevue.present) {
      map['date_fin_prevue'] = Variable<DateTime>(dateFinPrevue.value);
    }
    if (ligneBudgetaire.present) {
      map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire.value);
    }
    if (typeBudget.present) {
      map['type_budget'] = Variable<String>(typeBudget.value);
    }
    if (unite.present) {
      map['unite'] = Variable<String>(unite.value);
    }
    if (quantitePrevue.present) {
      map['quantite_prevue'] = Variable<double>(quantitePrevue.value);
    }
    if (nombreJours.present) {
      map['nombre_jours'] = Variable<double>(nombreJours.value);
    }
    if (tauxUnitaire.present) {
      map['taux_unitaire'] = Variable<double>(tauxUnitaire.value);
    }
    if (montantAlloue.present) {
      map['montant_alloue'] = Variable<double>(montantAlloue.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LignesBudgetCompanion(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('activiteLibelle: $activiteLibelle, ')
          ..write('dateDebutPrevue: $dateDebutPrevue, ')
          ..write('dateFinPrevue: $dateFinPrevue, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('typeBudget: $typeBudget, ')
          ..write('unite: $unite, ')
          ..write('quantitePrevue: $quantitePrevue, ')
          ..write('nombreJours: $nombreJours, ')
          ..write('tauxUnitaire: $tauxUnitaire, ')
          ..write('montantAlloue: $montantAlloue, ')
          ..write('details: $details, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }
}

class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, Participant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prenomMeta = const VerificationMeta('prenom');
  @override
  late final GeneratedColumn<String> prenom = GeneratedColumn<String>(
    'prenom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fonctionMeta = const VerificationMeta(
    'fonction',
  );
  @override
  late final GeneratedColumn<String> fonction = GeneratedColumn<String>(
    'fonction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _structureMeta = const VerificationMeta(
    'structure',
  );
  @override
  late final GeneratedColumn<String> structure = GeneratedColumn<String>(
    'structure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telephoneMeta = const VerificationMeta(
    'telephone',
  );
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
    'telephone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
    'actif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("actif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nom,
    prenom,
    fonction,
    structure,
    telephone,
    email,
    actif,
    observation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Participant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('prenom')) {
      context.handle(
        _prenomMeta,
        prenom.isAcceptableOrUnknown(data['prenom']!, _prenomMeta),
      );
    }
    if (data.containsKey('fonction')) {
      context.handle(
        _fonctionMeta,
        fonction.isAcceptableOrUnknown(data['fonction']!, _fonctionMeta),
      );
    }
    if (data.containsKey('structure')) {
      context.handle(
        _structureMeta,
        structure.isAcceptableOrUnknown(data['structure']!, _structureMeta),
      );
    }
    if (data.containsKey('telephone')) {
      context.handle(
        _telephoneMeta,
        telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('actif')) {
      context.handle(
        _actifMeta,
        actif.isAcceptableOrUnknown(data['actif']!, _actifMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Participant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Participant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      prenom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prenom'],
      )!,
      fonction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fonction'],
      ),
      structure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structure'],
      ),
      telephone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telephone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      actif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}actif'],
      )!,
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class Participant extends DataClass implements Insertable<Participant> {
  final int id;
  final String nom;
  final String prenom;
  final String? fonction;
  final String? structure;
  final String? telephone;
  final String? email;
  final bool actif;
  final String? observation;
  const Participant({
    required this.id,
    required this.nom,
    required this.prenom,
    this.fonction,
    this.structure,
    this.telephone,
    this.email,
    required this.actif,
    this.observation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['prenom'] = Variable<String>(prenom);
    if (!nullToAbsent || fonction != null) {
      map['fonction'] = Variable<String>(fonction);
    }
    if (!nullToAbsent || structure != null) {
      map['structure'] = Variable<String>(structure);
    }
    if (!nullToAbsent || telephone != null) {
      map['telephone'] = Variable<String>(telephone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['actif'] = Variable<bool>(actif);
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      nom: Value(nom),
      prenom: Value(prenom),
      fonction: fonction == null && nullToAbsent
          ? const Value.absent()
          : Value(fonction),
      structure: structure == null && nullToAbsent
          ? const Value.absent()
          : Value(structure),
      telephone: telephone == null && nullToAbsent
          ? const Value.absent()
          : Value(telephone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      actif: Value(actif),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
    );
  }

  factory Participant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Participant(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      prenom: serializer.fromJson<String>(json['prenom']),
      fonction: serializer.fromJson<String?>(json['fonction']),
      structure: serializer.fromJson<String?>(json['structure']),
      telephone: serializer.fromJson<String?>(json['telephone']),
      email: serializer.fromJson<String?>(json['email']),
      actif: serializer.fromJson<bool>(json['actif']),
      observation: serializer.fromJson<String?>(json['observation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'prenom': serializer.toJson<String>(prenom),
      'fonction': serializer.toJson<String?>(fonction),
      'structure': serializer.toJson<String?>(structure),
      'telephone': serializer.toJson<String?>(telephone),
      'email': serializer.toJson<String?>(email),
      'actif': serializer.toJson<bool>(actif),
      'observation': serializer.toJson<String?>(observation),
    };
  }

  Participant copyWith({
    int? id,
    String? nom,
    String? prenom,
    Value<String?> fonction = const Value.absent(),
    Value<String?> structure = const Value.absent(),
    Value<String?> telephone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    bool? actif,
    Value<String?> observation = const Value.absent(),
  }) => Participant(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    prenom: prenom ?? this.prenom,
    fonction: fonction.present ? fonction.value : this.fonction,
    structure: structure.present ? structure.value : this.structure,
    telephone: telephone.present ? telephone.value : this.telephone,
    email: email.present ? email.value : this.email,
    actif: actif ?? this.actif,
    observation: observation.present ? observation.value : this.observation,
  );
  Participant copyWithCompanion(ParticipantsCompanion data) {
    return Participant(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      prenom: data.prenom.present ? data.prenom.value : this.prenom,
      fonction: data.fonction.present ? data.fonction.value : this.fonction,
      structure: data.structure.present ? data.structure.value : this.structure,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      email: data.email.present ? data.email.value : this.email,
      actif: data.actif.present ? data.actif.value : this.actif,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('fonction: $fonction, ')
          ..write('structure: $structure, ')
          ..write('telephone: $telephone, ')
          ..write('email: $email, ')
          ..write('actif: $actif, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nom,
    prenom,
    fonction,
    structure,
    telephone,
    email,
    actif,
    observation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.prenom == this.prenom &&
          other.fonction == this.fonction &&
          other.structure == this.structure &&
          other.telephone == this.telephone &&
          other.email == this.email &&
          other.actif == this.actif &&
          other.observation == this.observation);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<int> id;
  final Value<String> nom;
  final Value<String> prenom;
  final Value<String?> fonction;
  final Value<String?> structure;
  final Value<String?> telephone;
  final Value<String?> email;
  final Value<bool> actif;
  final Value<String?> observation;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.prenom = const Value.absent(),
    this.fonction = const Value.absent(),
    this.structure = const Value.absent(),
    this.telephone = const Value.absent(),
    this.email = const Value.absent(),
    this.actif = const Value.absent(),
    this.observation = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.prenom = const Value.absent(),
    this.fonction = const Value.absent(),
    this.structure = const Value.absent(),
    this.telephone = const Value.absent(),
    this.email = const Value.absent(),
    this.actif = const Value.absent(),
    this.observation = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<Participant> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<String>? prenom,
    Expression<String>? fonction,
    Expression<String>? structure,
    Expression<String>? telephone,
    Expression<String>? email,
    Expression<bool>? actif,
    Expression<String>? observation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      if (fonction != null) 'fonction': fonction,
      if (structure != null) 'structure': structure,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (actif != null) 'actif': actif,
      if (observation != null) 'observation': observation,
    });
  }

  ParticipantsCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<String>? prenom,
    Value<String?>? fonction,
    Value<String?>? structure,
    Value<String?>? telephone,
    Value<String?>? email,
    Value<bool>? actif,
    Value<String?>? observation,
  }) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      fonction: fonction ?? this.fonction,
      structure: structure ?? this.structure,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      actif: actif ?? this.actif,
      observation: observation ?? this.observation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prenom.present) {
      map['prenom'] = Variable<String>(prenom.value);
    }
    if (fonction.present) {
      map['fonction'] = Variable<String>(fonction.value);
    }
    if (structure.present) {
      map['structure'] = Variable<String>(structure.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('fonction: $fonction, ')
          ..write('structure: $structure, ')
          ..write('telephone: $telephone, ')
          ..write('email: $email, ')
          ..write('actif: $actif, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }
}

class $ActiviteParticipantsTable extends ActiviteParticipants
    with TableInfo<$ActiviteParticipantsTable, ActiviteParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiviteParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _activiteCodeMeta = const VerificationMeta(
    'activiteCode',
  );
  @override
  late final GeneratedColumn<String> activiteCode = GeneratedColumn<String>(
    'activite_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Participant'),
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tauxJournalierMeta = const VerificationMeta(
    'tauxJournalier',
  );
  @override
  late final GeneratedColumn<double> tauxJournalier = GeneratedColumn<double>(
    'taux_journalier',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activiteCode,
    participantId,
    role,
    zone,
    tauxJournalier,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activite_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiviteParticipant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activite_code')) {
      context.handle(
        _activiteCodeMeta,
        activiteCode.isAcceptableOrUnknown(
          data['activite_code']!,
          _activiteCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activiteCodeMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    }
    if (data.containsKey('taux_journalier')) {
      context.handle(
        _tauxJournalierMeta,
        tauxJournalier.isAcceptableOrUnknown(
          data['taux_journalier']!,
          _tauxJournalierMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActiviteParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiviteParticipant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activiteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activite_code'],
      )!,
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      ),
      tauxJournalier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taux_journalier'],
      )!,
    );
  }

  @override
  $ActiviteParticipantsTable createAlias(String alias) {
    return $ActiviteParticipantsTable(attachedDatabase, alias);
  }
}

class ActiviteParticipant extends DataClass
    implements Insertable<ActiviteParticipant> {
  final int id;
  final String activiteCode;
  final int participantId;
  final String role;
  final String? zone;
  final double tauxJournalier;
  const ActiviteParticipant({
    required this.id,
    required this.activiteCode,
    required this.participantId,
    required this.role,
    this.zone,
    required this.tauxJournalier,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activite_code'] = Variable<String>(activiteCode);
    map['participant_id'] = Variable<int>(participantId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || zone != null) {
      map['zone'] = Variable<String>(zone);
    }
    map['taux_journalier'] = Variable<double>(tauxJournalier);
    return map;
  }

  ActiviteParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ActiviteParticipantsCompanion(
      id: Value(id),
      activiteCode: Value(activiteCode),
      participantId: Value(participantId),
      role: Value(role),
      zone: zone == null && nullToAbsent ? const Value.absent() : Value(zone),
      tauxJournalier: Value(tauxJournalier),
    );
  }

  factory ActiviteParticipant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiviteParticipant(
      id: serializer.fromJson<int>(json['id']),
      activiteCode: serializer.fromJson<String>(json['activiteCode']),
      participantId: serializer.fromJson<int>(json['participantId']),
      role: serializer.fromJson<String>(json['role']),
      zone: serializer.fromJson<String?>(json['zone']),
      tauxJournalier: serializer.fromJson<double>(json['tauxJournalier']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activiteCode': serializer.toJson<String>(activiteCode),
      'participantId': serializer.toJson<int>(participantId),
      'role': serializer.toJson<String>(role),
      'zone': serializer.toJson<String?>(zone),
      'tauxJournalier': serializer.toJson<double>(tauxJournalier),
    };
  }

  ActiviteParticipant copyWith({
    int? id,
    String? activiteCode,
    int? participantId,
    String? role,
    Value<String?> zone = const Value.absent(),
    double? tauxJournalier,
  }) => ActiviteParticipant(
    id: id ?? this.id,
    activiteCode: activiteCode ?? this.activiteCode,
    participantId: participantId ?? this.participantId,
    role: role ?? this.role,
    zone: zone.present ? zone.value : this.zone,
    tauxJournalier: tauxJournalier ?? this.tauxJournalier,
  );
  ActiviteParticipant copyWithCompanion(ActiviteParticipantsCompanion data) {
    return ActiviteParticipant(
      id: data.id.present ? data.id.value : this.id,
      activiteCode: data.activiteCode.present
          ? data.activiteCode.value
          : this.activiteCode,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      role: data.role.present ? data.role.value : this.role,
      zone: data.zone.present ? data.zone.value : this.zone,
      tauxJournalier: data.tauxJournalier.present
          ? data.tauxJournalier.value
          : this.tauxJournalier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiviteParticipant(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('participantId: $participantId, ')
          ..write('role: $role, ')
          ..write('zone: $zone, ')
          ..write('tauxJournalier: $tauxJournalier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, activiteCode, participantId, role, zone, tauxJournalier);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiviteParticipant &&
          other.id == this.id &&
          other.activiteCode == this.activiteCode &&
          other.participantId == this.participantId &&
          other.role == this.role &&
          other.zone == this.zone &&
          other.tauxJournalier == this.tauxJournalier);
}

class ActiviteParticipantsCompanion
    extends UpdateCompanion<ActiviteParticipant> {
  final Value<int> id;
  final Value<String> activiteCode;
  final Value<int> participantId;
  final Value<String> role;
  final Value<String?> zone;
  final Value<double> tauxJournalier;
  const ActiviteParticipantsCompanion({
    this.id = const Value.absent(),
    this.activiteCode = const Value.absent(),
    this.participantId = const Value.absent(),
    this.role = const Value.absent(),
    this.zone = const Value.absent(),
    this.tauxJournalier = const Value.absent(),
  });
  ActiviteParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String activiteCode,
    required int participantId,
    this.role = const Value.absent(),
    this.zone = const Value.absent(),
    this.tauxJournalier = const Value.absent(),
  }) : activiteCode = Value(activiteCode),
       participantId = Value(participantId);
  static Insertable<ActiviteParticipant> custom({
    Expression<int>? id,
    Expression<String>? activiteCode,
    Expression<int>? participantId,
    Expression<String>? role,
    Expression<String>? zone,
    Expression<double>? tauxJournalier,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activiteCode != null) 'activite_code': activiteCode,
      if (participantId != null) 'participant_id': participantId,
      if (role != null) 'role': role,
      if (zone != null) 'zone': zone,
      if (tauxJournalier != null) 'taux_journalier': tauxJournalier,
    });
  }

  ActiviteParticipantsCompanion copyWith({
    Value<int>? id,
    Value<String>? activiteCode,
    Value<int>? participantId,
    Value<String>? role,
    Value<String?>? zone,
    Value<double>? tauxJournalier,
  }) {
    return ActiviteParticipantsCompanion(
      id: id ?? this.id,
      activiteCode: activiteCode ?? this.activiteCode,
      participantId: participantId ?? this.participantId,
      role: role ?? this.role,
      zone: zone ?? this.zone,
      tauxJournalier: tauxJournalier ?? this.tauxJournalier,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activiteCode.present) {
      map['activite_code'] = Variable<String>(activiteCode.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (tauxJournalier.present) {
      map['taux_journalier'] = Variable<double>(tauxJournalier.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiviteParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('participantId: $participantId, ')
          ..write('role: $role, ')
          ..write('zone: $zone, ')
          ..write('tauxJournalier: $tauxJournalier')
          ..write(')'))
        .toString();
  }
}

class $PresencesTable extends Presences
    with TableInfo<$PresencesTable, Presence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _activiteCodeMeta = const VerificationMeta(
    'activiteCode',
  );
  @override
  late final GeneratedColumn<String> activiteCode = GeneratedColumn<String>(
    'activite_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Présent'),
  );
  static const VerificationMeta _signaturePreuveMeta = const VerificationMeta(
    'signaturePreuve',
  );
  @override
  late final GeneratedColumn<String> signaturePreuve = GeneratedColumn<String>(
    'signature_preuve',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tauxJournalierMeta = const VerificationMeta(
    'tauxJournalier',
  );
  @override
  late final GeneratedColumn<double> tauxJournalier = GeneratedColumn<double>(
    'taux_journalier',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _indemniteRecueMeta = const VerificationMeta(
    'indemniteRecue',
  );
  @override
  late final GeneratedColumn<double> indemniteRecue = GeneratedColumn<double>(
    'indemnite_recue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activiteCode,
    participantId,
    date,
    statut,
    signaturePreuve,
    tauxJournalier,
    indemniteRecue,
    observation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Presence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activite_code')) {
      context.handle(
        _activiteCodeMeta,
        activiteCode.isAcceptableOrUnknown(
          data['activite_code']!,
          _activiteCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activiteCodeMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(
        _statutMeta,
        statut.isAcceptableOrUnknown(data['statut']!, _statutMeta),
      );
    }
    if (data.containsKey('signature_preuve')) {
      context.handle(
        _signaturePreuveMeta,
        signaturePreuve.isAcceptableOrUnknown(
          data['signature_preuve']!,
          _signaturePreuveMeta,
        ),
      );
    }
    if (data.containsKey('taux_journalier')) {
      context.handle(
        _tauxJournalierMeta,
        tauxJournalier.isAcceptableOrUnknown(
          data['taux_journalier']!,
          _tauxJournalierMeta,
        ),
      );
    }
    if (data.containsKey('indemnite_recue')) {
      context.handle(
        _indemniteRecueMeta,
        indemniteRecue.isAcceptableOrUnknown(
          data['indemnite_recue']!,
          _indemniteRecueMeta,
        ),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Presence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Presence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activiteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activite_code'],
      )!,
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      statut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut'],
      )!,
      signaturePreuve: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature_preuve'],
      ),
      tauxJournalier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taux_journalier'],
      )!,
      indemniteRecue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}indemnite_recue'],
      )!,
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
    );
  }

  @override
  $PresencesTable createAlias(String alias) {
    return $PresencesTable(attachedDatabase, alias);
  }
}

class Presence extends DataClass implements Insertable<Presence> {
  final int id;
  final String activiteCode;
  final int participantId;
  final DateTime date;
  final String statut;
  final String? signaturePreuve;
  final double tauxJournalier;
  final double indemniteRecue;
  final String? observation;
  const Presence({
    required this.id,
    required this.activiteCode,
    required this.participantId,
    required this.date,
    required this.statut,
    this.signaturePreuve,
    required this.tauxJournalier,
    required this.indemniteRecue,
    this.observation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activite_code'] = Variable<String>(activiteCode);
    map['participant_id'] = Variable<int>(participantId);
    map['date'] = Variable<DateTime>(date);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || signaturePreuve != null) {
      map['signature_preuve'] = Variable<String>(signaturePreuve);
    }
    map['taux_journalier'] = Variable<double>(tauxJournalier);
    map['indemnite_recue'] = Variable<double>(indemniteRecue);
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    return map;
  }

  PresencesCompanion toCompanion(bool nullToAbsent) {
    return PresencesCompanion(
      id: Value(id),
      activiteCode: Value(activiteCode),
      participantId: Value(participantId),
      date: Value(date),
      statut: Value(statut),
      signaturePreuve: signaturePreuve == null && nullToAbsent
          ? const Value.absent()
          : Value(signaturePreuve),
      tauxJournalier: Value(tauxJournalier),
      indemniteRecue: Value(indemniteRecue),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
    );
  }

  factory Presence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Presence(
      id: serializer.fromJson<int>(json['id']),
      activiteCode: serializer.fromJson<String>(json['activiteCode']),
      participantId: serializer.fromJson<int>(json['participantId']),
      date: serializer.fromJson<DateTime>(json['date']),
      statut: serializer.fromJson<String>(json['statut']),
      signaturePreuve: serializer.fromJson<String?>(json['signaturePreuve']),
      tauxJournalier: serializer.fromJson<double>(json['tauxJournalier']),
      indemniteRecue: serializer.fromJson<double>(json['indemniteRecue']),
      observation: serializer.fromJson<String?>(json['observation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activiteCode': serializer.toJson<String>(activiteCode),
      'participantId': serializer.toJson<int>(participantId),
      'date': serializer.toJson<DateTime>(date),
      'statut': serializer.toJson<String>(statut),
      'signaturePreuve': serializer.toJson<String?>(signaturePreuve),
      'tauxJournalier': serializer.toJson<double>(tauxJournalier),
      'indemniteRecue': serializer.toJson<double>(indemniteRecue),
      'observation': serializer.toJson<String?>(observation),
    };
  }

  Presence copyWith({
    int? id,
    String? activiteCode,
    int? participantId,
    DateTime? date,
    String? statut,
    Value<String?> signaturePreuve = const Value.absent(),
    double? tauxJournalier,
    double? indemniteRecue,
    Value<String?> observation = const Value.absent(),
  }) => Presence(
    id: id ?? this.id,
    activiteCode: activiteCode ?? this.activiteCode,
    participantId: participantId ?? this.participantId,
    date: date ?? this.date,
    statut: statut ?? this.statut,
    signaturePreuve: signaturePreuve.present
        ? signaturePreuve.value
        : this.signaturePreuve,
    tauxJournalier: tauxJournalier ?? this.tauxJournalier,
    indemniteRecue: indemniteRecue ?? this.indemniteRecue,
    observation: observation.present ? observation.value : this.observation,
  );
  Presence copyWithCompanion(PresencesCompanion data) {
    return Presence(
      id: data.id.present ? data.id.value : this.id,
      activiteCode: data.activiteCode.present
          ? data.activiteCode.value
          : this.activiteCode,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      date: data.date.present ? data.date.value : this.date,
      statut: data.statut.present ? data.statut.value : this.statut,
      signaturePreuve: data.signaturePreuve.present
          ? data.signaturePreuve.value
          : this.signaturePreuve,
      tauxJournalier: data.tauxJournalier.present
          ? data.tauxJournalier.value
          : this.tauxJournalier,
      indemniteRecue: data.indemniteRecue.present
          ? data.indemniteRecue.value
          : this.indemniteRecue,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Presence(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('participantId: $participantId, ')
          ..write('date: $date, ')
          ..write('statut: $statut, ')
          ..write('signaturePreuve: $signaturePreuve, ')
          ..write('tauxJournalier: $tauxJournalier, ')
          ..write('indemniteRecue: $indemniteRecue, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activiteCode,
    participantId,
    date,
    statut,
    signaturePreuve,
    tauxJournalier,
    indemniteRecue,
    observation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Presence &&
          other.id == this.id &&
          other.activiteCode == this.activiteCode &&
          other.participantId == this.participantId &&
          other.date == this.date &&
          other.statut == this.statut &&
          other.signaturePreuve == this.signaturePreuve &&
          other.tauxJournalier == this.tauxJournalier &&
          other.indemniteRecue == this.indemniteRecue &&
          other.observation == this.observation);
}

class PresencesCompanion extends UpdateCompanion<Presence> {
  final Value<int> id;
  final Value<String> activiteCode;
  final Value<int> participantId;
  final Value<DateTime> date;
  final Value<String> statut;
  final Value<String?> signaturePreuve;
  final Value<double> tauxJournalier;
  final Value<double> indemniteRecue;
  final Value<String?> observation;
  const PresencesCompanion({
    this.id = const Value.absent(),
    this.activiteCode = const Value.absent(),
    this.participantId = const Value.absent(),
    this.date = const Value.absent(),
    this.statut = const Value.absent(),
    this.signaturePreuve = const Value.absent(),
    this.tauxJournalier = const Value.absent(),
    this.indemniteRecue = const Value.absent(),
    this.observation = const Value.absent(),
  });
  PresencesCompanion.insert({
    this.id = const Value.absent(),
    required String activiteCode,
    required int participantId,
    required DateTime date,
    this.statut = const Value.absent(),
    this.signaturePreuve = const Value.absent(),
    this.tauxJournalier = const Value.absent(),
    this.indemniteRecue = const Value.absent(),
    this.observation = const Value.absent(),
  }) : activiteCode = Value(activiteCode),
       participantId = Value(participantId),
       date = Value(date);
  static Insertable<Presence> custom({
    Expression<int>? id,
    Expression<String>? activiteCode,
    Expression<int>? participantId,
    Expression<DateTime>? date,
    Expression<String>? statut,
    Expression<String>? signaturePreuve,
    Expression<double>? tauxJournalier,
    Expression<double>? indemniteRecue,
    Expression<String>? observation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activiteCode != null) 'activite_code': activiteCode,
      if (participantId != null) 'participant_id': participantId,
      if (date != null) 'date': date,
      if (statut != null) 'statut': statut,
      if (signaturePreuve != null) 'signature_preuve': signaturePreuve,
      if (tauxJournalier != null) 'taux_journalier': tauxJournalier,
      if (indemniteRecue != null) 'indemnite_recue': indemniteRecue,
      if (observation != null) 'observation': observation,
    });
  }

  PresencesCompanion copyWith({
    Value<int>? id,
    Value<String>? activiteCode,
    Value<int>? participantId,
    Value<DateTime>? date,
    Value<String>? statut,
    Value<String?>? signaturePreuve,
    Value<double>? tauxJournalier,
    Value<double>? indemniteRecue,
    Value<String?>? observation,
  }) {
    return PresencesCompanion(
      id: id ?? this.id,
      activiteCode: activiteCode ?? this.activiteCode,
      participantId: participantId ?? this.participantId,
      date: date ?? this.date,
      statut: statut ?? this.statut,
      signaturePreuve: signaturePreuve ?? this.signaturePreuve,
      tauxJournalier: tauxJournalier ?? this.tauxJournalier,
      indemniteRecue: indemniteRecue ?? this.indemniteRecue,
      observation: observation ?? this.observation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activiteCode.present) {
      map['activite_code'] = Variable<String>(activiteCode.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (signaturePreuve.present) {
      map['signature_preuve'] = Variable<String>(signaturePreuve.value);
    }
    if (tauxJournalier.present) {
      map['taux_journalier'] = Variable<double>(tauxJournalier.value);
    }
    if (indemniteRecue.present) {
      map['indemnite_recue'] = Variable<double>(indemniteRecue.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresencesCompanion(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('participantId: $participantId, ')
          ..write('date: $date, ')
          ..write('statut: $statut, ')
          ..write('signaturePreuve: $signaturePreuve, ')
          ..write('tauxJournalier: $tauxJournalier, ')
          ..write('indemniteRecue: $indemniteRecue, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }
}

class $IndemnitesSaisiesTable extends IndemnitesSaisies
    with TableInfo<$IndemnitesSaisiesTable, IndemniteSaisie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IndemnitesSaisiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _activiteCodeMeta = const VerificationMeta(
    'activiteCode',
  );
  @override
  late final GeneratedColumn<String> activiteCode = GeneratedColumn<String>(
    'activite_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ligneBudgetaireMeta = const VerificationMeta(
    'ligneBudgetaire',
  );
  @override
  late final GeneratedColumn<String> ligneBudgetaire = GeneratedColumn<String>(
    'ligne_budgetaire',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _participantNomMeta = const VerificationMeta(
    'participantNom',
  );
  @override
  late final GeneratedColumn<String> participantNom = GeneratedColumn<String>(
    'participant_nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _etatPaiementMeta = const VerificationMeta(
    'etatPaiement',
  );
  @override
  late final GeneratedColumn<String> etatPaiement = GeneratedColumn<String>(
    'etat_paiement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('À payer'),
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _delaiRouteMeta = const VerificationMeta(
    'delaiRoute',
  );
  @override
  late final GeneratedColumn<double> delaiRoute = GeneratedColumn<double>(
    'delai_route',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nombreJoursActiviteMeta =
      const VerificationMeta('nombreJoursActivite');
  @override
  late final GeneratedColumn<double> nombreJoursActivite =
      GeneratedColumn<double>(
        'nombre_jours_activite',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _restaurationMeta = const VerificationMeta(
    'restauration',
  );
  @override
  late final GeneratedColumn<bool> restauration = GeneratedColumn<bool>(
    'restauration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("restauration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tauxMeta = const VerificationMeta('taux');
  @override
  late final GeneratedColumn<double> taux = GeneratedColumn<double>(
    'taux',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _montantAlloueMeta = const VerificationMeta(
    'montantAlloue',
  );
  @override
  late final GeneratedColumn<double> montantAlloue = GeneratedColumn<double>(
    'montant_alloue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _montantPayeMeta = const VerificationMeta(
    'montantPaye',
  );
  @override
  late final GeneratedColumn<double> montantPaye = GeneratedColumn<double>(
    'montant_paye',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
    'cree_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activiteCode,
    ligneBudgetaire,
    participantId,
    participantNom,
    etatPaiement,
    provenance,
    delaiRoute,
    nombreJoursActivite,
    restauration,
    taux,
    montantAlloue,
    montantPaye,
    creeLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'indemnites_saisies';
  @override
  VerificationContext validateIntegrity(
    Insertable<IndemniteSaisie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activite_code')) {
      context.handle(
        _activiteCodeMeta,
        activiteCode.isAcceptableOrUnknown(
          data['activite_code']!,
          _activiteCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activiteCodeMeta);
    }
    if (data.containsKey('ligne_budgetaire')) {
      context.handle(
        _ligneBudgetaireMeta,
        ligneBudgetaire.isAcceptableOrUnknown(
          data['ligne_budgetaire']!,
          _ligneBudgetaireMeta,
        ),
      );
    }
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    }
    if (data.containsKey('participant_nom')) {
      context.handle(
        _participantNomMeta,
        participantNom.isAcceptableOrUnknown(
          data['participant_nom']!,
          _participantNomMeta,
        ),
      );
    }
    if (data.containsKey('etat_paiement')) {
      context.handle(
        _etatPaiementMeta,
        etatPaiement.isAcceptableOrUnknown(
          data['etat_paiement']!,
          _etatPaiementMeta,
        ),
      );
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    }
    if (data.containsKey('delai_route')) {
      context.handle(
        _delaiRouteMeta,
        delaiRoute.isAcceptableOrUnknown(data['delai_route']!, _delaiRouteMeta),
      );
    }
    if (data.containsKey('nombre_jours_activite')) {
      context.handle(
        _nombreJoursActiviteMeta,
        nombreJoursActivite.isAcceptableOrUnknown(
          data['nombre_jours_activite']!,
          _nombreJoursActiviteMeta,
        ),
      );
    }
    if (data.containsKey('restauration')) {
      context.handle(
        _restaurationMeta,
        restauration.isAcceptableOrUnknown(
          data['restauration']!,
          _restaurationMeta,
        ),
      );
    }
    if (data.containsKey('taux')) {
      context.handle(
        _tauxMeta,
        taux.isAcceptableOrUnknown(data['taux']!, _tauxMeta),
      );
    }
    if (data.containsKey('montant_alloue')) {
      context.handle(
        _montantAlloueMeta,
        montantAlloue.isAcceptableOrUnknown(
          data['montant_alloue']!,
          _montantAlloueMeta,
        ),
      );
    }
    if (data.containsKey('montant_paye')) {
      context.handle(
        _montantPayeMeta,
        montantPaye.isAcceptableOrUnknown(
          data['montant_paye']!,
          _montantPayeMeta,
        ),
      );
    }
    if (data.containsKey('cree_le')) {
      context.handle(
        _creeLeMeta,
        creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IndemniteSaisie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IndemniteSaisie(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activiteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activite_code'],
      )!,
      ligneBudgetaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ligne_budgetaire'],
      )!,
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      ),
      participantNom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participant_nom'],
      )!,
      etatPaiement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etat_paiement'],
      )!,
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      ),
      delaiRoute: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delai_route'],
      )!,
      nombreJoursActivite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nombre_jours_activite'],
      )!,
      restauration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}restauration'],
      )!,
      taux: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taux'],
      )!,
      montantAlloue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_alloue'],
      )!,
      montantPaye: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_paye'],
      )!,
      creeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cree_le'],
      )!,
    );
  }

  @override
  $IndemnitesSaisiesTable createAlias(String alias) {
    return $IndemnitesSaisiesTable(attachedDatabase, alias);
  }
}

class IndemniteSaisie extends DataClass implements Insertable<IndemniteSaisie> {
  final int id;
  final String activiteCode;
  final String ligneBudgetaire;
  final int? participantId;
  final String participantNom;

  /// État de paiement : Payé, Partiel, À payer, Non payé.
  final String etatPaiement;

  /// Provenance (district de l'activité) : détermine le taux applicable.
  final String? provenance;

  /// Délai de route (jours) et jours d'activité retenus.
  final double delaiRoute;
  final double nombreJoursActivite;
  final bool restauration;

  /// Taux journalier appliqué (règle chef-lieu de région / district).
  final double taux;
  final double montantAlloue;
  final double montantPaye;
  final DateTime creeLe;
  const IndemniteSaisie({
    required this.id,
    required this.activiteCode,
    required this.ligneBudgetaire,
    this.participantId,
    required this.participantNom,
    required this.etatPaiement,
    this.provenance,
    required this.delaiRoute,
    required this.nombreJoursActivite,
    required this.restauration,
    required this.taux,
    required this.montantAlloue,
    required this.montantPaye,
    required this.creeLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activite_code'] = Variable<String>(activiteCode);
    map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire);
    if (!nullToAbsent || participantId != null) {
      map['participant_id'] = Variable<int>(participantId);
    }
    map['participant_nom'] = Variable<String>(participantNom);
    map['etat_paiement'] = Variable<String>(etatPaiement);
    if (!nullToAbsent || provenance != null) {
      map['provenance'] = Variable<String>(provenance);
    }
    map['delai_route'] = Variable<double>(delaiRoute);
    map['nombre_jours_activite'] = Variable<double>(nombreJoursActivite);
    map['restauration'] = Variable<bool>(restauration);
    map['taux'] = Variable<double>(taux);
    map['montant_alloue'] = Variable<double>(montantAlloue);
    map['montant_paye'] = Variable<double>(montantPaye);
    map['cree_le'] = Variable<DateTime>(creeLe);
    return map;
  }

  IndemnitesSaisiesCompanion toCompanion(bool nullToAbsent) {
    return IndemnitesSaisiesCompanion(
      id: Value(id),
      activiteCode: Value(activiteCode),
      ligneBudgetaire: Value(ligneBudgetaire),
      participantId: participantId == null && nullToAbsent
          ? const Value.absent()
          : Value(participantId),
      participantNom: Value(participantNom),
      etatPaiement: Value(etatPaiement),
      provenance: provenance == null && nullToAbsent
          ? const Value.absent()
          : Value(provenance),
      delaiRoute: Value(delaiRoute),
      nombreJoursActivite: Value(nombreJoursActivite),
      restauration: Value(restauration),
      taux: Value(taux),
      montantAlloue: Value(montantAlloue),
      montantPaye: Value(montantPaye),
      creeLe: Value(creeLe),
    );
  }

  factory IndemniteSaisie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IndemniteSaisie(
      id: serializer.fromJson<int>(json['id']),
      activiteCode: serializer.fromJson<String>(json['activiteCode']),
      ligneBudgetaire: serializer.fromJson<String>(json['ligneBudgetaire']),
      participantId: serializer.fromJson<int?>(json['participantId']),
      participantNom: serializer.fromJson<String>(json['participantNom']),
      etatPaiement: serializer.fromJson<String>(json['etatPaiement']),
      provenance: serializer.fromJson<String?>(json['provenance']),
      delaiRoute: serializer.fromJson<double>(json['delaiRoute']),
      nombreJoursActivite: serializer.fromJson<double>(
        json['nombreJoursActivite'],
      ),
      restauration: serializer.fromJson<bool>(json['restauration']),
      taux: serializer.fromJson<double>(json['taux']),
      montantAlloue: serializer.fromJson<double>(json['montantAlloue']),
      montantPaye: serializer.fromJson<double>(json['montantPaye']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activiteCode': serializer.toJson<String>(activiteCode),
      'ligneBudgetaire': serializer.toJson<String>(ligneBudgetaire),
      'participantId': serializer.toJson<int?>(participantId),
      'participantNom': serializer.toJson<String>(participantNom),
      'etatPaiement': serializer.toJson<String>(etatPaiement),
      'provenance': serializer.toJson<String?>(provenance),
      'delaiRoute': serializer.toJson<double>(delaiRoute),
      'nombreJoursActivite': serializer.toJson<double>(nombreJoursActivite),
      'restauration': serializer.toJson<bool>(restauration),
      'taux': serializer.toJson<double>(taux),
      'montantAlloue': serializer.toJson<double>(montantAlloue),
      'montantPaye': serializer.toJson<double>(montantPaye),
      'creeLe': serializer.toJson<DateTime>(creeLe),
    };
  }

  IndemniteSaisie copyWith({
    int? id,
    String? activiteCode,
    String? ligneBudgetaire,
    Value<int?> participantId = const Value.absent(),
    String? participantNom,
    String? etatPaiement,
    Value<String?> provenance = const Value.absent(),
    double? delaiRoute,
    double? nombreJoursActivite,
    bool? restauration,
    double? taux,
    double? montantAlloue,
    double? montantPaye,
    DateTime? creeLe,
  }) => IndemniteSaisie(
    id: id ?? this.id,
    activiteCode: activiteCode ?? this.activiteCode,
    ligneBudgetaire: ligneBudgetaire ?? this.ligneBudgetaire,
    participantId: participantId.present
        ? participantId.value
        : this.participantId,
    participantNom: participantNom ?? this.participantNom,
    etatPaiement: etatPaiement ?? this.etatPaiement,
    provenance: provenance.present ? provenance.value : this.provenance,
    delaiRoute: delaiRoute ?? this.delaiRoute,
    nombreJoursActivite: nombreJoursActivite ?? this.nombreJoursActivite,
    restauration: restauration ?? this.restauration,
    taux: taux ?? this.taux,
    montantAlloue: montantAlloue ?? this.montantAlloue,
    montantPaye: montantPaye ?? this.montantPaye,
    creeLe: creeLe ?? this.creeLe,
  );
  IndemniteSaisie copyWithCompanion(IndemnitesSaisiesCompanion data) {
    return IndemniteSaisie(
      id: data.id.present ? data.id.value : this.id,
      activiteCode: data.activiteCode.present
          ? data.activiteCode.value
          : this.activiteCode,
      ligneBudgetaire: data.ligneBudgetaire.present
          ? data.ligneBudgetaire.value
          : this.ligneBudgetaire,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      participantNom: data.participantNom.present
          ? data.participantNom.value
          : this.participantNom,
      etatPaiement: data.etatPaiement.present
          ? data.etatPaiement.value
          : this.etatPaiement,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      delaiRoute: data.delaiRoute.present
          ? data.delaiRoute.value
          : this.delaiRoute,
      nombreJoursActivite: data.nombreJoursActivite.present
          ? data.nombreJoursActivite.value
          : this.nombreJoursActivite,
      restauration: data.restauration.present
          ? data.restauration.value
          : this.restauration,
      taux: data.taux.present ? data.taux.value : this.taux,
      montantAlloue: data.montantAlloue.present
          ? data.montantAlloue.value
          : this.montantAlloue,
      montantPaye: data.montantPaye.present
          ? data.montantPaye.value
          : this.montantPaye,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IndemniteSaisie(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('participantId: $participantId, ')
          ..write('participantNom: $participantNom, ')
          ..write('etatPaiement: $etatPaiement, ')
          ..write('provenance: $provenance, ')
          ..write('delaiRoute: $delaiRoute, ')
          ..write('nombreJoursActivite: $nombreJoursActivite, ')
          ..write('restauration: $restauration, ')
          ..write('taux: $taux, ')
          ..write('montantAlloue: $montantAlloue, ')
          ..write('montantPaye: $montantPaye, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activiteCode,
    ligneBudgetaire,
    participantId,
    participantNom,
    etatPaiement,
    provenance,
    delaiRoute,
    nombreJoursActivite,
    restauration,
    taux,
    montantAlloue,
    montantPaye,
    creeLe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IndemniteSaisie &&
          other.id == this.id &&
          other.activiteCode == this.activiteCode &&
          other.ligneBudgetaire == this.ligneBudgetaire &&
          other.participantId == this.participantId &&
          other.participantNom == this.participantNom &&
          other.etatPaiement == this.etatPaiement &&
          other.provenance == this.provenance &&
          other.delaiRoute == this.delaiRoute &&
          other.nombreJoursActivite == this.nombreJoursActivite &&
          other.restauration == this.restauration &&
          other.taux == this.taux &&
          other.montantAlloue == this.montantAlloue &&
          other.montantPaye == this.montantPaye &&
          other.creeLe == this.creeLe);
}

class IndemnitesSaisiesCompanion extends UpdateCompanion<IndemniteSaisie> {
  final Value<int> id;
  final Value<String> activiteCode;
  final Value<String> ligneBudgetaire;
  final Value<int?> participantId;
  final Value<String> participantNom;
  final Value<String> etatPaiement;
  final Value<String?> provenance;
  final Value<double> delaiRoute;
  final Value<double> nombreJoursActivite;
  final Value<bool> restauration;
  final Value<double> taux;
  final Value<double> montantAlloue;
  final Value<double> montantPaye;
  final Value<DateTime> creeLe;
  const IndemnitesSaisiesCompanion({
    this.id = const Value.absent(),
    this.activiteCode = const Value.absent(),
    this.ligneBudgetaire = const Value.absent(),
    this.participantId = const Value.absent(),
    this.participantNom = const Value.absent(),
    this.etatPaiement = const Value.absent(),
    this.provenance = const Value.absent(),
    this.delaiRoute = const Value.absent(),
    this.nombreJoursActivite = const Value.absent(),
    this.restauration = const Value.absent(),
    this.taux = const Value.absent(),
    this.montantAlloue = const Value.absent(),
    this.montantPaye = const Value.absent(),
    this.creeLe = const Value.absent(),
  });
  IndemnitesSaisiesCompanion.insert({
    this.id = const Value.absent(),
    required String activiteCode,
    this.ligneBudgetaire = const Value.absent(),
    this.participantId = const Value.absent(),
    this.participantNom = const Value.absent(),
    this.etatPaiement = const Value.absent(),
    this.provenance = const Value.absent(),
    this.delaiRoute = const Value.absent(),
    this.nombreJoursActivite = const Value.absent(),
    this.restauration = const Value.absent(),
    this.taux = const Value.absent(),
    this.montantAlloue = const Value.absent(),
    this.montantPaye = const Value.absent(),
    this.creeLe = const Value.absent(),
  }) : activiteCode = Value(activiteCode);
  static Insertable<IndemniteSaisie> custom({
    Expression<int>? id,
    Expression<String>? activiteCode,
    Expression<String>? ligneBudgetaire,
    Expression<int>? participantId,
    Expression<String>? participantNom,
    Expression<String>? etatPaiement,
    Expression<String>? provenance,
    Expression<double>? delaiRoute,
    Expression<double>? nombreJoursActivite,
    Expression<bool>? restauration,
    Expression<double>? taux,
    Expression<double>? montantAlloue,
    Expression<double>? montantPaye,
    Expression<DateTime>? creeLe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activiteCode != null) 'activite_code': activiteCode,
      if (ligneBudgetaire != null) 'ligne_budgetaire': ligneBudgetaire,
      if (participantId != null) 'participant_id': participantId,
      if (participantNom != null) 'participant_nom': participantNom,
      if (etatPaiement != null) 'etat_paiement': etatPaiement,
      if (provenance != null) 'provenance': provenance,
      if (delaiRoute != null) 'delai_route': delaiRoute,
      if (nombreJoursActivite != null)
        'nombre_jours_activite': nombreJoursActivite,
      if (restauration != null) 'restauration': restauration,
      if (taux != null) 'taux': taux,
      if (montantAlloue != null) 'montant_alloue': montantAlloue,
      if (montantPaye != null) 'montant_paye': montantPaye,
      if (creeLe != null) 'cree_le': creeLe,
    });
  }

  IndemnitesSaisiesCompanion copyWith({
    Value<int>? id,
    Value<String>? activiteCode,
    Value<String>? ligneBudgetaire,
    Value<int?>? participantId,
    Value<String>? participantNom,
    Value<String>? etatPaiement,
    Value<String?>? provenance,
    Value<double>? delaiRoute,
    Value<double>? nombreJoursActivite,
    Value<bool>? restauration,
    Value<double>? taux,
    Value<double>? montantAlloue,
    Value<double>? montantPaye,
    Value<DateTime>? creeLe,
  }) {
    return IndemnitesSaisiesCompanion(
      id: id ?? this.id,
      activiteCode: activiteCode ?? this.activiteCode,
      ligneBudgetaire: ligneBudgetaire ?? this.ligneBudgetaire,
      participantId: participantId ?? this.participantId,
      participantNom: participantNom ?? this.participantNom,
      etatPaiement: etatPaiement ?? this.etatPaiement,
      provenance: provenance ?? this.provenance,
      delaiRoute: delaiRoute ?? this.delaiRoute,
      nombreJoursActivite: nombreJoursActivite ?? this.nombreJoursActivite,
      restauration: restauration ?? this.restauration,
      taux: taux ?? this.taux,
      montantAlloue: montantAlloue ?? this.montantAlloue,
      montantPaye: montantPaye ?? this.montantPaye,
      creeLe: creeLe ?? this.creeLe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activiteCode.present) {
      map['activite_code'] = Variable<String>(activiteCode.value);
    }
    if (ligneBudgetaire.present) {
      map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (participantNom.present) {
      map['participant_nom'] = Variable<String>(participantNom.value);
    }
    if (etatPaiement.present) {
      map['etat_paiement'] = Variable<String>(etatPaiement.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (delaiRoute.present) {
      map['delai_route'] = Variable<double>(delaiRoute.value);
    }
    if (nombreJoursActivite.present) {
      map['nombre_jours_activite'] = Variable<double>(
        nombreJoursActivite.value,
      );
    }
    if (restauration.present) {
      map['restauration'] = Variable<bool>(restauration.value);
    }
    if (taux.present) {
      map['taux'] = Variable<double>(taux.value);
    }
    if (montantAlloue.present) {
      map['montant_alloue'] = Variable<double>(montantAlloue.value);
    }
    if (montantPaye.present) {
      map['montant_paye'] = Variable<double>(montantPaye.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IndemnitesSaisiesCompanion(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('participantId: $participantId, ')
          ..write('participantNom: $participantNom, ')
          ..write('etatPaiement: $etatPaiement, ')
          ..write('provenance: $provenance, ')
          ..write('delaiRoute: $delaiRoute, ')
          ..write('nombreJoursActivite: $nombreJoursActivite, ')
          ..write('restauration: $restauration, ')
          ..write('taux: $taux, ')
          ..write('montantAlloue: $montantAlloue, ')
          ..write('montantPaye: $montantPaye, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }
}

class $ControlesPJTable extends ControlesPJ
    with TableInfo<$ControlesPJTable, ControlePJ> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ControlesPJTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _activiteCodeMeta = const VerificationMeta(
    'activiteCode',
  );
  @override
  late final GeneratedColumn<String> activiteCode = GeneratedColumn<String>(
    'activite_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDebutActiviteMeta = const VerificationMeta(
    'dateDebutActivite',
  );
  @override
  late final GeneratedColumn<DateTime> dateDebutActivite =
      GeneratedColumn<DateTime>(
        'date_debut_activite',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateFinActiviteMeta = const VerificationMeta(
    'dateFinActivite',
  );
  @override
  late final GeneratedColumn<DateTime> dateFinActivite =
      GeneratedColumn<DateTime>(
        'date_fin_activite',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _datePJMeta = const VerificationMeta('datePJ');
  @override
  late final GeneratedColumn<DateTime> datePJ = GeneratedColumn<DateTime>(
    'date_p_j',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ligneBudgetaireMeta = const VerificationMeta(
    'ligneBudgetaire',
  );
  @override
  late final GeneratedColumn<String> ligneBudgetaire = GeneratedColumn<String>(
    'ligne_budgetaire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beneficiaireMeta = const VerificationMeta(
    'beneficiaire',
  );
  @override
  late final GeneratedColumn<String> beneficiaire = GeneratedColumn<String>(
    'beneficiaire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typePJMeta = const VerificationMeta('typePJ');
  @override
  late final GeneratedColumn<String> typePJ = GeneratedColumn<String>(
    'type_p_j',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montantAlloueMeta = const VerificationMeta(
    'montantAlloue',
  );
  @override
  late final GeneratedColumn<double> montantAlloue = GeneratedColumn<double>(
    'montant_alloue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _montantPayeMeta = const VerificationMeta(
    'montantPaye',
  );
  @override
  late final GeneratedColumn<double> montantPaye = GeneratedColumn<double>(
    'montant_paye',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _montantPJMeta = const VerificationMeta(
    'montantPJ',
  );
  @override
  late final GeneratedColumn<double> montantPJ = GeneratedColumn<double>(
    'montant_p_j',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pjRecueMeta = const VerificationMeta(
    'pjRecue',
  );
  @override
  late final GeneratedColumn<String> pjRecue = GeneratedColumn<String>(
    'pj_recue',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pjConformeMeta = const VerificationMeta(
    'pjConforme',
  );
  @override
  late final GeneratedColumn<String> pjConforme = GeneratedColumn<String>(
    'pj_conforme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _checklistPJMeta = const VerificationMeta(
    'checklistPJ',
  );
  @override
  late final GeneratedColumn<String> checklistPJ = GeneratedColumn<String>(
    'checklist_p_j',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activiteCode,
    dateDebutActivite,
    dateFinActivite,
    datePJ,
    ligneBudgetaire,
    beneficiaire,
    typePJ,
    montantAlloue,
    montantPaye,
    montantPJ,
    pjRecue,
    pjConforme,
    checklistPJ,
    observation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'controles_p_j';
  @override
  VerificationContext validateIntegrity(
    Insertable<ControlePJ> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activite_code')) {
      context.handle(
        _activiteCodeMeta,
        activiteCode.isAcceptableOrUnknown(
          data['activite_code']!,
          _activiteCodeMeta,
        ),
      );
    }
    if (data.containsKey('date_debut_activite')) {
      context.handle(
        _dateDebutActiviteMeta,
        dateDebutActivite.isAcceptableOrUnknown(
          data['date_debut_activite']!,
          _dateDebutActiviteMeta,
        ),
      );
    }
    if (data.containsKey('date_fin_activite')) {
      context.handle(
        _dateFinActiviteMeta,
        dateFinActivite.isAcceptableOrUnknown(
          data['date_fin_activite']!,
          _dateFinActiviteMeta,
        ),
      );
    }
    if (data.containsKey('date_p_j')) {
      context.handle(
        _datePJMeta,
        datePJ.isAcceptableOrUnknown(data['date_p_j']!, _datePJMeta),
      );
    }
    if (data.containsKey('ligne_budgetaire')) {
      context.handle(
        _ligneBudgetaireMeta,
        ligneBudgetaire.isAcceptableOrUnknown(
          data['ligne_budgetaire']!,
          _ligneBudgetaireMeta,
        ),
      );
    }
    if (data.containsKey('beneficiaire')) {
      context.handle(
        _beneficiaireMeta,
        beneficiaire.isAcceptableOrUnknown(
          data['beneficiaire']!,
          _beneficiaireMeta,
        ),
      );
    }
    if (data.containsKey('type_p_j')) {
      context.handle(
        _typePJMeta,
        typePJ.isAcceptableOrUnknown(data['type_p_j']!, _typePJMeta),
      );
    }
    if (data.containsKey('montant_alloue')) {
      context.handle(
        _montantAlloueMeta,
        montantAlloue.isAcceptableOrUnknown(
          data['montant_alloue']!,
          _montantAlloueMeta,
        ),
      );
    }
    if (data.containsKey('montant_paye')) {
      context.handle(
        _montantPayeMeta,
        montantPaye.isAcceptableOrUnknown(
          data['montant_paye']!,
          _montantPayeMeta,
        ),
      );
    }
    if (data.containsKey('montant_p_j')) {
      context.handle(
        _montantPJMeta,
        montantPJ.isAcceptableOrUnknown(data['montant_p_j']!, _montantPJMeta),
      );
    }
    if (data.containsKey('pj_recue')) {
      context.handle(
        _pjRecueMeta,
        pjRecue.isAcceptableOrUnknown(data['pj_recue']!, _pjRecueMeta),
      );
    }
    if (data.containsKey('pj_conforme')) {
      context.handle(
        _pjConformeMeta,
        pjConforme.isAcceptableOrUnknown(data['pj_conforme']!, _pjConformeMeta),
      );
    }
    if (data.containsKey('checklist_p_j')) {
      context.handle(
        _checklistPJMeta,
        checklistPJ.isAcceptableOrUnknown(
          data['checklist_p_j']!,
          _checklistPJMeta,
        ),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ControlePJ map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ControlePJ(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activiteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activite_code'],
      ),
      dateDebutActivite: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_debut_activite'],
      ),
      dateFinActivite: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_fin_activite'],
      ),
      datePJ: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_p_j'],
      ),
      ligneBudgetaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ligne_budgetaire'],
      ),
      beneficiaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiaire'],
      ),
      typePJ: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_p_j'],
      ),
      montantAlloue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_alloue'],
      )!,
      montantPaye: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_paye'],
      )!,
      montantPJ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_p_j'],
      )!,
      pjRecue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pj_recue'],
      )!,
      pjConforme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pj_conforme'],
      )!,
      checklistPJ: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checklist_p_j'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
    );
  }

  @override
  $ControlesPJTable createAlias(String alias) {
    return $ControlesPJTable(attachedDatabase, alias);
  }
}

class ControlePJ extends DataClass implements Insertable<ControlePJ> {
  final int id;
  final String? activiteCode;
  final DateTime? dateDebutActivite;
  final DateTime? dateFinActivite;
  final DateTime? datePJ;
  final String? ligneBudgetaire;
  final String? beneficiaire;
  final String? typePJ;
  final double montantAlloue;
  final double montantPaye;
  final double montantPJ;
  final String pjRecue;
  final String pjConforme;

  /// Checklist des PJ requises (JSON) : pièce → « reçue » / « date conforme ».
  final String? checklistPJ;
  final String? observation;
  const ControlePJ({
    required this.id,
    this.activiteCode,
    this.dateDebutActivite,
    this.dateFinActivite,
    this.datePJ,
    this.ligneBudgetaire,
    this.beneficiaire,
    this.typePJ,
    required this.montantAlloue,
    required this.montantPaye,
    required this.montantPJ,
    required this.pjRecue,
    required this.pjConforme,
    this.checklistPJ,
    this.observation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || activiteCode != null) {
      map['activite_code'] = Variable<String>(activiteCode);
    }
    if (!nullToAbsent || dateDebutActivite != null) {
      map['date_debut_activite'] = Variable<DateTime>(dateDebutActivite);
    }
    if (!nullToAbsent || dateFinActivite != null) {
      map['date_fin_activite'] = Variable<DateTime>(dateFinActivite);
    }
    if (!nullToAbsent || datePJ != null) {
      map['date_p_j'] = Variable<DateTime>(datePJ);
    }
    if (!nullToAbsent || ligneBudgetaire != null) {
      map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire);
    }
    if (!nullToAbsent || beneficiaire != null) {
      map['beneficiaire'] = Variable<String>(beneficiaire);
    }
    if (!nullToAbsent || typePJ != null) {
      map['type_p_j'] = Variable<String>(typePJ);
    }
    map['montant_alloue'] = Variable<double>(montantAlloue);
    map['montant_paye'] = Variable<double>(montantPaye);
    map['montant_p_j'] = Variable<double>(montantPJ);
    map['pj_recue'] = Variable<String>(pjRecue);
    map['pj_conforme'] = Variable<String>(pjConforme);
    if (!nullToAbsent || checklistPJ != null) {
      map['checklist_p_j'] = Variable<String>(checklistPJ);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    return map;
  }

  ControlesPJCompanion toCompanion(bool nullToAbsent) {
    return ControlesPJCompanion(
      id: Value(id),
      activiteCode: activiteCode == null && nullToAbsent
          ? const Value.absent()
          : Value(activiteCode),
      dateDebutActivite: dateDebutActivite == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDebutActivite),
      dateFinActivite: dateFinActivite == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFinActivite),
      datePJ: datePJ == null && nullToAbsent
          ? const Value.absent()
          : Value(datePJ),
      ligneBudgetaire: ligneBudgetaire == null && nullToAbsent
          ? const Value.absent()
          : Value(ligneBudgetaire),
      beneficiaire: beneficiaire == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaire),
      typePJ: typePJ == null && nullToAbsent
          ? const Value.absent()
          : Value(typePJ),
      montantAlloue: Value(montantAlloue),
      montantPaye: Value(montantPaye),
      montantPJ: Value(montantPJ),
      pjRecue: Value(pjRecue),
      pjConforme: Value(pjConforme),
      checklistPJ: checklistPJ == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistPJ),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
    );
  }

  factory ControlePJ.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ControlePJ(
      id: serializer.fromJson<int>(json['id']),
      activiteCode: serializer.fromJson<String?>(json['activiteCode']),
      dateDebutActivite: serializer.fromJson<DateTime?>(
        json['dateDebutActivite'],
      ),
      dateFinActivite: serializer.fromJson<DateTime?>(json['dateFinActivite']),
      datePJ: serializer.fromJson<DateTime?>(json['datePJ']),
      ligneBudgetaire: serializer.fromJson<String?>(json['ligneBudgetaire']),
      beneficiaire: serializer.fromJson<String?>(json['beneficiaire']),
      typePJ: serializer.fromJson<String?>(json['typePJ']),
      montantAlloue: serializer.fromJson<double>(json['montantAlloue']),
      montantPaye: serializer.fromJson<double>(json['montantPaye']),
      montantPJ: serializer.fromJson<double>(json['montantPJ']),
      pjRecue: serializer.fromJson<String>(json['pjRecue']),
      pjConforme: serializer.fromJson<String>(json['pjConforme']),
      checklistPJ: serializer.fromJson<String?>(json['checklistPJ']),
      observation: serializer.fromJson<String?>(json['observation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activiteCode': serializer.toJson<String?>(activiteCode),
      'dateDebutActivite': serializer.toJson<DateTime?>(dateDebutActivite),
      'dateFinActivite': serializer.toJson<DateTime?>(dateFinActivite),
      'datePJ': serializer.toJson<DateTime?>(datePJ),
      'ligneBudgetaire': serializer.toJson<String?>(ligneBudgetaire),
      'beneficiaire': serializer.toJson<String?>(beneficiaire),
      'typePJ': serializer.toJson<String?>(typePJ),
      'montantAlloue': serializer.toJson<double>(montantAlloue),
      'montantPaye': serializer.toJson<double>(montantPaye),
      'montantPJ': serializer.toJson<double>(montantPJ),
      'pjRecue': serializer.toJson<String>(pjRecue),
      'pjConforme': serializer.toJson<String>(pjConforme),
      'checklistPJ': serializer.toJson<String?>(checklistPJ),
      'observation': serializer.toJson<String?>(observation),
    };
  }

  ControlePJ copyWith({
    int? id,
    Value<String?> activiteCode = const Value.absent(),
    Value<DateTime?> dateDebutActivite = const Value.absent(),
    Value<DateTime?> dateFinActivite = const Value.absent(),
    Value<DateTime?> datePJ = const Value.absent(),
    Value<String?> ligneBudgetaire = const Value.absent(),
    Value<String?> beneficiaire = const Value.absent(),
    Value<String?> typePJ = const Value.absent(),
    double? montantAlloue,
    double? montantPaye,
    double? montantPJ,
    String? pjRecue,
    String? pjConforme,
    Value<String?> checklistPJ = const Value.absent(),
    Value<String?> observation = const Value.absent(),
  }) => ControlePJ(
    id: id ?? this.id,
    activiteCode: activiteCode.present ? activiteCode.value : this.activiteCode,
    dateDebutActivite: dateDebutActivite.present
        ? dateDebutActivite.value
        : this.dateDebutActivite,
    dateFinActivite: dateFinActivite.present
        ? dateFinActivite.value
        : this.dateFinActivite,
    datePJ: datePJ.present ? datePJ.value : this.datePJ,
    ligneBudgetaire: ligneBudgetaire.present
        ? ligneBudgetaire.value
        : this.ligneBudgetaire,
    beneficiaire: beneficiaire.present ? beneficiaire.value : this.beneficiaire,
    typePJ: typePJ.present ? typePJ.value : this.typePJ,
    montantAlloue: montantAlloue ?? this.montantAlloue,
    montantPaye: montantPaye ?? this.montantPaye,
    montantPJ: montantPJ ?? this.montantPJ,
    pjRecue: pjRecue ?? this.pjRecue,
    pjConforme: pjConforme ?? this.pjConforme,
    checklistPJ: checklistPJ.present ? checklistPJ.value : this.checklistPJ,
    observation: observation.present ? observation.value : this.observation,
  );
  ControlePJ copyWithCompanion(ControlesPJCompanion data) {
    return ControlePJ(
      id: data.id.present ? data.id.value : this.id,
      activiteCode: data.activiteCode.present
          ? data.activiteCode.value
          : this.activiteCode,
      dateDebutActivite: data.dateDebutActivite.present
          ? data.dateDebutActivite.value
          : this.dateDebutActivite,
      dateFinActivite: data.dateFinActivite.present
          ? data.dateFinActivite.value
          : this.dateFinActivite,
      datePJ: data.datePJ.present ? data.datePJ.value : this.datePJ,
      ligneBudgetaire: data.ligneBudgetaire.present
          ? data.ligneBudgetaire.value
          : this.ligneBudgetaire,
      beneficiaire: data.beneficiaire.present
          ? data.beneficiaire.value
          : this.beneficiaire,
      typePJ: data.typePJ.present ? data.typePJ.value : this.typePJ,
      montantAlloue: data.montantAlloue.present
          ? data.montantAlloue.value
          : this.montantAlloue,
      montantPaye: data.montantPaye.present
          ? data.montantPaye.value
          : this.montantPaye,
      montantPJ: data.montantPJ.present ? data.montantPJ.value : this.montantPJ,
      pjRecue: data.pjRecue.present ? data.pjRecue.value : this.pjRecue,
      pjConforme: data.pjConforme.present
          ? data.pjConforme.value
          : this.pjConforme,
      checklistPJ: data.checklistPJ.present
          ? data.checklistPJ.value
          : this.checklistPJ,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ControlePJ(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('dateDebutActivite: $dateDebutActivite, ')
          ..write('dateFinActivite: $dateFinActivite, ')
          ..write('datePJ: $datePJ, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('beneficiaire: $beneficiaire, ')
          ..write('typePJ: $typePJ, ')
          ..write('montantAlloue: $montantAlloue, ')
          ..write('montantPaye: $montantPaye, ')
          ..write('montantPJ: $montantPJ, ')
          ..write('pjRecue: $pjRecue, ')
          ..write('pjConforme: $pjConforme, ')
          ..write('checklistPJ: $checklistPJ, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activiteCode,
    dateDebutActivite,
    dateFinActivite,
    datePJ,
    ligneBudgetaire,
    beneficiaire,
    typePJ,
    montantAlloue,
    montantPaye,
    montantPJ,
    pjRecue,
    pjConforme,
    checklistPJ,
    observation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ControlePJ &&
          other.id == this.id &&
          other.activiteCode == this.activiteCode &&
          other.dateDebutActivite == this.dateDebutActivite &&
          other.dateFinActivite == this.dateFinActivite &&
          other.datePJ == this.datePJ &&
          other.ligneBudgetaire == this.ligneBudgetaire &&
          other.beneficiaire == this.beneficiaire &&
          other.typePJ == this.typePJ &&
          other.montantAlloue == this.montantAlloue &&
          other.montantPaye == this.montantPaye &&
          other.montantPJ == this.montantPJ &&
          other.pjRecue == this.pjRecue &&
          other.pjConforme == this.pjConforme &&
          other.checklistPJ == this.checklistPJ &&
          other.observation == this.observation);
}

class ControlesPJCompanion extends UpdateCompanion<ControlePJ> {
  final Value<int> id;
  final Value<String?> activiteCode;
  final Value<DateTime?> dateDebutActivite;
  final Value<DateTime?> dateFinActivite;
  final Value<DateTime?> datePJ;
  final Value<String?> ligneBudgetaire;
  final Value<String?> beneficiaire;
  final Value<String?> typePJ;
  final Value<double> montantAlloue;
  final Value<double> montantPaye;
  final Value<double> montantPJ;
  final Value<String> pjRecue;
  final Value<String> pjConforme;
  final Value<String?> checklistPJ;
  final Value<String?> observation;
  const ControlesPJCompanion({
    this.id = const Value.absent(),
    this.activiteCode = const Value.absent(),
    this.dateDebutActivite = const Value.absent(),
    this.dateFinActivite = const Value.absent(),
    this.datePJ = const Value.absent(),
    this.ligneBudgetaire = const Value.absent(),
    this.beneficiaire = const Value.absent(),
    this.typePJ = const Value.absent(),
    this.montantAlloue = const Value.absent(),
    this.montantPaye = const Value.absent(),
    this.montantPJ = const Value.absent(),
    this.pjRecue = const Value.absent(),
    this.pjConforme = const Value.absent(),
    this.checklistPJ = const Value.absent(),
    this.observation = const Value.absent(),
  });
  ControlesPJCompanion.insert({
    this.id = const Value.absent(),
    this.activiteCode = const Value.absent(),
    this.dateDebutActivite = const Value.absent(),
    this.dateFinActivite = const Value.absent(),
    this.datePJ = const Value.absent(),
    this.ligneBudgetaire = const Value.absent(),
    this.beneficiaire = const Value.absent(),
    this.typePJ = const Value.absent(),
    this.montantAlloue = const Value.absent(),
    this.montantPaye = const Value.absent(),
    this.montantPJ = const Value.absent(),
    this.pjRecue = const Value.absent(),
    this.pjConforme = const Value.absent(),
    this.checklistPJ = const Value.absent(),
    this.observation = const Value.absent(),
  });
  static Insertable<ControlePJ> custom({
    Expression<int>? id,
    Expression<String>? activiteCode,
    Expression<DateTime>? dateDebutActivite,
    Expression<DateTime>? dateFinActivite,
    Expression<DateTime>? datePJ,
    Expression<String>? ligneBudgetaire,
    Expression<String>? beneficiaire,
    Expression<String>? typePJ,
    Expression<double>? montantAlloue,
    Expression<double>? montantPaye,
    Expression<double>? montantPJ,
    Expression<String>? pjRecue,
    Expression<String>? pjConforme,
    Expression<String>? checklistPJ,
    Expression<String>? observation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activiteCode != null) 'activite_code': activiteCode,
      if (dateDebutActivite != null) 'date_debut_activite': dateDebutActivite,
      if (dateFinActivite != null) 'date_fin_activite': dateFinActivite,
      if (datePJ != null) 'date_p_j': datePJ,
      if (ligneBudgetaire != null) 'ligne_budgetaire': ligneBudgetaire,
      if (beneficiaire != null) 'beneficiaire': beneficiaire,
      if (typePJ != null) 'type_p_j': typePJ,
      if (montantAlloue != null) 'montant_alloue': montantAlloue,
      if (montantPaye != null) 'montant_paye': montantPaye,
      if (montantPJ != null) 'montant_p_j': montantPJ,
      if (pjRecue != null) 'pj_recue': pjRecue,
      if (pjConforme != null) 'pj_conforme': pjConforme,
      if (checklistPJ != null) 'checklist_p_j': checklistPJ,
      if (observation != null) 'observation': observation,
    });
  }

  ControlesPJCompanion copyWith({
    Value<int>? id,
    Value<String?>? activiteCode,
    Value<DateTime?>? dateDebutActivite,
    Value<DateTime?>? dateFinActivite,
    Value<DateTime?>? datePJ,
    Value<String?>? ligneBudgetaire,
    Value<String?>? beneficiaire,
    Value<String?>? typePJ,
    Value<double>? montantAlloue,
    Value<double>? montantPaye,
    Value<double>? montantPJ,
    Value<String>? pjRecue,
    Value<String>? pjConforme,
    Value<String?>? checklistPJ,
    Value<String?>? observation,
  }) {
    return ControlesPJCompanion(
      id: id ?? this.id,
      activiteCode: activiteCode ?? this.activiteCode,
      dateDebutActivite: dateDebutActivite ?? this.dateDebutActivite,
      dateFinActivite: dateFinActivite ?? this.dateFinActivite,
      datePJ: datePJ ?? this.datePJ,
      ligneBudgetaire: ligneBudgetaire ?? this.ligneBudgetaire,
      beneficiaire: beneficiaire ?? this.beneficiaire,
      typePJ: typePJ ?? this.typePJ,
      montantAlloue: montantAlloue ?? this.montantAlloue,
      montantPaye: montantPaye ?? this.montantPaye,
      montantPJ: montantPJ ?? this.montantPJ,
      pjRecue: pjRecue ?? this.pjRecue,
      pjConforme: pjConforme ?? this.pjConforme,
      checklistPJ: checklistPJ ?? this.checklistPJ,
      observation: observation ?? this.observation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activiteCode.present) {
      map['activite_code'] = Variable<String>(activiteCode.value);
    }
    if (dateDebutActivite.present) {
      map['date_debut_activite'] = Variable<DateTime>(dateDebutActivite.value);
    }
    if (dateFinActivite.present) {
      map['date_fin_activite'] = Variable<DateTime>(dateFinActivite.value);
    }
    if (datePJ.present) {
      map['date_p_j'] = Variable<DateTime>(datePJ.value);
    }
    if (ligneBudgetaire.present) {
      map['ligne_budgetaire'] = Variable<String>(ligneBudgetaire.value);
    }
    if (beneficiaire.present) {
      map['beneficiaire'] = Variable<String>(beneficiaire.value);
    }
    if (typePJ.present) {
      map['type_p_j'] = Variable<String>(typePJ.value);
    }
    if (montantAlloue.present) {
      map['montant_alloue'] = Variable<double>(montantAlloue.value);
    }
    if (montantPaye.present) {
      map['montant_paye'] = Variable<double>(montantPaye.value);
    }
    if (montantPJ.present) {
      map['montant_p_j'] = Variable<double>(montantPJ.value);
    }
    if (pjRecue.present) {
      map['pj_recue'] = Variable<String>(pjRecue.value);
    }
    if (pjConforme.present) {
      map['pj_conforme'] = Variable<String>(pjConforme.value);
    }
    if (checklistPJ.present) {
      map['checklist_p_j'] = Variable<String>(checklistPJ.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ControlesPJCompanion(')
          ..write('id: $id, ')
          ..write('activiteCode: $activiteCode, ')
          ..write('dateDebutActivite: $dateDebutActivite, ')
          ..write('dateFinActivite: $dateFinActivite, ')
          ..write('datePJ: $datePJ, ')
          ..write('ligneBudgetaire: $ligneBudgetaire, ')
          ..write('beneficiaire: $beneficiaire, ')
          ..write('typePJ: $typePJ, ')
          ..write('montantAlloue: $montantAlloue, ')
          ..write('montantPaye: $montantPaye, ')
          ..write('montantPJ: $montantPJ, ')
          ..write('pjRecue: $pjRecue, ')
          ..write('pjConforme: $pjConforme, ')
          ..write('checklistPJ: $checklistPJ, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }
}

class $DepensesTable extends Depenses with TableInfo<$DepensesTable, Depense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateEnregistrementMeta =
      const VerificationMeta('dateEnregistrement');
  @override
  late final GeneratedColumn<DateTime> dateEnregistrement =
      GeneratedColumn<DateTime>(
        'date_enregistrement',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _datePieceComptableMeta =
      const VerificationMeta('datePieceComptable');
  @override
  late final GeneratedColumn<DateTime> datePieceComptable =
      GeneratedColumn<DateTime>(
        'date_piece_comptable',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _periodeAutoriseeMeta = const VerificationMeta(
    'periodeAutorisee',
  );
  @override
  late final GeneratedColumn<String> periodeAutorisee = GeneratedColumn<String>(
    'periode_autorisee',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fondsMeta = const VerificationMeta('fonds');
  @override
  late final GeneratedColumn<String> fonds = GeneratedColumn<String>(
    'fonds',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Banque'),
  );
  static const VerificationMeta _refDecaissementMeta = const VerificationMeta(
    'refDecaissement',
  );
  @override
  late final GeneratedColumn<String> refDecaissement = GeneratedColumn<String>(
    'ref_decaissement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refPieceDepenseMeta = const VerificationMeta(
    'refPieceDepense',
  );
  @override
  late final GeneratedColumn<String> refPieceDepense = GeneratedColumn<String>(
    'ref_piece_depense',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dctNumeroMeta = const VerificationMeta(
    'dctNumero',
  );
  @override
  late final GeneratedColumn<String> dctNumero = GeneratedColumn<String>(
    'dct_numero',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeActiviteMeta = const VerificationMeta(
    'codeActivite',
  );
  @override
  late final GeneratedColumn<String> codeActivite = GeneratedColumn<String>(
    'code_activite',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeBudgetMeta = const VerificationMeta(
    'codeBudget',
  );
  @override
  late final GeneratedColumn<String> codeBudget = GeneratedColumn<String>(
    'code_budget',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _designationMeta = const VerificationMeta(
    'designation',
  );
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
    'designation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _beneficiaireMeta = const VerificationMeta(
    'beneficiaire',
  );
  @override
  late final GeneratedColumn<String> beneficiaire = GeneratedColumn<String>(
    'beneficiaire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _controlePJIdMeta = const VerificationMeta(
    'controlePJId',
  );
  @override
  late final GeneratedColumn<int> controlePJId = GeneratedColumn<int>(
    'controle_p_j_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uniteMeta = const VerificationMeta('unite');
  @override
  late final GeneratedColumn<String> unite = GeneratedColumn<String>(
    'unite',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nbJrMoisMeta = const VerificationMeta(
    'nbJrMois',
  );
  @override
  late final GeneratedColumn<double> nbJrMois = GeneratedColumn<double>(
    'nb_jr_mois',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _frequenceMeta = const VerificationMeta(
    'frequence',
  );
  @override
  late final GeneratedColumn<double> frequence = GeneratedColumn<double>(
    'frequence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _puMeta = const VerificationMeta('pu');
  @override
  late final GeneratedColumn<double> pu = GeneratedColumn<double>(
    'pu',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dateEnregistrement,
    datePieceComptable,
    periodeAutorisee,
    fonds,
    refDecaissement,
    refPieceDepense,
    dctNumero,
    codeActivite,
    codeBudget,
    designation,
    beneficiaire,
    controlePJId,
    unite,
    nbJrMois,
    quantite,
    frequence,
    pu,
    observation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'depenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Depense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_enregistrement')) {
      context.handle(
        _dateEnregistrementMeta,
        dateEnregistrement.isAcceptableOrUnknown(
          data['date_enregistrement']!,
          _dateEnregistrementMeta,
        ),
      );
    }
    if (data.containsKey('date_piece_comptable')) {
      context.handle(
        _datePieceComptableMeta,
        datePieceComptable.isAcceptableOrUnknown(
          data['date_piece_comptable']!,
          _datePieceComptableMeta,
        ),
      );
    }
    if (data.containsKey('periode_autorisee')) {
      context.handle(
        _periodeAutoriseeMeta,
        periodeAutorisee.isAcceptableOrUnknown(
          data['periode_autorisee']!,
          _periodeAutoriseeMeta,
        ),
      );
    }
    if (data.containsKey('fonds')) {
      context.handle(
        _fondsMeta,
        fonds.isAcceptableOrUnknown(data['fonds']!, _fondsMeta),
      );
    }
    if (data.containsKey('ref_decaissement')) {
      context.handle(
        _refDecaissementMeta,
        refDecaissement.isAcceptableOrUnknown(
          data['ref_decaissement']!,
          _refDecaissementMeta,
        ),
      );
    }
    if (data.containsKey('ref_piece_depense')) {
      context.handle(
        _refPieceDepenseMeta,
        refPieceDepense.isAcceptableOrUnknown(
          data['ref_piece_depense']!,
          _refPieceDepenseMeta,
        ),
      );
    }
    if (data.containsKey('dct_numero')) {
      context.handle(
        _dctNumeroMeta,
        dctNumero.isAcceptableOrUnknown(data['dct_numero']!, _dctNumeroMeta),
      );
    }
    if (data.containsKey('code_activite')) {
      context.handle(
        _codeActiviteMeta,
        codeActivite.isAcceptableOrUnknown(
          data['code_activite']!,
          _codeActiviteMeta,
        ),
      );
    }
    if (data.containsKey('code_budget')) {
      context.handle(
        _codeBudgetMeta,
        codeBudget.isAcceptableOrUnknown(data['code_budget']!, _codeBudgetMeta),
      );
    }
    if (data.containsKey('designation')) {
      context.handle(
        _designationMeta,
        designation.isAcceptableOrUnknown(
          data['designation']!,
          _designationMeta,
        ),
      );
    }
    if (data.containsKey('beneficiaire')) {
      context.handle(
        _beneficiaireMeta,
        beneficiaire.isAcceptableOrUnknown(
          data['beneficiaire']!,
          _beneficiaireMeta,
        ),
      );
    }
    if (data.containsKey('controle_p_j_id')) {
      context.handle(
        _controlePJIdMeta,
        controlePJId.isAcceptableOrUnknown(
          data['controle_p_j_id']!,
          _controlePJIdMeta,
        ),
      );
    }
    if (data.containsKey('unite')) {
      context.handle(
        _uniteMeta,
        unite.isAcceptableOrUnknown(data['unite']!, _uniteMeta),
      );
    }
    if (data.containsKey('nb_jr_mois')) {
      context.handle(
        _nbJrMoisMeta,
        nbJrMois.isAcceptableOrUnknown(data['nb_jr_mois']!, _nbJrMoisMeta),
      );
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    }
    if (data.containsKey('frequence')) {
      context.handle(
        _frequenceMeta,
        frequence.isAcceptableOrUnknown(data['frequence']!, _frequenceMeta),
      );
    }
    if (data.containsKey('pu')) {
      context.handle(_puMeta, pu.isAcceptableOrUnknown(data['pu']!, _puMeta));
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Depense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Depense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dateEnregistrement: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_enregistrement'],
      ),
      datePieceComptable: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_piece_comptable'],
      ),
      periodeAutorisee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}periode_autorisee'],
      ),
      fonds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fonds'],
      )!,
      refDecaissement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_decaissement'],
      ),
      refPieceDepense: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_piece_depense'],
      ),
      dctNumero: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dct_numero'],
      ),
      codeActivite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_activite'],
      ),
      codeBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_budget'],
      ),
      designation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designation'],
      )!,
      beneficiaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiaire'],
      ),
      controlePJId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}controle_p_j_id'],
      ),
      unite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unite'],
      ),
      nbJrMois: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nb_jr_mois'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      frequence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frequence'],
      )!,
      pu: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pu'],
      )!,
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
    );
  }

  @override
  $DepensesTable createAlias(String alias) {
    return $DepensesTable(attachedDatabase, alias);
  }
}

class Depense extends DataClass implements Insertable<Depense> {
  final int id;
  final DateTime? dateEnregistrement;
  final DateTime? datePieceComptable;
  final String? periodeAutorisee;
  final String fonds;
  final String? refDecaissement;
  final String? refPieceDepense;
  final String? dctNumero;
  final String? codeActivite;
  final String? codeBudget;
  final String designation;
  final String? beneficiaire;

  /// Contrôle PJ d'origine quand la ligne est créée/mise à jour par le
  /// dossier PJ (permet d'afficher le statut de conformité de la pièce).
  final int? controlePJId;
  final String? unite;
  final double nbJrMois;
  final double quantite;
  final double frequence;
  final double pu;
  final String? observation;
  const Depense({
    required this.id,
    this.dateEnregistrement,
    this.datePieceComptable,
    this.periodeAutorisee,
    required this.fonds,
    this.refDecaissement,
    this.refPieceDepense,
    this.dctNumero,
    this.codeActivite,
    this.codeBudget,
    required this.designation,
    this.beneficiaire,
    this.controlePJId,
    this.unite,
    required this.nbJrMois,
    required this.quantite,
    required this.frequence,
    required this.pu,
    this.observation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || dateEnregistrement != null) {
      map['date_enregistrement'] = Variable<DateTime>(dateEnregistrement);
    }
    if (!nullToAbsent || datePieceComptable != null) {
      map['date_piece_comptable'] = Variable<DateTime>(datePieceComptable);
    }
    if (!nullToAbsent || periodeAutorisee != null) {
      map['periode_autorisee'] = Variable<String>(periodeAutorisee);
    }
    map['fonds'] = Variable<String>(fonds);
    if (!nullToAbsent || refDecaissement != null) {
      map['ref_decaissement'] = Variable<String>(refDecaissement);
    }
    if (!nullToAbsent || refPieceDepense != null) {
      map['ref_piece_depense'] = Variable<String>(refPieceDepense);
    }
    if (!nullToAbsent || dctNumero != null) {
      map['dct_numero'] = Variable<String>(dctNumero);
    }
    if (!nullToAbsent || codeActivite != null) {
      map['code_activite'] = Variable<String>(codeActivite);
    }
    if (!nullToAbsent || codeBudget != null) {
      map['code_budget'] = Variable<String>(codeBudget);
    }
    map['designation'] = Variable<String>(designation);
    if (!nullToAbsent || beneficiaire != null) {
      map['beneficiaire'] = Variable<String>(beneficiaire);
    }
    if (!nullToAbsent || controlePJId != null) {
      map['controle_p_j_id'] = Variable<int>(controlePJId);
    }
    if (!nullToAbsent || unite != null) {
      map['unite'] = Variable<String>(unite);
    }
    map['nb_jr_mois'] = Variable<double>(nbJrMois);
    map['quantite'] = Variable<double>(quantite);
    map['frequence'] = Variable<double>(frequence);
    map['pu'] = Variable<double>(pu);
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    return map;
  }

  DepensesCompanion toCompanion(bool nullToAbsent) {
    return DepensesCompanion(
      id: Value(id),
      dateEnregistrement: dateEnregistrement == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEnregistrement),
      datePieceComptable: datePieceComptable == null && nullToAbsent
          ? const Value.absent()
          : Value(datePieceComptable),
      periodeAutorisee: periodeAutorisee == null && nullToAbsent
          ? const Value.absent()
          : Value(periodeAutorisee),
      fonds: Value(fonds),
      refDecaissement: refDecaissement == null && nullToAbsent
          ? const Value.absent()
          : Value(refDecaissement),
      refPieceDepense: refPieceDepense == null && nullToAbsent
          ? const Value.absent()
          : Value(refPieceDepense),
      dctNumero: dctNumero == null && nullToAbsent
          ? const Value.absent()
          : Value(dctNumero),
      codeActivite: codeActivite == null && nullToAbsent
          ? const Value.absent()
          : Value(codeActivite),
      codeBudget: codeBudget == null && nullToAbsent
          ? const Value.absent()
          : Value(codeBudget),
      designation: Value(designation),
      beneficiaire: beneficiaire == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaire),
      controlePJId: controlePJId == null && nullToAbsent
          ? const Value.absent()
          : Value(controlePJId),
      unite: unite == null && nullToAbsent
          ? const Value.absent()
          : Value(unite),
      nbJrMois: Value(nbJrMois),
      quantite: Value(quantite),
      frequence: Value(frequence),
      pu: Value(pu),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
    );
  }

  factory Depense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Depense(
      id: serializer.fromJson<int>(json['id']),
      dateEnregistrement: serializer.fromJson<DateTime?>(
        json['dateEnregistrement'],
      ),
      datePieceComptable: serializer.fromJson<DateTime?>(
        json['datePieceComptable'],
      ),
      periodeAutorisee: serializer.fromJson<String?>(json['periodeAutorisee']),
      fonds: serializer.fromJson<String>(json['fonds']),
      refDecaissement: serializer.fromJson<String?>(json['refDecaissement']),
      refPieceDepense: serializer.fromJson<String?>(json['refPieceDepense']),
      dctNumero: serializer.fromJson<String?>(json['dctNumero']),
      codeActivite: serializer.fromJson<String?>(json['codeActivite']),
      codeBudget: serializer.fromJson<String?>(json['codeBudget']),
      designation: serializer.fromJson<String>(json['designation']),
      beneficiaire: serializer.fromJson<String?>(json['beneficiaire']),
      controlePJId: serializer.fromJson<int?>(json['controlePJId']),
      unite: serializer.fromJson<String?>(json['unite']),
      nbJrMois: serializer.fromJson<double>(json['nbJrMois']),
      quantite: serializer.fromJson<double>(json['quantite']),
      frequence: serializer.fromJson<double>(json['frequence']),
      pu: serializer.fromJson<double>(json['pu']),
      observation: serializer.fromJson<String?>(json['observation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateEnregistrement': serializer.toJson<DateTime?>(dateEnregistrement),
      'datePieceComptable': serializer.toJson<DateTime?>(datePieceComptable),
      'periodeAutorisee': serializer.toJson<String?>(periodeAutorisee),
      'fonds': serializer.toJson<String>(fonds),
      'refDecaissement': serializer.toJson<String?>(refDecaissement),
      'refPieceDepense': serializer.toJson<String?>(refPieceDepense),
      'dctNumero': serializer.toJson<String?>(dctNumero),
      'codeActivite': serializer.toJson<String?>(codeActivite),
      'codeBudget': serializer.toJson<String?>(codeBudget),
      'designation': serializer.toJson<String>(designation),
      'beneficiaire': serializer.toJson<String?>(beneficiaire),
      'controlePJId': serializer.toJson<int?>(controlePJId),
      'unite': serializer.toJson<String?>(unite),
      'nbJrMois': serializer.toJson<double>(nbJrMois),
      'quantite': serializer.toJson<double>(quantite),
      'frequence': serializer.toJson<double>(frequence),
      'pu': serializer.toJson<double>(pu),
      'observation': serializer.toJson<String?>(observation),
    };
  }

  Depense copyWith({
    int? id,
    Value<DateTime?> dateEnregistrement = const Value.absent(),
    Value<DateTime?> datePieceComptable = const Value.absent(),
    Value<String?> periodeAutorisee = const Value.absent(),
    String? fonds,
    Value<String?> refDecaissement = const Value.absent(),
    Value<String?> refPieceDepense = const Value.absent(),
    Value<String?> dctNumero = const Value.absent(),
    Value<String?> codeActivite = const Value.absent(),
    Value<String?> codeBudget = const Value.absent(),
    String? designation,
    Value<String?> beneficiaire = const Value.absent(),
    Value<int?> controlePJId = const Value.absent(),
    Value<String?> unite = const Value.absent(),
    double? nbJrMois,
    double? quantite,
    double? frequence,
    double? pu,
    Value<String?> observation = const Value.absent(),
  }) => Depense(
    id: id ?? this.id,
    dateEnregistrement: dateEnregistrement.present
        ? dateEnregistrement.value
        : this.dateEnregistrement,
    datePieceComptable: datePieceComptable.present
        ? datePieceComptable.value
        : this.datePieceComptable,
    periodeAutorisee: periodeAutorisee.present
        ? periodeAutorisee.value
        : this.periodeAutorisee,
    fonds: fonds ?? this.fonds,
    refDecaissement: refDecaissement.present
        ? refDecaissement.value
        : this.refDecaissement,
    refPieceDepense: refPieceDepense.present
        ? refPieceDepense.value
        : this.refPieceDepense,
    dctNumero: dctNumero.present ? dctNumero.value : this.dctNumero,
    codeActivite: codeActivite.present ? codeActivite.value : this.codeActivite,
    codeBudget: codeBudget.present ? codeBudget.value : this.codeBudget,
    designation: designation ?? this.designation,
    beneficiaire: beneficiaire.present ? beneficiaire.value : this.beneficiaire,
    controlePJId: controlePJId.present ? controlePJId.value : this.controlePJId,
    unite: unite.present ? unite.value : this.unite,
    nbJrMois: nbJrMois ?? this.nbJrMois,
    quantite: quantite ?? this.quantite,
    frequence: frequence ?? this.frequence,
    pu: pu ?? this.pu,
    observation: observation.present ? observation.value : this.observation,
  );
  Depense copyWithCompanion(DepensesCompanion data) {
    return Depense(
      id: data.id.present ? data.id.value : this.id,
      dateEnregistrement: data.dateEnregistrement.present
          ? data.dateEnregistrement.value
          : this.dateEnregistrement,
      datePieceComptable: data.datePieceComptable.present
          ? data.datePieceComptable.value
          : this.datePieceComptable,
      periodeAutorisee: data.periodeAutorisee.present
          ? data.periodeAutorisee.value
          : this.periodeAutorisee,
      fonds: data.fonds.present ? data.fonds.value : this.fonds,
      refDecaissement: data.refDecaissement.present
          ? data.refDecaissement.value
          : this.refDecaissement,
      refPieceDepense: data.refPieceDepense.present
          ? data.refPieceDepense.value
          : this.refPieceDepense,
      dctNumero: data.dctNumero.present ? data.dctNumero.value : this.dctNumero,
      codeActivite: data.codeActivite.present
          ? data.codeActivite.value
          : this.codeActivite,
      codeBudget: data.codeBudget.present
          ? data.codeBudget.value
          : this.codeBudget,
      designation: data.designation.present
          ? data.designation.value
          : this.designation,
      beneficiaire: data.beneficiaire.present
          ? data.beneficiaire.value
          : this.beneficiaire,
      controlePJId: data.controlePJId.present
          ? data.controlePJId.value
          : this.controlePJId,
      unite: data.unite.present ? data.unite.value : this.unite,
      nbJrMois: data.nbJrMois.present ? data.nbJrMois.value : this.nbJrMois,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      frequence: data.frequence.present ? data.frequence.value : this.frequence,
      pu: data.pu.present ? data.pu.value : this.pu,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Depense(')
          ..write('id: $id, ')
          ..write('dateEnregistrement: $dateEnregistrement, ')
          ..write('datePieceComptable: $datePieceComptable, ')
          ..write('periodeAutorisee: $periodeAutorisee, ')
          ..write('fonds: $fonds, ')
          ..write('refDecaissement: $refDecaissement, ')
          ..write('refPieceDepense: $refPieceDepense, ')
          ..write('dctNumero: $dctNumero, ')
          ..write('codeActivite: $codeActivite, ')
          ..write('codeBudget: $codeBudget, ')
          ..write('designation: $designation, ')
          ..write('beneficiaire: $beneficiaire, ')
          ..write('controlePJId: $controlePJId, ')
          ..write('unite: $unite, ')
          ..write('nbJrMois: $nbJrMois, ')
          ..write('quantite: $quantite, ')
          ..write('frequence: $frequence, ')
          ..write('pu: $pu, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dateEnregistrement,
    datePieceComptable,
    periodeAutorisee,
    fonds,
    refDecaissement,
    refPieceDepense,
    dctNumero,
    codeActivite,
    codeBudget,
    designation,
    beneficiaire,
    controlePJId,
    unite,
    nbJrMois,
    quantite,
    frequence,
    pu,
    observation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Depense &&
          other.id == this.id &&
          other.dateEnregistrement == this.dateEnregistrement &&
          other.datePieceComptable == this.datePieceComptable &&
          other.periodeAutorisee == this.periodeAutorisee &&
          other.fonds == this.fonds &&
          other.refDecaissement == this.refDecaissement &&
          other.refPieceDepense == this.refPieceDepense &&
          other.dctNumero == this.dctNumero &&
          other.codeActivite == this.codeActivite &&
          other.codeBudget == this.codeBudget &&
          other.designation == this.designation &&
          other.beneficiaire == this.beneficiaire &&
          other.controlePJId == this.controlePJId &&
          other.unite == this.unite &&
          other.nbJrMois == this.nbJrMois &&
          other.quantite == this.quantite &&
          other.frequence == this.frequence &&
          other.pu == this.pu &&
          other.observation == this.observation);
}

class DepensesCompanion extends UpdateCompanion<Depense> {
  final Value<int> id;
  final Value<DateTime?> dateEnregistrement;
  final Value<DateTime?> datePieceComptable;
  final Value<String?> periodeAutorisee;
  final Value<String> fonds;
  final Value<String?> refDecaissement;
  final Value<String?> refPieceDepense;
  final Value<String?> dctNumero;
  final Value<String?> codeActivite;
  final Value<String?> codeBudget;
  final Value<String> designation;
  final Value<String?> beneficiaire;
  final Value<int?> controlePJId;
  final Value<String?> unite;
  final Value<double> nbJrMois;
  final Value<double> quantite;
  final Value<double> frequence;
  final Value<double> pu;
  final Value<String?> observation;
  const DepensesCompanion({
    this.id = const Value.absent(),
    this.dateEnregistrement = const Value.absent(),
    this.datePieceComptable = const Value.absent(),
    this.periodeAutorisee = const Value.absent(),
    this.fonds = const Value.absent(),
    this.refDecaissement = const Value.absent(),
    this.refPieceDepense = const Value.absent(),
    this.dctNumero = const Value.absent(),
    this.codeActivite = const Value.absent(),
    this.codeBudget = const Value.absent(),
    this.designation = const Value.absent(),
    this.beneficiaire = const Value.absent(),
    this.controlePJId = const Value.absent(),
    this.unite = const Value.absent(),
    this.nbJrMois = const Value.absent(),
    this.quantite = const Value.absent(),
    this.frequence = const Value.absent(),
    this.pu = const Value.absent(),
    this.observation = const Value.absent(),
  });
  DepensesCompanion.insert({
    this.id = const Value.absent(),
    this.dateEnregistrement = const Value.absent(),
    this.datePieceComptable = const Value.absent(),
    this.periodeAutorisee = const Value.absent(),
    this.fonds = const Value.absent(),
    this.refDecaissement = const Value.absent(),
    this.refPieceDepense = const Value.absent(),
    this.dctNumero = const Value.absent(),
    this.codeActivite = const Value.absent(),
    this.codeBudget = const Value.absent(),
    this.designation = const Value.absent(),
    this.beneficiaire = const Value.absent(),
    this.controlePJId = const Value.absent(),
    this.unite = const Value.absent(),
    this.nbJrMois = const Value.absent(),
    this.quantite = const Value.absent(),
    this.frequence = const Value.absent(),
    this.pu = const Value.absent(),
    this.observation = const Value.absent(),
  });
  static Insertable<Depense> custom({
    Expression<int>? id,
    Expression<DateTime>? dateEnregistrement,
    Expression<DateTime>? datePieceComptable,
    Expression<String>? periodeAutorisee,
    Expression<String>? fonds,
    Expression<String>? refDecaissement,
    Expression<String>? refPieceDepense,
    Expression<String>? dctNumero,
    Expression<String>? codeActivite,
    Expression<String>? codeBudget,
    Expression<String>? designation,
    Expression<String>? beneficiaire,
    Expression<int>? controlePJId,
    Expression<String>? unite,
    Expression<double>? nbJrMois,
    Expression<double>? quantite,
    Expression<double>? frequence,
    Expression<double>? pu,
    Expression<String>? observation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateEnregistrement != null) 'date_enregistrement': dateEnregistrement,
      if (datePieceComptable != null)
        'date_piece_comptable': datePieceComptable,
      if (periodeAutorisee != null) 'periode_autorisee': periodeAutorisee,
      if (fonds != null) 'fonds': fonds,
      if (refDecaissement != null) 'ref_decaissement': refDecaissement,
      if (refPieceDepense != null) 'ref_piece_depense': refPieceDepense,
      if (dctNumero != null) 'dct_numero': dctNumero,
      if (codeActivite != null) 'code_activite': codeActivite,
      if (codeBudget != null) 'code_budget': codeBudget,
      if (designation != null) 'designation': designation,
      if (beneficiaire != null) 'beneficiaire': beneficiaire,
      if (controlePJId != null) 'controle_p_j_id': controlePJId,
      if (unite != null) 'unite': unite,
      if (nbJrMois != null) 'nb_jr_mois': nbJrMois,
      if (quantite != null) 'quantite': quantite,
      if (frequence != null) 'frequence': frequence,
      if (pu != null) 'pu': pu,
      if (observation != null) 'observation': observation,
    });
  }

  DepensesCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? dateEnregistrement,
    Value<DateTime?>? datePieceComptable,
    Value<String?>? periodeAutorisee,
    Value<String>? fonds,
    Value<String?>? refDecaissement,
    Value<String?>? refPieceDepense,
    Value<String?>? dctNumero,
    Value<String?>? codeActivite,
    Value<String?>? codeBudget,
    Value<String>? designation,
    Value<String?>? beneficiaire,
    Value<int?>? controlePJId,
    Value<String?>? unite,
    Value<double>? nbJrMois,
    Value<double>? quantite,
    Value<double>? frequence,
    Value<double>? pu,
    Value<String?>? observation,
  }) {
    return DepensesCompanion(
      id: id ?? this.id,
      dateEnregistrement: dateEnregistrement ?? this.dateEnregistrement,
      datePieceComptable: datePieceComptable ?? this.datePieceComptable,
      periodeAutorisee: periodeAutorisee ?? this.periodeAutorisee,
      fonds: fonds ?? this.fonds,
      refDecaissement: refDecaissement ?? this.refDecaissement,
      refPieceDepense: refPieceDepense ?? this.refPieceDepense,
      dctNumero: dctNumero ?? this.dctNumero,
      codeActivite: codeActivite ?? this.codeActivite,
      codeBudget: codeBudget ?? this.codeBudget,
      designation: designation ?? this.designation,
      beneficiaire: beneficiaire ?? this.beneficiaire,
      controlePJId: controlePJId ?? this.controlePJId,
      unite: unite ?? this.unite,
      nbJrMois: nbJrMois ?? this.nbJrMois,
      quantite: quantite ?? this.quantite,
      frequence: frequence ?? this.frequence,
      pu: pu ?? this.pu,
      observation: observation ?? this.observation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateEnregistrement.present) {
      map['date_enregistrement'] = Variable<DateTime>(dateEnregistrement.value);
    }
    if (datePieceComptable.present) {
      map['date_piece_comptable'] = Variable<DateTime>(
        datePieceComptable.value,
      );
    }
    if (periodeAutorisee.present) {
      map['periode_autorisee'] = Variable<String>(periodeAutorisee.value);
    }
    if (fonds.present) {
      map['fonds'] = Variable<String>(fonds.value);
    }
    if (refDecaissement.present) {
      map['ref_decaissement'] = Variable<String>(refDecaissement.value);
    }
    if (refPieceDepense.present) {
      map['ref_piece_depense'] = Variable<String>(refPieceDepense.value);
    }
    if (dctNumero.present) {
      map['dct_numero'] = Variable<String>(dctNumero.value);
    }
    if (codeActivite.present) {
      map['code_activite'] = Variable<String>(codeActivite.value);
    }
    if (codeBudget.present) {
      map['code_budget'] = Variable<String>(codeBudget.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (beneficiaire.present) {
      map['beneficiaire'] = Variable<String>(beneficiaire.value);
    }
    if (controlePJId.present) {
      map['controle_p_j_id'] = Variable<int>(controlePJId.value);
    }
    if (unite.present) {
      map['unite'] = Variable<String>(unite.value);
    }
    if (nbJrMois.present) {
      map['nb_jr_mois'] = Variable<double>(nbJrMois.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (frequence.present) {
      map['frequence'] = Variable<double>(frequence.value);
    }
    if (pu.present) {
      map['pu'] = Variable<double>(pu.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepensesCompanion(')
          ..write('id: $id, ')
          ..write('dateEnregistrement: $dateEnregistrement, ')
          ..write('datePieceComptable: $datePieceComptable, ')
          ..write('periodeAutorisee: $periodeAutorisee, ')
          ..write('fonds: $fonds, ')
          ..write('refDecaissement: $refDecaissement, ')
          ..write('refPieceDepense: $refPieceDepense, ')
          ..write('dctNumero: $dctNumero, ')
          ..write('codeActivite: $codeActivite, ')
          ..write('codeBudget: $codeBudget, ')
          ..write('designation: $designation, ')
          ..write('beneficiaire: $beneficiaire, ')
          ..write('controlePJId: $controlePJId, ')
          ..write('unite: $unite, ')
          ..write('nbJrMois: $nbJrMois, ')
          ..write('quantite: $quantite, ')
          ..write('frequence: $frequence, ')
          ..write('pu: $pu, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }
}

class $BanqueOperationsTable extends BanqueOperations
    with TableInfo<$BanqueOperationsTable, BanqueOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BanqueOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refPieceMeta = const VerificationMeta(
    'refPiece',
  );
  @override
  late final GeneratedColumn<String> refPiece = GeneratedColumn<String>(
    'ref_piece',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Opération'),
  );
  static const VerificationMeta _refChequeMeta = const VerificationMeta(
    'refCheque',
  );
  @override
  late final GeneratedColumn<String> refCheque = GeneratedColumn<String>(
    'ref_cheque',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _recettesMeta = const VerificationMeta(
    'recettes',
  );
  @override
  late final GeneratedColumn<double> recettes = GeneratedColumn<double>(
    'recettes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _depensesMeta = const VerificationMeta(
    'depenses',
  );
  @override
  late final GeneratedColumn<double> depenses = GeneratedColumn<double>(
    'depenses',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bailleurMeta = const VerificationMeta(
    'bailleur',
  );
  @override
  late final GeneratedColumn<String> bailleur = GeneratedColumn<String>(
    'bailleur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beneficiaireMeta = const VerificationMeta(
    'beneficiaire',
  );
  @override
  late final GeneratedColumn<String> beneficiaire = GeneratedColumn<String>(
    'beneficiaire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    refPiece,
    type,
    refCheque,
    description,
    recettes,
    depenses,
    bailleur,
    beneficiaire,
    observation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'banque_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<BanqueOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('ref_piece')) {
      context.handle(
        _refPieceMeta,
        refPiece.isAcceptableOrUnknown(data['ref_piece']!, _refPieceMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('ref_cheque')) {
      context.handle(
        _refChequeMeta,
        refCheque.isAcceptableOrUnknown(data['ref_cheque']!, _refChequeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('recettes')) {
      context.handle(
        _recettesMeta,
        recettes.isAcceptableOrUnknown(data['recettes']!, _recettesMeta),
      );
    }
    if (data.containsKey('depenses')) {
      context.handle(
        _depensesMeta,
        depenses.isAcceptableOrUnknown(data['depenses']!, _depensesMeta),
      );
    }
    if (data.containsKey('bailleur')) {
      context.handle(
        _bailleurMeta,
        bailleur.isAcceptableOrUnknown(data['bailleur']!, _bailleurMeta),
      );
    }
    if (data.containsKey('beneficiaire')) {
      context.handle(
        _beneficiaireMeta,
        beneficiaire.isAcceptableOrUnknown(
          data['beneficiaire']!,
          _beneficiaireMeta,
        ),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BanqueOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BanqueOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      refPiece: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_piece'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      refCheque: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_cheque'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      recettes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recettes'],
      )!,
      depenses: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}depenses'],
      )!,
      bailleur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bailleur'],
      ),
      beneficiaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiaire'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
    );
  }

  @override
  $BanqueOperationsTable createAlias(String alias) {
    return $BanqueOperationsTable(attachedDatabase, alias);
  }
}

class BanqueOperation extends DataClass implements Insertable<BanqueOperation> {
  final int id;
  final DateTime date;
  final String? refPiece;
  final String type;
  final String? refCheque;
  final String description;
  final double recettes;
  final double depenses;
  final String? bailleur;
  final String? beneficiaire;
  final String? observation;
  const BanqueOperation({
    required this.id,
    required this.date,
    this.refPiece,
    required this.type,
    this.refCheque,
    required this.description,
    required this.recettes,
    required this.depenses,
    this.bailleur,
    this.beneficiaire,
    this.observation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || refPiece != null) {
      map['ref_piece'] = Variable<String>(refPiece);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || refCheque != null) {
      map['ref_cheque'] = Variable<String>(refCheque);
    }
    map['description'] = Variable<String>(description);
    map['recettes'] = Variable<double>(recettes);
    map['depenses'] = Variable<double>(depenses);
    if (!nullToAbsent || bailleur != null) {
      map['bailleur'] = Variable<String>(bailleur);
    }
    if (!nullToAbsent || beneficiaire != null) {
      map['beneficiaire'] = Variable<String>(beneficiaire);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    return map;
  }

  BanqueOperationsCompanion toCompanion(bool nullToAbsent) {
    return BanqueOperationsCompanion(
      id: Value(id),
      date: Value(date),
      refPiece: refPiece == null && nullToAbsent
          ? const Value.absent()
          : Value(refPiece),
      type: Value(type),
      refCheque: refCheque == null && nullToAbsent
          ? const Value.absent()
          : Value(refCheque),
      description: Value(description),
      recettes: Value(recettes),
      depenses: Value(depenses),
      bailleur: bailleur == null && nullToAbsent
          ? const Value.absent()
          : Value(bailleur),
      beneficiaire: beneficiaire == null && nullToAbsent
          ? const Value.absent()
          : Value(beneficiaire),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
    );
  }

  factory BanqueOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BanqueOperation(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      refPiece: serializer.fromJson<String?>(json['refPiece']),
      type: serializer.fromJson<String>(json['type']),
      refCheque: serializer.fromJson<String?>(json['refCheque']),
      description: serializer.fromJson<String>(json['description']),
      recettes: serializer.fromJson<double>(json['recettes']),
      depenses: serializer.fromJson<double>(json['depenses']),
      bailleur: serializer.fromJson<String?>(json['bailleur']),
      beneficiaire: serializer.fromJson<String?>(json['beneficiaire']),
      observation: serializer.fromJson<String?>(json['observation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'refPiece': serializer.toJson<String?>(refPiece),
      'type': serializer.toJson<String>(type),
      'refCheque': serializer.toJson<String?>(refCheque),
      'description': serializer.toJson<String>(description),
      'recettes': serializer.toJson<double>(recettes),
      'depenses': serializer.toJson<double>(depenses),
      'bailleur': serializer.toJson<String?>(bailleur),
      'beneficiaire': serializer.toJson<String?>(beneficiaire),
      'observation': serializer.toJson<String?>(observation),
    };
  }

  BanqueOperation copyWith({
    int? id,
    DateTime? date,
    Value<String?> refPiece = const Value.absent(),
    String? type,
    Value<String?> refCheque = const Value.absent(),
    String? description,
    double? recettes,
    double? depenses,
    Value<String?> bailleur = const Value.absent(),
    Value<String?> beneficiaire = const Value.absent(),
    Value<String?> observation = const Value.absent(),
  }) => BanqueOperation(
    id: id ?? this.id,
    date: date ?? this.date,
    refPiece: refPiece.present ? refPiece.value : this.refPiece,
    type: type ?? this.type,
    refCheque: refCheque.present ? refCheque.value : this.refCheque,
    description: description ?? this.description,
    recettes: recettes ?? this.recettes,
    depenses: depenses ?? this.depenses,
    bailleur: bailleur.present ? bailleur.value : this.bailleur,
    beneficiaire: beneficiaire.present ? beneficiaire.value : this.beneficiaire,
    observation: observation.present ? observation.value : this.observation,
  );
  BanqueOperation copyWithCompanion(BanqueOperationsCompanion data) {
    return BanqueOperation(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      refPiece: data.refPiece.present ? data.refPiece.value : this.refPiece,
      type: data.type.present ? data.type.value : this.type,
      refCheque: data.refCheque.present ? data.refCheque.value : this.refCheque,
      description: data.description.present
          ? data.description.value
          : this.description,
      recettes: data.recettes.present ? data.recettes.value : this.recettes,
      depenses: data.depenses.present ? data.depenses.value : this.depenses,
      bailleur: data.bailleur.present ? data.bailleur.value : this.bailleur,
      beneficiaire: data.beneficiaire.present
          ? data.beneficiaire.value
          : this.beneficiaire,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BanqueOperation(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('refPiece: $refPiece, ')
          ..write('type: $type, ')
          ..write('refCheque: $refCheque, ')
          ..write('description: $description, ')
          ..write('recettes: $recettes, ')
          ..write('depenses: $depenses, ')
          ..write('bailleur: $bailleur, ')
          ..write('beneficiaire: $beneficiaire, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    refPiece,
    type,
    refCheque,
    description,
    recettes,
    depenses,
    bailleur,
    beneficiaire,
    observation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BanqueOperation &&
          other.id == this.id &&
          other.date == this.date &&
          other.refPiece == this.refPiece &&
          other.type == this.type &&
          other.refCheque == this.refCheque &&
          other.description == this.description &&
          other.recettes == this.recettes &&
          other.depenses == this.depenses &&
          other.bailleur == this.bailleur &&
          other.beneficiaire == this.beneficiaire &&
          other.observation == this.observation);
}

class BanqueOperationsCompanion extends UpdateCompanion<BanqueOperation> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String?> refPiece;
  final Value<String> type;
  final Value<String?> refCheque;
  final Value<String> description;
  final Value<double> recettes;
  final Value<double> depenses;
  final Value<String?> bailleur;
  final Value<String?> beneficiaire;
  final Value<String?> observation;
  const BanqueOperationsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.refPiece = const Value.absent(),
    this.type = const Value.absent(),
    this.refCheque = const Value.absent(),
    this.description = const Value.absent(),
    this.recettes = const Value.absent(),
    this.depenses = const Value.absent(),
    this.bailleur = const Value.absent(),
    this.beneficiaire = const Value.absent(),
    this.observation = const Value.absent(),
  });
  BanqueOperationsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.refPiece = const Value.absent(),
    this.type = const Value.absent(),
    this.refCheque = const Value.absent(),
    this.description = const Value.absent(),
    this.recettes = const Value.absent(),
    this.depenses = const Value.absent(),
    this.bailleur = const Value.absent(),
    this.beneficiaire = const Value.absent(),
    this.observation = const Value.absent(),
  }) : date = Value(date);
  static Insertable<BanqueOperation> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? refPiece,
    Expression<String>? type,
    Expression<String>? refCheque,
    Expression<String>? description,
    Expression<double>? recettes,
    Expression<double>? depenses,
    Expression<String>? bailleur,
    Expression<String>? beneficiaire,
    Expression<String>? observation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (refPiece != null) 'ref_piece': refPiece,
      if (type != null) 'type': type,
      if (refCheque != null) 'ref_cheque': refCheque,
      if (description != null) 'description': description,
      if (recettes != null) 'recettes': recettes,
      if (depenses != null) 'depenses': depenses,
      if (bailleur != null) 'bailleur': bailleur,
      if (beneficiaire != null) 'beneficiaire': beneficiaire,
      if (observation != null) 'observation': observation,
    });
  }

  BanqueOperationsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String?>? refPiece,
    Value<String>? type,
    Value<String?>? refCheque,
    Value<String>? description,
    Value<double>? recettes,
    Value<double>? depenses,
    Value<String?>? bailleur,
    Value<String?>? beneficiaire,
    Value<String?>? observation,
  }) {
    return BanqueOperationsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      refPiece: refPiece ?? this.refPiece,
      type: type ?? this.type,
      refCheque: refCheque ?? this.refCheque,
      description: description ?? this.description,
      recettes: recettes ?? this.recettes,
      depenses: depenses ?? this.depenses,
      bailleur: bailleur ?? this.bailleur,
      beneficiaire: beneficiaire ?? this.beneficiaire,
      observation: observation ?? this.observation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (refPiece.present) {
      map['ref_piece'] = Variable<String>(refPiece.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (refCheque.present) {
      map['ref_cheque'] = Variable<String>(refCheque.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recettes.present) {
      map['recettes'] = Variable<double>(recettes.value);
    }
    if (depenses.present) {
      map['depenses'] = Variable<double>(depenses.value);
    }
    if (bailleur.present) {
      map['bailleur'] = Variable<String>(bailleur.value);
    }
    if (beneficiaire.present) {
      map['beneficiaire'] = Variable<String>(beneficiaire.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BanqueOperationsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('refPiece: $refPiece, ')
          ..write('type: $type, ')
          ..write('refCheque: $refCheque, ')
          ..write('description: $description, ')
          ..write('recettes: $recettes, ')
          ..write('depenses: $depenses, ')
          ..write('bailleur: $bailleur, ')
          ..write('beneficiaire: $beneficiaire, ')
          ..write('observation: $observation')
          ..write(')'))
        .toString();
  }
}

class $ReleveBancaireTable extends ReleveBancaire
    with TableInfo<$ReleveBancaireTable, ReleveBancaireLigne> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReleveBancaireTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _libelleMeta = const VerificationMeta(
    'libelle',
  );
  @override
  late final GeneratedColumn<String> libelle = GeneratedColumn<String>(
    'libelle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _debitMeta = const VerificationMeta('debit');
  @override
  late final GeneratedColumn<double> debit = GeneratedColumn<double>(
    'debit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  @override
  late final GeneratedColumn<double> credit = GeneratedColumn<double>(
    'credit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    reference,
    libelle,
    debit,
    credit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'releve_bancaire';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReleveBancaireLigne> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('libelle')) {
      context.handle(
        _libelleMeta,
        libelle.isAcceptableOrUnknown(data['libelle']!, _libelleMeta),
      );
    }
    if (data.containsKey('debit')) {
      context.handle(
        _debitMeta,
        debit.isAcceptableOrUnknown(data['debit']!, _debitMeta),
      );
    }
    if (data.containsKey('credit')) {
      context.handle(
        _creditMeta,
        credit.isAcceptableOrUnknown(data['credit']!, _creditMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReleveBancaireLigne map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReleveBancaireLigne(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      libelle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}libelle'],
      ),
      debit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debit'],
      )!,
      credit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit'],
      )!,
    );
  }

  @override
  $ReleveBancaireTable createAlias(String alias) {
    return $ReleveBancaireTable(attachedDatabase, alias);
  }
}

class ReleveBancaireLigne extends DataClass
    implements Insertable<ReleveBancaireLigne> {
  final int id;
  final DateTime? date;
  final String? reference;
  final String? libelle;
  final double debit;
  final double credit;
  const ReleveBancaireLigne({
    required this.id,
    this.date,
    this.reference,
    this.libelle,
    required this.debit,
    required this.credit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || libelle != null) {
      map['libelle'] = Variable<String>(libelle);
    }
    map['debit'] = Variable<double>(debit);
    map['credit'] = Variable<double>(credit);
    return map;
  }

  ReleveBancaireCompanion toCompanion(bool nullToAbsent) {
    return ReleveBancaireCompanion(
      id: Value(id),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      libelle: libelle == null && nullToAbsent
          ? const Value.absent()
          : Value(libelle),
      debit: Value(debit),
      credit: Value(credit),
    );
  }

  factory ReleveBancaireLigne.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReleveBancaireLigne(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime?>(json['date']),
      reference: serializer.fromJson<String?>(json['reference']),
      libelle: serializer.fromJson<String?>(json['libelle']),
      debit: serializer.fromJson<double>(json['debit']),
      credit: serializer.fromJson<double>(json['credit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime?>(date),
      'reference': serializer.toJson<String?>(reference),
      'libelle': serializer.toJson<String?>(libelle),
      'debit': serializer.toJson<double>(debit),
      'credit': serializer.toJson<double>(credit),
    };
  }

  ReleveBancaireLigne copyWith({
    int? id,
    Value<DateTime?> date = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> libelle = const Value.absent(),
    double? debit,
    double? credit,
  }) => ReleveBancaireLigne(
    id: id ?? this.id,
    date: date.present ? date.value : this.date,
    reference: reference.present ? reference.value : this.reference,
    libelle: libelle.present ? libelle.value : this.libelle,
    debit: debit ?? this.debit,
    credit: credit ?? this.credit,
  );
  ReleveBancaireLigne copyWithCompanion(ReleveBancaireCompanion data) {
    return ReleveBancaireLigne(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      reference: data.reference.present ? data.reference.value : this.reference,
      libelle: data.libelle.present ? data.libelle.value : this.libelle,
      debit: data.debit.present ? data.debit.value : this.debit,
      credit: data.credit.present ? data.credit.value : this.credit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReleveBancaireLigne(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('reference: $reference, ')
          ..write('libelle: $libelle, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, reference, libelle, debit, credit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReleveBancaireLigne &&
          other.id == this.id &&
          other.date == this.date &&
          other.reference == this.reference &&
          other.libelle == this.libelle &&
          other.debit == this.debit &&
          other.credit == this.credit);
}

class ReleveBancaireCompanion extends UpdateCompanion<ReleveBancaireLigne> {
  final Value<int> id;
  final Value<DateTime?> date;
  final Value<String?> reference;
  final Value<String?> libelle;
  final Value<double> debit;
  final Value<double> credit;
  const ReleveBancaireCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.reference = const Value.absent(),
    this.libelle = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
  });
  ReleveBancaireCompanion.insert({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.reference = const Value.absent(),
    this.libelle = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
  });
  static Insertable<ReleveBancaireLigne> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? reference,
    Expression<String>? libelle,
    Expression<double>? debit,
    Expression<double>? credit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (reference != null) 'reference': reference,
      if (libelle != null) 'libelle': libelle,
      if (debit != null) 'debit': debit,
      if (credit != null) 'credit': credit,
    });
  }

  ReleveBancaireCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? date,
    Value<String?>? reference,
    Value<String?>? libelle,
    Value<double>? debit,
    Value<double>? credit,
  }) {
    return ReleveBancaireCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      libelle: libelle ?? this.libelle,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (libelle.present) {
      map['libelle'] = Variable<String>(libelle.value);
    }
    if (debit.present) {
      map['debit'] = Variable<double>(debit.value);
    }
    if (credit.present) {
      map['credit'] = Variable<double>(credit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReleveBancaireCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('reference: $reference, ')
          ..write('libelle: $libelle, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit')
          ..write(')'))
        .toString();
  }
}

class $UtilisateursTable extends Utilisateurs
    with TableInfo<$UtilisateursTable, Utilisateur> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UtilisateursTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _identifiantMeta = const VerificationMeta(
    'identifiant',
  );
  @override
  late final GeneratedColumn<String> identifiant = GeneratedColumn<String>(
    'identifiant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GESTIONNAIRE'),
  );
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
    'actif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("actif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _motDePasseHashMeta = const VerificationMeta(
    'motDePasseHash',
  );
  @override
  late final GeneratedColumn<String> motDePasseHash = GeneratedColumn<String>(
    'mot_de_passe_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prenomUtilisateurMeta = const VerificationMeta(
    'prenomUtilisateur',
  );
  @override
  late final GeneratedColumn<String> prenomUtilisateur =
      GeneratedColumn<String>(
        'prenom_utilisateur',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fonctionMeta = const VerificationMeta(
    'fonction',
  );
  @override
  late final GeneratedColumn<String> fonction = GeneratedColumn<String>(
    'fonction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telephoneMeta = const VerificationMeta(
    'telephone',
  );
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
    'telephone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<String> photo = GeneratedColumn<String>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreation = GeneratedColumn<DateTime>(
    'date_creation',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _derniereConnexionMeta = const VerificationMeta(
    'derniereConnexion',
  );
  @override
  late final GeneratedColumn<DateTime> derniereConnexion =
      GeneratedColumn<DateTime>(
        'derniere_connexion',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    identifiant,
    nom,
    role,
    actif,
    motDePasseHash,
    prenomUtilisateur,
    fonction,
    email,
    telephone,
    photo,
    dateCreation,
    derniereConnexion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'utilisateurs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Utilisateur> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('identifiant')) {
      context.handle(
        _identifiantMeta,
        identifiant.isAcceptableOrUnknown(
          data['identifiant']!,
          _identifiantMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identifiantMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('actif')) {
      context.handle(
        _actifMeta,
        actif.isAcceptableOrUnknown(data['actif']!, _actifMeta),
      );
    }
    if (data.containsKey('mot_de_passe_hash')) {
      context.handle(
        _motDePasseHashMeta,
        motDePasseHash.isAcceptableOrUnknown(
          data['mot_de_passe_hash']!,
          _motDePasseHashMeta,
        ),
      );
    }
    if (data.containsKey('prenom_utilisateur')) {
      context.handle(
        _prenomUtilisateurMeta,
        prenomUtilisateur.isAcceptableOrUnknown(
          data['prenom_utilisateur']!,
          _prenomUtilisateurMeta,
        ),
      );
    }
    if (data.containsKey('fonction')) {
      context.handle(
        _fonctionMeta,
        fonction.isAcceptableOrUnknown(data['fonction']!, _fonctionMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('telephone')) {
      context.handle(
        _telephoneMeta,
        telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta),
      );
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    if (data.containsKey('derniere_connexion')) {
      context.handle(
        _derniereConnexionMeta,
        derniereConnexion.isAcceptableOrUnknown(
          data['derniere_connexion']!,
          _derniereConnexionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Utilisateur map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Utilisateur(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      identifiant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identifiant'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      actif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}actif'],
      )!,
      motDePasseHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mot_de_passe_hash'],
      ),
      prenomUtilisateur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prenom_utilisateur'],
      ),
      fonction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fonction'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      telephone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telephone'],
      ),
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo'],
      ),
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_creation'],
      ),
      derniereConnexion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}derniere_connexion'],
      ),
    );
  }

  @override
  $UtilisateursTable createAlias(String alias) {
    return $UtilisateursTable(attachedDatabase, alias);
  }
}

class Utilisateur extends DataClass implements Insertable<Utilisateur> {
  final int id;
  final String identifiant;
  final String nom;
  final String role;
  final bool actif;
  final String? motDePasseHash;
  final String? prenomUtilisateur;
  final String? fonction;
  final String? email;
  final String? telephone;

  /// Photo de profil encodée en base64 (data URI), facultative.
  final String? photo;
  final DateTime? dateCreation;
  final DateTime? derniereConnexion;
  const Utilisateur({
    required this.id,
    required this.identifiant,
    required this.nom,
    required this.role,
    required this.actif,
    this.motDePasseHash,
    this.prenomUtilisateur,
    this.fonction,
    this.email,
    this.telephone,
    this.photo,
    this.dateCreation,
    this.derniereConnexion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['identifiant'] = Variable<String>(identifiant);
    map['nom'] = Variable<String>(nom);
    map['role'] = Variable<String>(role);
    map['actif'] = Variable<bool>(actif);
    if (!nullToAbsent || motDePasseHash != null) {
      map['mot_de_passe_hash'] = Variable<String>(motDePasseHash);
    }
    if (!nullToAbsent || prenomUtilisateur != null) {
      map['prenom_utilisateur'] = Variable<String>(prenomUtilisateur);
    }
    if (!nullToAbsent || fonction != null) {
      map['fonction'] = Variable<String>(fonction);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || telephone != null) {
      map['telephone'] = Variable<String>(telephone);
    }
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<String>(photo);
    }
    if (!nullToAbsent || dateCreation != null) {
      map['date_creation'] = Variable<DateTime>(dateCreation);
    }
    if (!nullToAbsent || derniereConnexion != null) {
      map['derniere_connexion'] = Variable<DateTime>(derniereConnexion);
    }
    return map;
  }

  UtilisateursCompanion toCompanion(bool nullToAbsent) {
    return UtilisateursCompanion(
      id: Value(id),
      identifiant: Value(identifiant),
      nom: Value(nom),
      role: Value(role),
      actif: Value(actif),
      motDePasseHash: motDePasseHash == null && nullToAbsent
          ? const Value.absent()
          : Value(motDePasseHash),
      prenomUtilisateur: prenomUtilisateur == null && nullToAbsent
          ? const Value.absent()
          : Value(prenomUtilisateur),
      fonction: fonction == null && nullToAbsent
          ? const Value.absent()
          : Value(fonction),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      telephone: telephone == null && nullToAbsent
          ? const Value.absent()
          : Value(telephone),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
      dateCreation: dateCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreation),
      derniereConnexion: derniereConnexion == null && nullToAbsent
          ? const Value.absent()
          : Value(derniereConnexion),
    );
  }

  factory Utilisateur.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Utilisateur(
      id: serializer.fromJson<int>(json['id']),
      identifiant: serializer.fromJson<String>(json['identifiant']),
      nom: serializer.fromJson<String>(json['nom']),
      role: serializer.fromJson<String>(json['role']),
      actif: serializer.fromJson<bool>(json['actif']),
      motDePasseHash: serializer.fromJson<String?>(json['motDePasseHash']),
      prenomUtilisateur: serializer.fromJson<String?>(
        json['prenomUtilisateur'],
      ),
      fonction: serializer.fromJson<String?>(json['fonction']),
      email: serializer.fromJson<String?>(json['email']),
      telephone: serializer.fromJson<String?>(json['telephone']),
      photo: serializer.fromJson<String?>(json['photo']),
      dateCreation: serializer.fromJson<DateTime?>(json['dateCreation']),
      derniereConnexion: serializer.fromJson<DateTime?>(
        json['derniereConnexion'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'identifiant': serializer.toJson<String>(identifiant),
      'nom': serializer.toJson<String>(nom),
      'role': serializer.toJson<String>(role),
      'actif': serializer.toJson<bool>(actif),
      'motDePasseHash': serializer.toJson<String?>(motDePasseHash),
      'prenomUtilisateur': serializer.toJson<String?>(prenomUtilisateur),
      'fonction': serializer.toJson<String?>(fonction),
      'email': serializer.toJson<String?>(email),
      'telephone': serializer.toJson<String?>(telephone),
      'photo': serializer.toJson<String?>(photo),
      'dateCreation': serializer.toJson<DateTime?>(dateCreation),
      'derniereConnexion': serializer.toJson<DateTime?>(derniereConnexion),
    };
  }

  Utilisateur copyWith({
    int? id,
    String? identifiant,
    String? nom,
    String? role,
    bool? actif,
    Value<String?> motDePasseHash = const Value.absent(),
    Value<String?> prenomUtilisateur = const Value.absent(),
    Value<String?> fonction = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> telephone = const Value.absent(),
    Value<String?> photo = const Value.absent(),
    Value<DateTime?> dateCreation = const Value.absent(),
    Value<DateTime?> derniereConnexion = const Value.absent(),
  }) => Utilisateur(
    id: id ?? this.id,
    identifiant: identifiant ?? this.identifiant,
    nom: nom ?? this.nom,
    role: role ?? this.role,
    actif: actif ?? this.actif,
    motDePasseHash: motDePasseHash.present
        ? motDePasseHash.value
        : this.motDePasseHash,
    prenomUtilisateur: prenomUtilisateur.present
        ? prenomUtilisateur.value
        : this.prenomUtilisateur,
    fonction: fonction.present ? fonction.value : this.fonction,
    email: email.present ? email.value : this.email,
    telephone: telephone.present ? telephone.value : this.telephone,
    photo: photo.present ? photo.value : this.photo,
    dateCreation: dateCreation.present ? dateCreation.value : this.dateCreation,
    derniereConnexion: derniereConnexion.present
        ? derniereConnexion.value
        : this.derniereConnexion,
  );
  Utilisateur copyWithCompanion(UtilisateursCompanion data) {
    return Utilisateur(
      id: data.id.present ? data.id.value : this.id,
      identifiant: data.identifiant.present
          ? data.identifiant.value
          : this.identifiant,
      nom: data.nom.present ? data.nom.value : this.nom,
      role: data.role.present ? data.role.value : this.role,
      actif: data.actif.present ? data.actif.value : this.actif,
      motDePasseHash: data.motDePasseHash.present
          ? data.motDePasseHash.value
          : this.motDePasseHash,
      prenomUtilisateur: data.prenomUtilisateur.present
          ? data.prenomUtilisateur.value
          : this.prenomUtilisateur,
      fonction: data.fonction.present ? data.fonction.value : this.fonction,
      email: data.email.present ? data.email.value : this.email,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      photo: data.photo.present ? data.photo.value : this.photo,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
      derniereConnexion: data.derniereConnexion.present
          ? data.derniereConnexion.value
          : this.derniereConnexion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Utilisateur(')
          ..write('id: $id, ')
          ..write('identifiant: $identifiant, ')
          ..write('nom: $nom, ')
          ..write('role: $role, ')
          ..write('actif: $actif, ')
          ..write('motDePasseHash: $motDePasseHash, ')
          ..write('prenomUtilisateur: $prenomUtilisateur, ')
          ..write('fonction: $fonction, ')
          ..write('email: $email, ')
          ..write('telephone: $telephone, ')
          ..write('photo: $photo, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('derniereConnexion: $derniereConnexion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    identifiant,
    nom,
    role,
    actif,
    motDePasseHash,
    prenomUtilisateur,
    fonction,
    email,
    telephone,
    photo,
    dateCreation,
    derniereConnexion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Utilisateur &&
          other.id == this.id &&
          other.identifiant == this.identifiant &&
          other.nom == this.nom &&
          other.role == this.role &&
          other.actif == this.actif &&
          other.motDePasseHash == this.motDePasseHash &&
          other.prenomUtilisateur == this.prenomUtilisateur &&
          other.fonction == this.fonction &&
          other.email == this.email &&
          other.telephone == this.telephone &&
          other.photo == this.photo &&
          other.dateCreation == this.dateCreation &&
          other.derniereConnexion == this.derniereConnexion);
}

class UtilisateursCompanion extends UpdateCompanion<Utilisateur> {
  final Value<int> id;
  final Value<String> identifiant;
  final Value<String> nom;
  final Value<String> role;
  final Value<bool> actif;
  final Value<String?> motDePasseHash;
  final Value<String?> prenomUtilisateur;
  final Value<String?> fonction;
  final Value<String?> email;
  final Value<String?> telephone;
  final Value<String?> photo;
  final Value<DateTime?> dateCreation;
  final Value<DateTime?> derniereConnexion;
  const UtilisateursCompanion({
    this.id = const Value.absent(),
    this.identifiant = const Value.absent(),
    this.nom = const Value.absent(),
    this.role = const Value.absent(),
    this.actif = const Value.absent(),
    this.motDePasseHash = const Value.absent(),
    this.prenomUtilisateur = const Value.absent(),
    this.fonction = const Value.absent(),
    this.email = const Value.absent(),
    this.telephone = const Value.absent(),
    this.photo = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.derniereConnexion = const Value.absent(),
  });
  UtilisateursCompanion.insert({
    this.id = const Value.absent(),
    required String identifiant,
    required String nom,
    this.role = const Value.absent(),
    this.actif = const Value.absent(),
    this.motDePasseHash = const Value.absent(),
    this.prenomUtilisateur = const Value.absent(),
    this.fonction = const Value.absent(),
    this.email = const Value.absent(),
    this.telephone = const Value.absent(),
    this.photo = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.derniereConnexion = const Value.absent(),
  }) : identifiant = Value(identifiant),
       nom = Value(nom);
  static Insertable<Utilisateur> custom({
    Expression<int>? id,
    Expression<String>? identifiant,
    Expression<String>? nom,
    Expression<String>? role,
    Expression<bool>? actif,
    Expression<String>? motDePasseHash,
    Expression<String>? prenomUtilisateur,
    Expression<String>? fonction,
    Expression<String>? email,
    Expression<String>? telephone,
    Expression<String>? photo,
    Expression<DateTime>? dateCreation,
    Expression<DateTime>? derniereConnexion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (identifiant != null) 'identifiant': identifiant,
      if (nom != null) 'nom': nom,
      if (role != null) 'role': role,
      if (actif != null) 'actif': actif,
      if (motDePasseHash != null) 'mot_de_passe_hash': motDePasseHash,
      if (prenomUtilisateur != null) 'prenom_utilisateur': prenomUtilisateur,
      if (fonction != null) 'fonction': fonction,
      if (email != null) 'email': email,
      if (telephone != null) 'telephone': telephone,
      if (photo != null) 'photo': photo,
      if (dateCreation != null) 'date_creation': dateCreation,
      if (derniereConnexion != null) 'derniere_connexion': derniereConnexion,
    });
  }

  UtilisateursCompanion copyWith({
    Value<int>? id,
    Value<String>? identifiant,
    Value<String>? nom,
    Value<String>? role,
    Value<bool>? actif,
    Value<String?>? motDePasseHash,
    Value<String?>? prenomUtilisateur,
    Value<String?>? fonction,
    Value<String?>? email,
    Value<String?>? telephone,
    Value<String?>? photo,
    Value<DateTime?>? dateCreation,
    Value<DateTime?>? derniereConnexion,
  }) {
    return UtilisateursCompanion(
      id: id ?? this.id,
      identifiant: identifiant ?? this.identifiant,
      nom: nom ?? this.nom,
      role: role ?? this.role,
      actif: actif ?? this.actif,
      motDePasseHash: motDePasseHash ?? this.motDePasseHash,
      prenomUtilisateur: prenomUtilisateur ?? this.prenomUtilisateur,
      fonction: fonction ?? this.fonction,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      photo: photo ?? this.photo,
      dateCreation: dateCreation ?? this.dateCreation,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (identifiant.present) {
      map['identifiant'] = Variable<String>(identifiant.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (motDePasseHash.present) {
      map['mot_de_passe_hash'] = Variable<String>(motDePasseHash.value);
    }
    if (prenomUtilisateur.present) {
      map['prenom_utilisateur'] = Variable<String>(prenomUtilisateur.value);
    }
    if (fonction.present) {
      map['fonction'] = Variable<String>(fonction.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (photo.present) {
      map['photo'] = Variable<String>(photo.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<DateTime>(dateCreation.value);
    }
    if (derniereConnexion.present) {
      map['derniere_connexion'] = Variable<DateTime>(derniereConnexion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtilisateursCompanion(')
          ..write('id: $id, ')
          ..write('identifiant: $identifiant, ')
          ..write('nom: $nom, ')
          ..write('role: $role, ')
          ..write('actif: $actif, ')
          ..write('motDePasseHash: $motDePasseHash, ')
          ..write('prenomUtilisateur: $prenomUtilisateur, ')
          ..write('fonction: $fonction, ')
          ..write('email: $email, ')
          ..write('telephone: $telephone, ')
          ..write('photo: $photo, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('derniereConnexion: $derniereConnexion')
          ..write(')'))
        .toString();
  }
}

class $JournalAuditTable extends JournalAudit
    with TableInfo<$JournalAuditTable, JournalAuditEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalAuditTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateHeureMeta = const VerificationMeta(
    'dateHeure',
  );
  @override
  late final GeneratedColumn<DateTime> dateHeure = GeneratedColumn<DateTime>(
    'date_heure',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _utilisateurMeta = const VerificationMeta(
    'utilisateur',
  );
  @override
  late final GeneratedColumn<String> utilisateur = GeneratedColumn<String>(
    'utilisateur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('systeme'),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entiteMeta = const VerificationMeta('entite');
  @override
  late final GeneratedColumn<String> entite = GeneratedColumn<String>(
    'entite',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entiteIdMeta = const VerificationMeta(
    'entiteId',
  );
  @override
  late final GeneratedColumn<String> entiteId = GeneratedColumn<String>(
    'entite_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _champMeta = const VerificationMeta('champ');
  @override
  late final GeneratedColumn<String> champ = GeneratedColumn<String>(
    'champ',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ancienneValeurMeta = const VerificationMeta(
    'ancienneValeur',
  );
  @override
  late final GeneratedColumn<String> ancienneValeur = GeneratedColumn<String>(
    'ancienne_valeur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nouvelleValeurMeta = const VerificationMeta(
    'nouvelleValeur',
  );
  @override
  late final GeneratedColumn<String> nouvelleValeur = GeneratedColumn<String>(
    'nouvelle_valeur',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dateHeure,
    utilisateur,
    action,
    entite,
    entiteId,
    champ,
    ancienneValeur,
    nouvelleValeur,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_audit';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalAuditEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_heure')) {
      context.handle(
        _dateHeureMeta,
        dateHeure.isAcceptableOrUnknown(data['date_heure']!, _dateHeureMeta),
      );
    }
    if (data.containsKey('utilisateur')) {
      context.handle(
        _utilisateurMeta,
        utilisateur.isAcceptableOrUnknown(
          data['utilisateur']!,
          _utilisateurMeta,
        ),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entite')) {
      context.handle(
        _entiteMeta,
        entite.isAcceptableOrUnknown(data['entite']!, _entiteMeta),
      );
    } else if (isInserting) {
      context.missing(_entiteMeta);
    }
    if (data.containsKey('entite_id')) {
      context.handle(
        _entiteIdMeta,
        entiteId.isAcceptableOrUnknown(data['entite_id']!, _entiteIdMeta),
      );
    }
    if (data.containsKey('champ')) {
      context.handle(
        _champMeta,
        champ.isAcceptableOrUnknown(data['champ']!, _champMeta),
      );
    }
    if (data.containsKey('ancienne_valeur')) {
      context.handle(
        _ancienneValeurMeta,
        ancienneValeur.isAcceptableOrUnknown(
          data['ancienne_valeur']!,
          _ancienneValeurMeta,
        ),
      );
    }
    if (data.containsKey('nouvelle_valeur')) {
      context.handle(
        _nouvelleValeurMeta,
        nouvelleValeur.isAcceptableOrUnknown(
          data['nouvelle_valeur']!,
          _nouvelleValeurMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalAuditEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalAuditEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dateHeure: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_heure'],
      )!,
      utilisateur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utilisateur'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entite'],
      )!,
      entiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entite_id'],
      ),
      champ: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}champ'],
      ),
      ancienneValeur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ancienne_valeur'],
      ),
      nouvelleValeur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nouvelle_valeur'],
      ),
    );
  }

  @override
  $JournalAuditTable createAlias(String alias) {
    return $JournalAuditTable(attachedDatabase, alias);
  }
}

class JournalAuditEntry extends DataClass
    implements Insertable<JournalAuditEntry> {
  final int id;
  final DateTime dateHeure;
  final String utilisateur;
  final String action;
  final String entite;
  final String? entiteId;
  final String? champ;
  final String? ancienneValeur;
  final String? nouvelleValeur;
  const JournalAuditEntry({
    required this.id,
    required this.dateHeure,
    required this.utilisateur,
    required this.action,
    required this.entite,
    this.entiteId,
    this.champ,
    this.ancienneValeur,
    this.nouvelleValeur,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_heure'] = Variable<DateTime>(dateHeure);
    map['utilisateur'] = Variable<String>(utilisateur);
    map['action'] = Variable<String>(action);
    map['entite'] = Variable<String>(entite);
    if (!nullToAbsent || entiteId != null) {
      map['entite_id'] = Variable<String>(entiteId);
    }
    if (!nullToAbsent || champ != null) {
      map['champ'] = Variable<String>(champ);
    }
    if (!nullToAbsent || ancienneValeur != null) {
      map['ancienne_valeur'] = Variable<String>(ancienneValeur);
    }
    if (!nullToAbsent || nouvelleValeur != null) {
      map['nouvelle_valeur'] = Variable<String>(nouvelleValeur);
    }
    return map;
  }

  JournalAuditCompanion toCompanion(bool nullToAbsent) {
    return JournalAuditCompanion(
      id: Value(id),
      dateHeure: Value(dateHeure),
      utilisateur: Value(utilisateur),
      action: Value(action),
      entite: Value(entite),
      entiteId: entiteId == null && nullToAbsent
          ? const Value.absent()
          : Value(entiteId),
      champ: champ == null && nullToAbsent
          ? const Value.absent()
          : Value(champ),
      ancienneValeur: ancienneValeur == null && nullToAbsent
          ? const Value.absent()
          : Value(ancienneValeur),
      nouvelleValeur: nouvelleValeur == null && nullToAbsent
          ? const Value.absent()
          : Value(nouvelleValeur),
    );
  }

  factory JournalAuditEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalAuditEntry(
      id: serializer.fromJson<int>(json['id']),
      dateHeure: serializer.fromJson<DateTime>(json['dateHeure']),
      utilisateur: serializer.fromJson<String>(json['utilisateur']),
      action: serializer.fromJson<String>(json['action']),
      entite: serializer.fromJson<String>(json['entite']),
      entiteId: serializer.fromJson<String?>(json['entiteId']),
      champ: serializer.fromJson<String?>(json['champ']),
      ancienneValeur: serializer.fromJson<String?>(json['ancienneValeur']),
      nouvelleValeur: serializer.fromJson<String?>(json['nouvelleValeur']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateHeure': serializer.toJson<DateTime>(dateHeure),
      'utilisateur': serializer.toJson<String>(utilisateur),
      'action': serializer.toJson<String>(action),
      'entite': serializer.toJson<String>(entite),
      'entiteId': serializer.toJson<String?>(entiteId),
      'champ': serializer.toJson<String?>(champ),
      'ancienneValeur': serializer.toJson<String?>(ancienneValeur),
      'nouvelleValeur': serializer.toJson<String?>(nouvelleValeur),
    };
  }

  JournalAuditEntry copyWith({
    int? id,
    DateTime? dateHeure,
    String? utilisateur,
    String? action,
    String? entite,
    Value<String?> entiteId = const Value.absent(),
    Value<String?> champ = const Value.absent(),
    Value<String?> ancienneValeur = const Value.absent(),
    Value<String?> nouvelleValeur = const Value.absent(),
  }) => JournalAuditEntry(
    id: id ?? this.id,
    dateHeure: dateHeure ?? this.dateHeure,
    utilisateur: utilisateur ?? this.utilisateur,
    action: action ?? this.action,
    entite: entite ?? this.entite,
    entiteId: entiteId.present ? entiteId.value : this.entiteId,
    champ: champ.present ? champ.value : this.champ,
    ancienneValeur: ancienneValeur.present
        ? ancienneValeur.value
        : this.ancienneValeur,
    nouvelleValeur: nouvelleValeur.present
        ? nouvelleValeur.value
        : this.nouvelleValeur,
  );
  JournalAuditEntry copyWithCompanion(JournalAuditCompanion data) {
    return JournalAuditEntry(
      id: data.id.present ? data.id.value : this.id,
      dateHeure: data.dateHeure.present ? data.dateHeure.value : this.dateHeure,
      utilisateur: data.utilisateur.present
          ? data.utilisateur.value
          : this.utilisateur,
      action: data.action.present ? data.action.value : this.action,
      entite: data.entite.present ? data.entite.value : this.entite,
      entiteId: data.entiteId.present ? data.entiteId.value : this.entiteId,
      champ: data.champ.present ? data.champ.value : this.champ,
      ancienneValeur: data.ancienneValeur.present
          ? data.ancienneValeur.value
          : this.ancienneValeur,
      nouvelleValeur: data.nouvelleValeur.present
          ? data.nouvelleValeur.value
          : this.nouvelleValeur,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalAuditEntry(')
          ..write('id: $id, ')
          ..write('dateHeure: $dateHeure, ')
          ..write('utilisateur: $utilisateur, ')
          ..write('action: $action, ')
          ..write('entite: $entite, ')
          ..write('entiteId: $entiteId, ')
          ..write('champ: $champ, ')
          ..write('ancienneValeur: $ancienneValeur, ')
          ..write('nouvelleValeur: $nouvelleValeur')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dateHeure,
    utilisateur,
    action,
    entite,
    entiteId,
    champ,
    ancienneValeur,
    nouvelleValeur,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalAuditEntry &&
          other.id == this.id &&
          other.dateHeure == this.dateHeure &&
          other.utilisateur == this.utilisateur &&
          other.action == this.action &&
          other.entite == this.entite &&
          other.entiteId == this.entiteId &&
          other.champ == this.champ &&
          other.ancienneValeur == this.ancienneValeur &&
          other.nouvelleValeur == this.nouvelleValeur);
}

class JournalAuditCompanion extends UpdateCompanion<JournalAuditEntry> {
  final Value<int> id;
  final Value<DateTime> dateHeure;
  final Value<String> utilisateur;
  final Value<String> action;
  final Value<String> entite;
  final Value<String?> entiteId;
  final Value<String?> champ;
  final Value<String?> ancienneValeur;
  final Value<String?> nouvelleValeur;
  const JournalAuditCompanion({
    this.id = const Value.absent(),
    this.dateHeure = const Value.absent(),
    this.utilisateur = const Value.absent(),
    this.action = const Value.absent(),
    this.entite = const Value.absent(),
    this.entiteId = const Value.absent(),
    this.champ = const Value.absent(),
    this.ancienneValeur = const Value.absent(),
    this.nouvelleValeur = const Value.absent(),
  });
  JournalAuditCompanion.insert({
    this.id = const Value.absent(),
    this.dateHeure = const Value.absent(),
    this.utilisateur = const Value.absent(),
    required String action,
    required String entite,
    this.entiteId = const Value.absent(),
    this.champ = const Value.absent(),
    this.ancienneValeur = const Value.absent(),
    this.nouvelleValeur = const Value.absent(),
  }) : action = Value(action),
       entite = Value(entite);
  static Insertable<JournalAuditEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? dateHeure,
    Expression<String>? utilisateur,
    Expression<String>? action,
    Expression<String>? entite,
    Expression<String>? entiteId,
    Expression<String>? champ,
    Expression<String>? ancienneValeur,
    Expression<String>? nouvelleValeur,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateHeure != null) 'date_heure': dateHeure,
      if (utilisateur != null) 'utilisateur': utilisateur,
      if (action != null) 'action': action,
      if (entite != null) 'entite': entite,
      if (entiteId != null) 'entite_id': entiteId,
      if (champ != null) 'champ': champ,
      if (ancienneValeur != null) 'ancienne_valeur': ancienneValeur,
      if (nouvelleValeur != null) 'nouvelle_valeur': nouvelleValeur,
    });
  }

  JournalAuditCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? dateHeure,
    Value<String>? utilisateur,
    Value<String>? action,
    Value<String>? entite,
    Value<String?>? entiteId,
    Value<String?>? champ,
    Value<String?>? ancienneValeur,
    Value<String?>? nouvelleValeur,
  }) {
    return JournalAuditCompanion(
      id: id ?? this.id,
      dateHeure: dateHeure ?? this.dateHeure,
      utilisateur: utilisateur ?? this.utilisateur,
      action: action ?? this.action,
      entite: entite ?? this.entite,
      entiteId: entiteId ?? this.entiteId,
      champ: champ ?? this.champ,
      ancienneValeur: ancienneValeur ?? this.ancienneValeur,
      nouvelleValeur: nouvelleValeur ?? this.nouvelleValeur,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateHeure.present) {
      map['date_heure'] = Variable<DateTime>(dateHeure.value);
    }
    if (utilisateur.present) {
      map['utilisateur'] = Variable<String>(utilisateur.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entite.present) {
      map['entite'] = Variable<String>(entite.value);
    }
    if (entiteId.present) {
      map['entite_id'] = Variable<String>(entiteId.value);
    }
    if (champ.present) {
      map['champ'] = Variable<String>(champ.value);
    }
    if (ancienneValeur.present) {
      map['ancienne_valeur'] = Variable<String>(ancienneValeur.value);
    }
    if (nouvelleValeur.present) {
      map['nouvelle_valeur'] = Variable<String>(nouvelleValeur.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalAuditCompanion(')
          ..write('id: $id, ')
          ..write('dateHeure: $dateHeure, ')
          ..write('utilisateur: $utilisateur, ')
          ..write('action: $action, ')
          ..write('entite: $entite, ')
          ..write('entiteId: $entiteId, ')
          ..write('champ: $champ, ')
          ..write('ancienneValeur: $ancienneValeur, ')
          ..write('nouvelleValeur: $nouvelleValeur')
          ..write(')'))
        .toString();
  }
}

class $ParametresTable extends Parametres
    with TableInfo<$ParametresTable, Parametre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParametresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cleMeta = const VerificationMeta('cle');
  @override
  late final GeneratedColumn<String> cle = GeneratedColumn<String>(
    'cle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valeurMeta = const VerificationMeta('valeur');
  @override
  late final GeneratedColumn<String> valeur = GeneratedColumn<String>(
    'valeur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [cle, valeur];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parametres';
  @override
  VerificationContext validateIntegrity(
    Insertable<Parametre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cle')) {
      context.handle(
        _cleMeta,
        cle.isAcceptableOrUnknown(data['cle']!, _cleMeta),
      );
    } else if (isInserting) {
      context.missing(_cleMeta);
    }
    if (data.containsKey('valeur')) {
      context.handle(
        _valeurMeta,
        valeur.isAcceptableOrUnknown(data['valeur']!, _valeurMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cle};
  @override
  Parametre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Parametre(
      cle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cle'],
      )!,
      valeur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valeur'],
      )!,
    );
  }

  @override
  $ParametresTable createAlias(String alias) {
    return $ParametresTable(attachedDatabase, alias);
  }
}

class Parametre extends DataClass implements Insertable<Parametre> {
  final String cle;
  final String valeur;
  const Parametre({required this.cle, required this.valeur});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cle'] = Variable<String>(cle);
    map['valeur'] = Variable<String>(valeur);
    return map;
  }

  ParametresCompanion toCompanion(bool nullToAbsent) {
    return ParametresCompanion(cle: Value(cle), valeur: Value(valeur));
  }

  factory Parametre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Parametre(
      cle: serializer.fromJson<String>(json['cle']),
      valeur: serializer.fromJson<String>(json['valeur']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cle': serializer.toJson<String>(cle),
      'valeur': serializer.toJson<String>(valeur),
    };
  }

  Parametre copyWith({String? cle, String? valeur}) =>
      Parametre(cle: cle ?? this.cle, valeur: valeur ?? this.valeur);
  Parametre copyWithCompanion(ParametresCompanion data) {
    return Parametre(
      cle: data.cle.present ? data.cle.value : this.cle,
      valeur: data.valeur.present ? data.valeur.value : this.valeur,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Parametre(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cle, valeur);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Parametre &&
          other.cle == this.cle &&
          other.valeur == this.valeur);
}

class ParametresCompanion extends UpdateCompanion<Parametre> {
  final Value<String> cle;
  final Value<String> valeur;
  final Value<int> rowid;
  const ParametresCompanion({
    this.cle = const Value.absent(),
    this.valeur = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParametresCompanion.insert({
    required String cle,
    this.valeur = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cle = Value(cle);
  static Insertable<Parametre> custom({
    Expression<String>? cle,
    Expression<String>? valeur,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cle != null) 'cle': cle,
      if (valeur != null) 'valeur': valeur,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParametresCompanion copyWith({
    Value<String>? cle,
    Value<String>? valeur,
    Value<int>? rowid,
  }) {
    return ParametresCompanion(
      cle: cle ?? this.cle,
      valeur: valeur ?? this.valeur,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cle.present) {
      map['cle'] = Variable<String>(cle.value);
    }
    if (valeur.present) {
      map['valeur'] = Variable<String>(valeur.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParametresCompanion(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DistrictsTable districts = $DistrictsTable(this);
  late final $ReferentielTarifsTable referentielTarifs =
      $ReferentielTarifsTable(this);
  late final $ReferenceValeursTable referenceValeurs = $ReferenceValeursTable(
    this,
  );
  late final $ActivitesTable activites = $ActivitesTable(this);
  late final $LignesBudgetTable lignesBudget = $LignesBudgetTable(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $ActiviteParticipantsTable activiteParticipants =
      $ActiviteParticipantsTable(this);
  late final $PresencesTable presences = $PresencesTable(this);
  late final $IndemnitesSaisiesTable indemnitesSaisies =
      $IndemnitesSaisiesTable(this);
  late final $ControlesPJTable controlesPJ = $ControlesPJTable(this);
  late final $DepensesTable depenses = $DepensesTable(this);
  late final $BanqueOperationsTable banqueOperations = $BanqueOperationsTable(
    this,
  );
  late final $ReleveBancaireTable releveBancaire = $ReleveBancaireTable(this);
  late final $UtilisateursTable utilisateurs = $UtilisateursTable(this);
  late final $JournalAuditTable journalAudit = $JournalAuditTable(this);
  late final $ParametresTable parametres = $ParametresTable(this);
  late final Index idxDistrictNom = Index(
    'idx_district_nom',
    'CREATE INDEX idx_district_nom ON districts (nom)',
  );
  late final Index idxRefCategorie = Index(
    'idx_ref_categorie',
    'CREATE INDEX idx_ref_categorie ON reference_valeurs (categorie)',
  );
  late final Index idxActiviteCode = Index(
    'idx_activite_code',
    'CREATE UNIQUE INDEX idx_activite_code ON activites (code)',
  );
  late final Index idxLignebudgetActivite = Index(
    'idx_lignebudget_activite',
    'CREATE INDEX idx_lignebudget_activite ON lignes_budget (activite_code)',
  );
  late final Index idxParticipantNom = Index(
    'idx_participant_nom',
    'CREATE INDEX idx_participant_nom ON participants (nom)',
  );
  late final Index idxActpartActivite = Index(
    'idx_actpart_activite',
    'CREATE INDEX idx_actpart_activite ON activite_participants (activite_code)',
  );
  late final Index idxPresenceActivite = Index(
    'idx_presence_activite',
    'CREATE INDEX idx_presence_activite ON presences (activite_code)',
  );
  late final Index idxPresenceParticipant = Index(
    'idx_presence_participant',
    'CREATE INDEX idx_presence_participant ON presences (participant_id)',
  );
  late final Index idxIndemniteActivite = Index(
    'idx_indemnite_activite',
    'CREATE INDEX idx_indemnite_activite ON indemnites_saisies (activite_code)',
  );
  late final Index idxPjActivite = Index(
    'idx_pj_activite',
    'CREATE INDEX idx_pj_activite ON controles_p_j (activite_code)',
  );
  late final Index idxDepenseActivite = Index(
    'idx_depense_activite',
    'CREATE INDEX idx_depense_activite ON depenses (code_activite)',
  );
  late final Index idxBanqueDate = Index(
    'idx_banque_date',
    'CREATE INDEX idx_banque_date ON banque_operations (date)',
  );
  late final Index idxAuditEntite = Index(
    'idx_audit_entite',
    'CREATE INDEX idx_audit_entite ON journal_audit (entite)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    districts,
    referentielTarifs,
    referenceValeurs,
    activites,
    lignesBudget,
    participants,
    activiteParticipants,
    presences,
    indemnitesSaisies,
    controlesPJ,
    depenses,
    banqueOperations,
    releveBancaire,
    utilisateurs,
    journalAudit,
    parametres,
    idxDistrictNom,
    idxRefCategorie,
    idxActiviteCode,
    idxLignebudgetActivite,
    idxParticipantNom,
    idxActpartActivite,
    idxPresenceActivite,
    idxPresenceParticipant,
    idxIndemniteActivite,
    idxPjActivite,
    idxDepenseActivite,
    idxBanqueDate,
    idxAuditEntite,
  ];
}

typedef $$DistrictsTableCreateCompanionBuilder =
    DistrictsCompanion Function({
      Value<int> id,
      Value<int?> numero,
      required String chefLieuRegion,
      required String region,
      required String nom,
      Value<bool> estChefLieuRegion,
      Value<double> distanceAllerKm,
      Value<double> distanceCarburantKm,
      Value<double> delaiRouteAller,
      Value<double> delaiRouteRetour,
      Value<double> delaiRouteTotal,
    });
typedef $$DistrictsTableUpdateCompanionBuilder =
    DistrictsCompanion Function({
      Value<int> id,
      Value<int?> numero,
      Value<String> chefLieuRegion,
      Value<String> region,
      Value<String> nom,
      Value<bool> estChefLieuRegion,
      Value<double> distanceAllerKm,
      Value<double> distanceCarburantKm,
      Value<double> delaiRouteAller,
      Value<double> delaiRouteRetour,
      Value<double> delaiRouteTotal,
    });

class $$DistrictsTableFilterComposer
    extends Composer<_$AppDatabase, $DistrictsTable> {
  $$DistrictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chefLieuRegion => $composableBuilder(
    column: $table.chefLieuRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get estChefLieuRegion => $composableBuilder(
    column: $table.estChefLieuRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceAllerKm => $composableBuilder(
    column: $table.distanceAllerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceCarburantKm => $composableBuilder(
    column: $table.distanceCarburantKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get delaiRouteAller => $composableBuilder(
    column: $table.delaiRouteAller,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get delaiRouteRetour => $composableBuilder(
    column: $table.delaiRouteRetour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get delaiRouteTotal => $composableBuilder(
    column: $table.delaiRouteTotal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DistrictsTableOrderingComposer
    extends Composer<_$AppDatabase, $DistrictsTable> {
  $$DistrictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chefLieuRegion => $composableBuilder(
    column: $table.chefLieuRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get estChefLieuRegion => $composableBuilder(
    column: $table.estChefLieuRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceAllerKm => $composableBuilder(
    column: $table.distanceAllerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceCarburantKm => $composableBuilder(
    column: $table.distanceCarburantKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get delaiRouteAller => $composableBuilder(
    column: $table.delaiRouteAller,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get delaiRouteRetour => $composableBuilder(
    column: $table.delaiRouteRetour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get delaiRouteTotal => $composableBuilder(
    column: $table.delaiRouteTotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DistrictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DistrictsTable> {
  $$DistrictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get chefLieuRegion => $composableBuilder(
    column: $table.chefLieuRegion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<bool> get estChefLieuRegion => $composableBuilder(
    column: $table.estChefLieuRegion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceAllerKm => $composableBuilder(
    column: $table.distanceAllerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceCarburantKm => $composableBuilder(
    column: $table.distanceCarburantKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get delaiRouteAller => $composableBuilder(
    column: $table.delaiRouteAller,
    builder: (column) => column,
  );

  GeneratedColumn<double> get delaiRouteRetour => $composableBuilder(
    column: $table.delaiRouteRetour,
    builder: (column) => column,
  );

  GeneratedColumn<double> get delaiRouteTotal => $composableBuilder(
    column: $table.delaiRouteTotal,
    builder: (column) => column,
  );
}

class $$DistrictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DistrictsTable,
          District,
          $$DistrictsTableFilterComposer,
          $$DistrictsTableOrderingComposer,
          $$DistrictsTableAnnotationComposer,
          $$DistrictsTableCreateCompanionBuilder,
          $$DistrictsTableUpdateCompanionBuilder,
          (District, BaseReferences<_$AppDatabase, $DistrictsTable, District>),
          District,
          PrefetchHooks Function()
        > {
  $$DistrictsTableTableManager(_$AppDatabase db, $DistrictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DistrictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DistrictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DistrictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> numero = const Value.absent(),
                Value<String> chefLieuRegion = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<bool> estChefLieuRegion = const Value.absent(),
                Value<double> distanceAllerKm = const Value.absent(),
                Value<double> distanceCarburantKm = const Value.absent(),
                Value<double> delaiRouteAller = const Value.absent(),
                Value<double> delaiRouteRetour = const Value.absent(),
                Value<double> delaiRouteTotal = const Value.absent(),
              }) => DistrictsCompanion(
                id: id,
                numero: numero,
                chefLieuRegion: chefLieuRegion,
                region: region,
                nom: nom,
                estChefLieuRegion: estChefLieuRegion,
                distanceAllerKm: distanceAllerKm,
                distanceCarburantKm: distanceCarburantKm,
                delaiRouteAller: delaiRouteAller,
                delaiRouteRetour: delaiRouteRetour,
                delaiRouteTotal: delaiRouteTotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> numero = const Value.absent(),
                required String chefLieuRegion,
                required String region,
                required String nom,
                Value<bool> estChefLieuRegion = const Value.absent(),
                Value<double> distanceAllerKm = const Value.absent(),
                Value<double> distanceCarburantKm = const Value.absent(),
                Value<double> delaiRouteAller = const Value.absent(),
                Value<double> delaiRouteRetour = const Value.absent(),
                Value<double> delaiRouteTotal = const Value.absent(),
              }) => DistrictsCompanion.insert(
                id: id,
                numero: numero,
                chefLieuRegion: chefLieuRegion,
                region: region,
                nom: nom,
                estChefLieuRegion: estChefLieuRegion,
                distanceAllerKm: distanceAllerKm,
                distanceCarburantKm: distanceCarburantKm,
                delaiRouteAller: delaiRouteAller,
                delaiRouteRetour: delaiRouteRetour,
                delaiRouteTotal: delaiRouteTotal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DistrictsTable, District>(table),
                  BaseReferences<_$AppDatabase, $DistrictsTable, District>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DistrictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DistrictsTable,
      District,
      $$DistrictsTableFilterComposer,
      $$DistrictsTableOrderingComposer,
      $$DistrictsTableAnnotationComposer,
      $$DistrictsTableCreateCompanionBuilder,
      $$DistrictsTableUpdateCompanionBuilder,
      (District, BaseReferences<_$AppDatabase, $DistrictsTable, District>),
      District,
      PrefetchHooks Function()
    >;
typedef $$ReferentielTarifsTableCreateCompanionBuilder =
    ReferentielTarifsCompanion Function({
      Value<int> id,
      required String rubrique,
      required String ligneBudgetaire,
      Value<String> typeActivite,
      Value<String> unite,
      Value<String> zone,
      Value<double> tarif,
      Value<bool> actif,
      Value<String?> observation,
    });
typedef $$ReferentielTarifsTableUpdateCompanionBuilder =
    ReferentielTarifsCompanion Function({
      Value<int> id,
      Value<String> rubrique,
      Value<String> ligneBudgetaire,
      Value<String> typeActivite,
      Value<String> unite,
      Value<String> zone,
      Value<double> tarif,
      Value<bool> actif,
      Value<String?> observation,
    });

class $$ReferentielTarifsTableFilterComposer
    extends Composer<_$AppDatabase, $ReferentielTarifsTable> {
  $$ReferentielTarifsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rubrique => $composableBuilder(
    column: $table.rubrique,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeActivite => $composableBuilder(
    column: $table.typeActivite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tarif => $composableBuilder(
    column: $table.tarif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReferentielTarifsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferentielTarifsTable> {
  $$ReferentielTarifsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rubrique => $composableBuilder(
    column: $table.rubrique,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeActivite => $composableBuilder(
    column: $table.typeActivite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tarif => $composableBuilder(
    column: $table.tarif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReferentielTarifsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferentielTarifsTable> {
  $$ReferentielTarifsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rubrique =>
      $composableBuilder(column: $table.rubrique, builder: (column) => column);

  GeneratedColumn<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeActivite => $composableBuilder(
    column: $table.typeActivite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unite =>
      $composableBuilder(column: $table.unite, builder: (column) => column);

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<double> get tarif =>
      $composableBuilder(column: $table.tarif, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );
}

class $$ReferentielTarifsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReferentielTarifsTable,
          TarifReferentiel,
          $$ReferentielTarifsTableFilterComposer,
          $$ReferentielTarifsTableOrderingComposer,
          $$ReferentielTarifsTableAnnotationComposer,
          $$ReferentielTarifsTableCreateCompanionBuilder,
          $$ReferentielTarifsTableUpdateCompanionBuilder,
          (
            TarifReferentiel,
            BaseReferences<
              _$AppDatabase,
              $ReferentielTarifsTable,
              TarifReferentiel
            >,
          ),
          TarifReferentiel,
          PrefetchHooks Function()
        > {
  $$ReferentielTarifsTableTableManager(
    _$AppDatabase db,
    $ReferentielTarifsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferentielTarifsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferentielTarifsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferentielTarifsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rubrique = const Value.absent(),
                Value<String> ligneBudgetaire = const Value.absent(),
                Value<String> typeActivite = const Value.absent(),
                Value<String> unite = const Value.absent(),
                Value<String> zone = const Value.absent(),
                Value<double> tarif = const Value.absent(),
                Value<bool> actif = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => ReferentielTarifsCompanion(
                id: id,
                rubrique: rubrique,
                ligneBudgetaire: ligneBudgetaire,
                typeActivite: typeActivite,
                unite: unite,
                zone: zone,
                tarif: tarif,
                actif: actif,
                observation: observation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rubrique,
                required String ligneBudgetaire,
                Value<String> typeActivite = const Value.absent(),
                Value<String> unite = const Value.absent(),
                Value<String> zone = const Value.absent(),
                Value<double> tarif = const Value.absent(),
                Value<bool> actif = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => ReferentielTarifsCompanion.insert(
                id: id,
                rubrique: rubrique,
                ligneBudgetaire: ligneBudgetaire,
                typeActivite: typeActivite,
                unite: unite,
                zone: zone,
                tarif: tarif,
                actif: actif,
                observation: observation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReferentielTarifsTable, TarifReferentiel>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReferentielTarifsTable,
                    TarifReferentiel
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReferentielTarifsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReferentielTarifsTable,
      TarifReferentiel,
      $$ReferentielTarifsTableFilterComposer,
      $$ReferentielTarifsTableOrderingComposer,
      $$ReferentielTarifsTableAnnotationComposer,
      $$ReferentielTarifsTableCreateCompanionBuilder,
      $$ReferentielTarifsTableUpdateCompanionBuilder,
      (
        TarifReferentiel,
        BaseReferences<
          _$AppDatabase,
          $ReferentielTarifsTable,
          TarifReferentiel
        >,
      ),
      TarifReferentiel,
      PrefetchHooks Function()
    >;
typedef $$ReferenceValeursTableCreateCompanionBuilder =
    ReferenceValeursCompanion Function({
      Value<int> id,
      required String categorie,
      required String valeur,
      Value<int> ordre,
      Value<bool> actif,
    });
typedef $$ReferenceValeursTableUpdateCompanionBuilder =
    ReferenceValeursCompanion Function({
      Value<int> id,
      Value<String> categorie,
      Value<String> valeur,
      Value<int> ordre,
      Value<bool> actif,
    });

class $$ReferenceValeursTableFilterComposer
    extends Composer<_$AppDatabase, $ReferenceValeursTable> {
  $$ReferenceValeursTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valeur => $composableBuilder(
    column: $table.valeur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReferenceValeursTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferenceValeursTable> {
  $$ReferenceValeursTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valeur => $composableBuilder(
    column: $table.valeur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReferenceValeursTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferenceValeursTable> {
  $$ReferenceValeursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<String> get valeur =>
      $composableBuilder(column: $table.valeur, builder: (column) => column);

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);
}

class $$ReferenceValeursTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReferenceValeursTable,
          ReferenceValeur,
          $$ReferenceValeursTableFilterComposer,
          $$ReferenceValeursTableOrderingComposer,
          $$ReferenceValeursTableAnnotationComposer,
          $$ReferenceValeursTableCreateCompanionBuilder,
          $$ReferenceValeursTableUpdateCompanionBuilder,
          (
            ReferenceValeur,
            BaseReferences<
              _$AppDatabase,
              $ReferenceValeursTable,
              ReferenceValeur
            >,
          ),
          ReferenceValeur,
          PrefetchHooks Function()
        > {
  $$ReferenceValeursTableTableManager(
    _$AppDatabase db,
    $ReferenceValeursTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceValeursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceValeursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceValeursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> categorie = const Value.absent(),
                Value<String> valeur = const Value.absent(),
                Value<int> ordre = const Value.absent(),
                Value<bool> actif = const Value.absent(),
              }) => ReferenceValeursCompanion(
                id: id,
                categorie: categorie,
                valeur: valeur,
                ordre: ordre,
                actif: actif,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String categorie,
                required String valeur,
                Value<int> ordre = const Value.absent(),
                Value<bool> actif = const Value.absent(),
              }) => ReferenceValeursCompanion.insert(
                id: id,
                categorie: categorie,
                valeur: valeur,
                ordre: ordre,
                actif: actif,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReferenceValeursTable, ReferenceValeur>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReferenceValeursTable,
                    ReferenceValeur
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReferenceValeursTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReferenceValeursTable,
      ReferenceValeur,
      $$ReferenceValeursTableFilterComposer,
      $$ReferenceValeursTableOrderingComposer,
      $$ReferenceValeursTableAnnotationComposer,
      $$ReferenceValeursTableCreateCompanionBuilder,
      $$ReferenceValeursTableUpdateCompanionBuilder,
      (
        ReferenceValeur,
        BaseReferences<_$AppDatabase, $ReferenceValeursTable, ReferenceValeur>,
      ),
      ReferenceValeur,
      PrefetchHooks Function()
    >;
typedef $$ActivitesTableCreateCompanionBuilder =
    ActivitesCompanion Function({
      Value<int> id,
      required String code,
      Value<String> description,
      Value<String> type,
      Value<String?> codeBudget,
      Value<String?> sourceFinancement,
      Value<int?> annee,
      Value<String?> periode,
      Value<DateTime?> dateDebut,
      Value<DateTime?> dateFin,
      Value<String?> lieu,
      Value<String?> district,
      Value<String?> zoneIndemnite,
      Value<String?> responsable,
      Value<int> nombreJours,
      Value<int> nombreParticipants,
      Value<int> nombreMissionnaires,
      Value<double> distanceAllerKm,
      Value<bool> restauration,
      Value<String> statut,
      Value<String?> observation,
      Value<DateTime> creeLe,
    });
typedef $$ActivitesTableUpdateCompanionBuilder =
    ActivitesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> description,
      Value<String> type,
      Value<String?> codeBudget,
      Value<String?> sourceFinancement,
      Value<int?> annee,
      Value<String?> periode,
      Value<DateTime?> dateDebut,
      Value<DateTime?> dateFin,
      Value<String?> lieu,
      Value<String?> district,
      Value<String?> zoneIndemnite,
      Value<String?> responsable,
      Value<int> nombreJours,
      Value<int> nombreParticipants,
      Value<int> nombreMissionnaires,
      Value<double> distanceAllerKm,
      Value<bool> restauration,
      Value<String> statut,
      Value<String?> observation,
      Value<DateTime> creeLe,
    });

class $$ActivitesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitesTable> {
  $$ActivitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeBudget => $composableBuilder(
    column: $table.codeBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFinancement => $composableBuilder(
    column: $table.sourceFinancement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annee => $composableBuilder(
    column: $table.annee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periode => $composableBuilder(
    column: $table.periode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateDebut => $composableBuilder(
    column: $table.dateDebut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFin => $composableBuilder(
    column: $table.dateFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lieu => $composableBuilder(
    column: $table.lieu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneIndemnite => $composableBuilder(
    column: $table.zoneIndemnite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreJours => $composableBuilder(
    column: $table.nombreJours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreParticipants => $composableBuilder(
    column: $table.nombreParticipants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreMissionnaires => $composableBuilder(
    column: $table.nombreMissionnaires,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceAllerKm => $composableBuilder(
    column: $table.distanceAllerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restauration => $composableBuilder(
    column: $table.restauration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivitesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitesTable> {
  $$ActivitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeBudget => $composableBuilder(
    column: $table.codeBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFinancement => $composableBuilder(
    column: $table.sourceFinancement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annee => $composableBuilder(
    column: $table.annee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periode => $composableBuilder(
    column: $table.periode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateDebut => $composableBuilder(
    column: $table.dateDebut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFin => $composableBuilder(
    column: $table.dateFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lieu => $composableBuilder(
    column: $table.lieu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneIndemnite => $composableBuilder(
    column: $table.zoneIndemnite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreJours => $composableBuilder(
    column: $table.nombreJours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreParticipants => $composableBuilder(
    column: $table.nombreParticipants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreMissionnaires => $composableBuilder(
    column: $table.nombreMissionnaires,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceAllerKm => $composableBuilder(
    column: $table.distanceAllerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restauration => $composableBuilder(
    column: $table.restauration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitesTable> {
  $$ActivitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get codeBudget => $composableBuilder(
    column: $table.codeBudget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFinancement => $composableBuilder(
    column: $table.sourceFinancement,
    builder: (column) => column,
  );

  GeneratedColumn<int> get annee =>
      $composableBuilder(column: $table.annee, builder: (column) => column);

  GeneratedColumn<String> get periode =>
      $composableBuilder(column: $table.periode, builder: (column) => column);

  GeneratedColumn<DateTime> get dateDebut =>
      $composableBuilder(column: $table.dateDebut, builder: (column) => column);

  GeneratedColumn<DateTime> get dateFin =>
      $composableBuilder(column: $table.dateFin, builder: (column) => column);

  GeneratedColumn<String> get lieu =>
      $composableBuilder(column: $table.lieu, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get zoneIndemnite => $composableBuilder(
    column: $table.zoneIndemnite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreJours => $composableBuilder(
    column: $table.nombreJours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreParticipants => $composableBuilder(
    column: $table.nombreParticipants,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreMissionnaires => $composableBuilder(
    column: $table.nombreMissionnaires,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceAllerKm => $composableBuilder(
    column: $table.distanceAllerKm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get restauration => $composableBuilder(
    column: $table.restauration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);
}

class $$ActivitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitesTable,
          Activite,
          $$ActivitesTableFilterComposer,
          $$ActivitesTableOrderingComposer,
          $$ActivitesTableAnnotationComposer,
          $$ActivitesTableCreateCompanionBuilder,
          $$ActivitesTableUpdateCompanionBuilder,
          (Activite, BaseReferences<_$AppDatabase, $ActivitesTable, Activite>),
          Activite,
          PrefetchHooks Function()
        > {
  $$ActivitesTableTableManager(_$AppDatabase db, $ActivitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> codeBudget = const Value.absent(),
                Value<String?> sourceFinancement = const Value.absent(),
                Value<int?> annee = const Value.absent(),
                Value<String?> periode = const Value.absent(),
                Value<DateTime?> dateDebut = const Value.absent(),
                Value<DateTime?> dateFin = const Value.absent(),
                Value<String?> lieu = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> zoneIndemnite = const Value.absent(),
                Value<String?> responsable = const Value.absent(),
                Value<int> nombreJours = const Value.absent(),
                Value<int> nombreParticipants = const Value.absent(),
                Value<int> nombreMissionnaires = const Value.absent(),
                Value<double> distanceAllerKm = const Value.absent(),
                Value<bool> restauration = const Value.absent(),
                Value<String> statut = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
              }) => ActivitesCompanion(
                id: id,
                code: code,
                description: description,
                type: type,
                codeBudget: codeBudget,
                sourceFinancement: sourceFinancement,
                annee: annee,
                periode: periode,
                dateDebut: dateDebut,
                dateFin: dateFin,
                lieu: lieu,
                district: district,
                zoneIndemnite: zoneIndemnite,
                responsable: responsable,
                nombreJours: nombreJours,
                nombreParticipants: nombreParticipants,
                nombreMissionnaires: nombreMissionnaires,
                distanceAllerKm: distanceAllerKm,
                restauration: restauration,
                statut: statut,
                observation: observation,
                creeLe: creeLe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> codeBudget = const Value.absent(),
                Value<String?> sourceFinancement = const Value.absent(),
                Value<int?> annee = const Value.absent(),
                Value<String?> periode = const Value.absent(),
                Value<DateTime?> dateDebut = const Value.absent(),
                Value<DateTime?> dateFin = const Value.absent(),
                Value<String?> lieu = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> zoneIndemnite = const Value.absent(),
                Value<String?> responsable = const Value.absent(),
                Value<int> nombreJours = const Value.absent(),
                Value<int> nombreParticipants = const Value.absent(),
                Value<int> nombreMissionnaires = const Value.absent(),
                Value<double> distanceAllerKm = const Value.absent(),
                Value<bool> restauration = const Value.absent(),
                Value<String> statut = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
              }) => ActivitesCompanion.insert(
                id: id,
                code: code,
                description: description,
                type: type,
                codeBudget: codeBudget,
                sourceFinancement: sourceFinancement,
                annee: annee,
                periode: periode,
                dateDebut: dateDebut,
                dateFin: dateFin,
                lieu: lieu,
                district: district,
                zoneIndemnite: zoneIndemnite,
                responsable: responsable,
                nombreJours: nombreJours,
                nombreParticipants: nombreParticipants,
                nombreMissionnaires: nombreMissionnaires,
                distanceAllerKm: distanceAllerKm,
                restauration: restauration,
                statut: statut,
                observation: observation,
                creeLe: creeLe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitesTable, Activite>(table),
                  BaseReferences<_$AppDatabase, $ActivitesTable, Activite>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitesTable,
      Activite,
      $$ActivitesTableFilterComposer,
      $$ActivitesTableOrderingComposer,
      $$ActivitesTableAnnotationComposer,
      $$ActivitesTableCreateCompanionBuilder,
      $$ActivitesTableUpdateCompanionBuilder,
      (Activite, BaseReferences<_$AppDatabase, $ActivitesTable, Activite>),
      Activite,
      PrefetchHooks Function()
    >;
typedef $$LignesBudgetTableCreateCompanionBuilder =
    LignesBudgetCompanion Function({
      Value<int> id,
      required String activiteCode,
      Value<String?> activiteLibelle,
      Value<DateTime?> dateDebutPrevue,
      Value<DateTime?> dateFinPrevue,
      required String ligneBudgetaire,
      Value<String> typeBudget,
      Value<String> unite,
      Value<double> quantitePrevue,
      Value<double> nombreJours,
      Value<double> tauxUnitaire,
      Value<double> montantAlloue,
      Value<String?> details,
      Value<String?> observation,
    });
typedef $$LignesBudgetTableUpdateCompanionBuilder =
    LignesBudgetCompanion Function({
      Value<int> id,
      Value<String> activiteCode,
      Value<String?> activiteLibelle,
      Value<DateTime?> dateDebutPrevue,
      Value<DateTime?> dateFinPrevue,
      Value<String> ligneBudgetaire,
      Value<String> typeBudget,
      Value<String> unite,
      Value<double> quantitePrevue,
      Value<double> nombreJours,
      Value<double> tauxUnitaire,
      Value<double> montantAlloue,
      Value<String?> details,
      Value<String?> observation,
    });

class $$LignesBudgetTableFilterComposer
    extends Composer<_$AppDatabase, $LignesBudgetTable> {
  $$LignesBudgetTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activiteLibelle => $composableBuilder(
    column: $table.activiteLibelle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateDebutPrevue => $composableBuilder(
    column: $table.dateDebutPrevue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFinPrevue => $composableBuilder(
    column: $table.dateFinPrevue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeBudget => $composableBuilder(
    column: $table.typeBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantitePrevue => $composableBuilder(
    column: $table.quantitePrevue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nombreJours => $composableBuilder(
    column: $table.nombreJours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tauxUnitaire => $composableBuilder(
    column: $table.tauxUnitaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LignesBudgetTableOrderingComposer
    extends Composer<_$AppDatabase, $LignesBudgetTable> {
  $$LignesBudgetTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activiteLibelle => $composableBuilder(
    column: $table.activiteLibelle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateDebutPrevue => $composableBuilder(
    column: $table.dateDebutPrevue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFinPrevue => $composableBuilder(
    column: $table.dateFinPrevue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeBudget => $composableBuilder(
    column: $table.typeBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantitePrevue => $composableBuilder(
    column: $table.quantitePrevue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nombreJours => $composableBuilder(
    column: $table.nombreJours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tauxUnitaire => $composableBuilder(
    column: $table.tauxUnitaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LignesBudgetTableAnnotationComposer
    extends Composer<_$AppDatabase, $LignesBudgetTable> {
  $$LignesBudgetTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activiteLibelle => $composableBuilder(
    column: $table.activiteLibelle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateDebutPrevue => $composableBuilder(
    column: $table.dateDebutPrevue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateFinPrevue => $composableBuilder(
    column: $table.dateFinPrevue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeBudget => $composableBuilder(
    column: $table.typeBudget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unite =>
      $composableBuilder(column: $table.unite, builder: (column) => column);

  GeneratedColumn<double> get quantitePrevue => $composableBuilder(
    column: $table.quantitePrevue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nombreJours => $composableBuilder(
    column: $table.nombreJours,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tauxUnitaire => $composableBuilder(
    column: $table.tauxUnitaire,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );
}

class $$LignesBudgetTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LignesBudgetTable,
          LigneBudget,
          $$LignesBudgetTableFilterComposer,
          $$LignesBudgetTableOrderingComposer,
          $$LignesBudgetTableAnnotationComposer,
          $$LignesBudgetTableCreateCompanionBuilder,
          $$LignesBudgetTableUpdateCompanionBuilder,
          (
            LigneBudget,
            BaseReferences<_$AppDatabase, $LignesBudgetTable, LigneBudget>,
          ),
          LigneBudget,
          PrefetchHooks Function()
        > {
  $$LignesBudgetTableTableManager(_$AppDatabase db, $LignesBudgetTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LignesBudgetTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LignesBudgetTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LignesBudgetTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> activiteCode = const Value.absent(),
                Value<String?> activiteLibelle = const Value.absent(),
                Value<DateTime?> dateDebutPrevue = const Value.absent(),
                Value<DateTime?> dateFinPrevue = const Value.absent(),
                Value<String> ligneBudgetaire = const Value.absent(),
                Value<String> typeBudget = const Value.absent(),
                Value<String> unite = const Value.absent(),
                Value<double> quantitePrevue = const Value.absent(),
                Value<double> nombreJours = const Value.absent(),
                Value<double> tauxUnitaire = const Value.absent(),
                Value<double> montantAlloue = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => LignesBudgetCompanion(
                id: id,
                activiteCode: activiteCode,
                activiteLibelle: activiteLibelle,
                dateDebutPrevue: dateDebutPrevue,
                dateFinPrevue: dateFinPrevue,
                ligneBudgetaire: ligneBudgetaire,
                typeBudget: typeBudget,
                unite: unite,
                quantitePrevue: quantitePrevue,
                nombreJours: nombreJours,
                tauxUnitaire: tauxUnitaire,
                montantAlloue: montantAlloue,
                details: details,
                observation: observation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String activiteCode,
                Value<String?> activiteLibelle = const Value.absent(),
                Value<DateTime?> dateDebutPrevue = const Value.absent(),
                Value<DateTime?> dateFinPrevue = const Value.absent(),
                required String ligneBudgetaire,
                Value<String> typeBudget = const Value.absent(),
                Value<String> unite = const Value.absent(),
                Value<double> quantitePrevue = const Value.absent(),
                Value<double> nombreJours = const Value.absent(),
                Value<double> tauxUnitaire = const Value.absent(),
                Value<double> montantAlloue = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => LignesBudgetCompanion.insert(
                id: id,
                activiteCode: activiteCode,
                activiteLibelle: activiteLibelle,
                dateDebutPrevue: dateDebutPrevue,
                dateFinPrevue: dateFinPrevue,
                ligneBudgetaire: ligneBudgetaire,
                typeBudget: typeBudget,
                unite: unite,
                quantitePrevue: quantitePrevue,
                nombreJours: nombreJours,
                tauxUnitaire: tauxUnitaire,
                montantAlloue: montantAlloue,
                details: details,
                observation: observation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LignesBudgetTable, LigneBudget>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LignesBudgetTable,
                    LigneBudget
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LignesBudgetTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LignesBudgetTable,
      LigneBudget,
      $$LignesBudgetTableFilterComposer,
      $$LignesBudgetTableOrderingComposer,
      $$LignesBudgetTableAnnotationComposer,
      $$LignesBudgetTableCreateCompanionBuilder,
      $$LignesBudgetTableUpdateCompanionBuilder,
      (
        LigneBudget,
        BaseReferences<_$AppDatabase, $LignesBudgetTable, LigneBudget>,
      ),
      LigneBudget,
      PrefetchHooks Function()
    >;
typedef $$ParticipantsTableCreateCompanionBuilder =
    ParticipantsCompanion Function({
      Value<int> id,
      required String nom,
      Value<String> prenom,
      Value<String?> fonction,
      Value<String?> structure,
      Value<String?> telephone,
      Value<String?> email,
      Value<bool> actif,
      Value<String?> observation,
    });
typedef $$ParticipantsTableUpdateCompanionBuilder =
    ParticipantsCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<String> prenom,
      Value<String?> fonction,
      Value<String?> structure,
      Value<String?> telephone,
      Value<String?> email,
      Value<bool> actif,
      Value<String?> observation,
    });

final class $$ParticipantsTableReferences
    extends BaseReferences<_$AppDatabase, $ParticipantsTable, Participant> {
  $$ParticipantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ActiviteParticipantsTable,
    List<ActiviteParticipant>
  >
  _activiteParticipantsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activiteParticipants,
        aliasName: 'participants__id__activite_participants__participant_id',
      );

  $$ActiviteParticipantsTableProcessedTableManager
  get activiteParticipantsRefs {
    final manager = $$ActiviteParticipantsTableTableManager(
      $_db,
      $_db.activiteParticipants,
    ).filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activiteParticipantsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PresencesTable, List<Presence>>
  _presencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.presences,
    aliasName: 'participants__id__presences__participant_id',
  );

  $$PresencesTableProcessedTableManager get presencesRefs {
    final manager = $$PresencesTableTableManager(
      $_db,
      $_db.presences,
    ).filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_presencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activiteParticipantsRefs(
    Expression<bool> Function($$ActiviteParticipantsTableFilterComposer f) f,
  ) {
    final $$ActiviteParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activiteParticipants,
      getReferencedColumn: (t) => t.participantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiviteParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.activiteParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> presencesRefs(
    Expression<bool> Function($$PresencesTableFilterComposer f) f,
  ) {
    final $$PresencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.presences,
      getReferencedColumn: (t) => t.participantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresencesTableFilterComposer(
            $db: $db,
            $table: $db.presences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get prenom =>
      $composableBuilder(column: $table.prenom, builder: (column) => column);

  GeneratedColumn<String> get fonction =>
      $composableBuilder(column: $table.fonction, builder: (column) => column);

  GeneratedColumn<String> get structure =>
      $composableBuilder(column: $table.structure, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  Expression<T> activiteParticipantsRefs<T extends Object>(
    Expression<T> Function($$ActiviteParticipantsTableAnnotationComposer a) f,
  ) {
    final $$ActiviteParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activiteParticipants,
          getReferencedColumn: (t) => t.participantId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActiviteParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.activiteParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> presencesRefs<T extends Object>(
    Expression<T> Function($$PresencesTableAnnotationComposer a) f,
  ) {
    final $$PresencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.presences,
      getReferencedColumn: (t) => t.participantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresencesTableAnnotationComposer(
            $db: $db,
            $table: $db.presences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParticipantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParticipantsTable,
          Participant,
          $$ParticipantsTableFilterComposer,
          $$ParticipantsTableOrderingComposer,
          $$ParticipantsTableAnnotationComposer,
          $$ParticipantsTableCreateCompanionBuilder,
          $$ParticipantsTableUpdateCompanionBuilder,
          (Participant, $$ParticipantsTableReferences),
          Participant,
          PrefetchHooks Function({
            bool activiteParticipantsRefs,
            bool presencesRefs,
          })
        > {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> prenom = const Value.absent(),
                Value<String?> fonction = const Value.absent(),
                Value<String?> structure = const Value.absent(),
                Value<String?> telephone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> actif = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => ParticipantsCompanion(
                id: id,
                nom: nom,
                prenom: prenom,
                fonction: fonction,
                structure: structure,
                telephone: telephone,
                email: email,
                actif: actif,
                observation: observation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                Value<String> prenom = const Value.absent(),
                Value<String?> fonction = const Value.absent(),
                Value<String?> structure = const Value.absent(),
                Value<String?> telephone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> actif = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => ParticipantsCompanion.insert(
                id: id,
                nom: nom,
                prenom: prenom,
                fonction: fonction,
                structure: structure,
                telephone: telephone,
                email: email,
                actif: actif,
                observation: observation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ParticipantsTable, Participant>(table),
                  $$ParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({activiteParticipantsRefs = false, presencesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activiteParticipantsRefs) db.activiteParticipants,
                    if (presencesRefs) db.presences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activiteParticipantsRefs)
                        await $_getPrefetchedData<
                          Participant,
                          $ParticipantsTable,
                          ActiviteParticipant
                        >(
                          currentTable: table,
                          referencedTable: $$ParticipantsTableReferences
                              ._activiteParticipantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).activiteParticipantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (presencesRefs)
                        await $_getPrefetchedData<
                          Participant,
                          $ParticipantsTable,
                          Presence
                        >(
                          currentTable: table,
                          referencedTable: $$ParticipantsTableReferences
                              ._presencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).presencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParticipantsTable,
      Participant,
      $$ParticipantsTableFilterComposer,
      $$ParticipantsTableOrderingComposer,
      $$ParticipantsTableAnnotationComposer,
      $$ParticipantsTableCreateCompanionBuilder,
      $$ParticipantsTableUpdateCompanionBuilder,
      (Participant, $$ParticipantsTableReferences),
      Participant,
      PrefetchHooks Function({
        bool activiteParticipantsRefs,
        bool presencesRefs,
      })
    >;
typedef $$ActiviteParticipantsTableCreateCompanionBuilder =
    ActiviteParticipantsCompanion Function({
      Value<int> id,
      required String activiteCode,
      required int participantId,
      Value<String> role,
      Value<String?> zone,
      Value<double> tauxJournalier,
    });
typedef $$ActiviteParticipantsTableUpdateCompanionBuilder =
    ActiviteParticipantsCompanion Function({
      Value<int> id,
      Value<String> activiteCode,
      Value<int> participantId,
      Value<String> role,
      Value<String?> zone,
      Value<double> tauxJournalier,
    });

final class $$ActiviteParticipantsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActiviteParticipantsTable,
          ActiviteParticipant
        > {
  $$ActiviteParticipantsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) => db
      .participants
      .createAlias('activite_participants__participant_id__participants__id');

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager(
      $_db,
      $_db.participants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActiviteParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ActiviteParticipantsTable> {
  $$ActiviteParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tauxJournalier => $composableBuilder(
    column: $table.tauxJournalier,
    builder: (column) => ColumnFilters(column),
  );

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiviteParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiviteParticipantsTable> {
  $$ActiviteParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tauxJournalier => $composableBuilder(
    column: $table.tauxJournalier,
    builder: (column) => ColumnOrderings(column),
  );

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableOrderingComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiviteParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiviteParticipantsTable> {
  $$ActiviteParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<double> get tauxJournalier => $composableBuilder(
    column: $table.tauxJournalier,
    builder: (column) => column,
  );

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableAnnotationComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiviteParticipantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiviteParticipantsTable,
          ActiviteParticipant,
          $$ActiviteParticipantsTableFilterComposer,
          $$ActiviteParticipantsTableOrderingComposer,
          $$ActiviteParticipantsTableAnnotationComposer,
          $$ActiviteParticipantsTableCreateCompanionBuilder,
          $$ActiviteParticipantsTableUpdateCompanionBuilder,
          (ActiviteParticipant, $$ActiviteParticipantsTableReferences),
          ActiviteParticipant,
          PrefetchHooks Function({bool participantId})
        > {
  $$ActiviteParticipantsTableTableManager(
    _$AppDatabase db,
    $ActiviteParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiviteParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiviteParticipantsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ActiviteParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> activiteCode = const Value.absent(),
                Value<int> participantId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> zone = const Value.absent(),
                Value<double> tauxJournalier = const Value.absent(),
              }) => ActiviteParticipantsCompanion(
                id: id,
                activiteCode: activiteCode,
                participantId: participantId,
                role: role,
                zone: zone,
                tauxJournalier: tauxJournalier,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String activiteCode,
                required int participantId,
                Value<String> role = const Value.absent(),
                Value<String?> zone = const Value.absent(),
                Value<double> tauxJournalier = const Value.absent(),
              }) => ActiviteParticipantsCompanion.insert(
                id: id,
                activiteCode: activiteCode,
                participantId: participantId,
                role: role,
                zone: zone,
                tauxJournalier: tauxJournalier,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActiviteParticipantsTable, ActiviteParticipant>(
                    table,
                  ),
                  $$ActiviteParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({participantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (participantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.participantId,
                                referencedTable:
                                    $$ActiviteParticipantsTableReferences
                                        ._participantIdTable(db),
                                referencedColumn:
                                    $$ActiviteParticipantsTableReferences
                                        ._participantIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActiviteParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiviteParticipantsTable,
      ActiviteParticipant,
      $$ActiviteParticipantsTableFilterComposer,
      $$ActiviteParticipantsTableOrderingComposer,
      $$ActiviteParticipantsTableAnnotationComposer,
      $$ActiviteParticipantsTableCreateCompanionBuilder,
      $$ActiviteParticipantsTableUpdateCompanionBuilder,
      (ActiviteParticipant, $$ActiviteParticipantsTableReferences),
      ActiviteParticipant,
      PrefetchHooks Function({bool participantId})
    >;
typedef $$PresencesTableCreateCompanionBuilder =
    PresencesCompanion Function({
      Value<int> id,
      required String activiteCode,
      required int participantId,
      required DateTime date,
      Value<String> statut,
      Value<String?> signaturePreuve,
      Value<double> tauxJournalier,
      Value<double> indemniteRecue,
      Value<String?> observation,
    });
typedef $$PresencesTableUpdateCompanionBuilder =
    PresencesCompanion Function({
      Value<int> id,
      Value<String> activiteCode,
      Value<int> participantId,
      Value<DateTime> date,
      Value<String> statut,
      Value<String?> signaturePreuve,
      Value<double> tauxJournalier,
      Value<double> indemniteRecue,
      Value<String?> observation,
    });

final class $$PresencesTableReferences
    extends BaseReferences<_$AppDatabase, $PresencesTable, Presence> {
  $$PresencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _participantIdTable(_$AppDatabase db) => db
      .participants
      .createAlias('presences__participant_id__participants__id');

  $$ParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$ParticipantsTableTableManager(
      $_db,
      $_db.participants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PresencesTableFilterComposer
    extends Composer<_$AppDatabase, $PresencesTable> {
  $$PresencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signaturePreuve => $composableBuilder(
    column: $table.signaturePreuve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tauxJournalier => $composableBuilder(
    column: $table.tauxJournalier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get indemniteRecue => $composableBuilder(
    column: $table.indemniteRecue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  $$ParticipantsTableFilterComposer get participantId {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PresencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PresencesTable> {
  $$PresencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signaturePreuve => $composableBuilder(
    column: $table.signaturePreuve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tauxJournalier => $composableBuilder(
    column: $table.tauxJournalier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get indemniteRecue => $composableBuilder(
    column: $table.indemniteRecue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  $$ParticipantsTableOrderingComposer get participantId {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableOrderingComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PresencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresencesTable> {
  $$PresencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get signaturePreuve => $composableBuilder(
    column: $table.signaturePreuve,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tauxJournalier => $composableBuilder(
    column: $table.tauxJournalier,
    builder: (column) => column,
  );

  GeneratedColumn<double> get indemniteRecue => $composableBuilder(
    column: $table.indemniteRecue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  $$ParticipantsTableAnnotationComposer get participantId {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.participants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParticipantsTableAnnotationComposer(
            $db: $db,
            $table: $db.participants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PresencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PresencesTable,
          Presence,
          $$PresencesTableFilterComposer,
          $$PresencesTableOrderingComposer,
          $$PresencesTableAnnotationComposer,
          $$PresencesTableCreateCompanionBuilder,
          $$PresencesTableUpdateCompanionBuilder,
          (Presence, $$PresencesTableReferences),
          Presence,
          PrefetchHooks Function({bool participantId})
        > {
  $$PresencesTableTableManager(_$AppDatabase db, $PresencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> activiteCode = const Value.absent(),
                Value<int> participantId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> statut = const Value.absent(),
                Value<String?> signaturePreuve = const Value.absent(),
                Value<double> tauxJournalier = const Value.absent(),
                Value<double> indemniteRecue = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => PresencesCompanion(
                id: id,
                activiteCode: activiteCode,
                participantId: participantId,
                date: date,
                statut: statut,
                signaturePreuve: signaturePreuve,
                tauxJournalier: tauxJournalier,
                indemniteRecue: indemniteRecue,
                observation: observation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String activiteCode,
                required int participantId,
                required DateTime date,
                Value<String> statut = const Value.absent(),
                Value<String?> signaturePreuve = const Value.absent(),
                Value<double> tauxJournalier = const Value.absent(),
                Value<double> indemniteRecue = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => PresencesCompanion.insert(
                id: id,
                activiteCode: activiteCode,
                participantId: participantId,
                date: date,
                statut: statut,
                signaturePreuve: signaturePreuve,
                tauxJournalier: tauxJournalier,
                indemniteRecue: indemniteRecue,
                observation: observation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PresencesTable, Presence>(table),
                  $$PresencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({participantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (participantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.participantId,
                                referencedTable: $$PresencesTableReferences
                                    ._participantIdTable(db),
                                referencedColumn: $$PresencesTableReferences
                                    ._participantIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PresencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PresencesTable,
      Presence,
      $$PresencesTableFilterComposer,
      $$PresencesTableOrderingComposer,
      $$PresencesTableAnnotationComposer,
      $$PresencesTableCreateCompanionBuilder,
      $$PresencesTableUpdateCompanionBuilder,
      (Presence, $$PresencesTableReferences),
      Presence,
      PrefetchHooks Function({bool participantId})
    >;
typedef $$IndemnitesSaisiesTableCreateCompanionBuilder =
    IndemnitesSaisiesCompanion Function({
      Value<int> id,
      required String activiteCode,
      Value<String> ligneBudgetaire,
      Value<int?> participantId,
      Value<String> participantNom,
      Value<String> etatPaiement,
      Value<String?> provenance,
      Value<double> delaiRoute,
      Value<double> nombreJoursActivite,
      Value<bool> restauration,
      Value<double> taux,
      Value<double> montantAlloue,
      Value<double> montantPaye,
      Value<DateTime> creeLe,
    });
typedef $$IndemnitesSaisiesTableUpdateCompanionBuilder =
    IndemnitesSaisiesCompanion Function({
      Value<int> id,
      Value<String> activiteCode,
      Value<String> ligneBudgetaire,
      Value<int?> participantId,
      Value<String> participantNom,
      Value<String> etatPaiement,
      Value<String?> provenance,
      Value<double> delaiRoute,
      Value<double> nombreJoursActivite,
      Value<bool> restauration,
      Value<double> taux,
      Value<double> montantAlloue,
      Value<double> montantPaye,
      Value<DateTime> creeLe,
    });

class $$IndemnitesSaisiesTableFilterComposer
    extends Composer<_$AppDatabase, $IndemnitesSaisiesTable> {
  $$IndemnitesSaisiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get participantNom => $composableBuilder(
    column: $table.participantNom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etatPaiement => $composableBuilder(
    column: $table.etatPaiement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get delaiRoute => $composableBuilder(
    column: $table.delaiRoute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nombreJoursActivite => $composableBuilder(
    column: $table.nombreJoursActivite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restauration => $composableBuilder(
    column: $table.restauration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taux => $composableBuilder(
    column: $table.taux,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IndemnitesSaisiesTableOrderingComposer
    extends Composer<_$AppDatabase, $IndemnitesSaisiesTable> {
  $$IndemnitesSaisiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get participantNom => $composableBuilder(
    column: $table.participantNom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etatPaiement => $composableBuilder(
    column: $table.etatPaiement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get delaiRoute => $composableBuilder(
    column: $table.delaiRoute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nombreJoursActivite => $composableBuilder(
    column: $table.nombreJoursActivite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restauration => $composableBuilder(
    column: $table.restauration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taux => $composableBuilder(
    column: $table.taux,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IndemnitesSaisiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IndemnitesSaisiesTable> {
  $$IndemnitesSaisiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => column,
  );

  GeneratedColumn<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get participantNom => $composableBuilder(
    column: $table.participantNom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etatPaiement => $composableBuilder(
    column: $table.etatPaiement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get delaiRoute => $composableBuilder(
    column: $table.delaiRoute,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nombreJoursActivite => $composableBuilder(
    column: $table.nombreJoursActivite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get restauration => $composableBuilder(
    column: $table.restauration,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taux =>
      $composableBuilder(column: $table.taux, builder: (column) => column);

  GeneratedColumn<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);
}

class $$IndemnitesSaisiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IndemnitesSaisiesTable,
          IndemniteSaisie,
          $$IndemnitesSaisiesTableFilterComposer,
          $$IndemnitesSaisiesTableOrderingComposer,
          $$IndemnitesSaisiesTableAnnotationComposer,
          $$IndemnitesSaisiesTableCreateCompanionBuilder,
          $$IndemnitesSaisiesTableUpdateCompanionBuilder,
          (
            IndemniteSaisie,
            BaseReferences<
              _$AppDatabase,
              $IndemnitesSaisiesTable,
              IndemniteSaisie
            >,
          ),
          IndemniteSaisie,
          PrefetchHooks Function()
        > {
  $$IndemnitesSaisiesTableTableManager(
    _$AppDatabase db,
    $IndemnitesSaisiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IndemnitesSaisiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IndemnitesSaisiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IndemnitesSaisiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> activiteCode = const Value.absent(),
                Value<String> ligneBudgetaire = const Value.absent(),
                Value<int?> participantId = const Value.absent(),
                Value<String> participantNom = const Value.absent(),
                Value<String> etatPaiement = const Value.absent(),
                Value<String?> provenance = const Value.absent(),
                Value<double> delaiRoute = const Value.absent(),
                Value<double> nombreJoursActivite = const Value.absent(),
                Value<bool> restauration = const Value.absent(),
                Value<double> taux = const Value.absent(),
                Value<double> montantAlloue = const Value.absent(),
                Value<double> montantPaye = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
              }) => IndemnitesSaisiesCompanion(
                id: id,
                activiteCode: activiteCode,
                ligneBudgetaire: ligneBudgetaire,
                participantId: participantId,
                participantNom: participantNom,
                etatPaiement: etatPaiement,
                provenance: provenance,
                delaiRoute: delaiRoute,
                nombreJoursActivite: nombreJoursActivite,
                restauration: restauration,
                taux: taux,
                montantAlloue: montantAlloue,
                montantPaye: montantPaye,
                creeLe: creeLe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String activiteCode,
                Value<String> ligneBudgetaire = const Value.absent(),
                Value<int?> participantId = const Value.absent(),
                Value<String> participantNom = const Value.absent(),
                Value<String> etatPaiement = const Value.absent(),
                Value<String?> provenance = const Value.absent(),
                Value<double> delaiRoute = const Value.absent(),
                Value<double> nombreJoursActivite = const Value.absent(),
                Value<bool> restauration = const Value.absent(),
                Value<double> taux = const Value.absent(),
                Value<double> montantAlloue = const Value.absent(),
                Value<double> montantPaye = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
              }) => IndemnitesSaisiesCompanion.insert(
                id: id,
                activiteCode: activiteCode,
                ligneBudgetaire: ligneBudgetaire,
                participantId: participantId,
                participantNom: participantNom,
                etatPaiement: etatPaiement,
                provenance: provenance,
                delaiRoute: delaiRoute,
                nombreJoursActivite: nombreJoursActivite,
                restauration: restauration,
                taux: taux,
                montantAlloue: montantAlloue,
                montantPaye: montantPaye,
                creeLe: creeLe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IndemnitesSaisiesTable, IndemniteSaisie>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IndemnitesSaisiesTable,
                    IndemniteSaisie
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IndemnitesSaisiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IndemnitesSaisiesTable,
      IndemniteSaisie,
      $$IndemnitesSaisiesTableFilterComposer,
      $$IndemnitesSaisiesTableOrderingComposer,
      $$IndemnitesSaisiesTableAnnotationComposer,
      $$IndemnitesSaisiesTableCreateCompanionBuilder,
      $$IndemnitesSaisiesTableUpdateCompanionBuilder,
      (
        IndemniteSaisie,
        BaseReferences<_$AppDatabase, $IndemnitesSaisiesTable, IndemniteSaisie>,
      ),
      IndemniteSaisie,
      PrefetchHooks Function()
    >;
typedef $$ControlesPJTableCreateCompanionBuilder =
    ControlesPJCompanion Function({
      Value<int> id,
      Value<String?> activiteCode,
      Value<DateTime?> dateDebutActivite,
      Value<DateTime?> dateFinActivite,
      Value<DateTime?> datePJ,
      Value<String?> ligneBudgetaire,
      Value<String?> beneficiaire,
      Value<String?> typePJ,
      Value<double> montantAlloue,
      Value<double> montantPaye,
      Value<double> montantPJ,
      Value<String> pjRecue,
      Value<String> pjConforme,
      Value<String?> checklistPJ,
      Value<String?> observation,
    });
typedef $$ControlesPJTableUpdateCompanionBuilder =
    ControlesPJCompanion Function({
      Value<int> id,
      Value<String?> activiteCode,
      Value<DateTime?> dateDebutActivite,
      Value<DateTime?> dateFinActivite,
      Value<DateTime?> datePJ,
      Value<String?> ligneBudgetaire,
      Value<String?> beneficiaire,
      Value<String?> typePJ,
      Value<double> montantAlloue,
      Value<double> montantPaye,
      Value<double> montantPJ,
      Value<String> pjRecue,
      Value<String> pjConforme,
      Value<String?> checklistPJ,
      Value<String?> observation,
    });

class $$ControlesPJTableFilterComposer
    extends Composer<_$AppDatabase, $ControlesPJTable> {
  $$ControlesPJTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateDebutActivite => $composableBuilder(
    column: $table.dateDebutActivite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFinActivite => $composableBuilder(
    column: $table.dateFinActivite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get datePJ => $composableBuilder(
    column: $table.datePJ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typePJ => $composableBuilder(
    column: $table.typePJ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantPJ => $composableBuilder(
    column: $table.montantPJ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pjRecue => $composableBuilder(
    column: $table.pjRecue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pjConforme => $composableBuilder(
    column: $table.pjConforme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checklistPJ => $composableBuilder(
    column: $table.checklistPJ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ControlesPJTableOrderingComposer
    extends Composer<_$AppDatabase, $ControlesPJTable> {
  $$ControlesPJTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateDebutActivite => $composableBuilder(
    column: $table.dateDebutActivite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFinActivite => $composableBuilder(
    column: $table.dateFinActivite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get datePJ => $composableBuilder(
    column: $table.datePJ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typePJ => $composableBuilder(
    column: $table.typePJ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantPJ => $composableBuilder(
    column: $table.montantPJ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pjRecue => $composableBuilder(
    column: $table.pjRecue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pjConforme => $composableBuilder(
    column: $table.pjConforme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checklistPJ => $composableBuilder(
    column: $table.checklistPJ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ControlesPJTableAnnotationComposer
    extends Composer<_$AppDatabase, $ControlesPJTable> {
  $$ControlesPJTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activiteCode => $composableBuilder(
    column: $table.activiteCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateDebutActivite => $composableBuilder(
    column: $table.dateDebutActivite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateFinActivite => $composableBuilder(
    column: $table.dateFinActivite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get datePJ =>
      $composableBuilder(column: $table.datePJ, builder: (column) => column);

  GeneratedColumn<String> get ligneBudgetaire => $composableBuilder(
    column: $table.ligneBudgetaire,
    builder: (column) => column,
  );

  GeneratedColumn<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typePJ =>
      $composableBuilder(column: $table.typePJ, builder: (column) => column);

  GeneratedColumn<double> get montantAlloue => $composableBuilder(
    column: $table.montantAlloue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montantPJ =>
      $composableBuilder(column: $table.montantPJ, builder: (column) => column);

  GeneratedColumn<String> get pjRecue =>
      $composableBuilder(column: $table.pjRecue, builder: (column) => column);

  GeneratedColumn<String> get pjConforme => $composableBuilder(
    column: $table.pjConforme,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checklistPJ => $composableBuilder(
    column: $table.checklistPJ,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );
}

class $$ControlesPJTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ControlesPJTable,
          ControlePJ,
          $$ControlesPJTableFilterComposer,
          $$ControlesPJTableOrderingComposer,
          $$ControlesPJTableAnnotationComposer,
          $$ControlesPJTableCreateCompanionBuilder,
          $$ControlesPJTableUpdateCompanionBuilder,
          (
            ControlePJ,
            BaseReferences<_$AppDatabase, $ControlesPJTable, ControlePJ>,
          ),
          ControlePJ,
          PrefetchHooks Function()
        > {
  $$ControlesPJTableTableManager(_$AppDatabase db, $ControlesPJTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ControlesPJTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ControlesPJTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ControlesPJTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> activiteCode = const Value.absent(),
                Value<DateTime?> dateDebutActivite = const Value.absent(),
                Value<DateTime?> dateFinActivite = const Value.absent(),
                Value<DateTime?> datePJ = const Value.absent(),
                Value<String?> ligneBudgetaire = const Value.absent(),
                Value<String?> beneficiaire = const Value.absent(),
                Value<String?> typePJ = const Value.absent(),
                Value<double> montantAlloue = const Value.absent(),
                Value<double> montantPaye = const Value.absent(),
                Value<double> montantPJ = const Value.absent(),
                Value<String> pjRecue = const Value.absent(),
                Value<String> pjConforme = const Value.absent(),
                Value<String?> checklistPJ = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => ControlesPJCompanion(
                id: id,
                activiteCode: activiteCode,
                dateDebutActivite: dateDebutActivite,
                dateFinActivite: dateFinActivite,
                datePJ: datePJ,
                ligneBudgetaire: ligneBudgetaire,
                beneficiaire: beneficiaire,
                typePJ: typePJ,
                montantAlloue: montantAlloue,
                montantPaye: montantPaye,
                montantPJ: montantPJ,
                pjRecue: pjRecue,
                pjConforme: pjConforme,
                checklistPJ: checklistPJ,
                observation: observation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> activiteCode = const Value.absent(),
                Value<DateTime?> dateDebutActivite = const Value.absent(),
                Value<DateTime?> dateFinActivite = const Value.absent(),
                Value<DateTime?> datePJ = const Value.absent(),
                Value<String?> ligneBudgetaire = const Value.absent(),
                Value<String?> beneficiaire = const Value.absent(),
                Value<String?> typePJ = const Value.absent(),
                Value<double> montantAlloue = const Value.absent(),
                Value<double> montantPaye = const Value.absent(),
                Value<double> montantPJ = const Value.absent(),
                Value<String> pjRecue = const Value.absent(),
                Value<String> pjConforme = const Value.absent(),
                Value<String?> checklistPJ = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => ControlesPJCompanion.insert(
                id: id,
                activiteCode: activiteCode,
                dateDebutActivite: dateDebutActivite,
                dateFinActivite: dateFinActivite,
                datePJ: datePJ,
                ligneBudgetaire: ligneBudgetaire,
                beneficiaire: beneficiaire,
                typePJ: typePJ,
                montantAlloue: montantAlloue,
                montantPaye: montantPaye,
                montantPJ: montantPJ,
                pjRecue: pjRecue,
                pjConforme: pjConforme,
                checklistPJ: checklistPJ,
                observation: observation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ControlesPJTable, ControlePJ>(table),
                  BaseReferences<_$AppDatabase, $ControlesPJTable, ControlePJ>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ControlesPJTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ControlesPJTable,
      ControlePJ,
      $$ControlesPJTableFilterComposer,
      $$ControlesPJTableOrderingComposer,
      $$ControlesPJTableAnnotationComposer,
      $$ControlesPJTableCreateCompanionBuilder,
      $$ControlesPJTableUpdateCompanionBuilder,
      (
        ControlePJ,
        BaseReferences<_$AppDatabase, $ControlesPJTable, ControlePJ>,
      ),
      ControlePJ,
      PrefetchHooks Function()
    >;
typedef $$DepensesTableCreateCompanionBuilder =
    DepensesCompanion Function({
      Value<int> id,
      Value<DateTime?> dateEnregistrement,
      Value<DateTime?> datePieceComptable,
      Value<String?> periodeAutorisee,
      Value<String> fonds,
      Value<String?> refDecaissement,
      Value<String?> refPieceDepense,
      Value<String?> dctNumero,
      Value<String?> codeActivite,
      Value<String?> codeBudget,
      Value<String> designation,
      Value<String?> beneficiaire,
      Value<int?> controlePJId,
      Value<String?> unite,
      Value<double> nbJrMois,
      Value<double> quantite,
      Value<double> frequence,
      Value<double> pu,
      Value<String?> observation,
    });
typedef $$DepensesTableUpdateCompanionBuilder =
    DepensesCompanion Function({
      Value<int> id,
      Value<DateTime?> dateEnregistrement,
      Value<DateTime?> datePieceComptable,
      Value<String?> periodeAutorisee,
      Value<String> fonds,
      Value<String?> refDecaissement,
      Value<String?> refPieceDepense,
      Value<String?> dctNumero,
      Value<String?> codeActivite,
      Value<String?> codeBudget,
      Value<String> designation,
      Value<String?> beneficiaire,
      Value<int?> controlePJId,
      Value<String?> unite,
      Value<double> nbJrMois,
      Value<double> quantite,
      Value<double> frequence,
      Value<double> pu,
      Value<String?> observation,
    });

class $$DepensesTableFilterComposer
    extends Composer<_$AppDatabase, $DepensesTable> {
  $$DepensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateEnregistrement => $composableBuilder(
    column: $table.dateEnregistrement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get datePieceComptable => $composableBuilder(
    column: $table.datePieceComptable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodeAutorisee => $composableBuilder(
    column: $table.periodeAutorisee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fonds => $composableBuilder(
    column: $table.fonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDecaissement => $composableBuilder(
    column: $table.refDecaissement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refPieceDepense => $composableBuilder(
    column: $table.refPieceDepense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dctNumero => $composableBuilder(
    column: $table.dctNumero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeActivite => $composableBuilder(
    column: $table.codeActivite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeBudget => $composableBuilder(
    column: $table.codeBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get controlePJId => $composableBuilder(
    column: $table.controlePJId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nbJrMois => $composableBuilder(
    column: $table.nbJrMois,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get frequence => $composableBuilder(
    column: $table.frequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pu => $composableBuilder(
    column: $table.pu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DepensesTableOrderingComposer
    extends Composer<_$AppDatabase, $DepensesTable> {
  $$DepensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateEnregistrement => $composableBuilder(
    column: $table.dateEnregistrement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get datePieceComptable => $composableBuilder(
    column: $table.datePieceComptable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodeAutorisee => $composableBuilder(
    column: $table.periodeAutorisee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fonds => $composableBuilder(
    column: $table.fonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDecaissement => $composableBuilder(
    column: $table.refDecaissement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refPieceDepense => $composableBuilder(
    column: $table.refPieceDepense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dctNumero => $composableBuilder(
    column: $table.dctNumero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeActivite => $composableBuilder(
    column: $table.codeActivite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeBudget => $composableBuilder(
    column: $table.codeBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get controlePJId => $composableBuilder(
    column: $table.controlePJId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nbJrMois => $composableBuilder(
    column: $table.nbJrMois,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get frequence => $composableBuilder(
    column: $table.frequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pu => $composableBuilder(
    column: $table.pu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DepensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DepensesTable> {
  $$DepensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dateEnregistrement => $composableBuilder(
    column: $table.dateEnregistrement,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get datePieceComptable => $composableBuilder(
    column: $table.datePieceComptable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodeAutorisee => $composableBuilder(
    column: $table.periodeAutorisee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fonds =>
      $composableBuilder(column: $table.fonds, builder: (column) => column);

  GeneratedColumn<String> get refDecaissement => $composableBuilder(
    column: $table.refDecaissement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refPieceDepense => $composableBuilder(
    column: $table.refPieceDepense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dctNumero =>
      $composableBuilder(column: $table.dctNumero, builder: (column) => column);

  GeneratedColumn<String> get codeActivite => $composableBuilder(
    column: $table.codeActivite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codeBudget => $composableBuilder(
    column: $table.codeBudget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => column,
  );

  GeneratedColumn<int> get controlePJId => $composableBuilder(
    column: $table.controlePJId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unite =>
      $composableBuilder(column: $table.unite, builder: (column) => column);

  GeneratedColumn<double> get nbJrMois =>
      $composableBuilder(column: $table.nbJrMois, builder: (column) => column);

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<double> get frequence =>
      $composableBuilder(column: $table.frequence, builder: (column) => column);

  GeneratedColumn<double> get pu =>
      $composableBuilder(column: $table.pu, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );
}

class $$DepensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DepensesTable,
          Depense,
          $$DepensesTableFilterComposer,
          $$DepensesTableOrderingComposer,
          $$DepensesTableAnnotationComposer,
          $$DepensesTableCreateCompanionBuilder,
          $$DepensesTableUpdateCompanionBuilder,
          (Depense, BaseReferences<_$AppDatabase, $DepensesTable, Depense>),
          Depense,
          PrefetchHooks Function()
        > {
  $$DepensesTableTableManager(_$AppDatabase db, $DepensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> dateEnregistrement = const Value.absent(),
                Value<DateTime?> datePieceComptable = const Value.absent(),
                Value<String?> periodeAutorisee = const Value.absent(),
                Value<String> fonds = const Value.absent(),
                Value<String?> refDecaissement = const Value.absent(),
                Value<String?> refPieceDepense = const Value.absent(),
                Value<String?> dctNumero = const Value.absent(),
                Value<String?> codeActivite = const Value.absent(),
                Value<String?> codeBudget = const Value.absent(),
                Value<String> designation = const Value.absent(),
                Value<String?> beneficiaire = const Value.absent(),
                Value<int?> controlePJId = const Value.absent(),
                Value<String?> unite = const Value.absent(),
                Value<double> nbJrMois = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<double> frequence = const Value.absent(),
                Value<double> pu = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => DepensesCompanion(
                id: id,
                dateEnregistrement: dateEnregistrement,
                datePieceComptable: datePieceComptable,
                periodeAutorisee: periodeAutorisee,
                fonds: fonds,
                refDecaissement: refDecaissement,
                refPieceDepense: refPieceDepense,
                dctNumero: dctNumero,
                codeActivite: codeActivite,
                codeBudget: codeBudget,
                designation: designation,
                beneficiaire: beneficiaire,
                controlePJId: controlePJId,
                unite: unite,
                nbJrMois: nbJrMois,
                quantite: quantite,
                frequence: frequence,
                pu: pu,
                observation: observation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> dateEnregistrement = const Value.absent(),
                Value<DateTime?> datePieceComptable = const Value.absent(),
                Value<String?> periodeAutorisee = const Value.absent(),
                Value<String> fonds = const Value.absent(),
                Value<String?> refDecaissement = const Value.absent(),
                Value<String?> refPieceDepense = const Value.absent(),
                Value<String?> dctNumero = const Value.absent(),
                Value<String?> codeActivite = const Value.absent(),
                Value<String?> codeBudget = const Value.absent(),
                Value<String> designation = const Value.absent(),
                Value<String?> beneficiaire = const Value.absent(),
                Value<int?> controlePJId = const Value.absent(),
                Value<String?> unite = const Value.absent(),
                Value<double> nbJrMois = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<double> frequence = const Value.absent(),
                Value<double> pu = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => DepensesCompanion.insert(
                id: id,
                dateEnregistrement: dateEnregistrement,
                datePieceComptable: datePieceComptable,
                periodeAutorisee: periodeAutorisee,
                fonds: fonds,
                refDecaissement: refDecaissement,
                refPieceDepense: refPieceDepense,
                dctNumero: dctNumero,
                codeActivite: codeActivite,
                codeBudget: codeBudget,
                designation: designation,
                beneficiaire: beneficiaire,
                controlePJId: controlePJId,
                unite: unite,
                nbJrMois: nbJrMois,
                quantite: quantite,
                frequence: frequence,
                pu: pu,
                observation: observation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DepensesTable, Depense>(table),
                  BaseReferences<_$AppDatabase, $DepensesTable, Depense>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DepensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DepensesTable,
      Depense,
      $$DepensesTableFilterComposer,
      $$DepensesTableOrderingComposer,
      $$DepensesTableAnnotationComposer,
      $$DepensesTableCreateCompanionBuilder,
      $$DepensesTableUpdateCompanionBuilder,
      (Depense, BaseReferences<_$AppDatabase, $DepensesTable, Depense>),
      Depense,
      PrefetchHooks Function()
    >;
typedef $$BanqueOperationsTableCreateCompanionBuilder =
    BanqueOperationsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<String?> refPiece,
      Value<String> type,
      Value<String?> refCheque,
      Value<String> description,
      Value<double> recettes,
      Value<double> depenses,
      Value<String?> bailleur,
      Value<String?> beneficiaire,
      Value<String?> observation,
    });
typedef $$BanqueOperationsTableUpdateCompanionBuilder =
    BanqueOperationsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String?> refPiece,
      Value<String> type,
      Value<String?> refCheque,
      Value<String> description,
      Value<double> recettes,
      Value<double> depenses,
      Value<String?> bailleur,
      Value<String?> beneficiaire,
      Value<String?> observation,
    });

class $$BanqueOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $BanqueOperationsTable> {
  $$BanqueOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refPiece => $composableBuilder(
    column: $table.refPiece,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refCheque => $composableBuilder(
    column: $table.refCheque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recettes => $composableBuilder(
    column: $table.recettes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get depenses => $composableBuilder(
    column: $table.depenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bailleur => $composableBuilder(
    column: $table.bailleur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BanqueOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $BanqueOperationsTable> {
  $$BanqueOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refPiece => $composableBuilder(
    column: $table.refPiece,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refCheque => $composableBuilder(
    column: $table.refCheque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recettes => $composableBuilder(
    column: $table.recettes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get depenses => $composableBuilder(
    column: $table.depenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bailleur => $composableBuilder(
    column: $table.bailleur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BanqueOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BanqueOperationsTable> {
  $$BanqueOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get refPiece =>
      $composableBuilder(column: $table.refPiece, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get refCheque =>
      $composableBuilder(column: $table.refCheque, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recettes =>
      $composableBuilder(column: $table.recettes, builder: (column) => column);

  GeneratedColumn<double> get depenses =>
      $composableBuilder(column: $table.depenses, builder: (column) => column);

  GeneratedColumn<String> get bailleur =>
      $composableBuilder(column: $table.bailleur, builder: (column) => column);

  GeneratedColumn<String> get beneficiaire => $composableBuilder(
    column: $table.beneficiaire,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );
}

class $$BanqueOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BanqueOperationsTable,
          BanqueOperation,
          $$BanqueOperationsTableFilterComposer,
          $$BanqueOperationsTableOrderingComposer,
          $$BanqueOperationsTableAnnotationComposer,
          $$BanqueOperationsTableCreateCompanionBuilder,
          $$BanqueOperationsTableUpdateCompanionBuilder,
          (
            BanqueOperation,
            BaseReferences<
              _$AppDatabase,
              $BanqueOperationsTable,
              BanqueOperation
            >,
          ),
          BanqueOperation,
          PrefetchHooks Function()
        > {
  $$BanqueOperationsTableTableManager(
    _$AppDatabase db,
    $BanqueOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BanqueOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BanqueOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BanqueOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> refPiece = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> refCheque = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> recettes = const Value.absent(),
                Value<double> depenses = const Value.absent(),
                Value<String?> bailleur = const Value.absent(),
                Value<String?> beneficiaire = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => BanqueOperationsCompanion(
                id: id,
                date: date,
                refPiece: refPiece,
                type: type,
                refCheque: refCheque,
                description: description,
                recettes: recettes,
                depenses: depenses,
                bailleur: bailleur,
                beneficiaire: beneficiaire,
                observation: observation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<String?> refPiece = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> refCheque = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> recettes = const Value.absent(),
                Value<double> depenses = const Value.absent(),
                Value<String?> bailleur = const Value.absent(),
                Value<String?> beneficiaire = const Value.absent(),
                Value<String?> observation = const Value.absent(),
              }) => BanqueOperationsCompanion.insert(
                id: id,
                date: date,
                refPiece: refPiece,
                type: type,
                refCheque: refCheque,
                description: description,
                recettes: recettes,
                depenses: depenses,
                bailleur: bailleur,
                beneficiaire: beneficiaire,
                observation: observation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BanqueOperationsTable, BanqueOperation>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BanqueOperationsTable,
                    BanqueOperation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BanqueOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BanqueOperationsTable,
      BanqueOperation,
      $$BanqueOperationsTableFilterComposer,
      $$BanqueOperationsTableOrderingComposer,
      $$BanqueOperationsTableAnnotationComposer,
      $$BanqueOperationsTableCreateCompanionBuilder,
      $$BanqueOperationsTableUpdateCompanionBuilder,
      (
        BanqueOperation,
        BaseReferences<_$AppDatabase, $BanqueOperationsTable, BanqueOperation>,
      ),
      BanqueOperation,
      PrefetchHooks Function()
    >;
typedef $$ReleveBancaireTableCreateCompanionBuilder =
    ReleveBancaireCompanion Function({
      Value<int> id,
      Value<DateTime?> date,
      Value<String?> reference,
      Value<String?> libelle,
      Value<double> debit,
      Value<double> credit,
    });
typedef $$ReleveBancaireTableUpdateCompanionBuilder =
    ReleveBancaireCompanion Function({
      Value<int> id,
      Value<DateTime?> date,
      Value<String?> reference,
      Value<String?> libelle,
      Value<double> debit,
      Value<double> credit,
    });

class $$ReleveBancaireTableFilterComposer
    extends Composer<_$AppDatabase, $ReleveBancaireTable> {
  $$ReleveBancaireTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libelle => $composableBuilder(
    column: $table.libelle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReleveBancaireTableOrderingComposer
    extends Composer<_$AppDatabase, $ReleveBancaireTable> {
  $$ReleveBancaireTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libelle => $composableBuilder(
    column: $table.libelle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReleveBancaireTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReleveBancaireTable> {
  $$ReleveBancaireTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get libelle =>
      $composableBuilder(column: $table.libelle, builder: (column) => column);

  GeneratedColumn<double> get debit =>
      $composableBuilder(column: $table.debit, builder: (column) => column);

  GeneratedColumn<double> get credit =>
      $composableBuilder(column: $table.credit, builder: (column) => column);
}

class $$ReleveBancaireTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReleveBancaireTable,
          ReleveBancaireLigne,
          $$ReleveBancaireTableFilterComposer,
          $$ReleveBancaireTableOrderingComposer,
          $$ReleveBancaireTableAnnotationComposer,
          $$ReleveBancaireTableCreateCompanionBuilder,
          $$ReleveBancaireTableUpdateCompanionBuilder,
          (
            ReleveBancaireLigne,
            BaseReferences<
              _$AppDatabase,
              $ReleveBancaireTable,
              ReleveBancaireLigne
            >,
          ),
          ReleveBancaireLigne,
          PrefetchHooks Function()
        > {
  $$ReleveBancaireTableTableManager(
    _$AppDatabase db,
    $ReleveBancaireTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReleveBancaireTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReleveBancaireTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReleveBancaireTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> libelle = const Value.absent(),
                Value<double> debit = const Value.absent(),
                Value<double> credit = const Value.absent(),
              }) => ReleveBancaireCompanion(
                id: id,
                date: date,
                reference: reference,
                libelle: libelle,
                debit: debit,
                credit: credit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> libelle = const Value.absent(),
                Value<double> debit = const Value.absent(),
                Value<double> credit = const Value.absent(),
              }) => ReleveBancaireCompanion.insert(
                id: id,
                date: date,
                reference: reference,
                libelle: libelle,
                debit: debit,
                credit: credit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReleveBancaireTable, ReleveBancaireLigne>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReleveBancaireTable,
                    ReleveBancaireLigne
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReleveBancaireTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReleveBancaireTable,
      ReleveBancaireLigne,
      $$ReleveBancaireTableFilterComposer,
      $$ReleveBancaireTableOrderingComposer,
      $$ReleveBancaireTableAnnotationComposer,
      $$ReleveBancaireTableCreateCompanionBuilder,
      $$ReleveBancaireTableUpdateCompanionBuilder,
      (
        ReleveBancaireLigne,
        BaseReferences<
          _$AppDatabase,
          $ReleveBancaireTable,
          ReleveBancaireLigne
        >,
      ),
      ReleveBancaireLigne,
      PrefetchHooks Function()
    >;
typedef $$UtilisateursTableCreateCompanionBuilder =
    UtilisateursCompanion Function({
      Value<int> id,
      required String identifiant,
      required String nom,
      Value<String> role,
      Value<bool> actif,
      Value<String?> motDePasseHash,
      Value<String?> prenomUtilisateur,
      Value<String?> fonction,
      Value<String?> email,
      Value<String?> telephone,
      Value<String?> photo,
      Value<DateTime?> dateCreation,
      Value<DateTime?> derniereConnexion,
    });
typedef $$UtilisateursTableUpdateCompanionBuilder =
    UtilisateursCompanion Function({
      Value<int> id,
      Value<String> identifiant,
      Value<String> nom,
      Value<String> role,
      Value<bool> actif,
      Value<String?> motDePasseHash,
      Value<String?> prenomUtilisateur,
      Value<String?> fonction,
      Value<String?> email,
      Value<String?> telephone,
      Value<String?> photo,
      Value<DateTime?> dateCreation,
      Value<DateTime?> derniereConnexion,
    });

class $$UtilisateursTableFilterComposer
    extends Composer<_$AppDatabase, $UtilisateursTable> {
  $$UtilisateursTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identifiant => $composableBuilder(
    column: $table.identifiant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motDePasseHash => $composableBuilder(
    column: $table.motDePasseHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prenomUtilisateur => $composableBuilder(
    column: $table.prenomUtilisateur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get derniereConnexion => $composableBuilder(
    column: $table.derniereConnexion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UtilisateursTableOrderingComposer
    extends Composer<_$AppDatabase, $UtilisateursTable> {
  $$UtilisateursTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identifiant => $composableBuilder(
    column: $table.identifiant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get actif => $composableBuilder(
    column: $table.actif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motDePasseHash => $composableBuilder(
    column: $table.motDePasseHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prenomUtilisateur => $composableBuilder(
    column: $table.prenomUtilisateur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get derniereConnexion => $composableBuilder(
    column: $table.derniereConnexion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UtilisateursTableAnnotationComposer
    extends Composer<_$AppDatabase, $UtilisateursTable> {
  $$UtilisateursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get identifiant => $composableBuilder(
    column: $table.identifiant,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<String> get motDePasseHash => $composableBuilder(
    column: $table.motDePasseHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prenomUtilisateur => $composableBuilder(
    column: $table.prenomUtilisateur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fonction =>
      $composableBuilder(column: $table.fonction, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get derniereConnexion => $composableBuilder(
    column: $table.derniereConnexion,
    builder: (column) => column,
  );
}

class $$UtilisateursTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UtilisateursTable,
          Utilisateur,
          $$UtilisateursTableFilterComposer,
          $$UtilisateursTableOrderingComposer,
          $$UtilisateursTableAnnotationComposer,
          $$UtilisateursTableCreateCompanionBuilder,
          $$UtilisateursTableUpdateCompanionBuilder,
          (
            Utilisateur,
            BaseReferences<_$AppDatabase, $UtilisateursTable, Utilisateur>,
          ),
          Utilisateur,
          PrefetchHooks Function()
        > {
  $$UtilisateursTableTableManager(_$AppDatabase db, $UtilisateursTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UtilisateursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UtilisateursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UtilisateursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> identifiant = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> actif = const Value.absent(),
                Value<String?> motDePasseHash = const Value.absent(),
                Value<String?> prenomUtilisateur = const Value.absent(),
                Value<String?> fonction = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> telephone = const Value.absent(),
                Value<String?> photo = const Value.absent(),
                Value<DateTime?> dateCreation = const Value.absent(),
                Value<DateTime?> derniereConnexion = const Value.absent(),
              }) => UtilisateursCompanion(
                id: id,
                identifiant: identifiant,
                nom: nom,
                role: role,
                actif: actif,
                motDePasseHash: motDePasseHash,
                prenomUtilisateur: prenomUtilisateur,
                fonction: fonction,
                email: email,
                telephone: telephone,
                photo: photo,
                dateCreation: dateCreation,
                derniereConnexion: derniereConnexion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String identifiant,
                required String nom,
                Value<String> role = const Value.absent(),
                Value<bool> actif = const Value.absent(),
                Value<String?> motDePasseHash = const Value.absent(),
                Value<String?> prenomUtilisateur = const Value.absent(),
                Value<String?> fonction = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> telephone = const Value.absent(),
                Value<String?> photo = const Value.absent(),
                Value<DateTime?> dateCreation = const Value.absent(),
                Value<DateTime?> derniereConnexion = const Value.absent(),
              }) => UtilisateursCompanion.insert(
                id: id,
                identifiant: identifiant,
                nom: nom,
                role: role,
                actif: actif,
                motDePasseHash: motDePasseHash,
                prenomUtilisateur: prenomUtilisateur,
                fonction: fonction,
                email: email,
                telephone: telephone,
                photo: photo,
                dateCreation: dateCreation,
                derniereConnexion: derniereConnexion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UtilisateursTable, Utilisateur>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UtilisateursTable,
                    Utilisateur
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UtilisateursTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UtilisateursTable,
      Utilisateur,
      $$UtilisateursTableFilterComposer,
      $$UtilisateursTableOrderingComposer,
      $$UtilisateursTableAnnotationComposer,
      $$UtilisateursTableCreateCompanionBuilder,
      $$UtilisateursTableUpdateCompanionBuilder,
      (
        Utilisateur,
        BaseReferences<_$AppDatabase, $UtilisateursTable, Utilisateur>,
      ),
      Utilisateur,
      PrefetchHooks Function()
    >;
typedef $$JournalAuditTableCreateCompanionBuilder =
    JournalAuditCompanion Function({
      Value<int> id,
      Value<DateTime> dateHeure,
      Value<String> utilisateur,
      required String action,
      required String entite,
      Value<String?> entiteId,
      Value<String?> champ,
      Value<String?> ancienneValeur,
      Value<String?> nouvelleValeur,
    });
typedef $$JournalAuditTableUpdateCompanionBuilder =
    JournalAuditCompanion Function({
      Value<int> id,
      Value<DateTime> dateHeure,
      Value<String> utilisateur,
      Value<String> action,
      Value<String> entite,
      Value<String?> entiteId,
      Value<String?> champ,
      Value<String?> ancienneValeur,
      Value<String?> nouvelleValeur,
    });

class $$JournalAuditTableFilterComposer
    extends Composer<_$AppDatabase, $JournalAuditTable> {
  $$JournalAuditTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateHeure => $composableBuilder(
    column: $table.dateHeure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utilisateur => $composableBuilder(
    column: $table.utilisateur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entite => $composableBuilder(
    column: $table.entite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entiteId => $composableBuilder(
    column: $table.entiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get champ => $composableBuilder(
    column: $table.champ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ancienneValeur => $composableBuilder(
    column: $table.ancienneValeur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nouvelleValeur => $composableBuilder(
    column: $table.nouvelleValeur,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalAuditTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalAuditTable> {
  $$JournalAuditTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateHeure => $composableBuilder(
    column: $table.dateHeure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utilisateur => $composableBuilder(
    column: $table.utilisateur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entite => $composableBuilder(
    column: $table.entite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entiteId => $composableBuilder(
    column: $table.entiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get champ => $composableBuilder(
    column: $table.champ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ancienneValeur => $composableBuilder(
    column: $table.ancienneValeur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nouvelleValeur => $composableBuilder(
    column: $table.nouvelleValeur,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalAuditTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalAuditTable> {
  $$JournalAuditTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dateHeure =>
      $composableBuilder(column: $table.dateHeure, builder: (column) => column);

  GeneratedColumn<String> get utilisateur => $composableBuilder(
    column: $table.utilisateur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entite =>
      $composableBuilder(column: $table.entite, builder: (column) => column);

  GeneratedColumn<String> get entiteId =>
      $composableBuilder(column: $table.entiteId, builder: (column) => column);

  GeneratedColumn<String> get champ =>
      $composableBuilder(column: $table.champ, builder: (column) => column);

  GeneratedColumn<String> get ancienneValeur => $composableBuilder(
    column: $table.ancienneValeur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nouvelleValeur => $composableBuilder(
    column: $table.nouvelleValeur,
    builder: (column) => column,
  );
}

class $$JournalAuditTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalAuditTable,
          JournalAuditEntry,
          $$JournalAuditTableFilterComposer,
          $$JournalAuditTableOrderingComposer,
          $$JournalAuditTableAnnotationComposer,
          $$JournalAuditTableCreateCompanionBuilder,
          $$JournalAuditTableUpdateCompanionBuilder,
          (
            JournalAuditEntry,
            BaseReferences<
              _$AppDatabase,
              $JournalAuditTable,
              JournalAuditEntry
            >,
          ),
          JournalAuditEntry,
          PrefetchHooks Function()
        > {
  $$JournalAuditTableTableManager(_$AppDatabase db, $JournalAuditTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalAuditTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalAuditTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalAuditTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> dateHeure = const Value.absent(),
                Value<String> utilisateur = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entite = const Value.absent(),
                Value<String?> entiteId = const Value.absent(),
                Value<String?> champ = const Value.absent(),
                Value<String?> ancienneValeur = const Value.absent(),
                Value<String?> nouvelleValeur = const Value.absent(),
              }) => JournalAuditCompanion(
                id: id,
                dateHeure: dateHeure,
                utilisateur: utilisateur,
                action: action,
                entite: entite,
                entiteId: entiteId,
                champ: champ,
                ancienneValeur: ancienneValeur,
                nouvelleValeur: nouvelleValeur,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> dateHeure = const Value.absent(),
                Value<String> utilisateur = const Value.absent(),
                required String action,
                required String entite,
                Value<String?> entiteId = const Value.absent(),
                Value<String?> champ = const Value.absent(),
                Value<String?> ancienneValeur = const Value.absent(),
                Value<String?> nouvelleValeur = const Value.absent(),
              }) => JournalAuditCompanion.insert(
                id: id,
                dateHeure: dateHeure,
                utilisateur: utilisateur,
                action: action,
                entite: entite,
                entiteId: entiteId,
                champ: champ,
                ancienneValeur: ancienneValeur,
                nouvelleValeur: nouvelleValeur,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalAuditTable, JournalAuditEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalAuditTable,
                    JournalAuditEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalAuditTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalAuditTable,
      JournalAuditEntry,
      $$JournalAuditTableFilterComposer,
      $$JournalAuditTableOrderingComposer,
      $$JournalAuditTableAnnotationComposer,
      $$JournalAuditTableCreateCompanionBuilder,
      $$JournalAuditTableUpdateCompanionBuilder,
      (
        JournalAuditEntry,
        BaseReferences<_$AppDatabase, $JournalAuditTable, JournalAuditEntry>,
      ),
      JournalAuditEntry,
      PrefetchHooks Function()
    >;
typedef $$ParametresTableCreateCompanionBuilder =
    ParametresCompanion Function({
      required String cle,
      Value<String> valeur,
      Value<int> rowid,
    });
typedef $$ParametresTableUpdateCompanionBuilder =
    ParametresCompanion Function({
      Value<String> cle,
      Value<String> valeur,
      Value<int> rowid,
    });

class $$ParametresTableFilterComposer
    extends Composer<_$AppDatabase, $ParametresTable> {
  $$ParametresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cle => $composableBuilder(
    column: $table.cle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valeur => $composableBuilder(
    column: $table.valeur,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ParametresTableOrderingComposer
    extends Composer<_$AppDatabase, $ParametresTable> {
  $$ParametresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cle => $composableBuilder(
    column: $table.cle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valeur => $composableBuilder(
    column: $table.valeur,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParametresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParametresTable> {
  $$ParametresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cle =>
      $composableBuilder(column: $table.cle, builder: (column) => column);

  GeneratedColumn<String> get valeur =>
      $composableBuilder(column: $table.valeur, builder: (column) => column);
}

class $$ParametresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParametresTable,
          Parametre,
          $$ParametresTableFilterComposer,
          $$ParametresTableOrderingComposer,
          $$ParametresTableAnnotationComposer,
          $$ParametresTableCreateCompanionBuilder,
          $$ParametresTableUpdateCompanionBuilder,
          (
            Parametre,
            BaseReferences<_$AppDatabase, $ParametresTable, Parametre>,
          ),
          Parametre,
          PrefetchHooks Function()
        > {
  $$ParametresTableTableManager(_$AppDatabase db, $ParametresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParametresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParametresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParametresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cle = const Value.absent(),
                Value<String> valeur = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParametresCompanion(cle: cle, valeur: valeur, rowid: rowid),
          createCompanionCallback:
              ({
                required String cle,
                Value<String> valeur = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParametresCompanion.insert(
                cle: cle,
                valeur: valeur,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ParametresTable, Parametre>(table),
                  BaseReferences<_$AppDatabase, $ParametresTable, Parametre>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParametresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParametresTable,
      Parametre,
      $$ParametresTableFilterComposer,
      $$ParametresTableOrderingComposer,
      $$ParametresTableAnnotationComposer,
      $$ParametresTableCreateCompanionBuilder,
      $$ParametresTableUpdateCompanionBuilder,
      (Parametre, BaseReferences<_$AppDatabase, $ParametresTable, Parametre>),
      Parametre,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DistrictsTableTableManager get districts =>
      $$DistrictsTableTableManager(_db, _db.districts);
  $$ReferentielTarifsTableTableManager get referentielTarifs =>
      $$ReferentielTarifsTableTableManager(_db, _db.referentielTarifs);
  $$ReferenceValeursTableTableManager get referenceValeurs =>
      $$ReferenceValeursTableTableManager(_db, _db.referenceValeurs);
  $$ActivitesTableTableManager get activites =>
      $$ActivitesTableTableManager(_db, _db.activites);
  $$LignesBudgetTableTableManager get lignesBudget =>
      $$LignesBudgetTableTableManager(_db, _db.lignesBudget);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$ActiviteParticipantsTableTableManager get activiteParticipants =>
      $$ActiviteParticipantsTableTableManager(_db, _db.activiteParticipants);
  $$PresencesTableTableManager get presences =>
      $$PresencesTableTableManager(_db, _db.presences);
  $$IndemnitesSaisiesTableTableManager get indemnitesSaisies =>
      $$IndemnitesSaisiesTableTableManager(_db, _db.indemnitesSaisies);
  $$ControlesPJTableTableManager get controlesPJ =>
      $$ControlesPJTableTableManager(_db, _db.controlesPJ);
  $$DepensesTableTableManager get depenses =>
      $$DepensesTableTableManager(_db, _db.depenses);
  $$BanqueOperationsTableTableManager get banqueOperations =>
      $$BanqueOperationsTableTableManager(_db, _db.banqueOperations);
  $$ReleveBancaireTableTableManager get releveBancaire =>
      $$ReleveBancaireTableTableManager(_db, _db.releveBancaire);
  $$UtilisateursTableTableManager get utilisateurs =>
      $$UtilisateursTableTableManager(_db, _db.utilisateurs);
  $$JournalAuditTableTableManager get journalAudit =>
      $$JournalAuditTableTableManager(_db, _db.journalAudit);
  $$ParametresTableTableManager get parametres =>
      $$ParametresTableTableManager(_db, _db.parametres);
}
