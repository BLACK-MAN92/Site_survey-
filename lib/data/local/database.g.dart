// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SitesTable extends Sites with TableInfo<$SitesTable, SiteEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _cycleStateMeta =
      const VerificationMeta('cycleState');
  @override
  late final GeneratedColumn<String> cycleState = GeneratedColumn<String>(
      'cycle_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rejectionReasonMeta =
      const VerificationMeta('rejectionReason');
  @override
  late final GeneratedColumn<String> rejectionReason = GeneratedColumn<String>(
      'rejection_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rejectionCommentMeta =
      const VerificationMeta('rejectionComment');
  @override
  late final GeneratedColumn<String> rejectionComment = GeneratedColumn<String>(
      'rejection_comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        latitude,
        longitude,
        cycleState,
        rejectionReason,
        rejectionComment
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  VerificationContext validateIntegrity(Insertable<SiteEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('cycle_state')) {
      context.handle(
          _cycleStateMeta,
          cycleState.isAcceptableOrUnknown(
              data['cycle_state']!, _cycleStateMeta));
    } else if (isInserting) {
      context.missing(_cycleStateMeta);
    }
    if (data.containsKey('rejection_reason')) {
      context.handle(
          _rejectionReasonMeta,
          rejectionReason.isAcceptableOrUnknown(
              data['rejection_reason']!, _rejectionReasonMeta));
    }
    if (data.containsKey('rejection_comment')) {
      context.handle(
          _rejectionCommentMeta,
          rejectionComment.isAcceptableOrUnknown(
              data['rejection_comment']!, _rejectionCommentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SiteEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      cycleState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cycle_state'])!,
      rejectionReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rejection_reason']),
      rejectionComment: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rejection_comment']),
    );
  }

  @override
  $SitesTable createAlias(String alias) {
    return $SitesTable(attachedDatabase, alias);
  }
}

class SiteEntity extends DataClass implements Insertable<SiteEntity> {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String cycleState;
  final String? rejectionReason;
  final String? rejectionComment;
  const SiteEntity(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.cycleState,
      this.rejectionReason,
      this.rejectionComment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['cycle_state'] = Variable<String>(cycleState);
    if (!nullToAbsent || rejectionReason != null) {
      map['rejection_reason'] = Variable<String>(rejectionReason);
    }
    if (!nullToAbsent || rejectionComment != null) {
      map['rejection_comment'] = Variable<String>(rejectionComment);
    }
    return map;
  }

  SitesCompanion toCompanion(bool nullToAbsent) {
    return SitesCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      cycleState: Value(cycleState),
      rejectionReason: rejectionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionReason),
      rejectionComment: rejectionComment == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionComment),
    );
  }

  factory SiteEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      cycleState: serializer.fromJson<String>(json['cycleState']),
      rejectionReason: serializer.fromJson<String?>(json['rejectionReason']),
      rejectionComment: serializer.fromJson<String?>(json['rejectionComment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'cycleState': serializer.toJson<String>(cycleState),
      'rejectionReason': serializer.toJson<String?>(rejectionReason),
      'rejectionComment': serializer.toJson<String?>(rejectionComment),
    };
  }

  SiteEntity copyWith(
          {String? id,
          String? name,
          double? latitude,
          double? longitude,
          String? cycleState,
          Value<String?> rejectionReason = const Value.absent(),
          Value<String?> rejectionComment = const Value.absent()}) =>
      SiteEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        cycleState: cycleState ?? this.cycleState,
        rejectionReason: rejectionReason.present
            ? rejectionReason.value
            : this.rejectionReason,
        rejectionComment: rejectionComment.present
            ? rejectionComment.value
            : this.rejectionComment,
      );
  SiteEntity copyWithCompanion(SitesCompanion data) {
    return SiteEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      cycleState:
          data.cycleState.present ? data.cycleState.value : this.cycleState,
      rejectionReason: data.rejectionReason.present
          ? data.rejectionReason.value
          : this.rejectionReason,
      rejectionComment: data.rejectionComment.present
          ? data.rejectionComment.value
          : this.rejectionComment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('cycleState: $cycleState, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('rejectionComment: $rejectionComment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, latitude, longitude, cycleState,
      rejectionReason, rejectionComment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.cycleState == this.cycleState &&
          other.rejectionReason == this.rejectionReason &&
          other.rejectionComment == this.rejectionComment);
}

