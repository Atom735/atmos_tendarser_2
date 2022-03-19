import 'database_column.dart';
import 'database_table.dart';

/// Прокси примесь таблицы
mixin DatabaseTableProxyMixin<T> on DatabaseTable<T> {
  DatabaseTable<T> get origin;

  @override
  String get name => origin.name;

  @override
  DatabaseColumn get columnSync => origin.columnSync;

  @override
  List<DatabaseColumn> get columns => origin.columns;

  @override
  T dartDecode(List value) => origin.dartDecode(value);

  @override
  List dartEncode(T value) => origin.dartEncode(value);
}
