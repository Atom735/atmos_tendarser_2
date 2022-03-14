import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:atmos_logger/atmos_logger.dart';

import '../common/common_stop_watch_ticks.dart';
import '../common/common_web_constants.dart';
import '../data/fetched_data.dart';
import '../interfaces/i_fetched_data.dart';
import '../interfaces/i_fetching_params.dart';
import '../interfaces/i_web_client.dart';

class WebClient implements IWebClient {
  final _tasks = <IWebClientTask>[];

  Logger logger = const LoggerConsole();

  final _httpClient = HttpClient()
    ..autoUncompress = false
    ..userAgent = 'AtmosTendarser/0.0.2+alpha';

  static late final _decoder = ZLibDecoder();

  @override
  Future<void> dispose() async {
    _httpClient.close();
  }

  @override
  IWebClientTask createTask(IFetchingParams params) {
    assert(!params.isNeedData, 'Params needs data');
    final task = WebClientTask(this, params);
    _tasks.add(task);
    _send(task);
    return task;
  }

  Future<void> _send(WebClientTask task) async {
    final params = task.params;
    final uri = params.uri;
    final ld = '(${params.method.canonical} $uri)';
    final completerDone = task.completerDone;
    final completerCancel = task.completerCancel;
    // ignore: close_sinks
    final controllerSatus = task.controllerSatus;
    logger.trace('Connecting$ld');
    File? file;
    if (params is IFetchingParamsWithData) {
      file = File('.req/${uri.host},${params.data.values.join(',')}.bin');
      Directory('.req').createSync();
    }
    final exists = file?.existsSync() ?? false;
    if (exists) {
      final r = BinaryReader(file!.readAsBytesSync());
      final data = FetchedData(
        params,
        StopWatchTicks(r.readSize()),
        StopWatchTicks(r.readSize()),
        StopWatchTicks(r.readSize()),
        StopWatchTicks(r.readSize()),
        r.readSize() != 0,
        WebContentType.values[r.readSize()],
        r.readSize(),
        r.readSize(),
        r.readListUint8(),
      );

      completerDone.complete(data);
      if (completerCancel.isCompleted) return;
      if (!controllerSatus.isClosed) {
        controllerSatus.add(WebClientTaskStatus.done);
        await controllerSatus.close();
      }
      if (completerCancel.isCompleted) return;
      completerCancel.complete(null);
    }

    try {
      if (completerCancel.isCompleted) return;
      controllerSatus.add(WebClientTaskStatus.connecting);

      final sw = Stopwatch()..start();
      final req = await _httpClient.openUrl(params.method.canonical, uri);
      final tConnecting = StopWatchTicks.fromSw(sw);
      logger.trace('Connected[$tConnecting]$ld');

      if (completerCancel.isCompleted) return;
      controllerSatus.add(WebClientTaskStatus.sending);

      switch (params.type) {
        case WebContentType.unknown:
        case WebContentType.html:
        case WebContentType.zip:
        case WebContentType.list:
          break;
        case WebContentType.json:
          req.headers.contentType = ContentType.parse(params.type.canonical);
          req.write(const Utf8Encoder().convert(params.query));
          break;
        case WebContentType.url:
          req.headers.contentType = ContentType.parse(params.type.canonical);
          req.write(const Utf8Encoder().convert(params.query));
          break;
      }

      sw.reset();
      await req.flush();
      final tSending = StopWatchTicks.fromSw(sw);
      logger.trace('Sended[$tSending]$ld', req.headers.toString());

      if (completerCancel.isCompleted) return;
      controllerSatus.add(WebClientTaskStatus.waiting);

      sw.reset();
      final res = await req.close();
      final tWaiting = StopWatchTicks.fromSw(sw);

      if (completerCancel.isCompleted) return;
      controllerSatus.add(WebClientTaskStatus.downloading);

      sw.reset();
      final bb = BytesBuilder();
      await res.forEach(bb.add);
      final tDownloading = StopWatchTicks.fromSw(sw);
      // sw.stop();
      final bytes = bb.takeBytes();
      logger.trace('Downloaded[$tDownloading]$ld ${bytes.length} bytes',
          res.headers.toString());
      final gzip =
          res.headers[HttpHeaders.contentEncodingHeader]?.first == 'gzip';
      final mime =
          WebContentTypeX.parse(res.headers.contentType?.toString() ?? '');
      final decodedBytes = gzip ? _decoder.convert(bytes) as Uint8List : bytes;

      if (completerCancel.isCompleted) return;

      final data = FetchedData(
        params,
        tConnecting,
        tSending,
        tWaiting,
        tDownloading,
        gzip,
        mime,
        bytes.length,
        decodedBytes.length,
        decodedBytes,
      );
      final r = BinaryWriter()
        ..writeSize(tConnecting.us)
        ..writeSize(tSending.us)
        ..writeSize(tWaiting.us)
        ..writeSize(tDownloading.us)
        ..writeSize(gzip ? 1 : 0)
        ..writeSize(mime.index)
        ..writeSize(bytes.length)
        ..writeSize(decodedBytes.length)
        ..writeListUint8(decodedBytes);
      file?.writeAsBytesSync(r.takeBytes());

      completerDone.complete(data);
      if (completerCancel.isCompleted) return;
      if (!controllerSatus.isClosed) {
        controllerSatus.add(WebClientTaskStatus.done);
        await controllerSatus.close();
      }
      if (completerCancel.isCompleted) return;
      completerCancel.complete(null);
    } on Object catch (error, stackTrace) {
      if (!completerDone.isCompleted) {
        completerDone.completeError(error, stackTrace);
      }
      if (!controllerSatus.isClosed) {
        controllerSatus.add(WebClientTaskStatus.error);
        await controllerSatus.close();
      }
      if (completerCancel.isCompleted) return;
      completerCancel.complete(null);
    }
  }
}

class WebClientTask implements IWebClientTask {
  WebClientTask(this.webClient, this.params) {
    controllerSatus.stream.listen(_setStatus);
  }

  final completerDone = Completer<IFetchedData>.sync();
  final completerCancel = Completer<void>.sync();
  // ignore: close_sinks
  final controllerSatus =
      StreamController<WebClientTaskStatus>.broadcast(sync: true);

  @override
  final IWebClient webClient;

  @override
  final IFetchingParams params;

  @override
  Future<IFetchedData> get done => completerDone.future;

  // ignore: use_setters_to_change_properties
  void _setStatus(WebClientTaskStatus v) => status = v;

  @override
  WebClientTaskStatus status = WebClientTaskStatus.initializing;

  @override
  Stream<WebClientTaskStatus> get statusUpdates => controllerSatus.stream;

  @override
  void cancel() {
    if (completerCancel.isCompleted) return;
    completerCancel.complete(null);
    if (!completerDone.isCompleted) {
      completerDone.completeError(StateError('Canceld'));
    }
    if (!controllerSatus.isClosed) {
      controllerSatus.add(WebClientTaskStatus.canceld);
    }
  }
}
