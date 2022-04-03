import 'package:sqlite3/sqlite3.dart';

import '../data/data_company.dart';
import '../data/data_props.dart';
import '../data/data_region.dart';
import '../data/data_tender_db_etpgpb.dart';
import '../data/updater_data.dart';

class DatabaseApp {
  DatabaseApp(this.fname);

  final String fname;
  late final sql = sqlite3.open(fname)
    ..execute('PRAGMA JOURNAL_MODE=OFF')
    ..execute('PRAGMA SYNCHRONOUS=OFF');

  late final tableCompanies = TableDataCompany(sql)..sqlCreate();

  late final tableRegions = TableDataRegion(sql)..sqlCreate();

  late final tableRegionsRefs = TableDataRegionRefs(sql)..sqlCreate();

  late final tableProps = TableDataProps(sql)..sqlCreate();

  late final tablePropsRefs = TableDataPropsRefs(sql)..sqlCreate();

  late final tableTenders = TableDataTenderDbEtpGpb(sql)..sqlCreate();

  late final tableUpdaters = TableDataUpdater(sql)..sqlCreate();

  late final tableUpdatersState = TableDataUpdaterState(sql);

  void updateUpdaterStates(UpdaterState data) {
    tableUpdatersState.sql.execute(
      tableUpdatersState.sqlQueryUpdate1(),
      tableUpdatersState.rowEncodeRaw(tableUpdatersState.dartDecodeRaw(data))
        ..add(data.id),
    );
  }

  List<UpdaterData> getUpdaterInterval(
      int offset, int length, UpdaterDataSortType sort, bool asc) {
    late final String order;
    switch (sort) {
      case UpdaterDataSortType.id:
        order = tableUpdaters.columnId.name;
        break;
      case UpdaterDataSortType.timestamp:
        order = tableUpdaters.vColumnsTimestamp.name;
        break;
      case UpdaterDataSortType.start:
        order = tableUpdaters.vColumnsStart.name;
        break;
      case UpdaterDataSortType.end:
        order = tableUpdaters.vColumnsEnd.name;
        break;
    }
    return tableUpdaters.sqlSelect('''
          WHERE ORDER BY $order ${asc ? 'ASC' : 'DESC'}
          LIMIT $length OFFSET $offset
        ''').toList();
  }

  void dispose() => sql.dispose();
}
