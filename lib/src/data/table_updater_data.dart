import 'package:meta/meta.dart';

import '../common/common_date_time.dart';
import '../database/database_column.dart';
import '../database/database_table.dart';
import 'dto_updater_data.dart';

@immutable
class TableUpdaterData extends DatabaseTable<DtoUpdaterData> {
  @literal
  const TableUpdaterData();

  @override
  String get name => 'UpdaterData';

  static const statusCodeColumnName = 'statusCode';

  @override
  DatabaseColumn get columnSync => const DatabaseColumnTimestamp();

  @override
  List<DatabaseColumn> get columns => const [
        DatabaseColumnId('updaterId'),
        DatabaseColumnTimestamp(),
        DatabaseColumnMyDateTime('start'),
        DatabaseColumnMyDateTime('end'),
        DatabaseColumnUint('page'),
        DatabaseColumnMyDateTime('date'),
        DatabaseColumnUint('pageMax'),
        DatabaseColumnUint(statusCodeColumnName),
        DatabaseColumnString('statusMessage'),
      ];

  @override
  List dartEncode(DtoUpdaterData value) => [
        value.state.id,
        value.state.timestamp,
        value.settings.start,
        value.settings.end,
        value.state.page,
        value.state.date,
        value.state.pageMax,
        value.state.statusCode.index,
        value.state.statusMessage,
      ];

  @override
  DtoUpdaterData dartDecode(List value) => DtoUpdaterData(
        DtoUpdaterDataSettings(
          value[0],
          value[1],
          value[2],
          value[3],
        ),
        DtoUpdaterDataState(
          value[0],
          value[1],
          value[4],
          value[5],
          value[6],
          UpdaterStateStatus.values[value[7]],
          value[8],
        ),
      );
}

@immutable
class TableUpdaterDataState extends DatabaseTable<DtoUpdaterDataState> {
  @literal
  const TableUpdaterDataState();

  @override
  String get name => const TableUpdaterData().name;

  @override
  DatabaseColumn get columnSync => const DatabaseColumnTimestamp();

  @override
  List<DatabaseColumn> get columns => const [
        DatabaseColumnId('updaterId'),
        DatabaseColumnTimestamp(),
        DatabaseColumnUint('page'),
        DatabaseColumnMyDateTime('date'),
        DatabaseColumnUint('pageMax'),
        DatabaseColumnUint('statusCode'),
        DatabaseColumnString('statusMessage'),
      ];

  @override
  List dartEncode(DtoUpdaterDataState value) => [
        value.id,
        value.timestamp,
        value.page,
        value.date,
        value.pageMax,
        value.statusCode.index,
        value.statusMessage,
      ];

  @override
  DtoUpdaterDataState dartDecode(List value) => DtoUpdaterDataState(
        value[0],
        value[1],
        value[2],
        value[3],
        value[4],
        value[5],
        value[6],
      );
}
