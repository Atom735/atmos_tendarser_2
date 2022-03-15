import 'package:meta/meta.dart';

import '../common/common_date_time.dart';

const kTenderEtpGpbOffset = 1 << 32;
const kTenderEtpGpbLimit = 1 << 32;

@immutable
class TenderDataEtpGpb {
  const TenderDataEtpGpb(
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
  ) : assert(id >= 0 && id < kTenderEtpGpbLimit, 'invalidate id');

  static int getId(TenderDataEtpGpb e) => e.id;

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
}
