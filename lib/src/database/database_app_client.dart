import '../data/dto_database_sync_data.dart';
import '../messages/msg_sync_data_frame.dart';
import '../messages/msg_sync_data_haved.dart';
import 'database_app.dart';

class DatabaseAppClient extends DatabaseApp {
  DatabaseAppClient(String fname) : super(fname);

  void insertSyncFrame(MsgSyncDataFrame frame) {
    tableCompanies.sqlInsert(sql, frame.companies);
    tableRegions.sqlInsert(sql, frame.regions);
    tableRegionsRefs.sqlInsert(sql, frame.regionsRefs);
    tableProps.sqlInsert(sql, frame.props);
    tablePropsRefs.sqlInsert(sql, frame.propsRefs);
    tableTenders.sqlInsert(sql, frame.tenders);
  }

  DtoDatabaseSyncData getLastSyncData() {
    final syncDatas = tableSync.sqlSelect(sql).toList();
    if (syncDatas.isEmpty) {
      return const DtoDatabaseSyncData(0, 0, 0, 0, 0, 0);
    } else {
      return syncDatas.last;
    }
  }

  MsgSyncDataHaved getSyncDataHaved(
          int msgId, DtoDatabaseSyncData begin, DtoDatabaseSyncData end) =>
      MsgSyncDataHaved(
        msgId,
        tableCompanies
            .sqlSelectSyncIdsClamp(
              sql,
              begin.companies,
              end.companies,
            )
            .toList(),
        tableRegions
            .sqlSelectSyncIdsClamp(
              sql,
              begin.regions,
              end.regions,
            )
            .toList(),
        tableRegionsRefs
            .sqlSelectSyncIdsClamp(
              sql,
              begin.regionsRefs,
              end.regionsRefs,
            )
            .toList(),
        tableProps
            .sqlSelectSyncIdsClamp(
              sql,
              begin.props,
              end.props,
            )
            .toList(),
        tablePropsRefs
            .sqlSelectSyncIdsClamp(
              sql,
              begin.propsRefs,
              end.propsRefs,
            )
            .toList(),
        tableTenders
            .sqlSelectSyncIdsClamp(
              sql,
              begin.tenders,
              end.tenders,
            )
            .toList(),
      );
}
