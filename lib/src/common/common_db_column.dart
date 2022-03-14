import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Описание колонки таблицы
/// - [S] - Тип данных представление в дарте
/// - [D] - Тип данных представляемый в БД
@immutable
abstract class CommonDbColumn<S, D> {
  @literal
  const CommonDbColumn();

  /// Название колонки
  String get name;

  /// Тип колонки
  String get type;

  /// Ограничения колонки
  String get constraints;

  /// Преобразование значения из БД в дарт
  S decode(D value);

  /// Преобразование значения из дарта в БД
  D encode(S value);

  /// Серриализация строки для SQLite
  String toStringSQLite() => '$name $type $constraints';

  @override
  String toString() => toStringSQLite();

  static String getSQLiteString(CommonDbColumn c) => c.toStringSQLite();
  static String getName(CommonDbColumn c) => c.name;
  static String getNameNewPrefix(CommonDbColumn c) => 'new.${c.name}';
  static String getNameOldPrefix(CommonDbColumn c) => 'old.${c.name}';
}

@immutable
abstract class CommonDbColumnInteger<S> extends CommonDbColumn<S, int> {
  @literal
  const CommonDbColumnInteger();

  @override
  String get type => 'INTEGER';

  @override
  String get constraints => 'NOT NULL';
}

@immutable
abstract class CommonDbColumnBlob<S> extends CommonDbColumn<S, Uint8List> {
  @literal
  const CommonDbColumnBlob();

  @override
  String get type => 'BLOB';

  @override
  String get constraints => 'NOT NULL';
}

@immutable
abstract class CommonDbColumnText<S> extends CommonDbColumn<S, String> {
  @literal
  const CommonDbColumnText();

  @override
  String get type => 'TEXT';

  @override
  String get constraints => 'NOT NULL';
}

@immutable
class DbColumnId extends CommonDbColumnInteger<int> {
  @literal
  const DbColumnId([this.name = 'id']);

  @override
  final String name;

  @override
  String get constraints => 'PRIMARY KEY ASC AUTOINCREMENT';

  @override
  int decode(int value) => value;

  @override
  int encode(int value) => value;
}

@immutable
class DbColumnInt extends CommonDbColumnInteger<int> {
  @literal
  const DbColumnInt(this.name);

  @override
  final String name;

  @override
  int decode(int value) => value;

  @override
  int encode(int value) => value;
}

@immutable
class DbColumnString extends CommonDbColumnText<String> {
  @literal
  const DbColumnString(this.name);

  @override
  final String name;

  @override
  String decode(String value) => value;

  @override
  String encode(String value) => value;
}

@immutable
class DbColumnStringFts extends CommonDbColumnText<String> {
  @literal
  const DbColumnStringFts(this.name);

  @override
  final String name;

  @override
  String decode(String value) => value;

  @override
  String encode(String value) => value;
}

@immutable
class DbColumnBytes extends CommonDbColumnBlob<Uint8List> {
  @literal
  const DbColumnBytes([this.name = 'bytes']);

  @override
  final String name;

  @override
  Uint8List decode(Uint8List value) => value;

  @override
  Uint8List encode(Uint8List value) => value;
}

@immutable
class DbColumnTimeStamp extends CommonDbColumnInteger<DateTime> {
  @literal
  const DbColumnTimeStamp([this.name = 'timestamp']);

  @override
  final String name;

  @override
  DateTime decode(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();

  @override
  int encode(DateTime value) => value.toUtc().microsecondsSinceEpoch;
}

@immutable
class DbColumnStringsSet extends CommonDbColumnText<Set<String>> {
  @literal
  const DbColumnStringsSet(this.name);

  @override
  final String name;

  static const recSeparator = '\u{1F}';

  @override
  Set<String> decode(String value) {
    if (value.isEmpty) return {};
    return Set.of(value.split(recSeparator));
  }

  @override
  String encode(Set<String> value) => value.join(recSeparator);
}
