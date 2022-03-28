import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';

import '../common/common_date_time.dart';
import 'data_company.dart';
import 'data_tender_db_etpgpb.dart';

@immutable
class TenderDataEtpGpb {
  TenderDataEtpGpb(
    int tenderId,
    String link,
    String number,
    String name,
    int sum,
    MyDateTime publish,
    MyDateTime start,
    MyDateTime end,
    MyDateTime auctionDate,
    String organizer,
    String organizerLogo,
    String auctionType,
    int lots,
    List<String> regions,
    List<String> auctionSections,
    List<String> props,
  ) : this.db(
            DataTenderDbEtpGpb(0, 0, 0, tenderId, link, number, name, sum,
                publish, start, end, auctionDate, lots, 0, 0),
            DataCompany.v(organizer, organizerLogo),
            DataString.v(auctionType),
            regions.map(DataString.v).toList(),
            [
              DataString.v(auctionType),
              ...auctionSections.map(DataString.v),
              ...props.map(DataString.v),
            ]);
  const TenderDataEtpGpb.db(
    this.dbCore,
    this.dbOrganizer,
    this.dbAuctionType,
    this.dbRegions,
    this.dbProps,
  );

  final DataTenderDbEtpGpb dbCore;
  final DataCompany dbOrganizer;
  final DataString dbAuctionType;
  final List<DataString> dbRegions;
  final List<DataString> dbProps;

  int get tenderId => dbCore.tenderId;
  String get link => dbCore.link;
  String get number => dbCore.number;
  String get name => dbCore.name;
  int get sum => dbCore.sum;
  MyDateTime get publish => dbCore.publish;
  MyDateTime get start => dbCore.start;
  MyDateTime get end => dbCore.end;
  MyDateTime get auctionDate => dbCore.auctionDate;
  String get organizer => dbOrganizer.name;
  String get organizerLogo => dbOrganizer.logo;
  String get auctionType => dbAuctionType.value;
  int get lots => dbCore.lots;
  List<String> get regions => dbRegions.map((e) => e.value).toList();
  List<String> get props => dbProps.map((e) => e.value).toList();

  static List<DataCompany> getAllCompanies(List<TenderDataEtpGpb> items) {
    final out = <DataCompany>[];
    for (final item in items) {
      final c = item.dbOrganizer;
      if (!out.contains(c)) {
        out.add(c);
      }
    }
    return out;
  }

  static List<DataString> getAllRegions(List<TenderDataEtpGpb> items) {
    final out = <DataString>[];
    for (final item in items) {
      for (final c in item.dbRegions) {
        if (!out.contains(c)) {
          out.add(c);
        }
      }
    }
    return out;
  }

  static List<DataString> getAllProps(List<TenderDataEtpGpb> items) {
    final out = <DataString>[];
    for (final item in items) {
      final c = item.dbAuctionType;
      if (!out.contains(c)) {
        out.add(c);
      }
      for (final c in item.dbProps) {
        if (!out.contains(c)) {
          out.add(c);
        }
      }
    }
    return out;
  }

  TenderDataEtpGpb copyWith({
    DataTenderDbEtpGpb? dbCore,
    DataCompany? dbOrganizer,
    DataString? dbAuctionType,
    List<DataString>? dbRegions,
    List<DataString>? dbProps,
  }) =>
      TenderDataEtpGpb.db(
        dbCore ?? this.dbCore,
        dbOrganizer ?? this.dbOrganizer,
        dbAuctionType ?? this.dbAuctionType,
        dbRegions ?? this.dbRegions,
        dbProps ?? this.dbProps,
      );
}
