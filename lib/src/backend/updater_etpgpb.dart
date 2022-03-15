import 'dart:async';
import 'dart:collection';

import 'package:intl/intl.dart';

import '../backend/parser_etpgpb.dart';
import '../common/common_date_time.dart';
import '../data/fetching_params.dart';
import '../data/fetching_params_etpgpb.dart';
import '../data/tender_data_etpgpb.dart';
import '../data/updater_data_etpgpb.dart';
import 'backend_module_etpgpb.dart';

class UpdaterEtpGpb extends UpdaterDataEtpGpb {
  UpdaterEtpGpb(this.module, UpdaterDataEtpGpb v) : super(v.settings, v.state);

  final BackendModuleEtpGpb module;
  final sc = StreamController<UpdaterEtpGpb>.broadcast(sync: true);

  Stream<UpdaterEtpGpb> get updates => sc.stream;

  static const parser = ParserEtpGpb();

  Completer<void> pauseCompleter = Completer<void>.sync();
  Future<void> get done => _doneCompleter.future;
  final _doneCompleter = Completer<void>();

  void status(UpdaterStateStatus code, [String message = '']) {
    state
      ..timestamp = DateTime.now()
      ..statusCode = code
      ..statusMessage = message;
    sc.add(this);
  }

  Future<void> run() async {
    try {
      pauseCompleter = Completer<void>.sync();
      do {
        if (pauseCompleter.isCompleted) {
          status(UpdaterStateStatus.paused);
          return;
        }
        await step();
      } while (next());
      status(UpdaterStateStatus.done);
      _doneCompleter.complete();
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
    final task = module.app.webClient.createTask(fetchingParams);
    final fetched = await task.done;
    final canParse = parser.canParse(fetched);
    if (!canParse) {
      throw Exception('Невозможно разобрать страницу');
    }
    final parsed = parser.parse(fetched);
    state.pageMax = parsed.iMax;
    final dp = module.dpTenders;
    final tendersAdded =
        dp.getByIds(parsed.items.map(TenderDataEtpGpb.getId).toList());
    final tenders = HashSet<TenderDataEtpGpb>(
        equals: (p0, p1) => p0.id == p1.id, hashCode: (e) => e.id)
      ..addAll(parsed.items)
      ..removeAll(tendersAdded);
    dp.addAll(tenders.toList());
  }

  Future<void> dispose() {
    pauseCompleter.complete();
    return sc.close();
  }
}
