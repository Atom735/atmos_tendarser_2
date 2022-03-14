import 'package:meta/meta.dart';

import '../common/common_stop_watch_ticks.dart';
import '../interfaces/i_fetched_data.dart';
import '../interfaces/i_parsed_data.dart';

@immutable
class ParsedData<T> implements IParsedData<T> {
  const ParsedData(this.fetched, this.tDeserialization, this.tParsing,
      this.iCurrent, this.iMax, this.items);

  @override
  final IFetchedData fetched;

  @override
  final StopWatchTicks tDeserialization;

  @override
  final StopWatchTicks tParsing;

  @override
  final int iCurrent;

  @override
  final int iMax;

  @override
  final List<T> items;
}