class SitesCompanion extends UpdateCompanion<SiteEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> cycleState;
  final Value<String?> rejectionReason;
  final Value<String?> rejectionComment;
  final Value<int> rowid;
  const SitesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.cycleState = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.rejectionComment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SitesCompanion.insert({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String cycleState,
    this.rejectionReason = const Value.absent(),
    this.rejectionComment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        latitude = Value(latitude),
        longitude = Value(longitude),
        cycleState = Value(cycleState);
  static Insertable<SiteEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? cycleState,
    Expression<String>? rejectionReason,
    Expression<String>? rejectionComment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (cycleState != null) 'cycle_state': cycleState,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (rejectionComment != null) 'rejection_comment': rejectionComment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SitesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String>? cycleState,
      Value<String?>? rejectionReason,
      Value<String?>? rejectionComment,
      Value<int>? rowid}) {
    return SitesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cycleState: cycleState ?? this.cycleState,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectionComment: rejectionComment ?? this.rejectionComment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (cycleState.present) {
      map['cycle_state'] = Variable<String>(cycleState.value);
    }
    if (rejectionReason.present) {
      map['rejection_reason'] = Variable<String>(rejectionReason.value);
    }
    if (rejectionComment.present) {
      map['rejection_comment'] = Variable<String>(rejectionComment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('cycleState: $cycleState, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('rejectionComment: $rejectionComment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SurveysTable extends Surveys
    with TableInfo<$SurveysTable, SurveyEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurveysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
      'site_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sites (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plannedDateMeta =
      const VerificationMeta('plannedDate');
  @override
  late final GeneratedColumn<DateTime> plannedDate = GeneratedColumn<DateTime>(
      'planned_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _actualDateMeta =
      const VerificationMeta('actualDate');
  @override
  late final GeneratedColumn<DateTime> actualDate = GeneratedColumn<DateTime>(
      'actual_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _gpsLatMeta = const VerificationMeta('gpsLat');
  @override
  late final GeneratedColumn<double> gpsLat = GeneratedColumn<double>(
      'gps_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _gpsLngMeta = const VerificationMeta('gpsLng');
  @override
  late final GeneratedColumn<double> gpsLng = GeneratedColumn<double>(
      'gps_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _gpsAccuracyMeta =
      const VerificationMeta('gpsAccuracy');
  @override
  late final GeneratedColumn<double> gpsAccuracy = GeneratedColumn<double>(
      'gps_accuracy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _outOfFenceReasonMeta =
      const VerificationMeta('outOfFenceReason');
  @override
  late final GeneratedColumn<String> outOfFenceReason = GeneratedColumn<String>(
      'out_of_fence_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientUuid,
        siteId,
        type,
        plannedDate,
        actualDate,
        gpsLat,
        gpsLng,
        gpsAccuracy,
        outOfFenceReason,
        comment,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surveys';
  @override
  VerificationContext validateIntegrity(Insertable<SurveyEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(_siteIdMeta,
          siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta));
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('planned_date')) {
      context.handle(
          _plannedDateMeta,
          plannedDate.isAcceptableOrUnknown(
              data['planned_date']!, _plannedDateMeta));
    }
    if (data.containsKey('actual_date')) {
      context.handle(
          _actualDateMeta,
          actualDate.isAcceptableOrUnknown(
              data['actual_date']!, _actualDateMeta));
    }
    if (data.containsKey('gps_lat')) {
      context.handle(_gpsLatMeta,
          gpsLat.isAcceptableOrUnknown(data['gps_lat']!, _gpsLatMeta));
    }
    if (data.containsKey('gps_lng')) {
      context.handle(_gpsLngMeta,
          gpsLng.isAcceptableOrUnknown(data['gps_lng']!, _gpsLngMeta));
    }
    if (data.containsKey('gps_accuracy')) {
      context.handle(
          _gpsAccuracyMeta,
          gpsAccuracy.isAcceptableOrUnknown(
              data['gps_accuracy']!, _gpsAccuracyMeta));
    }
    if (data.containsKey('out_of_fence_reason')) {
      context.handle(
          _outOfFenceReasonMeta,
          outOfFenceReason.isAcceptableOrUnknown(
              data['out_of_fence_reason']!, _outOfFenceReasonMeta));
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SurveyEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurveyEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid'])!,
      siteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}site_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      plannedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}planned_date']),
      actualDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}actual_date']),
      gpsLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lat']),
      gpsLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lng']),
      gpsAccuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_accuracy']),
      outOfFenceReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}out_of_fence_reason']),
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $SurveysTable createAlias(String alias) {
    return $SurveysTable(attachedDatabase, alias);
  }
}

class SurveyEntity extends DataClass implements Insertable<SurveyEntity> {
  final String id;
  final String clientUuid;
  final String siteId;
  final String type;
  final DateTime? plannedDate;
  final DateTime? actualDate;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsAccuracy;
  final String? outOfFenceReason;
  final String? comment;
  final String syncStatus;
  const SurveyEntity(
      {required this.id,
      required this.clientUuid,
      required this.siteId,
      required this.type,
      this.plannedDate,
      this.actualDate,
      this.gpsLat,
      this.gpsLng,
      this.gpsAccuracy,
      this.outOfFenceReason,
      this.comment,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['site_id'] = Variable<String>(siteId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || plannedDate != null) {
      map['planned_date'] = Variable<DateTime>(plannedDate);
    }
    if (!nullToAbsent || actualDate != null) {
      map['actual_date'] = Variable<DateTime>(actualDate);
    }
    if (!nullToAbsent || gpsLat != null) {
      map['gps_lat'] = Variable<double>(gpsLat);
    }
    if (!nullToAbsent || gpsLng != null) {
      map['gps_lng'] = Variable<double>(gpsLng);
    }
    if (!nullToAbsent || gpsAccuracy != null) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy);
    }
    if (!nullToAbsent || outOfFenceReason != null) {
      map['out_of_fence_reason'] = Variable<String>(outOfFenceReason);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SurveysCompanion toCompanion(bool nullToAbsent) {
    return SurveysCompanion(
      id: Value(id),
      clientUuid: Value(clientUuid),
      siteId: Value(siteId),
      type: Value(type),
      plannedDate: plannedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDate),
      actualDate: actualDate == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDate),
      gpsLat:
          gpsLat == null && nullToAbsent ? const Value.absent() : Value(gpsLat),
      gpsLng:
          gpsLng == null && nullToAbsent ? const Value.absent() : Value(gpsLng),
      gpsAccuracy: gpsAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracy),
      outOfFenceReason: outOfFenceReason == null && nullToAbsent
          ? const Value.absent()
          : Value(outOfFenceReason),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      syncStatus: Value(syncStatus),
    );
  }

  factory SurveyEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurveyEntity(
      id: serializer.fromJson<String>(json['id']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      siteId: serializer.fromJson<String>(json['siteId']),
      type: serializer.fromJson<String>(json['type']),
      plannedDate: serializer.fromJson<DateTime?>(json['plannedDate']),
      actualDate: serializer.fromJson<DateTime?>(json['actualDate']),
      gpsLat: serializer.fromJson<double?>(json['gpsLat']),
      gpsLng: serializer.fromJson<double?>(json['gpsLng']),
      gpsAccuracy: serializer.fromJson<double?>(json['gpsAccuracy']),
      outOfFenceReason: serializer.fromJson<String?>(json['outOfFenceReason']),
      comment: serializer.fromJson<String?>(json['comment']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'siteId': serializer.toJson<String>(siteId),
      'type': serializer.toJson<String>(type),
      'plannedDate': serializer.toJson<DateTime?>(plannedDate),
      'actualDate': serializer.toJson<DateTime?>(actualDate),
      'gpsLat': serializer.toJson<double?>(gpsLat),
      'gpsLng': serializer.toJson<double?>(gpsLng),
      'gpsAccuracy': serializer.toJson<double?>(gpsAccuracy),
      'outOfFenceReason': serializer.toJson<String?>(outOfFenceReason),
      'comment': serializer.toJson<String?>(comment),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  SurveyEntity copyWith(
          {String? id,
          String? clientUuid,
          String? siteId,
          String? type,
          Value<DateTime?> plannedDate = const Value.absent(),
          Value<DateTime?> actualDate = const Value.absent(),
          Value<double?> gpsLat = const Value.absent(),
          Value<double?> gpsLng = const Value.absent(),
          Value<double?> gpsAccuracy = const Value.absent(),
          Value<String?> outOfFenceReason = const Value.absent(),
          Value<String?> comment = const Value.absent(),
          String? syncStatus}) =>
      SurveyEntity(
        id: id ?? this.id,
        clientUuid: clientUuid ?? this.clientUuid,
        siteId: siteId ?? this.siteId,
        type: type ?? this.type,
        plannedDate: plannedDate.present ? plannedDate.value : this.plannedDate,
        actualDate: actualDate.present ? actualDate.value : this.actualDate,
        gpsLat: gpsLat.present ? gpsLat.value : this.gpsLat,
        gpsLng: gpsLng.present ? gpsLng.value : this.gpsLng,
        gpsAccuracy: gpsAccuracy.present ? gpsAccuracy.value : this.gpsAccuracy,
        outOfFenceReason: outOfFenceReason.present
            ? outOfFenceReason.value
            : this.outOfFenceReason,
        comment: comment.present ? comment.value : this.comment,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  SurveyEntity copyWithCompanion(SurveysCompanion data) {
    return SurveyEntity(
      id: data.id.present ? data.id.value : this.id,
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      type: data.type.present ? data.type.value : this.type,
      plannedDate:
          data.plannedDate.present ? data.plannedDate.value : this.plannedDate,
      actualDate:
          data.actualDate.present ? data.actualDate.value : this.actualDate,
      gpsLat: data.gpsLat.present ? data.gpsLat.value : this.gpsLat,
      gpsLng: data.gpsLng.present ? data.gpsLng.value : this.gpsLng,
      gpsAccuracy:
          data.gpsAccuracy.present ? data.gpsAccuracy.value : this.gpsAccuracy,
      outOfFenceReason: data.outOfFenceReason.present
          ? data.outOfFenceReason.value
          : this.outOfFenceReason,
      comment: data.comment.present ? data.comment.value : this.comment,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurveyEntity(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('siteId: $siteId, ')
          ..write('type: $type, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('outOfFenceReason: $outOfFenceReason, ')
          ..write('comment: $comment, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      clientUuid,
      siteId,
      type,
      plannedDate,
      actualDate,
      gpsLat,
      gpsLng,
      gpsAccuracy,
      outOfFenceReason,
      comment,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurveyEntity &&
          other.id == this.id &&
          other.clientUuid == this.clientUuid &&
          other.siteId == this.siteId &&
          other.type == this.type &&
          other.plannedDate == this.plannedDate &&
          other.actualDate == this.actualDate &&
          other.gpsLat == this.gpsLat &&
          other.gpsLng == this.gpsLng &&
          other.gpsAccuracy == this.gpsAccuracy &&
          other.outOfFenceReason == this.outOfFenceReason &&
          other.comment == this.comment &&
          other.syncStatus == this.syncStatus);
}

class SurveysCompanion extends UpdateCompanion<SurveyEntity> {
  final Value<String> id;
  final Value<String> clientUuid;
  final Value<String> siteId;
  final Value<String> type;
  final Value<DateTime?> plannedDate;
  final Value<DateTime?> actualDate;
  final Value<double?> gpsLat;
  final Value<double?> gpsLng;
  final Value<double?> gpsAccuracy;
  final Value<String?> outOfFenceReason;
  final Value<String?> comment;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SurveysCompanion({
    this.id = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.siteId = const Value.absent(),
    this.type = const Value.absent(),
    this.plannedDate = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.outOfFenceReason = const Value.absent(),
    this.comment = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SurveysCompanion.insert({
    required String id,
    required String clientUuid,
    required String siteId,
    required String type,
    this.plannedDate = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.outOfFenceReason = const Value.absent(),
    this.comment = const Value.absent(),
    required String syncStatus,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        clientUuid = Value(clientUuid),
        siteId = Value(siteId),
        type = Value(type),
        syncStatus = Value(syncStatus);
  static Insertable<SurveyEntity> custom({
    Expression<String>? id,
    Expression<String>? clientUuid,
    Expression<String>? siteId,
    Expression<String>? type,
    Expression<DateTime>? plannedDate,
    Expression<DateTime>? actualDate,
    Expression<double>? gpsLat,
    Expression<double>? gpsLng,
    Expression<double>? gpsAccuracy,
    Expression<String>? outOfFenceReason,
    Expression<String>? comment,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (siteId != null) 'site_id': siteId,
      if (type != null) 'type': type,
      if (plannedDate != null) 'planned_date': plannedDate,
      if (actualDate != null) 'actual_date': actualDate,
      if (gpsLat != null) 'gps_lat': gpsLat,
      if (gpsLng != null) 'gps_lng': gpsLng,
      if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
      if (outOfFenceReason != null) 'out_of_fence_reason': outOfFenceReason,
      if (comment != null) 'comment': comment,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SurveysCompanion copyWith(
      {Value<String>? id,
      Value<String>? clientUuid,
      Value<String>? siteId,
      Value<String>? type,
      Value<DateTime?>? plannedDate,
      Value<DateTime?>? actualDate,
      Value<double?>? gpsLat,
      Value<double?>? gpsLng,
      Value<double?>? gpsAccuracy,
      Value<String?>? outOfFenceReason,
      Value<String?>? comment,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return SurveysCompanion(
      id: id ?? this.id,
      clientUuid: clientUuid ?? this.clientUuid,
      siteId: siteId ?? this.siteId,
      type: type ?? this.type,
      plannedDate: plannedDate ?? this.plannedDate,
      actualDate: actualDate ?? this.actualDate,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      outOfFenceReason: outOfFenceReason ?? this.outOfFenceReason,
      comment: comment ?? this.comment,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (plannedDate.present) {
      map['planned_date'] = Variable<DateTime>(plannedDate.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<DateTime>(actualDate.value);
    }
    if (gpsLat.present) {
      map['gps_lat'] = Variable<double>(gpsLat.value);
    }
    if (gpsLng.present) {
      map['gps_lng'] = Variable<double>(gpsLng.value);
    }
    if (gpsAccuracy.present) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy.value);
    }
    if (outOfFenceReason.present) {
      map['out_of_fence_reason'] = Variable<String>(outOfFenceReason.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurveysCompanion(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('siteId: $siteId, ')
          ..write('type: $type, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('outOfFenceReason: $outOfFenceReason, ')
          ..write('comment: $comment, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkItemsTable extends WorkItems
    with TableInfo<$WorkItemsTable, WorkItemEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _surveyIdMeta =
      const VerificationMeta('surveyId');
  @override
  late final GeneratedColumn<String> surveyId = GeneratedColumn<String>(
      'survey_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES surveys (id)'));
  static const VerificationMeta _itemTypeMeta =
      const VerificationMeta('itemType');
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
      'item_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isRequiredMeta =
      const VerificationMeta('isRequired');
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
      'is_required', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_required" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<String> progress = GeneratedColumn<String>(
      'progress', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _qtyReplacedMeta =
      const VerificationMeta('qtyReplaced');
  @override
  late final GeneratedColumn<int> qtyReplaced = GeneratedColumn<int>(
      'qty_replaced', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, surveyId, itemType, isRequired, progress, qtyReplaced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_items';
  @override
  VerificationContext validateIntegrity(Insertable<WorkItemEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('survey_id')) {
      context.handle(_surveyIdMeta,
          surveyId.isAcceptableOrUnknown(data['survey_id']!, _surveyIdMeta));
    } else if (isInserting) {
      context.missing(_surveyIdMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(_itemTypeMeta,
          itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta));
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('is_required')) {
      context.handle(
          _isRequiredMeta,
          isRequired.isAcceptableOrUnknown(
              data['is_required']!, _isRequiredMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('qty_replaced')) {
      context.handle(
          _qtyReplacedMeta,
          qtyReplaced.isAcceptableOrUnknown(
              data['qty_replaced']!, _qtyReplacedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkItemEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkItemEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      surveyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}survey_id'])!,
      itemType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_type'])!,
      isRequired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_required'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}progress']),
      qtyReplaced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_replaced']),
    );
  }

  @override
  $WorkItemsTable createAlias(String alias) {
    return $WorkItemsTable(attachedDatabase, alias);
  }
}

class WorkItemEntity extends DataClass implements Insertable<WorkItemEntity> {
  final String id;
  final String surveyId;
  final String itemType;
  final bool isRequired;
  final String? progress;
  final int? qtyReplaced;
  const WorkItemEntity(
      {required this.id,
      required this.surveyId,
      required this.itemType,
      required this.isRequired,
      this.progress,
      this.qtyReplaced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['survey_id'] = Variable<String>(surveyId);
    map['item_type'] = Variable<String>(itemType);
    map['is_required'] = Variable<bool>(isRequired);
    if (!nullToAbsent || progress != null) {
      map['progress'] = Variable<String>(progress);
    }
    if (!nullToAbsent || qtyReplaced != null) {
      map['qty_replaced'] = Variable<int>(qtyReplaced);
    }
    return map;
  }

  WorkItemsCompanion toCompanion(bool nullToAbsent) {
    return WorkItemsCompanion(
      id: Value(id),
      surveyId: Value(surveyId),
      itemType: Value(itemType),
      isRequired: Value(isRequired),
      progress: progress == null && nullToAbsent
          ? const Value.absent()
          : Value(progress),
      qtyReplaced: qtyReplaced == null && nullToAbsent
          ? const Value.absent()
          : Value(qtyReplaced),
    );
  }

  factory WorkItemEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkItemEntity(
      id: serializer.fromJson<String>(json['id']),
      surveyId: serializer.fromJson<String>(json['surveyId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      progress: serializer.fromJson<String?>(json['progress']),
      qtyReplaced: serializer.fromJson<int?>(json['qtyReplaced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'surveyId': serializer.toJson<String>(surveyId),
      'itemType': serializer.toJson<String>(itemType),
      'isRequired': serializer.toJson<bool>(isRequired),
      'progress': serializer.toJson<String?>(progress),
      'qtyReplaced': serializer.toJson<int?>(qtyReplaced),
    };
  }

  WorkItemEntity copyWith(
          {String? id,
          String? surveyId,
          String? itemType,
          bool? isRequired,
          Value<String?> progress = const Value.absent(),
          Value<int?> qtyReplaced = const Value.absent()}) =>
      WorkItemEntity(
        id: id ?? this.id,
        surveyId: surveyId ?? this.surveyId,
        itemType: itemType ?? this.itemType,
        isRequired: isRequired ?? this.isRequired,
        progress: progress.present ? progress.value : this.progress,
        qtyReplaced: qtyReplaced.present ? qtyReplaced.value : this.qtyReplaced,
      );
  WorkItemEntity copyWithCompanion(WorkItemsCompanion data) {
    return WorkItemEntity(
      id: data.id.present ? data.id.value : this.id,
      surveyId: data.surveyId.present ? data.surveyId.value : this.surveyId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      isRequired:
          data.isRequired.present ? data.isRequired.value : this.isRequired,
      progress: data.progress.present ? data.progress.value : this.progress,
      qtyReplaced:
          data.qtyReplaced.present ? data.qtyReplaced.value : this.qtyReplaced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemEntity(')
          ..write('id: $id, ')
          ..write('surveyId: $surveyId, ')
          ..write('itemType: $itemType, ')
          ..write('isRequired: $isRequired, ')
          ..write('progress: $progress, ')
          ..write('qtyReplaced: $qtyReplaced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, surveyId, itemType, isRequired, progress, qtyReplaced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkItemEntity &&
          other.id == this.id &&
          other.surveyId == this.surveyId &&
          other.itemType == this.itemType &&
          other.isRequired == this.isRequired &&
          other.progress == this.progress &&
          other.qtyReplaced == this.qtyReplaced);
}

class WorkItemsCompanion extends UpdateCompanion<WorkItemEntity> {
  final Value<String> id;
  final Value<String> surveyId;
  final Value<String> itemType;
  final Value<bool> isRequired;
  final Value<String?> progress;
  final Value<int?> qtyReplaced;
  final Value<int> rowid;
  const WorkItemsCompanion({
    this.id = const Value.absent(),
    this.surveyId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.progress = const Value.absent(),
    this.qtyReplaced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkItemsCompanion.insert({
    required String id,
    required String surveyId,
    required String itemType,
    this.isRequired = const Value.absent(),
    this.progress = const Value.absent(),
    this.qtyReplaced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        surveyId = Value(surveyId),
        itemType = Value(itemType);
  static Insertable<WorkItemEntity> custom({
    Expression<String>? id,
    Expression<String>? surveyId,
    Expression<String>? itemType,
    Expression<bool>? isRequired,
    Expression<String>? progress,
    Expression<int>? qtyReplaced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surveyId != null) 'survey_id': surveyId,
      if (itemType != null) 'item_type': itemType,
      if (isRequired != null) 'is_required': isRequired,
      if (progress != null) 'progress': progress,
      if (qtyReplaced != null) 'qty_replaced': qtyReplaced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? surveyId,
      Value<String>? itemType,
      Value<bool>? isRequired,
      Value<String?>? progress,
      Value<int?>? qtyReplaced,
      Value<int>? rowid}) {
    return WorkItemsCompanion(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      itemType: itemType ?? this.itemType,
      isRequired: isRequired ?? this.isRequired,
      progress: progress ?? this.progress,
      qtyReplaced: qtyReplaced ?? this.qtyReplaced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (surveyId.present) {
      map['survey_id'] = Variable<String>(surveyId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (progress.present) {
      map['progress'] = Variable<String>(progress.value);
    }
    if (qtyReplaced.present) {
      map['qty_replaced'] = Variable<int>(qtyReplaced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkItemsCompanion(')
          ..write('id: $id, ')
          ..write('surveyId: $surveyId, ')
          ..write('itemType: $itemType, ')
          ..write('isRequired: $isRequired, ')
          ..write('progress: $progress, ')
          ..write('qtyReplaced: $qtyReplaced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, PhotoEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _surveyIdMeta =
      const VerificationMeta('surveyId');
  @override
  late final GeneratedColumn<String> surveyId = GeneratedColumn<String>(
      'survey_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES surveys (id)'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cloudUrlMeta =
      const VerificationMeta('cloudUrl');
  @override
  late final GeneratedColumn<String> cloudUrl = GeneratedColumn<String>(
      'cloud_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, surveyId, category, localPath, cloudUrl, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(Insertable<PhotoEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('survey_id')) {
      context.handle(_surveyIdMeta,
          surveyId.isAcceptableOrUnknown(data['survey_id']!, _surveyIdMeta));
    } else if (isInserting) {
      context.missing(_surveyIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('cloud_url')) {
      context.handle(_cloudUrlMeta,
          cloudUrl.isAcceptableOrUnknown(data['cloud_url']!, _cloudUrlMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      surveyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}survey_id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      cloudUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_url']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class PhotoEntity extends DataClass implements Insertable<PhotoEntity> {
  final String id;
  final String surveyId;
  final String category;
  final String localPath;
  final String? cloudUrl;
  final String syncStatus;
  const PhotoEntity(
      {required this.id,
      required this.surveyId,
      required this.category,
      required this.localPath,
      this.cloudUrl,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['survey_id'] = Variable<String>(surveyId);
    map['category'] = Variable<String>(category);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || cloudUrl != null) {
      map['cloud_url'] = Variable<String>(cloudUrl);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      surveyId: Value(surveyId),
      category: Value(category),
      localPath: Value(localPath),
      cloudUrl: cloudUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudUrl),
      syncStatus: Value(syncStatus),
    );
  }

  factory PhotoEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoEntity(
      id: serializer.fromJson<String>(json['id']),
      surveyId: serializer.fromJson<String>(json['surveyId']),
      category: serializer.fromJson<String>(json['category']),
      localPath: serializer.fromJson<String>(json['localPath']),
      cloudUrl: serializer.fromJson<String?>(json['cloudUrl']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'surveyId': serializer.toJson<String>(surveyId),
      'category': serializer.toJson<String>(category),
      'localPath': serializer.toJson<String>(localPath),
      'cloudUrl': serializer.toJson<String?>(cloudUrl),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PhotoEntity copyWith(
          {String? id,
          String? surveyId,
          String? category,
          String? localPath,
          Value<String?> cloudUrl = const Value.absent(),
          String? syncStatus}) =>
      PhotoEntity(
        id: id ?? this.id,
        surveyId: surveyId ?? this.surveyId,
        category: category ?? this.category,
        localPath: localPath ?? this.localPath,
        cloudUrl: cloudUrl.present ? cloudUrl.value : this.cloudUrl,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  PhotoEntity copyWithCompanion(PhotosCompanion data) {
    return PhotoEntity(
      id: data.id.present ? data.id.value : this.id,
      surveyId: data.surveyId.present ? data.surveyId.value : this.surveyId,
      category: data.category.present ? data.category.value : this.category,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      cloudUrl: data.cloudUrl.present ? data.cloudUrl.value : this.cloudUrl,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoEntity(')
          ..write('id: $id, ')
          ..write('surveyId: $surveyId, ')
          ..write('category: $category, ')
          ..write('localPath: $localPath, ')
          ..write('cloudUrl: $cloudUrl, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, surveyId, category, localPath, cloudUrl, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoEntity &&
          other.id == this.id &&
          other.surveyId == this.surveyId &&
          other.category == this.category &&
          other.localPath == this.localPath &&
          other.cloudUrl == this.cloudUrl &&
          other.syncStatus == this.syncStatus);
}

class PhotosCompanion extends UpdateCompanion<PhotoEntity> {
  final Value<String> id;
  final Value<String> surveyId;
  final Value<String> category;
  final Value<String> localPath;
  final Value<String?> cloudUrl;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.surveyId = const Value.absent(),
    this.category = const Value.absent(),
    this.localPath = const Value.absent(),
    this.cloudUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String surveyId,
    required String category,
    required String localPath,
    this.cloudUrl = const Value.absent(),
    required String syncStatus,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        surveyId = Value(surveyId),
        category = Value(category),
        localPath = Value(localPath),
        syncStatus = Value(syncStatus);
  static Insertable<PhotoEntity> custom({
    Expression<String>? id,
    Expression<String>? surveyId,
    Expression<String>? category,
    Expression<String>? localPath,
    Expression<String>? cloudUrl,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surveyId != null) 'survey_id': surveyId,
      if (category != null) 'category': category,
      if (localPath != null) 'local_path': localPath,
      if (cloudUrl != null) 'cloud_url': cloudUrl,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? surveyId,
      Value<String>? category,
      Value<String>? localPath,
      Value<String?>? cloudUrl,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return PhotosCompanion(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      category: category ?? this.category,
      localPath: localPath ?? this.localPath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (surveyId.present) {
      map['survey_id'] = Variable<String>(surveyId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (cloudUrl.present) {
      map['cloud_url'] = Variable<String>(cloudUrl.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('surveyId: $surveyId, ')
          ..write('category: $category, ')
          ..write('localPath: $localPath, ')
          ..write('cloudUrl: $cloudUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endpointMeta =
      const VerificationMeta('endpoint');
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
      'endpoint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        clientUuid,
        entityType,
        payload,
        method,
        endpoint,
        status,
        attemptCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(_endpointMeta,
          endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta));
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientUuid};
  @override
  OutboxEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntity(
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      endpoint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endpoint'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxEntity extends DataClass implements Insertable<OutboxEntity> {
  final String clientUuid;
  final String entityType;
  final String payload;
  final String method;
  final String endpoint;
  final String status;
  final int attemptCount;
  final String? lastError;
  const OutboxEntity(
      {required this.clientUuid,
      required this.entityType,
      required this.payload,
      required this.method,
      required this.endpoint,
      required this.status,
      required this.attemptCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_uuid'] = Variable<String>(clientUuid);
    map['entity_type'] = Variable<String>(entityType);
    map['payload'] = Variable<String>(payload);
    map['method'] = Variable<String>(method);
    map['endpoint'] = Variable<String>(endpoint);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      clientUuid: Value(clientUuid),
      entityType: Value(entityType),
      payload: Value(payload),
      method: Value(method),
      endpoint: Value(endpoint),
      status: Value(status),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntity(
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      entityType: serializer.fromJson<String>(json['entityType']),
      payload: serializer.fromJson<String>(json['payload']),
      method: serializer.fromJson<String>(json['method']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientUuid': serializer.toJson<String>(clientUuid),
      'entityType': serializer.toJson<String>(entityType),
      'payload': serializer.toJson<String>(payload),
      'method': serializer.toJson<String>(method),
      'endpoint': serializer.toJson<String>(endpoint),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntity copyWith(
          {String? clientUuid,
          String? entityType,
          String? payload,
          String? method,
          String? endpoint,
          String? status,
          int? attemptCount,
          Value<String?> lastError = const Value.absent()}) =>
      OutboxEntity(
        clientUuid: clientUuid ?? this.clientUuid,
        entityType: entityType ?? this.entityType,
        payload: payload ?? this.payload,
        method: method ?? this.method,
        endpoint: endpoint ?? this.endpoint,
        status: status ?? this.status,
        attemptCount: attemptCount ?? this.attemptCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  OutboxEntity copyWithCompanion(OutboxCompanion data) {
    return OutboxEntity(
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      payload: data.payload.present ? data.payload.value : this.payload,
      method: data.method.present ? data.method.value : this.method,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntity(')
          ..write('clientUuid: $clientUuid, ')
          ..write('entityType: $entityType, ')
          ..write('payload: $payload, ')
          ..write('method: $method, ')
          ..write('endpoint: $endpoint, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clientUuid, entityType, payload, method,
      endpoint, status, attemptCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntity &&
          other.clientUuid == this.clientUuid &&
          other.entityType == this.entityType &&
          other.payload == this.payload &&
          other.method == this.method &&
          other.endpoint == this.endpoint &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError);
}

class OutboxCompanion extends UpdateCompanion<OutboxEntity> {
  final Value<String> clientUuid;
  final Value<String> entityType;
  final Value<String> payload;
  final Value<String> method;
  final Value<String> endpoint;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxCompanion({
    this.clientUuid = const Value.absent(),
    this.entityType = const Value.absent(),
    this.payload = const Value.absent(),
    this.method = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String clientUuid,
    required String entityType,
    required String payload,
    required String method,
    required String endpoint,
    required String status,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : clientUuid = Value(clientUuid),
        entityType = Value(entityType),
        payload = Value(payload),
        method = Value(method),
        endpoint = Value(endpoint),
        status = Value(status);
  static Insertable<OutboxEntity> custom({
    Expression<String>? clientUuid,
    Expression<String>? entityType,
    Expression<String>? payload,
    Expression<String>? method,
    Expression<String>? endpoint,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (entityType != null) 'entity_type': entityType,
      if (payload != null) 'payload': payload,
      if (method != null) 'method': method,
      if (endpoint != null) 'endpoint': endpoint,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith(
      {Value<String>? clientUuid,
      Value<String>? entityType,
      Value<String>? payload,
      Value<String>? method,
      Value<String>? endpoint,
      Value<String>? status,
      Value<int>? attemptCount,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return OutboxCompanion(
      clientUuid: clientUuid ?? this.clientUuid,
      entityType: entityType ?? this.entityType,
      payload: payload ?? this.payload,
      method: method ?? this.method,
      endpoint: endpoint ?? this.endpoint,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('clientUuid: $clientUuid, ')
          ..write('entityType: $entityType, ')
          ..write('payload: $payload, ')
          ..write('method: $method, ')
          ..write('endpoint: $endpoint, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $SurveysTable surveys = $SurveysTable(this);
  late final $WorkItemsTable workItems = $WorkItemsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sites, surveys, workItems, photos, outbox];
}

typedef $$SitesTableCreateCompanionBuilder = SitesCompanion Function({
  required String id,
  required String name,
  required double latitude,
  required double longitude,
  required String cycleState,
  Value<String?> rejectionReason,
  Value<String?> rejectionComment,
  Value<int> rowid,
});
typedef $$SitesTableUpdateCompanionBuilder = SitesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> cycleState,
  Value<String?> rejectionReason,
  Value<String?> rejectionComment,
  Value<int> rowid,
});

final class $$SitesTableReferences
    extends BaseReferences<_$AppDatabase, $SitesTable, SiteEntity> {
  $$SitesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SurveysTable, List<SurveyEntity>>
      _surveysRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.surveys,
              aliasName: $_aliasNameGenerator(db.sites.id, db.surveys.siteId));

  $$SurveysTableProcessedTableManager get surveysRefs {
    final manager = $$SurveysTableTableManager($_db, $_db.surveys)
        .filter((f) => f.siteId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_surveysRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SitesTableFilterComposer extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cycleState => $composableBuilder(
      column: $table.cycleState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectionReason => $composableBuilder(
      column: $table.rejectionReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectionComment => $composableBuilder(
      column: $table.rejectionComment,
      builder: (column) => ColumnFilters(column));

  Expression<bool> surveysRefs(
      Expression<bool> Function($$SurveysTableFilterComposer f) f) {
    final $$SurveysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableFilterComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cycleState => $composableBuilder(
      column: $table.cycleState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectionReason => $composableBuilder(
      column: $table.rejectionReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectionComment => $composableBuilder(
      column: $table.rejectionComment,
      builder: (column) => ColumnOrderings(column));
}

class $$SitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get cycleState => $composableBuilder(
      column: $table.cycleState, builder: (column) => column);

  GeneratedColumn<String> get rejectionReason => $composableBuilder(
      column: $table.rejectionReason, builder: (column) => column);

  GeneratedColumn<String> get rejectionComment => $composableBuilder(
      column: $table.rejectionComment, builder: (column) => column);

  Expression<T> surveysRefs<T extends Object>(
      Expression<T> Function($$SurveysTableAnnotationComposer a) f) {
    final $$SurveysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.siteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableAnnotationComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SitesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SitesTable,
    SiteEntity,
    $$SitesTableFilterComposer,
    $$SitesTableOrderingComposer,
    $$SitesTableAnnotationComposer,
    $$SitesTableCreateCompanionBuilder,
    $$SitesTableUpdateCompanionBuilder,
    (SiteEntity, $$SitesTableReferences),
    SiteEntity,
    PrefetchHooks Function({bool surveysRefs})> {
  $$SitesTableTableManager(_$AppDatabase db, $SitesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<String> cycleState = const Value.absent(),
            Value<String?> rejectionReason = const Value.absent(),
            Value<String?> rejectionComment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SitesCompanion(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            cycleState: cycleState,
            rejectionReason: rejectionReason,
            rejectionComment: rejectionComment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double latitude,
            required double longitude,
            required String cycleState,
            Value<String?> rejectionReason = const Value.absent(),
            Value<String?> rejectionComment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SitesCompanion.insert(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            cycleState: cycleState,
            rejectionReason: rejectionReason,
            rejectionComment: rejectionComment,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SitesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({surveysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (surveysRefs) db.surveys],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (surveysRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SitesTableReferences._surveysRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SitesTableReferences(db, table, p0).surveysRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.siteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SitesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SitesTable,
    SiteEntity,
    $$SitesTableFilterComposer,
    $$SitesTableOrderingComposer,
    $$SitesTableAnnotationComposer,
    $$SitesTableCreateCompanionBuilder,
    $$SitesTableUpdateCompanionBuilder,
    (SiteEntity, $$SitesTableReferences),
    SiteEntity,
    PrefetchHooks Function({bool surveysRefs})>;
typedef $$SurveysTableCreateCompanionBuilder = SurveysCompanion Function({
  required String id,
  required String clientUuid,
  required String siteId,
  required String type,
  Value<DateTime?> plannedDate,
  Value<DateTime?> actualDate,
  Value<double?> gpsLat,
  Value<double?> gpsLng,
  Value<double?> gpsAccuracy,
  Value<String?> outOfFenceReason,
  Value<String?> comment,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$SurveysTableUpdateCompanionBuilder = SurveysCompanion Function({
  Value<String> id,
  Value<String> clientUuid,
  Value<String> siteId,
  Value<String> type,
  Value<DateTime?> plannedDate,
  Value<DateTime?> actualDate,
  Value<double?> gpsLat,
  Value<double?> gpsLng,
  Value<double?> gpsAccuracy,
  Value<String?> outOfFenceReason,
  Value<String?> comment,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$SurveysTableReferences
    extends BaseReferences<_$AppDatabase, $SurveysTable, SurveyEntity> {
  $$SurveysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SitesTable _siteIdTable(_$AppDatabase db) => db.sites
      .createAlias($_aliasNameGenerator(db.surveys.siteId, db.sites.id));

  $$SitesTableProcessedTableManager? get siteId {
    if ($_item.siteId == null) return null;
    final manager = $$SitesTableTableManager($_db, $_db.sites)
        .filter((f) => f.id($_item.siteId!));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WorkItemsTable, List<WorkItemEntity>>
      _workItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workItems,
              aliasName:
                  $_aliasNameGenerator(db.surveys.id, db.workItems.surveyId));

  $$WorkItemsTableProcessedTableManager get workItemsRefs {
    final manager = $$WorkItemsTableTableManager($_db, $_db.workItems)
        .filter((f) => f.surveyId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_workItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PhotosTable, List<PhotoEntity>> _photosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.photos,
          aliasName: $_aliasNameGenerator(db.surveys.id, db.photos.surveyId));

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager($_db, $_db.photos)
        .filter((f) => f.surveyId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SurveysTableFilterComposer
    extends Composer<_$AppDatabase, $SurveysTable> {
  $$SurveysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get plannedDate => $composableBuilder(
      column: $table.plannedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actualDate => $composableBuilder(
      column: $table.actualDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outOfFenceReason => $composableBuilder(
      column: $table.outOfFenceReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  $$SitesTableFilterComposer get siteId {
    final $$SitesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableFilterComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> workItemsRefs(
      Expression<bool> Function($$WorkItemsTableFilterComposer f) f) {
    final $$WorkItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workItems,
        getReferencedColumn: (t) => t.surveyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkItemsTableFilterComposer(
              $db: $db,
              $table: $db.workItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> photosRefs(
      Expression<bool> Function($$PhotosTableFilterComposer f) f) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photos,
        getReferencedColumn: (t) => t.surveyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotosTableFilterComposer(
              $db: $db,
              $table: $db.photos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SurveysTableOrderingComposer
    extends Composer<_$AppDatabase, $SurveysTable> {
  $$SurveysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get plannedDate => $composableBuilder(
      column: $table.plannedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actualDate => $composableBuilder(
      column: $table.actualDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outOfFenceReason => $composableBuilder(
      column: $table.outOfFenceReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$SitesTableOrderingComposer get siteId {
    final $$SitesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableOrderingComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SurveysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurveysTable> {
  $$SurveysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedDate => $composableBuilder(
      column: $table.plannedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get actualDate => $composableBuilder(
      column: $table.actualDate, builder: (column) => column);

  GeneratedColumn<double> get gpsLat =>
      $composableBuilder(column: $table.gpsLat, builder: (column) => column);

  GeneratedColumn<double> get gpsLng =>
      $composableBuilder(column: $table.gpsLng, builder: (column) => column);

  GeneratedColumn<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => column);

  GeneratedColumn<String> get outOfFenceReason => $composableBuilder(
      column: $table.outOfFenceReason, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  $$SitesTableAnnotationComposer get siteId {
    final $$SitesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteId,
        referencedTable: $db.sites,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SitesTableAnnotationComposer(
              $db: $db,
              $table: $db.sites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> workItemsRefs<T extends Object>(
      Expression<T> Function($$WorkItemsTableAnnotationComposer a) f) {
    final $$WorkItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workItems,
        getReferencedColumn: (t) => t.surveyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.workItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> photosRefs<T extends Object>(
      Expression<T> Function($$PhotosTableAnnotationComposer a) f) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photos,
        getReferencedColumn: (t) => t.surveyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.photos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SurveysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SurveysTable,
    SurveyEntity,
    $$SurveysTableFilterComposer,
    $$SurveysTableOrderingComposer,
    $$SurveysTableAnnotationComposer,
    $$SurveysTableCreateCompanionBuilder,
    $$SurveysTableUpdateCompanionBuilder,
    (SurveyEntity, $$SurveysTableReferences),
    SurveyEntity,
    PrefetchHooks Function(
        {bool siteId, bool workItemsRefs, bool photosRefs})> {
  $$SurveysTableTableManager(_$AppDatabase db, $SurveysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurveysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurveysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurveysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> clientUuid = const Value.absent(),
            Value<String> siteId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime?> plannedDate = const Value.absent(),
            Value<DateTime?> actualDate = const Value.absent(),
            Value<double?> gpsLat = const Value.absent(),
            Value<double?> gpsLng = const Value.absent(),
            Value<double?> gpsAccuracy = const Value.absent(),
            Value<String?> outOfFenceReason = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SurveysCompanion(
            id: id,
            clientUuid: clientUuid,
            siteId: siteId,
            type: type,
            plannedDate: plannedDate,
            actualDate: actualDate,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            gpsAccuracy: gpsAccuracy,
            outOfFenceReason: outOfFenceReason,
            comment: comment,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String clientUuid,
            required String siteId,
            required String type,
            Value<DateTime?> plannedDate = const Value.absent(),
            Value<DateTime?> actualDate = const Value.absent(),
            Value<double?> gpsLat = const Value.absent(),
            Value<double?> gpsLng = const Value.absent(),
            Value<double?> gpsAccuracy = const Value.absent(),
            Value<String?> outOfFenceReason = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            required String syncStatus,
            Value<int> rowid = const Value.absent(),
          }) =>
              SurveysCompanion.insert(
            id: id,
            clientUuid: clientUuid,
            siteId: siteId,
            type: type,
            plannedDate: plannedDate,
            actualDate: actualDate,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            gpsAccuracy: gpsAccuracy,
            outOfFenceReason: outOfFenceReason,
            comment: comment,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SurveysTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {siteId = false, workItemsRefs = false, photosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workItemsRefs) db.workItems,
                if (photosRefs) db.photos
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (siteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siteId,
                    referencedTable: $$SurveysTableReferences._siteIdTable(db),
                    referencedColumn:
                        $$SurveysTableReferences._siteIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SurveysTableReferences._workItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SurveysTableReferences(db, table, p0)
                                .workItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.surveyId == item.id),
                        typedResults: items),
                  if (photosRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SurveysTableReferences._photosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SurveysTableReferences(db, table, p0).photosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.surveyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SurveysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SurveysTable,
    SurveyEntity,
    $$SurveysTableFilterComposer,
    $$SurveysTableOrderingComposer,
    $$SurveysTableAnnotationComposer,
    $$SurveysTableCreateCompanionBuilder,
    $$SurveysTableUpdateCompanionBuilder,
    (SurveyEntity, $$SurveysTableReferences),
    SurveyEntity,
    PrefetchHooks Function({bool siteId, bool workItemsRefs, bool photosRefs})>;
typedef $$WorkItemsTableCreateCompanionBuilder = WorkItemsCompanion Function({
  required String id,
  required String surveyId,
  required String itemType,
  Value<bool> isRequired,
  Value<String?> progress,
  Value<int?> qtyReplaced,
  Value<int> rowid,
});
typedef $$WorkItemsTableUpdateCompanionBuilder = WorkItemsCompanion Function({
  Value<String> id,
  Value<String> surveyId,
  Value<String> itemType,
  Value<bool> isRequired,
  Value<String?> progress,
  Value<int?> qtyReplaced,
  Value<int> rowid,
});

final class $$WorkItemsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkItemsTable, WorkItemEntity> {
  $$WorkItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurveysTable _surveyIdTable(_$AppDatabase db) => db.surveys
      .createAlias($_aliasNameGenerator(db.workItems.surveyId, db.surveys.id));

  $$SurveysTableProcessedTableManager? get surveyId {
    if ($_item.surveyId == null) return null;
    final manager = $$SurveysTableTableManager($_db, $_db.surveys)
        .filter((f) => f.id($_item.surveyId!));
    final item = $_typedResult.readTableOrNull(_surveyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkItemsTable> {
  $$WorkItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyReplaced => $composableBuilder(
      column: $table.qtyReplaced, builder: (column) => ColumnFilters(column));

  $$SurveysTableFilterComposer get surveyId {
    final $$SurveysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surveyId,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableFilterComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkItemsTable> {
  $$WorkItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyReplaced => $composableBuilder(
      column: $table.qtyReplaced, builder: (column) => ColumnOrderings(column));

  $$SurveysTableOrderingComposer get surveyId {
    final $$SurveysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surveyId,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableOrderingComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkItemsTable> {
  $$WorkItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => column);

  GeneratedColumn<String> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get qtyReplaced => $composableBuilder(
      column: $table.qtyReplaced, builder: (column) => column);

  $$SurveysTableAnnotationComposer get surveyId {
    final $$SurveysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surveyId,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableAnnotationComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkItemsTable,
    WorkItemEntity,
    $$WorkItemsTableFilterComposer,
    $$WorkItemsTableOrderingComposer,
    $$WorkItemsTableAnnotationComposer,
    $$WorkItemsTableCreateCompanionBuilder,
    $$WorkItemsTableUpdateCompanionBuilder,
    (WorkItemEntity, $$WorkItemsTableReferences),
    WorkItemEntity,
    PrefetchHooks Function({bool surveyId})> {
  $$WorkItemsTableTableManager(_$AppDatabase db, $WorkItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> surveyId = const Value.absent(),
            Value<String> itemType = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<String?> progress = const Value.absent(),
            Value<int?> qtyReplaced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkItemsCompanion(
            id: id,
            surveyId: surveyId,
            itemType: itemType,
            isRequired: isRequired,
            progress: progress,
            qtyReplaced: qtyReplaced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String surveyId,
            required String itemType,
            Value<bool> isRequired = const Value.absent(),
            Value<String?> progress = const Value.absent(),
            Value<int?> qtyReplaced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkItemsCompanion.insert(
            id: id,
            surveyId: surveyId,
            itemType: itemType,
            isRequired: isRequired,
            progress: progress,
            qtyReplaced: qtyReplaced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({surveyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (surveyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.surveyId,
                    referencedTable:
                        $$WorkItemsTableReferences._surveyIdTable(db),
                    referencedColumn:
                        $$WorkItemsTableReferences._surveyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkItemsTable,
    WorkItemEntity,
    $$WorkItemsTableFilterComposer,
    $$WorkItemsTableOrderingComposer,
    $$WorkItemsTableAnnotationComposer,
    $$WorkItemsTableCreateCompanionBuilder,
    $$WorkItemsTableUpdateCompanionBuilder,
    (WorkItemEntity, $$WorkItemsTableReferences),
    WorkItemEntity,
    PrefetchHooks Function({bool surveyId})>;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  required String surveyId,
  required String category,
  required String localPath,
  Value<String?> cloudUrl,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<String> surveyId,
  Value<String> category,
  Value<String> localPath,
  Value<String?> cloudUrl,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, PhotoEntity> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurveysTable _surveyIdTable(_$AppDatabase db) => db.surveys
      .createAlias($_aliasNameGenerator(db.photos.surveyId, db.surveys.id));

  $$SurveysTableProcessedTableManager? get surveyId {
    if ($_item.surveyId == null) return null;
    final manager = $$SurveysTableTableManager($_db, $_db.surveys)
        .filter((f) => f.id($_item.surveyId!));
    final item = $_typedResult.readTableOrNull(_surveyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudUrl => $composableBuilder(
      column: $table.cloudUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  $$SurveysTableFilterComposer get surveyId {
    final $$SurveysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surveyId,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableFilterComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudUrl => $composableBuilder(
      column: $table.cloudUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$SurveysTableOrderingComposer get surveyId {
    final $$SurveysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surveyId,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableOrderingComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get cloudUrl =>
      $composableBuilder(column: $table.cloudUrl, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  $$SurveysTableAnnotationComposer get surveyId {
    final $$SurveysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surveyId,
        referencedTable: $db.surveys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurveysTableAnnotationComposer(
              $db: $db,
              $table: $db.surveys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhotosTable,
    PhotoEntity,
    $$PhotosTableFilterComposer,
    $$PhotosTableOrderingComposer,
    $$PhotosTableAnnotationComposer,
    $$PhotosTableCreateCompanionBuilder,
    $$PhotosTableUpdateCompanionBuilder,
    (PhotoEntity, $$PhotosTableReferences),
    PhotoEntity,
    PrefetchHooks Function({bool surveyId})> {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> surveyId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> cloudUrl = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotosCompanion(
            id: id,
            surveyId: surveyId,
            category: category,
            localPath: localPath,
            cloudUrl: cloudUrl,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String surveyId,
            required String category,
            required String localPath,
            Value<String?> cloudUrl = const Value.absent(),
            required String syncStatus,
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotosCompanion.insert(
            id: id,
            surveyId: surveyId,
            category: category,
            localPath: localPath,
            cloudUrl: cloudUrl,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PhotosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({surveyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (surveyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.surveyId,
                    referencedTable: $$PhotosTableReferences._surveyIdTable(db),
                    referencedColumn:
                        $$PhotosTableReferences._surveyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhotosTable,
    PhotoEntity,
    $$PhotosTableFilterComposer,
    $$PhotosTableOrderingComposer,
    $$PhotosTableAnnotationComposer,
    $$PhotosTableCreateCompanionBuilder,
    $$PhotosTableUpdateCompanionBuilder,
    (PhotoEntity, $$PhotosTableReferences),
    PhotoEntity,
    PrefetchHooks Function({bool surveyId})>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String clientUuid,
  required String entityType,
  required String payload,
  required String method,
  required String endpoint,
  required String status,
  Value<int> attemptCount,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> clientUuid,
  Value<String> entityType,
  Value<String> payload,
  Value<String> method,
  Value<String> endpoint,
  Value<String> status,
  Value<int> attemptCount,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxEntity,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxEntity, BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntity>),
    OutboxEntity,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> clientUuid = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> endpoint = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCompanion(
            clientUuid: clientUuid,
            entityType: entityType,
            payload: payload,
            method: method,
            endpoint: endpoint,
            status: status,
            attemptCount: attemptCount,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String clientUuid,
            required String entityType,
            required String payload,
            required String method,
            required String endpoint,
            required String status,
            Value<int> attemptCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            clientUuid: clientUuid,
            entityType: entityType,
            payload: payload,
            method: method,
            endpoint: endpoint,
            status: status,
            attemptCount: attemptCount,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxEntity,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxEntity, BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntity>),
    OutboxEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$SurveysTableTableManager get surveys =>
      $$SurveysTableTableManager(_db, _db.surveys);
  $$WorkItemsTableTableManager get workItems =>
      $$WorkItemsTableTableManager(_db, _db.workItems);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
}
