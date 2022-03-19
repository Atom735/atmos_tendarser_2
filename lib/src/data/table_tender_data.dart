import 'package:meta/meta.dart';

import '../common/common_date_time.dart';
import '../common/common_zlib_link.dart';
import '../database/database_column.dart';
import '../database/database_column_ref.dart';
import '../database/database_table.dart';
import 'dto_tender_data.dart';
import 'table_companies.dart';
import 'table_tender_props.dart';

@immutable
class TableTenderData extends DatabaseTable<DtoTenderData> {
  @literal
  const TableTenderData();

  @override
  String get name => 'TenderData';

  @override
  DatabaseColumn get columnSync => const DatabaseColumnTimestamp();

  @override
  List<DatabaseColumn> get columns => const [
        DatabaseColumnId('tenderId'),
        DatabaseColumnTimestamp(),
        DatabaseColumnLink(),
        DatabaseColumnString('number', fts: true),
        DatabaseColumnString('name', fts: true),
        DatabaseColumnUint('sum'),
        DatabaseColumnMyDateTime('publish'),
        DatabaseColumnMyDateTime('start'),
        DatabaseColumnMyDateTime('end'),
        DatabaseColumnMyDateTime('auctionDate'),
        DatabaseColumnUint('lots'),
        DatabaseColumnRef('auctionType', TableProps()),
        DatabaseColumnRef('organizer', TableCompanies()),
      ];

  @override
  List dartEncode(DtoTenderData value) => [
        value.id,
        value.timestamp,
        value.link,
        value.number,
        value.name,
        value.sum,
        value.publish,
        value.start,
        value.end,
        value.auctionDate,
        value.lots,
        value.auctionTypeId,
        value.organizerId,
      ];

  @override
  DtoTenderData dartDecode(List value) => DtoTenderData(
        value[0],
        value[1],
        value[2],
        value[3],
        value[4],
        value[5],
        value[6],
        value[7],
        value[8],
        value[9],
        value[10],
        value[11],
        value[12],
      );
}
