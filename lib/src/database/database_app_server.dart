import '../common/common_date_time.dart';
import '../data/dto_company.dart';
import '../data/dto_database_sync_data.dart';
import '../data/dto_ref.dart';
import '../data/dto_string.dart';
import '../data/dto_tender_data.dart';
import '../data/dto_tender_data_etpgpb.dart';
import '../data/dto_updater_data.dart';
import '../data/table_updater_data.dart';
import '../messages/msg_sync_data_frame.dart';
import '../messages/msg_sync_data_haved.dart';
import 'database_app.dart';
import 'database_column.dart';

class DatabaseAppServer extends DatabaseApp {
  DatabaseAppServer(String fname) : super(fname);

  MsgSyncDataFrame getSyncFrame(MsgSyncDataHaved msg) => MsgSyncDataFrame(
        msg.id,
        tableCompanies.sqlSelectSyncFrame(sql, msg.companies),
        tableRegions.sqlSelectSyncFrame(sql, msg.regions),
        tableRegionsRefs.sqlSelectSyncFrame(sql, msg.regionsRefs),
        tableProps.sqlSelectSyncFrame(sql, msg.props),
        tablePropsRefs.sqlSelectSyncFrame(sql, msg.propsRefs),
        tableTenders.sqlSelectSyncFrame(sql, msg.tenders),
      );

  DtoDatabaseSyncData getLastSyncData() => DtoDatabaseSyncData(
        tableCompanies.sqlSelectSyncIdMax(sql),
        tableRegions.sqlSelectSyncIdMax(sql),
        tableRegionsRefs.sqlSelectSyncIdMax(sql),
        tableProps.sqlSelectSyncIdMax(sql),
        tablePropsRefs.sqlSelectSyncIdMax(sql),
        tableTenders.sqlSelectSyncIdMax(sql),
      );

  MsgSyncDataHaved getSyncDataChunkData(
          int msgId, DtoDatabaseSyncData begin, DtoDatabaseSyncData end) =>
      MsgSyncDataHaved(
        msgId,
        tableCompanies
            .sqlSelectSyncIdsLimit(
              sql,
              begin.companies,
              end.companies,
            )
            .toList(),
        tableRegions
            .sqlSelectSyncIdsLimit(
              sql,
              begin.regions,
              end.regions,
            )
            .toList(),
        tableRegionsRefs
            .sqlSelectSyncIdsLimit(
              sql,
              begin.regionsRefs,
              end.regionsRefs,
            )
            .toList(),
        tableProps
            .sqlSelectSyncIdsLimit(
              sql,
              begin.props,
              end.props,
            )
            .toList(),
        tablePropsRefs
            .sqlSelectSyncIdsLimit(
              sql,
              begin.propsRefs,
              end.propsRefs,
            )
            .toList(),
        tableTenders
            .sqlSelectSyncIdsLimit(
              sql,
              begin.tenders,
              end.tenders,
            )
            .toList(),
      );

  /// Добавляет данные тендеров в БД, возвращает кол-во добавлений/обновлений
  int addTenders(List<DtoTenderDataEtpGpb> items) {
    final companies = tableCompanies
        .sqlInsertNews1(
          sql,
          DtoTenderDataEtpGpb.getCompaniesAll(items),
          1,
          DtoCompany.selector,
        )
        .value;

    final regions = tableRegions
        .sqlInsertNews1(
          sql,
          DtoTenderDataEtpGpb.getRegionsAll(items),
          1,
          DtoString.selector,
        )
        .value;

    final props = tableProps
        .sqlInsertNews1(
          sql,
          DtoTenderDataEtpGpb.getPropsAll(items),
          1,
          DtoString.selector,
        )
        .value;

    final tendersNews = DtoTenderData.createSet()
      ..addAll(
        items.map(
          (e) => DtoTenderData(
            e.id,
            DatabaseColumnTimestamp.zeroDt,
            e.link,
            e.number,
            e.name,
            e.sum,
            e.publish,
            e.start,
            e.end,
            e.auctionDate,
            e.lots,
            props.firstWhere((p) => e.auctionType == p.value).id,
            companies.firstWhere((p) => e.organizer == p.name).id,
          ),
        ),
      );
    final result = tableTenders
        .sqlInsertNews1(sql, tendersNews, 0, DtoTenderData.getId, true)
        .key;

    final regionsRefs = DtoRef.createSet()
      ..addAll(
        items.expand(
          (item) => item.regions.map(
            (value) => DtoRef.value(
              item.id,
              regions.firstWhere((e) => e.value == value).id,
            ),
          ),
        ),
      );
    tableRegionsRefs.sqlInsertNewsMulti(
      sql,
      regionsRefs,
      DtoRef.selectors,
      true,
    );

    final propsRefs = DtoRef.createSet()
      ..addAll(
        items.expand(
          (item) => [
            DtoRef.value(
              item.id,
              props.firstWhere((e) => e.value == item.auctionType).id,
            ),
            ...item.auctionSections.map(
              (value) => DtoRef.value(
                item.id,
                props.firstWhere((e) => e.value == value).id,
              ),
            ),
            ...item.props.map(
              (value) => DtoRef.value(
                item.id,
                props.firstWhere((e) => e.value == value).id,
              ),
            ),
          ],
        ),
      );

    tablePropsRefs.sqlInsertNewsMulti(
      sql,
      propsRefs,
      DtoRef.selectors,
      true,
    );

    return result;
  }

  DtoUpdaterData createNewUpdaterEtpGpb(DateTime start, DateTime end) {
    tableUpdaters.sqlInsert(sql, [
      DtoUpdaterData(
        DtoUpdaterDataSettings(
          0,
          DatabaseColumnTimestamp.zeroDt,
          MyDateTime(start, MyDateTimeQuality.day),
          MyDateTime(end, MyDateTimeQuality.day),
        ),
        DtoUpdaterDataState(
          0,
          DatabaseColumnTimestamp.zeroDt,
          1,
          MyDateTime(start, MyDateTimeQuality.day),
          0,
          UpdaterStateStatus.initializing,
          '',
        ),
      ),
    ]);
    final rowid = sql.lastInsertRowId;
    return tableUpdaters.sqlSelectByIds(sql, [rowid]).first;
  }

  Iterable<DtoUpdaterData> getActiveUpdaters() => tableUpdaters.sqlSelect(sql,
      '''WHERE ${TableUpdaterData.statusCodeColumnName} < ${UpdaterStateStatus.done.index}''');
}
