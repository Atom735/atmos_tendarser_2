import 'package:meta/meta.dart';

import '../common/common_date_time.dart';
import '../common/common_db_column.dart';
import '../common/common_db_table.dart';
import '../common/common_zlib_link.dart';
import 'tender_data_etpgpb.dart';

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
