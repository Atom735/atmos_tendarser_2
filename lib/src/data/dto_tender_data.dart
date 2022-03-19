import 'dart:collection';

import 'package:meta/meta.dart';

import '../common/common_date_time.dart';

@immutable
class DtoTenderData {
  const DtoTenderData(
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
    this.lots,
    this.auctionTypeId,
    this.organizerId,
  )   : assert(id > 0, 'invalid id'),
        assert(auctionTypeId > 0, 'invalid type id'),
        assert(organizerId > 0, 'invalid organizer id');

  static int getId(DtoTenderData e) => e.id;

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

  /// Количество лотов
  final int lots;

  /// Тип торгов
  final int auctionTypeId;

  /// Название компании - организатора
  final int organizerId;

  @override
  String toString() => 'TenderData: $id ($name)';

  static bool _setEquals(DtoTenderData a, DtoTenderData b) => a.id == b.id;

  static int _setHashCode(DtoTenderData a) => a.id;

  static Set<DtoTenderData> createSet() => HashSet<DtoTenderData>(
        equals: _setEquals,
        hashCode: _setHashCode,
      );
}
