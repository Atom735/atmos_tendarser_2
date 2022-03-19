import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import 'database_column.dart';

/// Описание таблицы базыданных
/// - [T] - тип данных поставляемые таблицой
@immutable
abstract class DatabaseTable<T> {
  @literal
  const DatabaseTable();

  /// Название таблицы
  String get name;

  /// Колонки таблицы
  List<DatabaseColumn> get columns;

  /// Колонка таблицы для синхронизации
  DatabaseColumn get columnSync;

  /// Кол-во колонок таблицы
  int get columnsCount => columns.length;

  /// Колонки таблицы которые подлежат индексации
  Iterable<DatabaseColumn> get columnsIndexed =>
      columns.where(DatabaseColumn.filterIndexed);

  /// Колонки таблицы которые помечаны для полнотекстового поиска
  Iterable<DatabaseColumn> get columnsFts =>
      columns.where(DatabaseColumn.filterFts);

  /// Колонка айди таблицы
  DatabaseColumnId get columnId => columns.whereType<DatabaseColumnId>().single;

  /// Колонка отметки изменения запики таблицы
  DatabaseColumnTimestamp get columnTimestamp =>
      columns.whereType<DatabaseColumnTimestamp>().single;

  /// Преобразует данные полученые с БД в
  /// дарт объект представляемый этой таблицей
  T dartDecode(List value);

  /// Преобразует данные полученые из байт сообщения в
  /// дарт объект представляемый этой таблицей
  T msgDartRead(BinaryReader reader) => dartDecode(msgDbRead(reader));

  T _msgDartReadList(int i, BinaryReader reader) => msgDartRead(reader);
  List<T> msgDartReadList(BinaryReader reader) =>
      reader.readList(_msgDartReadList);

  /// Преобразует данные полученые из байт сообщения в
  /// список данных для отправки в БД
  List msgDbRead(BinaryReader reader) {
    final t = [];
    for (var i = 0; i < columns.length; i++) {
      t.add(columns[i].msgDbRead(reader));
    }
    return t;
  }

  /// Преобразует данные дарт объекта в
  /// список данных для отправки в БД
  List dartEncode(T value);

  /// Запись дарт представления в значения байт сообщения
  void msgDartWrite(T value, BinaryWriter writer) =>
      msgDbWrite(dartEncode(value), writer);

  void _msgDartWriteList(T value, int i, BinaryWriter writer) =>
      msgDartWrite(value, writer);
  void msgDartWriteList(List<T> value, BinaryWriter writer) =>
      writer.writeList(value, _msgDartWriteList);

  /// Запись данных бд в значения байт сообщения
  void msgDbWrite(List value, BinaryWriter writer) {
    for (var i = 0; i < columns.length; i++) {
      columns[i].msgDbWrite(value[i], writer);
    }
  }

  @override
  String toString() => '$name(${columns.join(', ')})';
}
