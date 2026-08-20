import 'package:drift/drift.dart';

part 'database.g.dart';

@DataClassName('SiteEntity')
class Sites extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get cycleState => text()();
  TextColumn get rejectionReason => text().nullable()();
  TextColumn get rejectionComment => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SurveyEntity')
class Surveys extends Table {
  TextColumn get id => text()();
  TextColumn get clientUuid => text()();
  TextColumn get siteId => text().references(Sites, #id)();
  TextColumn get type => text()(); // pre or post
  DateTimeColumn get plannedDate => dateTime().nullable()();
  DateTimeColumn get actualDate => dateTime().nullable()();
  RealColumn get gpsLat => real().nullable()();
  RealColumn get gpsLng => real().nullable()();
  RealColumn get gpsAccuracy => real().nullable()();
  TextColumn get outOfFenceReason => text().nullable()();
  TextColumn get comment => text().nullable()();
  TextColumn get syncStatus => text()(); // Draft, Queued, Synced
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkItemEntity')
class WorkItems extends Table {
  TextColumn get id => text()();
  TextColumn get surveyId => text().references(Surveys, #id)();
  TextColumn get itemType => text()(); // janitorial, granite, etc
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  TextColumn get progress => text().nullable()(); // WIP, Closed
  IntColumn get qtyReplaced => integer().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PhotoEntity')
class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get surveyId => text().references(Surveys, #id)();
  TextColumn get category => text()(); // before, after
  TextColumn get localPath => text()();
  TextColumn get cloudUrl => text().nullable()();
  TextColumn get syncStatus => text()(); // Queued, Synced
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OutboxEntity')
class Outbox extends Table {
  TextColumn get clientUuid => text()();
  TextColumn get entityType => text()(); // survey, photo
  TextColumn get payload => text()(); // JSON
  TextColumn get method => text()();
  TextColumn get endpoint => text()();
  TextColumn get status => text()(); // Draft, Queued, Uploading, Synced, Failed, Conflict
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {clientUuid};
}

@DriftDatabase(tables: [Sites, Surveys, WorkItems, Photos, Outbox])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
