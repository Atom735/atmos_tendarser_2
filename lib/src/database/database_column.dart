import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

const highlightTextBegin = '\u{1}';
const highlightTextEnd = '\u{2}';

/// Описание колонки таблицы
/// - [S] - Тип данных представление в дарте
/// - [D] - Тип данных представляемый в БД
@immutable
abstract class DatabaseColumn<S, D> {
  const DatabaseColumn();

  /// Название колонки
  String get name;

  /// Типа содержащихся данных
  String get type;

  /// Ограничения содержащихся данных колонки
  String get constraints;

  /// Флаг индексации колонки
  bool get indexed => false;

  /// Флаг уникальных значений колонки
  bool get unique => false;

  /// Серриализация строки для SQLite
  String get columnDefinitions => '$name $type $constraints';

  /// Конвертация значения из данных БД в дарт представление
  S dartDecode(D value);

  /// Чтение значения из байт сообщения как дарт представление
  S msgDartRead(BinaryReader reader) => dartDecode(msgDbRead(reader));

  /// Чтение значения из байт сообщения как данные БД
  D msgDbRead(BinaryReader reader);

  /// Конвертация значения из дарт представления в БД данные
  D dartEncode(S value);

  /// Запись дарт представления в значения байт сообщения
  void msgDartWrite(S value, BinaryWriter writer) =>
      msgDbWrite(dartEncode(value), writer);

  /// Запись данных бд в значения байт сообщения
  void msgDbWrite(D value, BinaryWriter writer);

  @override
  String toString() => columnDefinitions;

  static String getName(DatabaseColumn c) => c.name;
  static String getNameBind(DatabaseColumn c) => '${c.name} = ?';

  static bool filterIndexed(DatabaseColumn c) => c.indexed;
  static bool filterFts(DatabaseColumn c) =>
      c is DatabaseColumnTextBase && c.fts;
}

/// Базовый тип колонки БД содержащая целое число
@immutable
abstract class DatabaseColumnIntegerBase<S> extends DatabaseColumn<S, int> {
  @literal
  const DatabaseColumnIntegerBase();

  @override
  String get type => 'INTEGER';

  @override
  String get constraints => 'NOT NULL';

  @override
  int msgDbRead(BinaryReader reader) => reader.readPackedInt();

  @override
  void msgDbWrite(int value, BinaryWriter writer) =>
      writer.writePackedInt(value);
}

/// Базовый тип колонки БД содержащая целое неотрицательное число
@immutable
abstract class DatabaseColumnUnsignedBase<S>
    extends DatabaseColumnIntegerBase<S> {
  @literal
  const DatabaseColumnUnsignedBase();

  @override
  String get constraints => '${super.constraints} CHECK($name >= 0)';

  @override
  int msgDbRead(BinaryReader reader) => reader.readSize();

  @override
  void msgDbWrite(int value, BinaryWriter writer) => writer.writeSize(value);
}

/// Базовый тип колонки БД содержащая целое неотрицательное число
@immutable
abstract class DatabaseColumnBlobBase<S> extends DatabaseColumn<S, Uint8List> {
  @literal
  const DatabaseColumnBlobBase();

  @override
  String get type => 'BLOB';

  @override
  String get constraints => 'NOT NULL';

  @override
  Uint8List msgDbRead(BinaryReader reader) => reader.readListUint8();

  @override
  void msgDbWrite(Uint8List value, BinaryWriter writer) =>
      writer.writeListUint8(value);
}

/// Базовый тип колонки БД содержащая текстовое значение
@immutable
abstract class DatabaseColumnTextBase<S> extends DatabaseColumn<S, String> {
  @literal
  const DatabaseColumnTextBase();

  @override
  String get type => 'TEXT';

  @override
  String get constraints => 'NOT NULL';

  /// Флаг является ли колонка доступной для поиска через Full Text Search
  bool get fts;

  @override
  String msgDbRead(BinaryReader reader) => reader.readString();

  @override
  void msgDbWrite(String value, BinaryWriter writer) =>
      writer.writeString(value);
}

/// Колонка БД содержащая уникальный айди записи
/// - Если передать [DatabaseColumnId.zero] то вернётся новый уникальный айди
@immutable
class DatabaseColumnId extends DatabaseColumn<int, int?> {
  @literal
  const DatabaseColumnId([this.name = 'id']);

