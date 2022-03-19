import 'package:meta/meta.dart';

import '../common/common_date_time.dart';
import 'dto_company.dart';
import 'dto_string.dart';

@immutable
class DtoTenderDataEtpGpb {
  const DtoTenderDataEtpGpb(
    this.id,
    this.timestamp,
    this.link,
    this.number,
    this.name,
    this.sum,
    this.publish,
    this.start,
    this.end,
    this.auctionDate,
    this.organizer,
    this.organizerLogo,
    this.auctionType,
    this.lots,
    this.regions,
    this.auctionSections,
    this.props,
  );

  static int getId(DtoTenderDataEtpGpb e) => e.id;

  /// Уникальный айди тендера в БД
  final int id;

  /// Время последнего обновления записи
  final DateTime timestamp;

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

  /// Название компании - организатора
  final String organizer;

  /// Ссылка на логотип копании
  final String organizerLogo;

  /// Тип торгов
  final String auctionType;

  /// Количество лотов
  final int lots;

  /// Название регионов
  final Set<String> regions;

  /// Секции торгов
  final Set<String> auctionSections;

  /// Параметры
  final Set<String> props;

  static Iterable<DtoString> getProps(DtoTenderDataEtpGpb e) =>
      e.auctionSections
          .map(DtoString.value)
          .followedBy(e.props.map(DtoString.value))
          .followedBy([DtoString.value(e.auctionType)]);

  static Set<DtoString> getPropsAll(List<DtoTenderDataEtpGpb> items) =>
      DtoString.createSet()..addAll(items.expand(getProps));

  static Iterable<DtoString> getRegions(DtoTenderDataEtpGpb e) =>
      e.regions.map(DtoString.value);

  static Set<DtoString> getRegionsAll(List<DtoTenderDataEtpGpb> items) =>
      DtoString.createSet()..addAll(items.expand(getRegions));

  static DtoCompany getCompany(DtoTenderDataEtpGpb e) =>
      DtoCompany(0, e.organizer, e.organizerLogo);

  static Set<DtoCompany> getCompaniesAll(List<DtoTenderDataEtpGpb> items) =>
      DtoCompany.createSet()..addAll(items.map(getCompany));
}
