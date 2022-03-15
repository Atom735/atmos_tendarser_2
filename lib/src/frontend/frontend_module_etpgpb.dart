import '../backend/updater_etpgpb.dart';
import '../common/common_date_time.dart';
import '../data/data_provider_sqlite.dart';
import '../data/tender_data_etpgpb.dart';
import '../data/tender_data_table_eptgbp.dart';
import '../data/updater_data_etpgpb.dart';
import '../data/updater_data_table_etpgpb.dart';
import '../interfaces/i_data_search_struct.dart';
import 'frontend_app.dart';

class FrontendModuleEtpGpb {
  FrontendModuleEtpGpb(this.app);

  final FrontendApp app;

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

  void spawnNewUpdater(MyDateTime start, MyDateTime end) {}

  Future<void> init() async {
    await dpTenders.init();
    dpTenders.sqlCreateTable();
    await dpUpdaters.init();
    dpUpdaters.sqlCreateTable();
    await dpUpdateStates.init();
  }

  Future<void> dispose() async {
    await dpUpdateStates.dispose();
    await dpUpdaters.dispose();
    await dpTenders.dispose();
  }
}
