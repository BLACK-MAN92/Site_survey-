import 'package:drift/drift.dart';
import 'database.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [Outbox])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<void> insertOutboxItem(OutboxEntity item) => into(outbox).insert(item);
  
  Future<void> updateOutboxStatus(String clientUuid, String status, {String? lastError}) {
    return (update(outbox)..where((t) => t.clientUuid.equals(clientUuid))).write(
      OutboxCompanion(
        status: Value(status),
        lastError: Value(lastError),
      ),
    );
  }

  Future<void> incrementAttempt(String clientUuid) async {
    final item = await (select(outbox)..where((t) => t.clientUuid.equals(clientUuid))).getSingle();
    await (update(outbox)..where((t) => t.clientUuid.equals(clientUuid))).write(
      OutboxCompanion(attemptCount: Value(item.attemptCount + 1)),
    );
  }

  Stream<List<OutboxEntity>> watchPendingItems() {
    return (select(outbox)..where((t) => t.status.isIn(['Queued', 'Uploading']))).watch();
  }
  
  Future<List<OutboxEntity>> getItemsToSync() {
    return (select(outbox)..where((t) => t.status.equals('Queued'))).get();
  }
}
