import '../common/common_date_time.dart';
import '../data/data_provider_sqlite.dart';
import '../data/tender_data_etpgpb.dart';
import '../data/tender_data_table_eptgbp.dart';
import '../data/updater_data_etpgpb.dart';
import '../data/updater_data_table_etpgpb.dart';
import '../interfaces/i_data_search_struct.dart';
import 'backend_app.dart';
import 'updater_etpgpb.dart';

class BackendModuleEtpGpb {
  BackendModuleEtpGpb(this.app);

  final BackendApp app;

  late final dpTenders =
      DataProviderSqlite<TenderDataEtpGpb, TenderDataEtpGpb, IDataSearchStruct>(
          app.db, const DbEtpGpbTenderDataTable());

  late final dpUpdaters = DataProviderSqlite<
      UpdaterDataEtpGpb,
      UpdaterDataEtpGpb,
      IDataSearchStruct>(app.db, const DbEtpGpbUpdaterDataTable());

  late final dpUpdateStates = DataProviderSqlite<
      UpdaterDataStateEtpGpb,
      UpdaterDataStateEtpGpb,
      IDataSearchStruct>(app.db, const DbEtpGpbUpdaterDataStateTable());

  final updates = <UpdaterEtpGpb>{};

  void _updaterStateUpdate(UpdaterEtpGpb data) =>
      dpUpdateStates.update(data.state);

  void spawnNewUpdater(MyDateTime start, MyDateTime end) {
    final id = dpUpdaters.getNewId();
    final timestamp = DateTime.now();
    final result = UpdaterEtpGpb(
      this,
      UpdaterDataEtpGpb(
        UpdaterDataSettingsEtpGpb(id, timestamp, start, end),
        UpdaterDataStateEtpGpb(
          id,
          timestamp,
          1,
          start,
          0,
          UpdaterStateStatus.initializing,
          '',
        ),
      ),
    )..updates.listen(_updaterStateUpdate);
    dpUpdaters.add(result);
    updates.add(result..run());
    result.done.whenComplete(() => updates.remove(result));
  }

  Future<void> init() async {
    await dpTenders.init();
    dpTenders.sqlCreateTable();
    await dpUpdaters.init();
    dpUpdaters.sqlCreateTable();
    await dpUpdateStates.init();
    final datas = dpUpdaters
        .sqlSelect('WHERE statusCode < ${UpdaterStateStatus.done.index}');
    updates.addAll(datas.map(
      (e) => UpdaterEtpGpb(this, e)
        ..run()
        ..updates.listen(_updaterStateUpdate),
    ));
  }

  Future<void> dispose() async {
    for (final item in updates) {
      await item.dispose();
    }
    await dpUpdateStates.dispose();
    await dpUpdaters.dispose();
    await dpTenders.dispose();
  }
}