  @override
  final String name;

  @override
  String get type => 'INTEGER';

  @override
  String get constraints => 'PRIMARY KEY ASC';

  static const zero = 0;

  @override
  int dartDecode(int? value) => value ?? zero;

  @override
  int? dartEncode(int value) {
    if (value == zero) return null;
    return value;
  }

  @override
  int? msgDbRead(BinaryReader reader) {
    final value = reader.readSize();
    if (value == zero) return null;
    return value;
  }

  @override
  void msgDbWrite(int? value, BinaryWriter writer) =>
      writer.writeSize(value ?? zero);
}

/// Колонка БД содержащая метку времени обнолвения записи
/// - Если передать [DatabaseColumnTimestamp.zero] то вернётся [DateTime.now]
@immutable
class DatabaseColumnTimestamp extends DatabaseColumnUnsignedBase<DateTime> {
  @literal
  const DatabaseColumnTimestamp([this.name = 'timestamp']);

  @override
  final String name;

  @override
  String get type => 'INTEGER';

  @override
  String get constraints => '${super.constraints} UNIQUE';

  @override
  bool get indexed => true;

  static final _tickStart = Stopwatch()..start();
  static final _tickStartDt =
      DateTime.now().toUtc().microsecondsSinceEpoch - zero;
  static final zeroDt = DateTime.utc(2022);
  static final zero = zeroDt.microsecondsSinceEpoch;

  @override
  DateTime dartDecode(int value) {
    if (value == 0) {
      return DateTime.fromMicrosecondsSinceEpoch(
        _tickStartDt + _tickStart.elapsedMicroseconds,
        isUtc: true,
      );
    }
    return DateTime.fromMicrosecondsSinceEpoch(value + zero, isUtc: true);
  }

  @override
  int dartEncode(DateTime value) {
    final i = value.toUtc().microsecondsSinceEpoch - zero;
    if (i == 0) {
      return _tickStartDt + _tickStart.elapsedMicroseconds;
    }
    return i;
  }
}

/// Колонка БД содержащая целое число
@immutable
class DatabaseColumnInt extends DatabaseColumnIntegerBase<int> {
  @literal
  const DatabaseColumnInt(
    this.name, {
    this.unique = false,
    this.indexed = false,
  });

  @override
  final String name;

  @override
  final bool unique;

  @override
  final bool indexed;

  @override
  String get constraints =>
      unique ? '${super.constraints} UNIQUE' : super.constraints;

  @override
  int dartDecode(int value) => value;

  @override
  int dartEncode(int value) => value;
}

/// Колонка БД содержащая целое неотрицательное число
@immutable
class DatabaseColumnUint extends DatabaseColumnUnsignedBase<int> {
  @literal
  const DatabaseColumnUint(
    this.name, {
    this.unique = false,
    this.indexed = false,
  });

  @override
  final String name;

  @override
  final bool unique;

  @override
  final bool indexed;

  @override
  String get constraints =>
      unique ? '${super.constraints} UNIQUE' : super.constraints;

  @override
  int dartDecode(int value) => value;

  @override
  int dartEncode(int value) => value;
}

/// Колонка БД содержащая обычную текстовую строку
@immutable
class DatabaseColumnString extends DatabaseColumnTextBase<String> {
  @literal
  const DatabaseColumnString(
    this.name, {
    this.fts = false,
    this.unique = false,
    this.indexed = false,
  });

  @override
  final String name;

  @override
  final bool fts;

  @override
  final bool unique;

  @override
  final bool indexed;

  @override
  String get constraints =>
      unique ? '${super.constraints} UNIQUE' : super.constraints;

  @override
  String dartDecode(String value) => value;

  @override
  String dartEncode(String value) => value;
}

/// Колонка БД содержащая обычный массив байт
@immutable
class DatabaseColumnBytes extends DatabaseColumnBlobBase<Uint8List> {
  @literal
  const DatabaseColumnBytes([this.name = 'bytes']);

  @override
  final String name;

  @override
  Uint8List dartDecode(Uint8List value) => value;

  @override
  Uint8List dartEncode(Uint8List value) => value;
}
