import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';

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
class DatabaseStopWatchTicks
    extends DatabaseColumnUnsignedBase<StopWatchTicks> {
  @literal
  const DatabaseStopWatchTicks(String name) : super(name);

  @override
  StopWatchTicks dartEncode(int value) => StopWatchTicks(value);

  @override
  int dartDecode(StopWatchTicks value) => value.us;
}
