import 'package:sqlite3/sqlite3.dart';

import 'database_table_sqlite_mixin.dart';

mixin DatabaseTableSyncSqliteMixin<T> on DatabaseTableSqliteMixin<T> {
  /// Получить максимальный айди записей для синхронизации
  int sqlSelectSyncIdMax(Database sql) {
    final res = sql.select('SELECT MAX(${columnSync.name}) FROM $name');
    if (res.isEmpty) return 0;
    return res.first.columnAt(0);
  }

  late final _selectSyncIdsLimit = 'SELECT ${columnSync.name} FROM $name'
      ' WHERE ${columnSync.name} > ?'
      ' AND ${columnSync.name} <= ?'
      ' ORDER BY ${columnSync.name}'
      ' LIMIT ?';

  /// Получить список айди записей для синхронизации
  /// (Лимитированное кол-во)
  Iterable<int> sqlSelectSyncIdsLimit(Database sql, int value, int valueMax,
      [int limit = 1024]) {
    final res = sql.select(_selectSyncIdsLimit, [value, valueMax, limit]);
    return res.map((row) => row.columnAt(0) as int);
  }

  late final _selectSyncIdsClamp = 'SELECT ${columnSync.name} FROM $name'
      ' WHERE ${columnSync.name} > ?'
      ' AND ${columnSync.name} <= ?'
      ' ORDER BY ${columnSync.name}';

  /// Получить список айди записей для синхронизации
  /// (с включающей верхней границей)
  Iterable<int> sqlSelectSyncIdsClamp(Database sql, int value, int valueMax) {
    final res = sql.select(_selectSyncIdsClamp, [value, valueMax]);
    return res.map((row) => row.columnAt(0) as int);
  }

  List<T> sqlSelectSyncFrame(Database sql, List<int> ids) => sqlSelect(
        sql,
        'WHERE ${columnSync.name} IN (${ids.map((e) => '?').join(', ')})',
        ids,
      ).toList();
}
