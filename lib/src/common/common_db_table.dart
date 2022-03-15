import 'package:meta/meta.dart';

import 'common_db_column.dart';

/// Интерфейс базы данных
/// - [T] - тип принимаемых данных
/// - [O] - тип возвращаемых данных
@immutable
abstract class CommonDbTable<T, O extends T> {
  @literal
  const CommonDbTable();

  bool get isSubTable;

  /// Название таблицы
  String get name;

  /// Колонки таблицы
  List<CommonDbColumn> get columns;

  /// Готовит данные для записи в таблицу
  List encode(T data);

  /// Преобразует запись из таблицы в данные
  O decode(List data);

  @override
  String toString() => '$name(${columns.map((e) => e.name).join(', ')})';
}
