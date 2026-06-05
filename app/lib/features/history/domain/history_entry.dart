import 'package:hive/hive.dart';

class HistoryEntry extends HiveObject {
  final String expression;
  final String result;
  final DateTime createdAt;
  final bool pinned;
  final String? latex;

  /// JSON-encoded SolveResult for entries saved from the AI Solver.
  /// `null` for plain calculator entries. When present, tapping the
  /// row in History reopens a full Solution screen.
  final String? aiResultJson;

  HistoryEntry({
    required this.expression,
    required this.result,
    required this.createdAt,
    this.pinned = false,
    this.latex,
    this.aiResultJson,
  });

  bool get isAi => aiResultJson != null;

  HistoryEntry copyWith({bool? pinned}) => HistoryEntry(
        expression: expression,
        result: result,
        createdAt: createdAt,
        pinned: pinned ?? this.pinned,
        latex: latex,
        aiResultJson: aiResultJson,
      );
}

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 1;

  @override
  HistoryEntry read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      expression: fields[0] as String,
      result: fields[1] as String,
      createdAt: fields[2] as DateTime,
      pinned: (fields[3] as bool?) ?? false,
      latex: fields[4] as String?,
      aiResultJson: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.expression)
      ..writeByte(1)..write(obj.result)
      ..writeByte(2)..write(obj.createdAt)
      ..writeByte(3)..write(obj.pinned)
      ..writeByte(4)..write(obj.latex)
      ..writeByte(5)..write(obj.aiResultJson);
  }
}
