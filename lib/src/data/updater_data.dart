import 'package:atmos_database/atmos_database.dart';
import 'package:sqlite3/sqlite3.dart';

import '../common/common_date_time.dart';

class UpdaterData {
  UpdaterData(this.settings, this.state);
  UpdaterData.v(MyDateTime start, MyDateTime end)
      : this(UpdaterDataSettings.v(start, end), UpdaterState.v(start));

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
}

class UpdaterDataSettings {
  UpdaterDataSettings(this.id, this.timestamp, this.start, this.end);
  UpdaterDataSettings.v(MyDateTime start, MyDateTime end)
      : this(0, 0, start, end);

  final int id;
  final int timestamp;
  DateTime get timestampDt =>
      const DatabaseColumnTimestampDateTime('').dartEncode(timestamp);
  final MyDateTime start;
  final MyDateTime end;

  @override
  String toString() =>
      '''UpdaterDataSettings(id: $id, timestamp: $timestampDt, start: $start, end: $end)''';
}

class UpdaterState {
  UpdaterState(this.id, this.timestamp, this.page, this.date, this.pageMax,
      this.statusCode, this.statusMessage);

  UpdaterState.v(MyDateTime start)
      : this(0, 0, 1, start, 0, UpdaterStateStatus.initializing, '');

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
    DatabaseColumnTimestamp('timestamp'),
    DatabaseColumnUnsigned('page'),
    DatabaseColumnMyDateTime('date'),
    DatabaseColumnUnsigned('pageMax'),
    kColumnsStatusCode,
    DatabaseColumnText('statusMessage'),
  ];
  static const kColumnsStatusCode = DatabaseColumnUnsigned('statusCode');
  DatabaseColumnUnsigned get vColumnsStatusCode => kColumnsStatusCode;

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
