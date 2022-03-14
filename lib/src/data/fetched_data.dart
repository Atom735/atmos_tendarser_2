import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/common_stop_watch_ticks.dart';
import '../common/common_web_constants.dart';
import '../interfaces/i_fetched_data.dart';
import '../interfaces/i_fetching_params.dart';

/// Полные сырые данные ответа запроса хранимые в БД
@immutable
class FetchedData implements IFetchedData {
  const FetchedData(
    this.params,
    this.tConnecting,
    this.tSending,
    this.tWaiting,
    this.tDownloading,
    this.gzip,
    this.type,
    this.length,
    this.decodedLength,
    this.bytes,
  );

  @override
  final IFetchingParams params;

  @override
  final StopWatchTicks tConnecting;

  @override
  final StopWatchTicks tSending;

  @override
  final StopWatchTicks tWaiting;

  @override
  final StopWatchTicks tDownloading;

  @override
  final bool gzip;

  @override
  final WebContentType type;

  @override
  final int length;

  @override
  final int decodedLength;

  @override
  final Uint8List? bytes;
}
