import 'package:meta/meta.dart';

import 'common_db_column.dart';

@immutable
class StopWatchTicks {
  const StopWatchTicks(this.us);

  StopWatchTicks.fromSw(Stopwatch sw) : this(sw.elapsedMicroseconds);

  static const zero = StopWatchTicks(0);

  final int us;

  static MapEntry<String, String> suffixes = const MapEntry('мкс', 'мс');

  @override
  String toString() {
    if (us >= 3000) {
      return '${us ~/ 1000}.${(us % 1000) ~/ 100} ${suffixes.value}';
    }
    return '$us ${suffixes.key}';
  }
}

@immutable
class DbColumnStopWatchTicks extends CommonDbColumnInteger<StopWatchTicks> {
  @literal
  const DbColumnStopWatchTicks(this.name);

  @override
  final String name;

  @override
  StopWatchTicks decode(int value) => StopWatchTicks(value);

  @override
  int encode(StopWatchTicks value) => value.us;
}
