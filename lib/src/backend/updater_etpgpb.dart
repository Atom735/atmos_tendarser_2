import 'dart:async';

import 'package:intl/intl.dart';

import '../backend/parser_etpgpb.dart';
import '../common/common_date_time.dart';
import '../data/dto_updater_data.dart';
import '../data/fetching_params.dart';
import '../data/fetching_params_etpgpb.dart';
import '../database/database_app_server.dart';
import '../interfaces/i_web_client.dart';

class UpdaterEtpGpb extends DtoUpdaterData {
  UpdaterEtpGpb(
    this.webClient,
    this.db,
    DtoUpdaterData v,
  ) : super(v.settings, v.state);

  final DatabaseAppServer db;
  final IWebClient webClient;
  Stream<UpdaterEtpGpb> get updates => _sc.stream;
  Future<UpdaterEtpGpb> get done => _doneCompleter.future;

  static const parser = ParserEtpGpb();

  Completer<void> _pauseCompleter = Completer<void>.sync();
  final _doneCompleter = Completer<UpdaterEtpGpb>();
  final _sc = StreamController<UpdaterEtpGpb>.broadcast(sync: true);

  void pause() => _pauseCompleter.complete();

  void status(UpdaterStateStatus code, [String message = '']) {
    state
      ..timestamp = DateTime.now()
      ..statusCode = code
      ..statusMessage = message;
    _sc.add(this);
  }

  Future<void> run() async {
    try {
      _pauseCompleter = Completer<void>.sync();
      do {
        if (_pauseCompleter.isCompleted) {
          status(UpdaterStateStatus.paused);
          return;
        }
        await step();
      } while (next());
      status(UpdaterStateStatus.done);
      _doneCompleter.complete(this);
    } on Object catch (e, st) {
      status(UpdaterStateStatus.error, '$e\n$st');
      _doneCompleter.completeError(e, st);
    }
  }

  static final dateFmt = DateFormat('dd.MM.yyyy');

  FetchingParamsWithData get fetchingParams =>
      FetchingParamsWithData(kFetchingParamsEtpGpb)
        ..data['page:int'] = state.page.toString()
        ..data['date:date(dd.MM.yyyy)'] = dateFmt.format(state.date.dt);

  /// Переход к след странице
  bool next() {
    if (state.pageMax > 0) {
      if (state.page < state.pageMax) {
        state.page++;
      } else {
        state
          ..page = 1
          ..pageMax = 1
          ..date = MyDateTime(
            state.date.dt.subtract(const Duration(days: 1)),
            MyDateTimeQuality.day,
          );
      }
      final i = state.date.compareTo(settings.end);
      if (i < 0) return false;
    } else {
      state.page++;
    }
    return true;
  }

  Future<void> step() async {
    status(UpdaterStateStatus.run);
    final task = webClient.createTask(fetchingParams);
    final fetched = await task.done;
    final canParse = parser.canParse(fetched);
    if (!canParse) {
      throw Exception('Невозможно разобрать страницу');
    }
    final parsed = parser.parse(fetched);
    state.pageMax = parsed.iMax;
    db.addTenders(parsed.items);
  }

  Future<void> dispose() {
    _pauseCompleter.complete();
    return _sc.close();
  }
}
