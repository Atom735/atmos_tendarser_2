import 'dart:async';
import 'dart:collection';

import 'package:intl/intl.dart';

import '../app/app.dart';
import '../common/common_date_time.dart';
import '../data/fetching_params.dart';
import 'fetching_params_etpgpb.dart';
import 'parser_etpgpb.dart';
import 'tender_data_etpgpb.dart';

class UpdaterEtpGpb {
  UpdaterEtpGpb(
    this.id,
    this.timestamp,
    this.start,
    this.end,
    this.page,
    this.date,
    this.pageMax,
    this.status,
  );

  final int id;
  final DateTime timestamp;
  final MyDateTime start;
  final MyDateTime end;
  int page;
  MyDateTime date;
  int pageMax;
  String status;

  final sc = StreamController<UpdaterEtpGpb>.broadcast(sync: true);

  Stream<UpdaterEtpGpb> get updates => sc.stream;

  int get intervalDays => start.dt.difference(end.dt).inDays + 1;
  int get elapsedDays => start.dt.difference(date.dt).inDays;

  double get progressDays => (elapsedDays / intervalDays).clamp(0, 1.0);
  double get progressPages => (page - 1 / pageMax).clamp(0, 1.0);
  double get progressDaysStep => 1 / intervalDays;
  double get progressPagesStep => 1 / pageMax;

  static const parser = ParserEtpGpb();

  Completer<void> pauseCompleter = Completer<void>.sync();
  Future<void> get done => _doneCompleter.future;
  final _doneCompleter = Completer<void>();

  Future<void> run() async {
    try {
      pauseCompleter = Completer<void>.sync();
      do {
        if (pauseCompleter.isCompleted) {
          status = 'Остановлен';
          sc.add(this);
          return;
        }
        await step();
      } while (next());
      status = 'Закончено';
      sc.add(this);
      _doneCompleter.complete();
    } on Object catch (e, st) {
      status = 'Ошибка: $e';
      sc.add(this);
      _doneCompleter.completeError(e, st);
    }
  }

  static final dateFmt = DateFormat('dd.MM.yyyy');

  FetchingParamsWithData get fetchingParams =>
      FetchingParamsWithData(kFetchingParamsEtpGpb)
        ..data['page:int'] = page.toString()
        ..data['date:date(dd.MM.yyyy)'] = dateFmt.format(date.dt);

  /// Переход к след странице
  bool next() {
    if (pageMax > 0) {
      if (page < pageMax) {
        page++;
      } else {
        page = 1;
        pageMax = 1;
        date = MyDateTime(
          date.dt.subtract(const Duration(days: 1)),
          MyDateTimeQuality.day,
        );
      }
      final i = date.compareTo(end);
      if (i < 0) return false;
    } else {
      page++;
    }
    return true;
  }

  Future<void> step() async {
    status = 'Получение страницы';
    sc.add(this);
    final task = app.webClient.createTask(fetchingParams);
    final fetched = await task.done;
    status = 'Парсинг страницы';
    sc.add(this);
    final canParse = await parser.canParse(fetched);
    if (!canParse) {
      throw Exception('Невозможно разобрать страницу');
    }
    final parsed = await parser.parse(fetched);
    status = 'Добавление данных в БД';
    sc.add(this);
    await Future.delayed(const Duration(milliseconds: 100));
    final dp = app.pEtpGpb.dpTenders;
    final tendersAdded =
        await dp.getByIds(parsed.items.map(TenderDataEtpGpb.getId).toList());
    final tenders = HashSet<TenderDataEtpGpb>(
        equals: (p0, p1) => p0.id == p1.id, hashCode: (e) => e.id)
      ..addAll(parsed.items)
      ..removeAll(tendersAdded);
    await dp.addAll(tenders.toList());
  }

  Future<void> dispose() {
    pauseCompleter.complete();
    if (!_doneCompleter.isCompleted) {
      status = 'Остановлен';
      sc.add(this);
    }
    return sc.close();
  }
}
