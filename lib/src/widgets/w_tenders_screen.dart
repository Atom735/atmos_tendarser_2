import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:atmos_database/atmos_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/common_highlihter.dart';
import '../data/data_company.dart';
import '../data/data_interval.dart';
import '../data/data_tender_db_etpgpb.dart';
import '../data/tender_data_etpgpb.dart';
import '../interfaces/i_data_interval.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/msg_db_get_interval_request.dart';
import '../messages/msg_db_get_interval_response.dart';
import '../messages/msg_db_get_length_request.dart';
import '../messages/msg_db_get_length_response.dart';
import 'w_loading_placeholder.dart';
import 'w_siwtch_theme_mode_button.dart';
import 'wm_app.dart';
import 'wm_misc.dart';
import 'wm_searcher.dart';
import 'wm_theme.dart';

class WTendersScreen extends StatefulWidget {
  const WTendersScreen({Key? key}) : super(key: key);

  @override
  State<WTendersScreen> createState() => _WTendersScreenState();
}

class _WTendersScreenState extends State<WTendersScreen>
    with WmApp, WmMisc, WmTheme, WmSearch {
  int get intervalSize => 256;
  IDataIntervals<TenderDataEtpGpb> intervals = DataIntervals();

  int length = -1;

  IMsgConnectionClient get connection => app.connection;

  StreamSubscription? intervalsSs;

  List<Completer> completers = [];

  @override
  Future<void> searchHandle() async {
    super.searchHandle();
    assert(connection.statusCode == ConnectionStatus.connected,
        'Соединение разорвано');
    length = -1;
    updateState();
    final res = await connection.request(
      MsgDbGetLengthRequest(connection.mewMsgId, 0, searchText),
    );
    if (res is! MsgDbGetLengthResponse) {
      throw Exception(res.toString());
    }
    length = res.length;
    unawaited(intervalsSs?.cancel());
    intervals.close();
    intervals = DataIntervals();
    intervalsSs = intervals.updates.listen(updateState);
    updateState();
  }

  @override
  void dispose() {
    intervalsSs?.cancel();
    intervals.close();
    super.dispose();
  }

  @override
  void onAppGetted() {
    super.onAppGetted();
    searchHandle();
  }

  Future<void> getInterval(int index) async {
    intervals.addFuture(index, intervalSize);
    final r1 = await connection.request(
      MsgDbGetIntervalRequest(
        connection.mewMsgId,
        0,
        searchText,
        index,
        intervalSize,
      ),
    );
    if (r1 is! MsgDbGetIntervalResponse) {
      debugger();
      throw Exception();
    }
    final data = r1.data;
    final ids = data.ids;
    final tendersR = BinaryReader(data.tenders);
    final tenders = <DataTenderDbEtpGpb>[];
    while (tendersR.peek > 0) {
      tenders.add(app.db.tableTenders.binRead(tendersR));
    }
    final companiesR = BinaryReader(data.companies);
    final companies = <DataCompany>[];
    while (companiesR.peek > 0) {
      companies.add(app.db.tableCompanies.binRead(companiesR));
    }
    final regionsR = BinaryReader(data.regions);
    final regions = <DataString>[];
    while (regionsR.peek > 0) {
      regions.add(app.db.tableRegions.binRead(regionsR));
    }
    final propsR = BinaryReader(data.props);
    final props = <DataString>[];
    while (propsR.peek > 0) {
      props.add(app.db.tableProps.binRead(propsR));
    }
    final regionsRefsR = BinaryReader(data.regionsRefs);
    final regionsRefs = <DataRef>[];
    while (regionsRefsR.peek > 0) {
      regionsRefs.add(app.db.tableRegionsRefs.binRead(regionsRefsR));
    }
    final propsRefsR = BinaryReader(data.propsRefs);
    final propsRefs = <DataRef>[];
    while (propsRefsR.peek > 0) {
      propsRefs.add(app.db.tablePropsRefs.binRead(propsRefsR));
    }
    final tendersX = <TenderDataEtpGpb>[];
    for (final id in ids) {
      final core = tenders.firstWhere((e) => e.rowid == id);
      tendersX.add(
        TenderDataEtpGpb.db(
          core,
          companies.firstWhere((c) => c.id == core.organizerId),
          props.firstWhere((c) => c.id == core.auctionTypeId),
          regions
              .where((v) => regionsRefs
                  .where((r) => r.idA == core.rowid)
                  .any((r) => r.idB == v.id))
              .toList(),
          props
              .where((v) => propsRefs
                  .where((r) => r.idA == core.rowid)
                  .any((r) => r.idB == v.id))
              .toList(),
        ),
      );
    }
    intervals.add(DataInterval(index, tendersX));
  }

  Widget itemBuilder(BuildContext context, int index) {
    final item = intervals[index];
    if (item == null && !(intervals | index)) {
      getInterval(index);
    }

    return WTenderData(item);
  }

  Widget? get searchBottomBar => searchShown
      ? Material(
          type: MaterialType.card,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: searchTextField,
          ),
        )
      : null;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Список тендеров'),
          actions: const [WSwitchThemeModeButton()],
        ),
        body: length == -1
            ? const WLoadingPlaceholder('Получение данных')
            : ListView.builder(
                itemBuilder: itemBuilder,
                itemCount: length,
                prototypeItem: WTenderData.prototype,
              ),
        floatingActionButton: searchFab,
        bottomNavigationBar: searchBottomBar,
      );
}

class WTenderData extends StatelessWidget {
  const WTenderData(this.data, {Key? key}) : super(key: key);

  final TenderDataEtpGpb? data;

  static final kDateFormat = DateFormat('HH:mm dd.MM.yyyy');

  static const prototype = ListTile(
    isThreeLine: true,
    title: Text(
      'Загрузка...',
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
    ),
    subtitle: Text(
      'Загрузка...\n*\n*\n*',
      maxLines: 4,
      softWrap: false,
      overflow: TextOverflow.fade,
    ),
  );

  void lounch() {
    Process.start('explorer', [data!.link]);
  }

  @override
  Widget build(BuildContext context) {
    final data = this.data;
    if (data == null) return prototype;

    final styleHighlight = TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        decoration: TextDecoration.underline);
    Widget number;
    Widget name;
    if (data.number.contains('<#>')) {
      number = Text.rich(
        TextSpan(children: highlightText(data.number, styleHighlight)),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      );
    } else {
      number = Text(
        data.number,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      );
    }
    if (data.name.contains('<#>')) {
      name = Text.rich(
        TextSpan(children: highlightText(data.name, styleHighlight)),
        maxLines: 4,
        softWrap: true,
        overflow: TextOverflow.fade,
      );
    } else {
      name = Text(
        data.name,
        maxLines: 4,
        softWrap: true,
        overflow: TextOverflow.fade,
      );
    }
    return ListTile(
      onTap: lounch,
      isThreeLine: true,
      title: number,
      subtitle: name,
      trailing: Text(kDateFormat.format(data.end.dtLocal)),
    );
  }
}
