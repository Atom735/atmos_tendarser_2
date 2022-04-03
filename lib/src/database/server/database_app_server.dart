import 'dart:collection';
import 'dart:developer';

import 'package:atmos_database/atmos_database.dart';

import '../../common/common_date_time.dart';
import '../../data/data_tender_db_etpgpb.dart';
import '../../data/tender_data_etpgpb.dart';
import '../../data/updater_data.dart';
import '../database_app.dart';

class DatabaseAppServer extends DatabaseApp {
  DatabaseAppServer(String fname) : super(fname);

  /// Добавляет данные тендеров в БД, возвращает кол-во добавлений/обновлений
  int addTenders(List<TenderDataEtpGpb> items) {
    final companies = tableCompanies
        .sqlInsertNewsUnqiueValues(
          TenderDataEtpGpb.getAllCompanies(items),
          [tableCompanies.vColumnName],
          returnFulls: true,
        )
        .value;
    final regions = tableRegions
        .sqlInsertNewsUnqiueValues(
          TenderDataEtpGpb.getAllRegions(items),
          [tableRegions.columnValue],
          returnFulls: true,
        )
        .value;
    final props = tableProps
        .sqlInsertNewsUnqiueValues(
          TenderDataEtpGpb.getAllProps(items),
          [tableProps.columnValue],
          returnFulls: true,
        )
        .value;

    final coresSelector = {
      tableTenders.vColumnTenderId: [
        ...items.map((e) => e.dbCore.tenderId),
      ],
    };
    final coresInTable = SplayTreeSet<DataTenderDbEtpGpb>()
      ..addAll(tableTenders.sqlSelectByColumns(coresSelector));
    final coresForInsert = <DataTenderDbEtpGpb>[];

    // final coresPrepared = <DataTenderDbEtpGpb>[];
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      item = items[i] = item.copyWith(
          dbCore: item.dbCore.copyWith(
        organizerId: companies
            .firstWhere(
              (c) => c.compareTo(item.dbOrganizer) == 0,
            )
            .id,
        auctionTypeId: props
            .firstWhere(
              (c) => c.compareTo(item.dbAuctionType) == 0,
            )
            .id,
      ));
      final coreThis = item.dbCore;
      final lookuped = coresInTable.lookup(coreThis);
      if (lookuped == null) {
        final coresWithSomeIds = coresInTable
            .where(
              (c) =>
                  c.tenderId == coreThis.tenderId &&
                  c.link == coreThis.link &&
                  c.number == coreThis.number &&
                  c.name == coreThis.name &&
                  c.auctionTypeId == coreThis.auctionTypeId &&
                  c.organizerId == coreThis.organizerId,
            )
            .toList();
        if (coresWithSomeIds.isNotEmpty) {
          if (coresWithSomeIds.length == 1) {
            final c = coresWithSomeIds.first;
            final diffs = <String>{};
            if (c.sum.compareTo(coreThis.sum) != 0) {
              diffs.add('sum');
            }
            if (c.publish.compareTo(coreThis.publish) != 0) {
              diffs.add('publish');
            }
            if (c.start.compareTo(coreThis.start) != 0) {
              diffs.add('start');
            }
            if (c.end.compareTo(coreThis.end) != 0) {
              diffs.add('end');
            }
            if (c.auctionDate.compareTo(coreThis.auctionDate) != 0) {
              diffs.add('auctionDate');
            }
            if (c.lots.compareTo(coreThis.lots) != 0) {
              diffs.add('lots');
            }
            if ({'end'}.containsAll(diffs)) {
              continue;
            }
            debugger();
            throw Exception();
          }
          debugger();
          throw Exception();
        } else {
          coresInTable.add(coreThis);
          coresForInsert.add(coreThis);
        }
      }
    }
    tableTenders.sqlInsert(coresForInsert);
    coresInTable
      ..clear()
      ..addAll(tableTenders.sqlSelectByColumns(coresSelector));

    final regionRefs = SplayTreeSet<DataRef>();
    final propsRefs = SplayTreeSet<DataRef>();
    for (final item in items) {
      final coreThis = item.dbCore;
      final coresWithSomeIds = coresInTable
          .where(
            (c) =>
                c.tenderId == coreThis.tenderId &&
                c.link == coreThis.link &&
                c.number == coreThis.number &&
                c.name == coreThis.name &&
                c.auctionTypeId == coreThis.auctionTypeId &&
                c.organizerId == coreThis.organizerId,
          )
          .toList();
      for (final r in item.dbRegions) {
        final rInTable = regions.firstWhere((e) => e.value == r.value);
        assert(rInTable.id != 0, 'region need to be in table');
        for (final core in coresWithSomeIds) {
          assert(core.rowid != 0, 'core need to be in table');
          regionRefs.add(DataRef.v(core.rowid, rInTable.id));
        }
      }
      for (final r in item.dbProps) {
        final rInTable = props.firstWhere((e) => e.value == r.value);
        assert(rInTable.id != 0, 'prop need to be in table');
        for (final core in coresWithSomeIds) {
          assert(core.rowid != 0, 'core need to be in table');
          propsRefs.add(DataRef.v(core.rowid, rInTable.id));
        }
      }
    }

    tableRegionsRefs.sqlInsertNewsUnqiueValues(regionRefs.toList(),
        [tableRegionsRefs.columnA, tableRegionsRefs.columnB]);
    tablePropsRefs.sqlInsertNewsUnqiueValues(
        propsRefs.toList(), [tablePropsRefs.columnA, tablePropsRefs.columnB]);

    TenderDataEtpGpb.getAllCompanies(items);
    return 0;
  }

  /// Создаеёт запись нового апдейтера
  UpdaterData createNewUpdaterEtpGpb(DateTime start, DateTime end) {
    tableUpdaters.sqlInsert([
      UpdaterData.v(
        MyDateTime(start, MyDateTimeQuality.day),
        MyDateTime(end, MyDateTimeQuality.day),
      ),
    ]);
    final rowid = tableUpdaters.sql.lastInsertRowId;
    return tableUpdaters.sqlSelectByIds([rowid]).first;
  }

  /// Получает записи активных апдейтеров
  Iterable<UpdaterData> getActiveUpdaters() => tableUpdaters.sqlSelect('''
      WHERE ${tableUpdaters.vColumnsStatusCode.name}
      IN (
        ${UpdaterStateStatus.initializing.index},
        ${UpdaterStateStatus.run.index},
        ${UpdaterStateStatus.paused.index}
      )''');
}
