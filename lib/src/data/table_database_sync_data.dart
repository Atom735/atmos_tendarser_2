import 'package:meta/meta.dart';

import '../database/database_column.dart';
import '../database/database_table.dart';
import 'dto_database_sync_data.dart';

@immutable
class TableDatabaseSyncData extends DatabaseTable<DtoDatabaseSyncData> {
  @literal
  const TableDatabaseSyncData();
  @override
  DatabaseColumn get columnSync => throw UnsupportedError('cant sync');

  @override
  String get name => 'DatabaseSyncData';
  @override
  List<DatabaseColumn> get columns => const [
        DatabaseColumnUint('companies'),
        DatabaseColumnUint('regions'),
        DatabaseColumnUint('regionsRefs'),
        DatabaseColumnUint('props'),
        DatabaseColumnUint('propsRefs'),
        DatabaseColumnUint('tenders'),
      ];

  @override
  List dartEncode(DtoDatabaseSyncData value) => [
        value.companies,
        value.regions,
        value.regionsRefs,
        value.props,
        value.propsRefs,
        value.tenders,
      ];

  @override
  DtoDatabaseSyncData dartDecode(List value) => DtoDatabaseSyncData(
        value[0],
        value[1],
        value[2],
        value[3],
        value[4],
        value[5],
      );
}
