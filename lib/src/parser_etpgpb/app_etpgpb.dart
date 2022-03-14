import 'dart:async';

import 'package:meta/meta.dart';

import '../app/app.dart';
import '../common/common_date_time.dart';
import '../common/common_db_column.dart';
import '../common/common_db_table.dart';
import '../common/common_zlib_link.dart';
import '../data/data_provider_sqlite.dart';
import '../data/data_search_struct.dart';
import 'tender_data_etpgpb.dart';
import 'updater_etpgpb.dart';

class AppEtpGpb {
  AppEtpGpb(this.app);

  final App app;

  late final dpTenders =
      DataProviderSqlite<TenderDataEtpGpb, TenderDataEtpGpb, DataSearchStruct>(
          app.db, const DbEtpGpbTenderDataTable());

  late final _dpUpdaters =
      DataProviderSqlite<UpdaterEtpGpb, UpdaterEtpGpb, DataSearchStruct>(
          app.db, const DbEtpGpbUpdaterDataTable());

  Stream<void> get updatesUpdaters => _dpUpdaters.updates;

  UpdaterEtpGpb newUpdater(DateTime start, DateTime end) {
    final id = _dpUpdaters.getNewId();
    final dStart = MyDateTime(
      DateTime(start.year, start.month, start.day),
      MyDateTimeQuality.day,
    );
    final dEnd = MyDateTime(
      DateTime(end.year, end.month, end.day),
      MyDateTimeQuality.day,
    );
    final result = UpdaterEtpGpb(
        id, DateTime.now(), dStart, dEnd, 1, dStart, 0, 'Инициализая');
    _dpUpdaters.add(result);
    result.updates.listen(_dpUpdaters.update);
    updaters.add(result);
    unawaited(result.run());
    return result;
  }

  final updaters = <UpdaterEtpGpb>[];

  Future<void> init() async {
    await dpTenders.init();
    await _dpUpdaters.init();
    dpTenders.sqlCreateTable();
    _dpUpdaters.sqlCreateTable();
    updaters.addAll(await _dpUpdaters.getByIds([0], not: true));

    for (final updater in updaters) {
      updater.updates.listen(_dpUpdaters.update);
      unawaited(updater.run());
    }
  }

  Future<void> dispose() async {
    for (final updater in updaters) {
      await updater.dispose();
    }
    await _dpUpdaters.dispose();
    await dpTenders.dispose();
  }
}

@immutable
class DbEtpGpbUpdaterDataTable
    extends CommonDbTable<UpdaterEtpGpb, UpdaterEtpGpb> {
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
        DbColumnString('status'),
      ];

  @override
  List encode(UpdaterEtpGpb data) => [
        data.id,
        data.timestamp,
        data.start,
        data.end,
        data.page,
        data.date,
        data.pageMax,
        data.status,
      ];

  @override
  UpdaterEtpGpb decode(List data) => UpdaterEtpGpb(
        data[0],
        data[1],
        data[2],
        data[3],
        data[4],
        data[5],
        data[6],
        data[7],
      );
}

@immutable
class DbEtpGpbTenderDataTable
    extends CommonDbTable<TenderDataEtpGpb, TenderDataEtpGpb> {
  @literal
  const DbEtpGpbTenderDataTable();

  @override
  String get name => 'EtpGpbTenders';
  @override
  List<CommonDbColumn> get columns => const [
        DbColumnId(),
        DbColumnTimeStamp(),
        DbColumnLink(),
        DbColumnStringFts('number'),
        DbColumnStringFts('name'),
        DbColumnInt('sum'),
        DbColumnMyDateTime('publish'),
        DbColumnMyDateTime('start'),
        DbColumnMyDateTime('end'),
        DbColumnMyDateTime('auctionDate'),
        DbColumnStringFts('organizer'),
        DbColumnString('organizerLogo'),
        DbColumnStringFts('auctionType'),
        DbColumnInt('lots'),
        DbColumnStringsSet('regions'),
        DbColumnStringsSet('auctionSections'),
        DbColumnStringsSet('props'),
      ];

  @override
  List encode(TenderDataEtpGpb data) => [
        data.id, // DbColumnId(),
        data.timestamp, // DbColumnTimeStamp(),
        data.link, // DbColumnLink(),
        data.number, // DbColumnString('number'),
        data.name, // DbColumnString('name'),
        data.sum, // DbColumnInt('sum'),
        data.publish, // DbColumnMyDateTime('publish'),
        data.start, // DbColumnMyDateTime('start'),
        data.end, // DbColumnMyDateTime('end'),
        data.auctionDate, // DbColumnMyDateTime('auctionDate'),
        data.organizer, // DbColumnString('organizer'),
        data.organizerLogo, // DbColumnString('organizerLogo'),
        data.auctionType, // DbColumnString('auctionType'),
        data.lots, // DbColumnInt('lots'),
        data.regions, // DbColumnStringsSet('regions'),
        data.auctionSections, // DbColumnStringsSet('auctionSections'),
        data.props, // DbColumnStringsSet('props'),
      ];

  @override
  TenderDataEtpGpb decode(List data) => TenderDataEtpGpb(
        data[0],
        data[1],
        data[2],
        data[3],
        data[4],
        data[5],
        data[6],
        data[7],
        data[8],
        data[9],
        data[10],
        data[11],
        data[12],
        data[13],
        data[14],
        data[15],
        data[16],
      );
}
