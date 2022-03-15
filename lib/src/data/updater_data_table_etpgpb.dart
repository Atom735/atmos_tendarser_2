import 'package:meta/meta.dart';

import '../common/common_date_time.dart';
import '../common/common_db_column.dart';
import '../common/common_db_table.dart';
import 'updater_data_etpgpb.dart';

@immutable
class DbEtpGpbUpdaterDataTable
    extends CommonDbTable<UpdaterDataEtpGpb, UpdaterDataEtpGpb> {
  @literal
  const DbEtpGpbUpdaterDataTable();

  @override
  String get name => 'EtpGpbUpdaters';

  @override
  List<CommonDbColumn> get columns => const [
        DbColumnId(),
        DbColumnTimeStamp(),
        DbColumnMyDateTime('start'),
        DbColumnMyDateTime('end'),
        DbColumnInt('page'),
        DbColumnMyDateTime('date'),
        DbColumnInt('pageMax'),
        DbColumnInt('statusCode'),
        DbColumnString('statusMessage'),
      ];

  @override
  List encode(UpdaterDataEtpGpb data) => [
        data.state.id,
        data.state.timestamp,
        data.settings.start,
        data.settings.end,
        data.state.page,
        data.state.date,
        data.state.pageMax,
        data.state.statusCode.index,
        data.state.statusMessage,
      ];

  @override
  UpdaterDataEtpGpb decode(List data) => UpdaterDataEtpGpb(
        UpdaterDataSettingsEtpGpb(
          data[0],
          data[1],
          data[2],
          data[3],
        ),
        UpdaterDataStateEtpGpb(
          data[0],
          data[1],
          data[4],
          data[5],
          data[6],
          UpdaterStateStatus.values[data[7]],
          data[8],
        ),
      );
}

@immutable
class DbEtpGpbUpdaterDataStateTable
    extends CommonDbTable<UpdaterDataStateEtpGpb, UpdaterDataStateEtpGpb> {
  @literal
  const DbEtpGpbUpdaterDataStateTable();

  @override
  String get name => const DbEtpGpbUpdaterDataTable().name;

  @override
  List<CommonDbColumn> get columns => const [
        DbColumnId(),
        DbColumnTimeStamp(),
        DbColumnInt('page'),
        DbColumnMyDateTime('date'),
        DbColumnInt('pageMax'),
        DbColumnInt('statusCode'),
        DbColumnString('statusMessage'),
      ];

  @override
  List encode(UpdaterDataStateEtpGpb data) => [
        data.id,
        data.timestamp,
        data.page,
        data.date,
        data.pageMax,
        data.statusCode.index,
        data.statusMessage,
      ];

  @override
  UpdaterDataStateEtpGpb decode(List data) => UpdaterDataStateEtpGpb(
        data[0],
        data[1],
        data[2],
        data[3],
        data[4],
        UpdaterStateStatus.values[data[5]],
        data[6],
      );
}
