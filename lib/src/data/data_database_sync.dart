import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

/// Пакет данных сообщающий какие последние данные имеются у обеих сторон
@immutable
class DataDatabaseSync {
  const DataDatabaseSync(
    this.id,
    this.tenders0,
    this.tenders1,
    this.updaters0,
    this.updaters1,
  );

  /// Номер записи в БД
  final int id;

  /// Интервал записей тендеров начало (id)
  final int tenders0;

  /// Интервал записей тендеров конец (id)
  final int tenders1;

  /// Интервал записей обновлений начало (timestamps)
  final int updaters0;

  /// Интервал записей тендеров конец (timstamps)
  final int updaters1;

  @override
  String toString() =>
      '''DataDatabaseSync(tenders0: $tenders0, tenders1: $tenders1, updaters0: $updaters0, updaters1: $updaters1)''';
}

class TableDataDatabaseSync extends DatabaseTable<DataDatabaseSync> {
  const TableDataDatabaseSync(Database sql) : super(sql, kTableName, kColumns);

  static const kTableName = 'Syncs';
  static const kColumns = <DatabaseColumn>[
    DatabaseColumnId('id'),
    DatabaseColumnUnsigned('t0'),
    DatabaseColumnUnsigned('t1'),
    DatabaseColumnUnsigned('u0'),
    DatabaseColumnUnsigned('u1'),
  ];

  @override
  List dartDecode(DataDatabaseSync value) => [
        value.id,
        value.tenders0,
        value.tenders1,
        value.updaters0,
        value.updaters1,
      ];

  @override
  DataDatabaseSync dartEncode(List value) =>
      DataDatabaseSync(value[0], value[1], value[2], value[3], value[4]);
}
