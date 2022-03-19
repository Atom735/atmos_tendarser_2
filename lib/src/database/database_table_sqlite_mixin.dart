import 'package:sqlite3/sqlite3.dart';

import 'database_column.dart';
import 'database_table.dart';

mixin DatabaseTableSqliteMixin<T> on DatabaseTable<T> {
  /// Название связанной таблицы Fts5
  String get nameFts => '_fts_$name';

  /// Максимально вставляемое количество данных за раз
  int get sqlInsertChunkSize => 0x7f00 ~/ (columnsCount + 1);

  /// Размер максимального обновления элементов за раз без темп таблицы
  static const sqlUpdateChunkSize = 0x40;

  String get _nameI => '_i_${name}_';
  String get _nameTemp => '_tmp_$name';
  String get _nameFtsI => '_ftsI_$name';
  String get _nameFtsD => '_ftsD_$name';
  String get _nameFtsU => '_ftsU_$name';

  /// Создание таблицы в БД
  void sqlCreateTable(Database sql) {
    final sb = StringBuffer('CREATE TABLE IF NOT EXISTS $name (')
      ..write(columns.first.columnDefinitions);
    for (final column in columns.skip(1)) {
      sb
        ..write(', ')
        ..write(column.columnDefinitions);
    }
    sb.writeln(');');
    _sqlCreateIndexes(sb);
    _sqlCreateFts(sb);
    sql.execute(sb.toString());
  }

  /// Удаление таблицы из БД
  void sqlDropTable(Database sql) {
    final sb = StringBuffer();
    for (final column in columnsIndexed) {
      sb.writeln('DROP INDEX IF EXISTS $_nameI${column.name};');
    }
    if (columnsFts.isNotEmpty) {
      sb
        ..writeln('DROP TRIGGER IF EXISTS $_nameFtsU;')
        ..writeln('DROP TRIGGER IF EXISTS $_nameFtsD;')
        ..writeln('DROP TRIGGER IF EXISTS $_nameFtsI;')
        ..writeln('DROP TABLE IF EXISTS $nameFts;');
    }
    sb.writeln('DROP TABLE IF EXISTS $name;');
    sql.execute(sb.toString());
  }

  /// Преобразование [T] данные в данные для записи в БД
  List<Object?> sqlRowEncode(T data) {
    final encoded = dartEncode(data);
    final result = [];
    for (var i = 0; i < columnsCount; i++) {
      result.add(columns[i].dartEncode(encoded[i]));
    }
    return result;
  }

  /// Преобразование [T] данные в данные для обновления записи в БД
  List<Object?> sqlRowEncodeForUpdate(T data) {
    final encoded = dartEncode(data);
    final result = [];
    var id = 0;
    for (var i = 0; i < columnsCount; i++) {
      final column = columns[i];
      final res = column.dartEncode(encoded[i]);
      result.add(res);
      if (column is DatabaseColumnId) {
        id = res;
      }
    }
    return result..add(id);
  }

  /// Преобразование записи из БД в данные типа [T]
  T sqlRowDecode(Row row) {
    final result = [];
    for (var i = 0; i < row.length; i++) {
      result.add(columns[i].dartDecode(row.columnAt(i)));
    }
    return dartDecode(result);
  }

  List<T> sqlSelectByIds(Database sql, List<int> ids) => sqlSelect(
        sql,
        'WHERE ${columnId.name} IN (${ids.map((e) => '?').join(', ')})',
        ids,
      ).toList();

  MapEntry<int, Set<T>> sqlInsertNews1(
    Database sql,
    Set<T> data,
    int columnId,
    dynamic Function(T e) selector, [
    bool noReturn = false,
  ]) {
    final colName = columns[columnId].name;
    final selected = data.map(selector).toList();
    final str = 'WHERE $colName IN (${data.map((e) => '?').join(', ')})';
    final added = data.toSet()..removeAll(sqlSelect(sql, str, selected));
    sqlInsert(sql, added);
    if (noReturn) return MapEntry(added.length, data);
    return MapEntry(
      added.length,
      data
        ..clear()
        ..addAll(sqlSelect(sql, str, selected)),
    );
  }

  MapEntry<int, Set<T>> sqlInsertNewsMulti(
    Database sql,
    Set<T> data,
    Map<int, dynamic Function(T e)> selectors, [
    bool noReturn = false,
  ]) {
    final sb = StringBuffer('WHERE ');
    final e = selectors.entries.first;
    sb.write('${columns[e.key].name} IN (${data.map((e) => '?').join(', ')})');
    for (final e in selectors.entries.skip(1)) {
      sb.write(
          ''' AND ${columns[e.key].name} IN (${data.map((e) => '?').join(', ')})''');
    }
    final str = sb.toString();
    final selected =
        selectors.values.expand((selector) => data.map(selector)).toList();
    final added = data.toSet()
      ..removeAll(sqlSelect(
        sql,
        str,
        selected,
      ));
    sqlInsert(sql, added);
    if (noReturn) return MapEntry(added.length, data);
    return MapEntry(
      added.length,
      data
        ..clear()
        ..addAll(sqlSelect(
          sql,
          str,
          selected,
        )),
    );
  }

  /// Вставка записей
  /// - Записываем пачками по [sqlInsertChunkSize] элементов
  void sqlInsert(Database sql, Iterable<T> data) {
    if (data.isEmpty) return;

    if (data.length > sqlInsertChunkSize) {
      sqlInsert(sql, data.take(sqlInsertChunkSize));
      sqlInsert(sql, data.skip(sqlInsertChunkSize));
    } else {
      final sb = StringBuffer('INSERT INTO $name VALUES ');
      for (var i = 0; i < data.length; i++) {
        if (i != 0) {
          sb.write(', ');
        }
        sb.write('(');
        for (var j = 0; j < columnsCount; j++) {
          if (j != 0) {
            sb.write(', ');
          }
          sb.write('?');
        }
        sb.write(')');
      }
      sql.execute(sb.toString(), data.expand(sqlRowEncode).toList());
    }
  }

  /// Получить список записей с условием
  Iterable<T> sqlSelect(
    Database sql, [
    String condition = '',
    List<Object?> parameters = const [],
  ]) {
    final sb = StringBuffer('SELECT ${columns.first.name}');
    for (final column in columns.skip(1)) {
      sb
        ..write(', ')
        ..write(column.name);
    }
    sb
      ..write(' FROM $name ')
      ..write(condition);
    return sql.select(sb.toString(), parameters).map(sqlRowDecode);
  }

  /// Обновление записей
  /// - Обновляем пачками по [sqlInsertChunkSize] элементов
  void sqlUpdate(Database sql, Iterable<T> data) {
    if (data.isEmpty) return;

    /// Обновляем пачками по [sqlInsertChunkSize] элементов
    if (data.length > sqlInsertChunkSize) {
      sqlUpdate(sql, data.take(sqlInsertChunkSize));
      sqlUpdate(sql, data.skip(sqlInsertChunkSize));
    } else if (data.length <= sqlUpdateChunkSize) {
      sql.execute(
        _sqlUpdate1Prefix * data.length,
        data.expand(sqlRowEncodeForUpdate).toList(),
      );
    } else {
      final sb = StringBuffer(_sqlUpdate2Prefix);
      for (var i = 0; i < data.length; i++) {
        if (i != 0) {
          sb.write(', ');
        }
        sb.write('(');
        for (var j = 0; j < columnsCount; j++) {
          if (j != 0) {
            sb.write(', ');
          }
          sb.write('?');
        }
        sb.write(')');
      }
      sb.write(_sqlUpdate2Suffix);
      sql.execute(
        sb.toString(),
        data.expand(sqlRowEncode).toList(),
      );
    }
  }

  /// Удаление записей по условию
  void sqlDelete(
    Database sql, [
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql.execute('DELETE FROM $name $condition', parameters);

  String get _idName => columnId.name;

  late final _sqlUpdate1Prefix = 'UPDATE $name SET'
      ' ${columns.map(DatabaseColumn.getNameBind).join(', ')}'
      ' WHERE $_idName = ?;';

  late final _sqlUpdate2Prefix = '''
      WITH $_nameTemp(
        ${columns.map(DatabaseColumn.getName).join(', ')}
      ) AS ( VALUES ''';

  late final _sqlUpdate2Suffix = '''
      ) UPDATE $name SET
        ${columns.map((e) => '''
          ${e.name} = (
            SELECT ${e.name} FROM $_nameTemp
            WHERE $name.$_idName = $_nameTemp.$_idName
          )
        ''').join(', ')}
      WHERE $_idName IN (SELECT $_idName FROM $name.$_idName)''';

  /// Создание таблицы индексов в БД
  void _sqlCreateIndexes(StringBuffer sb) {
    for (final column in columnsIndexed) {
      sb.writeln(
          '''CREATE INDEX IF NOT EXISTS $_nameI${column.name} ON $name(${column.name});''');
    }
  }

  /// Создание таблицы Fts5 в БД
  void _sqlCreateFts(StringBuffer sb) {
    if (columnsFts.isEmpty) return;
    sb.write('CREATE VIRTUAL TABLE IF NOT EXISTS $nameFts USING fts5(');
    for (final column in columnsFts) {
      sb
        ..write(column.name)
        ..write(', ');
    }
    sb.writeln('content=\'$name\', content_rowid=\'rowid\');');
    _sqlCreateFtsTriggerI(sb);
    _sqlCreateFtsTriggerD(sb);
    _sqlCreateFtsTriggerU(sb);
  }

  /// Создание триггера таблицы Fts5 для вставки
  void _sqlCreateFtsTriggerI(StringBuffer sb) {
    sb.writeln(
        '''CREATE TRIGGER IF NOT EXISTS $_nameFtsI AFTER INSERT ON $name BEGIN''');
    _sqlCreateFtsI(sb);
    sb.writeln('END;');
  }

  /// Создание триггера таблицы Fts5 для удаления
  void _sqlCreateFtsTriggerD(StringBuffer sb) {
    sb.writeln(
        '''CREATE TRIGGER IF NOT EXISTS $_nameFtsD AFTER DELETE ON $name BEGIN''');
    _sqlCreateFtsD(sb);
    sb.writeln('END;');
  }

  /// Создание триггера таблицы Fts5 для обновления
  void _sqlCreateFtsTriggerU(StringBuffer sb) {
    sb.writeln(
        '''CREATE TRIGGER IF NOT EXISTS $_nameFtsU AFTER UPDATE ON $name BEGIN''');
    _sqlCreateFtsD(sb);
    _sqlCreateFtsI(sb);
    sb.writeln('END;');
  }

  void _sqlCreateFtsD(StringBuffer sb) {
    sb.write('INSERT INTO $nameFts($nameFts, rowid');
    for (final column in columnsFts) {
      sb
        ..write(', ')
        ..write(column.name);
    }
    sb.write(') VALUES (\'delete\', old.rowid');
    for (final column in columnsFts) {
      sb
        ..write(', ')
        ..write('old.')
        ..write(column.name);
    }
    sb.writeln(');');
  }

  void _sqlCreateFtsI(StringBuffer sb) {
    sb.write('INSERT INTO $nameFts(rowid');
    for (final column in columnsFts) {
      sb
        ..write(', ')
        ..write(column.name);
    }
    sb.write(') VALUES (new.rowid');
    for (final column in columnsFts) {
      sb
        ..write(', ')
        ..write('new.')
        ..write(column.name);
    }
    sb.writeln(');');
  }
}
