import 'package:atmos_database/atmos_database.dart';
import 'package:sqlite3/sqlite3.dart';

import 'data_tender_db_etpgpb.dart';

class TableDataRegion extends DatabaseTableDict {
  TableDataRegion(Database sql) : super(sql, kTableName);

  static const kTableName = 'Regions';
}

class TableDataRegionRefs extends DatabaseTableRefs {
  TableDataRegionRefs(Database sql)
      : super(
          sql,
          kTableName,
          columnA: const DatabaseColumnRef(
            'tenderRowid',
            TableDataTenderDbEtpGpb.kTableName,
          ),
          columnB: const DatabaseColumnRef(
            'regionRowid',
            TableDataRegion.kTableName,
          ),
        );

  static const kTableName = 'RegionsRefs';
}
