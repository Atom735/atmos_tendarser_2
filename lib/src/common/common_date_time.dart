import 'dart:math';

import 'package:atmos_database/atmos_database.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

final kDtDayFormatter = DateFormat('dd.MM.yyyy');
final kDtMinutesFormatter = DateFormat('dd.MM.yyyy HH:mm');

/// Точность [MyDateTime]
enum MyDateTimeQuality {
  /// Отсутсвует дата
  unknown,

  /// с точность до Микросекунд
  microsecond,

  /// с точность до Миллисекунд
  millisecond,

  /// с точность до Секунд
  second,

  /// с точность до Минут
  minute,

  /// с точность до Часа
  hour,

  /// с точность до Половины дня
  halfDay,

  /// с точность до Дня
  day,

  /// с точность до Недели
  week,

  /// с точность до Половины месяца
  halfMonth,

  /// с точность до Месяца
  month,

  /// с точность до Квартала
  quartal,

  /// с точность до Полугода
  halfYear,

  /// с точность до года
  year,
}

/// Собственное представление даты/времени
@immutable
class MyDateTime implements Comparable<MyDateTime> {
  MyDateTime(this.dt, this.quality);

  /// Распаковывает время из целого числа
  MyDateTime.fromInt(int v)
      : this(
          DateTime.fromMillisecondsSinceEpoch(v >> 5, isUtc: true),
          MyDateTimeQuality.values[v & 0x1f],
        );

  factory MyDateTime.iso(String txt,
      [MyDateTimeQuality quality = MyDateTimeQuality.unknown]) {
    if (txt.isEmpty) return unknown;
    final m = _reIso.matchAsPrefix(txt);
    if (m == null) return unknown;

    final nums = m
        .groups(const [1, 2, 3, 4, 5, 6])
        .cast<String>()
        .map(int.parse)
        .toList();
    if (nums[3] == 0 && nums[4] == 0 && nums[5] == 0) {
      return MyDateTime(
        DateTime.utc(nums[0], nums[1], nums[2]),
        getMaxQuality(quality, MyDateTimeQuality.day),
      );
    }
    return MyDateTime(
      DateTime.utc(nums[0], nums[1], nums[2], nums[3], nums[4], nums[5]),
      getMaxQuality(quality, MyDateTimeQuality.minute),
    );
  }

  static MyDateTimeQuality getMaxQuality(
      MyDateTimeQuality a, MyDateTimeQuality b) {
    final i = min(a.index, b.index);
    if (i != 0) {
      return MyDateTimeQuality.values[i];
    }
    if (a.index != 0) return a;
    return b;
  }

  /// Неизвестное время в принципе
  static final unknown = MyDateTime(
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      MyDateTimeQuality.unknown);

  /// Неизвестное время до сейчас
  static MyDateTime unknownNow =
      MyDateTime(DateTime.now().toUtc(), MyDateTimeQuality.unknown);

  /// Обновлнеие неизвестного времени до сейчас
  static void unknownNowUpdate() => unknownNow =
      MyDateTime(DateTime.now().toUtc(), MyDateTimeQuality.unknown);

  static final _reIso =
      RegExp(r'(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)');

  final DateTime dt;

  late final DateTime dtLocal =
      quality.index != 0 && quality.index <= MyDateTimeQuality.halfDay.index
          ? dt.subtract(const Duration(hours: 3))
          : dt;

  /// Точность заданной даты/времени
  final MyDateTimeQuality quality;

  bool get isEmpty => quality == MyDateTimeQuality.unknown;

  @override
  int get hashCode => dt.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyDateTime && compareTo(other) == 0;
  }

  @override
  int compareTo(MyDateTime other) {
    if (identical(this, other)) return 0;
    if (quality == MyDateTimeQuality.unknown) {
      if (other.quality == MyDateTimeQuality.unknown) return 0;
      return -1;
    }
    if (other.quality == MyDateTimeQuality.unknown) return 1;
    return dt.compareTo(other.dt);
  }

  @override
  String toString() {
    switch (quality) {
      case MyDateTimeQuality.unknown:
        return 'Неизвестно';

      case MyDateTimeQuality.microsecond:
      case MyDateTimeQuality.millisecond:
      case MyDateTimeQuality.second:
        return dtLocal.toString();

      case MyDateTimeQuality.minute:
      case MyDateTimeQuality.hour:
      case MyDateTimeQuality.halfDay:
        return kDtMinutesFormatter.format(dtLocal);

      case MyDateTimeQuality.day:
      case MyDateTimeQuality.week:
      case MyDateTimeQuality.halfMonth:
      case MyDateTimeQuality.month:
      case MyDateTimeQuality.quartal:
      case MyDateTimeQuality.halfYear:
      case MyDateTimeQuality.year:
        return kDtDayFormatter.format(dtLocal);
    }
  }

  /// Пакует время в целоге число
  int get toInt => quality.index | (dt.millisecondsSinceEpoch << 5);
}

@immutable
class DatabaseColumnMyDateTime extends DatabaseColumnIntegerBase<MyDateTime> {
  @literal
  const DatabaseColumnMyDateTime(
    String name, {
    bool unique = false,
    bool indexed = false,
  }) : super(name, unique: unique, indexed: indexed);

  @override
  MyDateTime dartEncode(int value) => MyDateTime.fromInt(value);

  @override
  int dartDecode(MyDateTime value) => value.toInt;
}
