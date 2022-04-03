import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:atmos_database/atmos_database.dart';
import 'package:sqlite3/sqlite3.dart';

import '../common/common_date_time.dart';
import '../common/common_misc.dart';
import '../interfaces/i_writable.dart';

/// Типы сортировки списка [UpdaterData]
enum UpdaterDataSortType {
  /// Сориторвка по [UpdaterState.id] записей
  id,

  /// Сориторвка по [UpdaterState.timestamp] записей
  timestamp,

  /// Сориторвка по [UpdaterDataSettings.start] записей
  start,

  /// Сориторвка по [UpdaterDataSettings.end] записей
  end,
}

class UpdaterData implements IWritable {
  UpdaterData(this.settings, this.state);
  UpdaterData.v(MyDateTime start, MyDateTime end)
      : this(UpdaterDataSettings.v(start, end), UpdaterState.v(start));
  factory UpdaterData.read(BinaryReader reader) {
    final settings = UpdaterDataSettings.read(reader);
    final state = UpdaterState.read(reader);
    return UpdaterData(settings, state);
  }

  final UpdaterDataSettings settings;
  final UpdaterState state;

  late final int intervalDays =
      settings.start.dt.difference(settings.end.dt).inDays + 1;
  int get elapsedDays => settings.start.dt.difference(state.date.dt).inDays;

  double get progressDays => (elapsedDays / intervalDays).clamp(0, 1.0);
  double get progressPages => (state.page - 1 / state.pageMax).clamp(0, 1.0);
  late final double progressDaysStep = 1 / intervalDays;
  double get progressPagesStep => 1 / state.pageMax;

  @override
  String toString() => 'UpdaterData(settings: $settings, state: $state)';

  @override
  BinaryWriter write(BinaryWriter writer) {
    settings.write(writer);
    state.write(writer);
    return writer;
  }

  static void listWriter(UpdaterData v, int index, BinaryWriter writer) =>
      v.write(writer);

  // ignore: prefer_constructors_over_static_methods
  static UpdaterData listReader(int index, BinaryReader reader) =>
      UpdaterData.read(reader);
}

class UpdaterDataSettings implements IWritable {
  UpdaterDataSettings(this.id, this.timestamp, this.start, this.end);
  UpdaterDataSettings.v(MyDateTime start, MyDateTime end)
      : this(0, 0, start, end);
  factory UpdaterDataSettings.read(BinaryReader reader) {
    final id = reader.readSize();
    final timestamp = reader.readSize();
    final start = DateTime.fromMillisecondsSinceEpoch(
      reader.readSize() * kMillisecondsInDay,
      isUtc: true,
    );

    final end = DateTime.fromMillisecondsSinceEpoch(
      reader.readSize() * kMillisecondsInDay,
      isUtc: true,
    );
    return UpdaterDataSettings(
      id,
      timestamp,
      MyDateTime(start, MyDateTimeQuality.day),
      MyDateTime(end, MyDateTimeQuality.day),
    );
  }

  final int id;
  final int timestamp;
  DateTime get timestampDt =>
      const DatabaseColumnTimestampDateTime('').dartEncode(timestamp);
  final MyDateTime start;
  final MyDateTime end;

  @override
  String toString() =>
      '''UpdaterDataSettings(id: $id, timestamp: $timestampDt, start: $start, end: $end)''';

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(id)
    ..writeSize(timestamp)
    ..writeSize(start.dt.millisecondsSinceEpoch ~/ kMillisecondsInDay)
    ..writeSize(end.dt.millisecondsSinceEpoch ~/ kMillisecondsInDay);
}

class UpdaterState implements IWritable {
  UpdaterState(this.id, this.timestamp, this.page, this.date, this.pageMax,
      this.statusCode, this.statusMessage);

