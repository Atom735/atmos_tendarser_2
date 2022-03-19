import 'package:sqlite3/sqlite3.dart';

import '../data/dto_updater_data.dart';
import '../data/table_companies.dart';
import '../data/table_database_sync_data.dart';
import '../data/table_regions.dart';
import '../data/table_tender_data.dart';
import '../data/table_tender_props.dart';
import '../data/table_updater_data.dart';
import 'database_table_sqlite_proxy.dart';

class DatabaseApp {
  DatabaseApp(this.fname);

  final String fname;
  late final sql = sqlite3.open(fname)
    ..execute('PRAGMA JOURNAL_MODE=OFF')
    ..execute('PRAGMA SYNCHRONOUS=OFF');

  late final tableSync = DatabaseTableSqliteProxy(
    const TableDatabaseSyncData(),
  )..sqlCreateTable(sql);

  late final tableCompanies = DatabaseTableSqliteProxy(
    const TableCompanies(),
  )..sqlCreateTable(sql);

  late final tableRegions = DatabaseTableSqliteProxy(
    const TableRegions(),
  )..sqlCreateTable(sql);

  late final tableProps = DatabaseTableSqliteProxy(
    const TableProps(),
  )..sqlCreateTable(sql);

  late final tableTenders = DatabaseTableSqliteProxy(
    const TableTenderData(),
  )..sqlCreateTable(sql);

  late final tableRegionsRefs = DatabaseTableSqliteProxy(
    const TableRegionsRefs(),
  )..sqlCreateTable(sql);

  late final tablePropsRefs = DatabaseTableSqliteProxy(
    const TablePropsRefs(),
  )..sqlCreateTable(sql);

  late final tableUpdaters = DatabaseTableSqliteProxy(
    const TableUpdaterData(),
  )..sqlCreateTable(sql);

  late final tableUpdatersState = DatabaseTableSqliteProxy(
    const TableUpdaterDataState(),
  );

  void updateUpdaterStates(List<DtoUpdaterDataState> data) {
    tableUpdatersState.sqlUpdate(sql, data);
  }

  void dispose() => sql.dispose();
}
