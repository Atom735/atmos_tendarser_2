import 'common_db_column.dart';

/// Интерфейс базы данных
/// - [T] - тип принимаемых данных
/// - [O] - тип возвращаемых данных
abstract class CommonDbTable<T, O extends T> {
  /// Название таблицы
  String get tableName;

  /// Колонки таблицы
  List<CommonDbColumn> get tableColumns;

  /// Готовит данные для записи в таблицу
  List encode(T data);

  /// Преобразует запись из таблицы в данные
  O decode(List data);
}
