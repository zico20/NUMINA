import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../domain/history_entry.dart';

const _boxName = 'history';

class HistoryRepository {
  HistoryRepository(this._box);
  final Box<HistoryEntry> _box;

  List<HistoryEntry> all() {
    final items = _box.values.toList();
    items.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return items;
  }

  Stream<List<HistoryEntry>> watch() async* {
    yield all();
    yield* _box.watch().map((_) => all());
  }

  Future<void> add(HistoryEntry e) => _box.add(e);

  Future<void> togglePin(HistoryEntry e) async {
    e.pinned ? null : null;
    final updated = e.copyWith(pinned: !e.pinned);
    await e.delete();
    await _box.add(updated);
  }

  Future<void> delete(HistoryEntry e) => e.delete();

  Future<void> clearAll() => _box.clear();

  static Future<HistoryRepository> open() async {
    final box = await Hive.openBox<HistoryEntry>(_boxName);
    return HistoryRepository(box);
  }
}

/// Overridden in main.dart after Hive box is open.
final historyRepositoryProvider = Provider<HistoryRepository>((_) {
  throw UnimplementedError('historyRepositoryProvider must be overridden');
});