  UpdaterState.v(MyDateTime start)
      : this(0, 0, 1, start, 0, UpdaterStateStatus.initializing, '');
  factory UpdaterState.read(BinaryReader reader) {
    final id = reader.readSize();
    final timestamp = reader.readSize();
    final page = reader.readSize();
    final date = DateTime.fromMillisecondsSinceEpoch(
      reader.readSize() * kMillisecondsInDay,
      isUtc: true,
    );
    final pageMax = reader.readSize();
    final statusCode = UpdaterStateStatus.values[reader.readSize()];
    final statusMessage = reader.readString();
    return UpdaterState(
      id,
      timestamp,
      page,
      MyDateTime(date, MyDateTimeQuality.day),
      pageMax,
      statusCode,
      statusMessage,
    );
  }

  final int id;
  int timestamp;
  DateTime get timestampDt =>
      const DatabaseColumnTimestampDateTime('').dartEncode(timestamp);
  int page;
  MyDateTime date;
  int pageMax;
  UpdaterStateStatus statusCode;
  String statusMessage;

  @override
  String toString() =>
      '''UpdaterState(id: $id, timestamp: $timestampDt, page: $page, date: $date, pageMax: $pageMax, statusCode: $statusCode, statusMessage: $statusMessage)''';

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(id)
    ..writeSize(timestamp)
    ..writeSize(page)
    ..writeSize(date.dt.millisecondsSinceEpoch ~/ kMillisecondsInDay)
    ..writeSize(pageMax)
    ..writeSize(statusCode.index)
    ..writeString(statusMessage);
}

enum UpdaterStateStatus {
  initializing,
  run,
  done,
  paused,
  error,
}

class TableDataUpdater extends DatabaseTable<UpdaterData> {
  const TableDataUpdater(Database sql) : super(sql, kTableName, kColumnsFull);

  static const kTableName = 'Updaters';
  static const kColumnsFull = <DatabaseColumn>[
    ...kColumnsState,
    DatabaseColumnMyDateTime('start'),
    DatabaseColumnMyDateTime('end'),
    // DatabaseColumnUnsigned('parserId'),
  ];
  static const kColumnsState = <DatabaseColumn>[
    DatabaseColumnId('rowid'),
    kColumnsTimestamp,
    DatabaseColumnUnsigned('page'),
    DatabaseColumnMyDateTime('date'),
    DatabaseColumnUnsigned('pageMax'),
    kColumnsStatusCode,
    DatabaseColumnText('statusMessage'),
  ];
  static const kColumnsStatusCode = DatabaseColumnUnsigned('statusCode');
  DatabaseColumnUnsigned get vColumnsStatusCode => kColumnsStatusCode;
  static const kColumnsTimestamp = DatabaseColumnTimestamp('timestamp');
  DatabaseColumnTimestamp get vColumnsTimestamp => kColumnsTimestamp;

  @override
  List dartDecode(UpdaterData value) => [
        value.state.id,
        value.state.timestamp,
        value.state.page,
        value.state.date,
        value.state.pageMax,
        value.state.statusCode.index,
        value.state.statusMessage,
        value.settings.start,
        value.settings.end,
        // value.settings.parserId,
      ];

  @override
  UpdaterData dartEncode(List value) => UpdaterData(
        UpdaterDataSettings(
          value[0],
          value[1],
          // value[9],
          value[7],
          value[8],
        ),
        UpdaterState(
          value[0],
          value[1],
          value[2],
          value[3],
          value[4],
          UpdaterStateStatus.values[value[5]],
          value[6],
        ),
      );
}

class TableDataUpdaterState extends DatabaseTable<UpdaterState> {
  const TableDataUpdaterState(Database sql)
      : super(
          sql,
          TableDataUpdater.kTableName,
          TableDataUpdater.kColumnsState,
        );

  DatabaseColumnUnsigned get vColumnsStatusCode =>
      TableDataUpdater.kColumnsStatusCode;

  @override
  List dartDecode(UpdaterState value) => [
        value.id,
        value.timestamp,
        value.page,
        value.date,
        value.pageMax,
        value.statusCode.index,
        value.statusMessage,
      ];

  @override
  UpdaterState dartEncode(List value) => UpdaterState(
        value[0],
        value[1],
        value[2],
        value[3],
        value[4],
        UpdaterStateStatus.values[value[5]],
        value[6],
      );
}
