import 'dart:async';

import 'package:sqlite3/sqlite3.dart';

import '../common/common_db_column.dart';
import '../common/common_db_table.dart';
import '../interfaces/i_data_interval.dart';
import '../interfaces/i_data_provider.dart';
import '../interfaces/i_data_search_struct.dart';
import 'data_interval.dart';
import 'data_provider_events.dart';

/// Базовый класс по работе с данными через SQLite
/// - [T] - тип принимаемых данных
/// - [O] - тип возвращаемых данных
/// - [S] - тип данных используемых для поиска
class DataProviderSqlite<T, O extends T, S extends IDataSearchStruct>
    implements IDataProviderSync<T, O, S> {
  DataProviderSqlite(this.sql, this.dbTable);

  /// Размер максимальной вставки элементов за раз
  static const sqlInsertChunkSize = 128;

  /// Размер максимального обновления элементов за раз без темп таблицы
  static const sqlUpdateChunkSize = 16;

  /// Переодичность передачи обновлений базыданных
  static const sqlUpdatesDuration = Duration(milliseconds: 100);

  /// Соединение с БД
  final Database sql;

  final CommonDbTable dbTable;

  @override
  String get name =>
      haveFts ? 'SQLite: $tableName with Fts5' : 'SQLite: $tableName';

  List<CommonDbColumn> get columns => dbTable.columns;
  Iterable<DbColumnStringFts> get columnsFts =>
      columns.whereType<DbColumnStringFts>();

  late final haveFts = columnsFts.isNotEmpty;

  String get tableName => dbTable.name;
  String get tableNameFts => '${tableName}_idx';
  String get triggerNameFtsI => '${tableName}_ai';
  String get triggerNameFtsD => '${tableName}_ad';
  String get triggerNameFtsU => '${tableName}_au';
  late final idName = columns.whereType<DbColumnId>().first.name;

  /// Создание таблицы
  void sqlCreateTable() {
    sql.execute('''
      CREATE TABLE IF NOT EXISTS $tableName(
        ${columns.map(CommonDbColumn.getSQLiteString).join(', ')}
      )
    ''');
    if (haveFts) {
      sql.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS $tableNameFts USING fts5(
        ${columnsFts.map(CommonDbColumn.getName).join(', ')},
        content='$tableName',
        content_rowid='rowid'
      );
      CREATE TRIGGER IF NOT EXISTS $triggerNameFtsI AFTER INSERT ON $tableName BEGIN
        INSERT INTO $tableNameFts(
          rowid,
          ${columnsFts.map(CommonDbColumn.getName).join(', ')}
        ) VALUES (
          new.rowid,
          ${columnsFts.map(CommonDbColumn.getNameNewPrefix).join(', ')}
        );
      END;
      CREATE TRIGGER IF NOT EXISTS $triggerNameFtsD AFTER DELETE ON $tableName BEGIN
        INSERT INTO $tableNameFts(
          $tableNameFts,
          rowid,
          ${columnsFts.map(CommonDbColumn.getName).join(', ')}
        ) VALUES(
          'delete',
          old.rowid,
          ${columnsFts.map(CommonDbColumn.getNameOldPrefix).join(', ')}
        );
      END;
      CREATE TRIGGER IF NOT EXISTS $triggerNameFtsU AFTER UPDATE ON $tableName BEGIN
        INSERT INTO $tableNameFts(
          $tableNameFts,
          rowid,
          ${columnsFts.map(CommonDbColumn.getName).join(', ')}
        ) VALUES(
          'delete',
          old.rowid,
          ${columnsFts.map(CommonDbColumn.getNameOldPrefix).join(', ')}
        );
        INSERT INTO $tableNameFts(
          rowid,
          ${columnsFts.map(CommonDbColumn.getName).join(', ')}
        ) VALUES (
          new.rowid,
          ${columnsFts.map(CommonDbColumn.getNameNewPrefix).join(', ')}
        );
      END;
    ''');
    }
  }

  /// Удаление таблицы
  void sqlDropTable() {
    if (haveFts) {
      sql.execute('''
        DROP TRIGGER IF EXISTS $triggerNameFtsU;
        DROP TRIGGER IF EXISTS $triggerNameFtsD;
        DROP TRIGGER IF EXISTS $triggerNameFtsI;
        DROP TABLE IF EXISTS $tableNameFts;
      ''');
    }
    sql.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Преобразование [T] данные в данные для записи в БД
  List<Object?> sqlDataToRow(T data) {
    final encoded = dbTable.encode(data);
    final result = [];
    for (var i = 0; i < sqlColumnsCount; i++) {
      result.add(columns[i].encode(encoded[i]));
    }
    return result;
  }

  /// Преобразование [T] данные в данные для обновления записи в БД
  List<Object?> sqlDataToRowUpdate(T data) {
    final encoded = dbTable.encode(data);
    final result = [];
    var id = 0;
    for (var i = 0; i < sqlColumnsCount; i++) {
      final column = columns[i];
      final res = column.encode(encoded[i]);
      result.add(res);
      if (column is DbColumnId) {
        id = res;
      }
    }
    result.add(id);
    return result;
  }

  /// Преобразование записи из БД в данные типа [T]
  O sqlRowToData(Row row) {
    final result = [];
    for (var i = 0; i < row.length; i++) {
      result.add(dbTable.columns[i].decode(row.columnAt(i)));
    }
    return dbTable.decode(result);
  }

  /// ColumnTemplate, Шаблок для заполнения одного значения
  static String _ct<T>(T column) => '?';

  String get sqlColumnNames => columns.map((e) => e.name).join(',');

  int get sqlColumnsCount => columns.length;

  /// RowTemplate, Строка шаблона для заполнения данных записи, типа (?, ?, ?)
  late final _rt = '(${Iterable.generate(columns.length, _ct).join(', ')})';
  String _rtGen(int i) => _rt;
  String _tempsGen(int i) => Iterable.generate(i, _rtGen).join(', ');

  late final _sqlSelectPrefix =
      'SELECT ${columns.map(CommonDbColumn.getName).join(',')} FROM $tableName';

  /// Получить список записей по условию
  Iterable<O> sqlSelect([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql.select(' $_sqlSelectPrefix $condition', parameters).map(sqlRowToData);

  late final _sqlInsertPrefix = 'INSERT INTO $tableName VALUES';

  /// Вставка записей
  void sqlInsert(Iterable<T> data) {
    if (data.isEmpty) return;

    // Записываем пачками по [insertChunkSize] элементов
    if (data.length > sqlInsertChunkSize) {
      sqlInsert(data.take(sqlInsertChunkSize));
      sqlInsert(
        data.skip(sqlInsertChunkSize),
      );
    } else {
      final templates = _tempsGen(data.length);
      sql.execute(
        '$_sqlInsertPrefix $templates',
        data.expand(sqlDataToRow).toList(),
      );
    }
  }

  late final _sqlUpdate1Prefix = 'UPDATE $tableName SET'
      ' ${columns.map((e) => '${e.name} = ?').join(', ')} WHERE $idName = ?;';

  late final _sqlUpdate2Prefix = '''
      WITH ${tableName}_tmp(
        ${columns.map(CommonDbColumn.getName).join(', ')}
      ) AS ( VALUES''';
  late final _sqlUpdate2Suffix = '''
      )
      UPDATE $tableName SET
        ${columns.map((e) => '''
          ${e.name} = (
            SELECT ${e.name} FROM ${tableName}_tmp
            WHERE $tableName.$idName = ${tableName}_tmp.$idName
          )
        ''').join(', ')}
      WHERE $idName IN (SELECT $idName FROM $tableName.$idName)''';

  /// Обновление записей
  void sqlUpdate(Iterable<T> data) {
    if (data.isEmpty) return;

    // Записываем пачками по [insertChunkSize] элементов
    if (data.length > sqlInsertChunkSize) {
      sqlUpdate(data.take(sqlInsertChunkSize));
      sqlUpdate(data.skip(sqlInsertChunkSize));
    } else if (data.length <= sqlUpdateChunkSize) {
      sql.execute(
        _sqlUpdate1Prefix * data.length,
        data.expand(sqlDataToRowUpdate).toList(),
      );
    } else {
      final templates = _tempsGen(data.length);
      sql.execute(
        '$_sqlUpdate2Prefix $templates $_sqlUpdate2Suffix',
        data.expand(sqlDataToRow).toList(),
      );
    }
  }

  /// Удаление записей по условию
  void sqlDelete([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql.execute('DELETE FROM $tableName $condition', parameters);

  // void sqlUpdateSequence(int i) {
  //   final select =
  //       sql.select('SELECT MAX(rowid) FROM $tableName').first.columnAt(0);
  //   if (select == null) {
  //     sql.execute(
  //       'INSERT INTO sqlite_sequence (seq, name) VALUES (?, ?)',
  //       [i, tableName],
  //     );
  //     return;
  //   }
  //   if (select as int < i) {
  //     sql.execute(
  //       'UPDATE sqlite_sequence SET seq = ? WHERE name = ?',
  //       [i, tableName],
  //     );
  //   }
  // }

  /// Удаялет список записей по списку айди
  /// - [not] - флаг указывает исключение из списка
  void sqlDeleteByIds(List<int> ids, {bool not = false}) {
    if (ids.isEmpty) return;
    if (ids.length == 1) {
      return sqlDelete('WHERE $idName ${not ? '!=' : '='} ?', ids);
    }
    final templates = Iterable.generate(ids.length, _ct).join(', ');
    return sqlDelete('WHERE $idName ${not ? 'NOT ' : ''} IN ($templates)', ids);
  }

  @override
  int getNewId() {
    final res = sql.select('SELECT MAX($idName) FROM $tableName');
    return (res.first.columnAt(0) as int?) ?? 0 + 1;
  }

  @override
  O? getById(int id) {
    final o = getByIds([id]);
    if (o.isEmpty) return null;
    return o.first;
  }

  @override
  List<O> getByIds(List<int> ids, {bool not = false}) {
    if (ids.isEmpty) return [];
    if (ids.length == 1) {
      return sqlSelect('WHERE $idName ${not ? '!=' : '='} ?', ids).toList();
    }
    final templates = Iterable.generate(ids.length, _ct).join(', ');
    return sqlSelect('WHERE $idName ${not ? 'NOT' : ''} IN ($templates)', ids)
        .toList();
  }

  @override
  IDataInterval<O> getInterval(int offset, int length, [S? search]) {
    if (search == null) {
      if (length == 0) {
        return DataInterval(0, sqlSelect().toList());
      }
      return DataInterval(
        offset,
        sqlSelect(
          'LIMIT ?, ?',
          [offset, length],
        ).toList(),
      );
    }
    var order = '';
    if (search.orderColumn >= 0 && search.orderColumn < columns.length) {
      order = 'ORDER BY $tableName.${columns[search.orderColumn].name}';
      if (search.orderAsc) {
        order = '$order ASC';
      } else {
        order = '$order DESC';
      }
    }
    final match = search.text;
    if (match == null || !haveFts) {
      if (length == 0) {
        return DataInterval(0, sqlSelect().toList());
      }
      return DataInterval(
        offset,
        sqlSelect(
          '$order LIMIT ?, ?',
          [offset, length],
        ).toList(),
      );
    }
    if (search.orderColumn == -1) {
      order = 'ORDER BY bm25($tableNameFts)';
      if (search.orderAsc) {
        order = '$order ASC';
      } else {
        order = '$order DESC';
      }
    }
    var names = '$tableName.*';
    const i0 = highlightTextBegin;
    const i1 = highlightTextEnd;
    if (search.textHighlights) {
      var i = 0;
      final sb = <String>[];
      for (final column in columns) {
        if (column is DbColumnStringFts) {
          sb.add('''highlight($tableNameFts, $i, '$i0', '$i1')''');
          i++;
        } else {
          sb.add('''$tableName.${column.name}''');
        }
      }
      names = sb.join(', ');
    }
    if (length == 0) {
      return DataInterval(
        0,
        sql
            .select(
              '''
              SELECT $names FROM $tableNameFts
              LEFT JOIN $tableName ON $tableNameFts.rowid = $tableName.rowid
              WHERE $tableNameFts = ?
              $order
            ''',
              [match],
            )
            .map(sqlRowToData)
            .toList(),
      );
    }
    return DataInterval(
      offset,
      sql
          .select(
            '''
              SELECT $names FROM $tableNameFts
              LEFT JOIN $tableName ON $tableNameFts.rowid = $tableName.rowid
              WHERE $tableNameFts = ?
              $order LIMIT ?, ?
            ''',
            [match, offset, length],
          )
          .map(sqlRowToData)
          .toList(),
    );
  }

  @override
  int add(T value) {
    sqlInsert([value]);
    return sql.lastInsertRowId;
  }

  final List<int> _updatedRowsId = [];
  void _updatedCallback(SqliteUpdate event) {
    if (event.tableName != tableName) return;
    _updatedRowsId.add(event.rowId);
  }

  @override
  List<int> addAll(List<T> values) {
    _updatedRowsId.clear();
    sql.addCallback(_updatedCallback);
    sqlInsert(values);
    sql.removeCallback(_updatedCallback);
    final o = _updatedRowsId.toList();
    _updatedRowsId.clear();
    return o;
  }

  @override
  int update(T value) => (updateAll([value])).first;

  @override
  List<int> updateAll(List<T> values) {
    _updatedRowsId.clear();
    sql.addCallback(_updatedCallback);
    sqlUpdate(values);
    sql.removeCallback(_updatedCallback);
    final o = _updatedRowsId.toList();
    _updatedRowsId.clear();
    return o;
  }

  @override
  bool deleteById(int id) => deleteByIds([id]) == 1;

  @override
  int deleteByIds(List<int> ids) {
    _updatedRowsId.clear();
    sql.addCallback(_updatedCallback);
    sqlDeleteByIds(ids);
    sql.removeCallback(_updatedCallback);
    final o = _updatedRowsId.length;
    _updatedRowsId.clear();
    return o;
  }

  @override
  int length([S? search]) {
    if (search == null || search.text == null || !haveFts) {
      return sql.select('SELECT COUNT(*) FROM $tableName').first.columnAt(0);
    }
    return sql
        .select(
          'SELECT COUNT(*) FROM $tableNameFts WHERE $tableNameFts = ?',
          [search.text!],
        )
        .first
        .columnAt(0);
  }

  Timer? _updatesTimer;
  final _updatesAdds = <int>{};
  final _updatesUpdates = <int>{};
  final _updatesDeletes = <int>{};

  void _updatesSqliteCallback(SqliteUpdate event) {
    if (event.tableName != tableName) return;
    switch (event.kind) {
      case SqliteUpdateKind.insert:
        _updatesAdds.add(event.rowId);
        break;
      case SqliteUpdateKind.update:
        _updatesUpdates.add(event.rowId);
        break;
      case SqliteUpdateKind.delete:
        _updatesDeletes.add(event.rowId);
        break;
    }
  }

  void _updatesTimerCallback(Timer timer) {
    if (_updatesAdds.isNotEmpty) {
      _updatesController.add(
        DataProviderEvent.add(_updatesAdds.toList()),
      );
      _updatesAdds.clear();
    }
    if (_updatesUpdates.isNotEmpty) {
      _updatesController.add(
        DataProviderEvent.update(_updatesUpdates.toList()),
      );
      _updatesUpdates.clear();
    }
    if (_updatesDeletes.isNotEmpty) {
      _updatesController.add(
        DataProviderEvent.delete(_updatesDeletes.toList()),
      );
      _updatesDeletes.clear();
    }
  }

  var _updatesListners = 0;
  void _updatesListnersAdd() {
    if (_updatesListners == 0) {
      sql.addCallback(_updatesSqliteCallback);
      _updatesTimer = Timer.periodic(sqlUpdatesDuration, _updatesTimerCallback);
    }
    _updatesListners++;
  }

  void _updatesListnersCancel() {
    _updatesListners--;
    if (_updatesListners == 0) {
      _updatesTimer!.cancel();
      _updatesTimer = null;
      sql.removeCallback(_updatesSqliteCallback);
    }
  }

  late final _updatesController = StreamController<DataProviderEvent>.broadcast(
    onListen: _updatesListnersAdd,
    onCancel: _updatesListnersCancel,
    sync: true,
  );

  @override
  Stream<DataProviderEvent> get updates => _updatesController.stream;

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() {
    if (_updatesListners != 0) sql.removeCallback(_updatesSqliteCallback);
    _updatesListners = -1;
    return _updatesController.close();
  }
}
