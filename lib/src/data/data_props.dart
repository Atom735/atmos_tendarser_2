import 'package:atmos_database/atmos_database.dart';
import 'package:sqlite3/sqlite3.dart';

import 'data_tender_db_etpgpb.dart';

class TableDataProps extends DatabaseTableDict {
  TableDataProps(Database sql) : super(sql, kTableName);

  static const kTableName = 'TenderProps';
}

class TableDataPropsRefs extends DatabaseTableRefs {
  TableDataPropsRefs(Database sql)
      : super(
          sql,
          kTableName,
          columnA: const DatabaseColumnRef(
            'tenderRowid',
            TableDataTenderDbEtpGpb.kTableName,
          ),
          columnB: const DatabaseColumnRef(
            'propRowid',
            TableDataProps.kTableName,
          ),
        );

  static const kTableName = 'TenderPropsRefs';
}
