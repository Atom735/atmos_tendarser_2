import 'package:meta/meta.dart';

import 'database_column.dart';
import 'database_table.dart';

/// Колонка БД содержащая уникальный айди записи другой таблицы
@immutable
class DatabaseColumnRef extends DatabaseColumnUint {
  @literal
  const DatabaseColumnRef(String name, this.refTable)
      : super(name, indexed: true);

  /// Таблицы на которую идёт ссылка
  final DatabaseTable refTable;

  @override
  String get constraints => '${super.constraints} REFERENCES ${refTable.name}'
      '(${refTable.columnId.name})';
}
