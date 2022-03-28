import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import '../common/common_date_time.dart';
import 'data_company.dart';
import 'data_props.dart';

@immutable
class DataTenderDbEtpGpb implements Comparable<DataTenderDbEtpGpb> {
  const DataTenderDbEtpGpb(
    this.rowid,
    this.timestamp,
    this.prev,
    this.tenderId,
    this.link,
    this.number,
    this.name,
    this.sum,
    this.publish,
    this.start,
    this.end,
    this.auctionDate,
    this.lots,
    this.auctionTypeId,
    this.organizerId,
  );

  /// Уникальный айди записи тендера в БД
  final int rowid;

  /// Время последнего обновления записи
  final int timestamp;

  DateTime get timestampDt =>
      const DatabaseColumnTimestampDateTime('').dartEncode(timestamp);

  /// Уникальный айди предыдущей версии тендера в БД
  final int prev;

  /// Уникальный айди тендера на сайте
  final int tenderId;

  /// Ссылка на тендер
  final String link;

  /// Номер тендера
  final String number;

  /// Название тендера
  final String name;

  /// Цена
  final int sum;

  /// Дата публикации извещения
  final MyDateTime publish;

  /// Начало приёма заявок
  final MyDateTime start;

  /// Дата окончания приёма заявок
  final MyDateTime end;

  /// Дата аукциона
  final MyDateTime auctionDate;

  /// Количество лотов
  final int lots;

  /// айди типа торгов
  final int auctionTypeId;

  /// айди компании организатора
  final int organizerId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataTenderDbEtpGpb &&
        other.rowid == rowid &&
        other.timestamp == timestamp &&
        other.prev == prev &&
        other.tenderId == tenderId &&
        other.link == link &&
        other.number == number &&
        other.name == name &&
        other.sum == sum &&
        other.publish == publish &&
        other.start == start &&
        other.end == end &&
        other.auctionDate == auctionDate &&
        other.lots == lots &&
        other.auctionTypeId == auctionTypeId &&
        other.organizerId == organizerId;
  }

  @override
  int get hashCode =>
      rowid.hashCode ^
      timestamp.hashCode ^
      prev.hashCode ^
      tenderId.hashCode ^
      link.hashCode ^
      number.hashCode ^
      name.hashCode ^
      sum.hashCode ^
      publish.hashCode ^
      start.hashCode ^
      end.hashCode ^
      auctionDate.hashCode ^
      lots.hashCode ^
      auctionTypeId.hashCode ^
      organizerId.hashCode;

  DataTenderDbEtpGpb copyWith({
    int? rowid,
    int? timestamp,
    int? prev,
    int? tenderId,
    String? link,
    String? number,
    String? name,
    int? sum,
    MyDateTime? publish,
    MyDateTime? start,
    MyDateTime? end,
    MyDateTime? auctionDate,
    int? lots,
    int? auctionTypeId,
    int? organizerId,
  }) =>
      DataTenderDbEtpGpb(
        rowid ?? this.rowid,
        timestamp ?? this.timestamp,
        prev ?? this.prev,
        tenderId ?? this.tenderId,
        link ?? this.link,
        number ?? this.number,
        name ?? this.name,
        sum ?? this.sum,
        publish ?? this.publish,
        start ?? this.start,
        end ?? this.end,
        auctionDate ?? this.auctionDate,
        lots ?? this.lots,
        auctionTypeId ?? this.auctionTypeId,
        organizerId ?? this.organizerId,
      );

  @override
  int compareTo(DataTenderDbEtpGpb other) {
    var i = 0;
    // if ((i = rowid.compareTo(other.rowid)) != 0) return i;
    // if ((i = timestamp.compareTo(other.timestamp)) != 0) return i;
    // if ((i = prev.compareTo(other.prev)) != 0) return i;
    if ((i = tenderId.compareTo(other.tenderId)) != 0) return i;
    if ((i = link.compareTo(other.link)) != 0) return i;
    if ((i = number.compareTo(other.number)) != 0) return i;
    if ((i = name.compareTo(other.name)) != 0) return i;
    if ((i = sum.compareTo(other.sum)) != 0) return i;
    if ((i = publish.compareTo(other.publish)) != 0) return i;
    if ((i = start.compareTo(other.start)) != 0) return i;
    if ((i = end.compareTo(other.end)) != 0) return i;
    if ((i = auctionDate.compareTo(other.auctionDate)) != 0) return i;
    if ((i = lots.compareTo(other.lots)) != 0) return i;
    if ((i = auctionTypeId.compareTo(other.auctionTypeId)) != 0) return i;
    if ((i = organizerId.compareTo(other.organizerId)) != 0) return i;
    return i;
  }

  @override
  String toString() =>
      '''DataTenderDbEtpGpb(rowid: $rowid, timestamp: $timestamp, prev: $prev, tenderId: $tenderId, link: $link, number: $number, name: $name, sum: $sum, publish: $publish, start: $start, end: $end, auctionDate: $auctionDate, lots: $lots, auctionTypeId: $auctionTypeId, organizerId: $organizerId)''';
}

class TableDataTenderDbEtpGpb extends DatabaseTable<DataTenderDbEtpGpb> {
  const TableDataTenderDbEtpGpb(Database sql)
      : super(sql, kTableName, kColumns);

  static const kTableName = 'TendersEtpGpb';
  static const kColumns = <DatabaseColumn>[
    DatabaseColumnId('rowid'),
    DatabaseColumnTimestamp('timestamp'),
    DatabaseColumnRef('prev', kTableName, unique: true),
    kColumnTenderId,
    DatabaseColumnText('link'),
    DatabaseColumnText('number', fts: true, indexed: true),
    DatabaseColumnText('name', fts: true, indexed: true),
    DatabaseColumnUnsigned('sum', indexed: true),
    DatabaseColumnMyDateTime('publish', indexed: true),
    DatabaseColumnMyDateTime('start', indexed: true),
    DatabaseColumnMyDateTime('end', indexed: true),
    DatabaseColumnMyDateTime('auctionDate', indexed: true),
    DatabaseColumnUnsigned('lots'),
    DatabaseColumnRef('auctionTypeId', TableDataProps.kTableName),
    DatabaseColumnRef('organizerId', TableDataCompany.kTableName),
  ];
  static const kColumnTenderId = DatabaseColumnUnsigned('tenderId');
  DatabaseColumnUnsigned get vColumnTenderId => kColumnTenderId;

  @override
  List dartDecode(DataTenderDbEtpGpb value) => [
        value.rowid,
        value.timestamp,
        value.prev,
        value.tenderId,
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
  DataTenderDbEtpGpb dartEncode(List value) => DataTenderDbEtpGpb(
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
        value[13],
        value[14],
      );
}
