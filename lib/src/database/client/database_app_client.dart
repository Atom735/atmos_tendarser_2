import '../../data/updater_data.dart';
import '../database_app.dart';

class DatabaseAppClient extends DatabaseApp {
  DatabaseAppClient(String fname) : super(fname);

  void upsertUpdaters(List<UpdaterData> data) {
    final table = tableUpdaters;
    final newIds = data.map((e) => e.settings.id).toList();
    final newIdsContains =
        table.sqlSelectByIds(newIds).map((e) => e.settings.id).toList();
    newIds.removeWhere(newIdsContains.contains);
    for (final item in newIdsContains) {
      updateUpdaterStates(data.firstWhere((e) => e.state.id == item).state);
    }
    table.sqlInsert(data.where((e) => newIds.contains(e.state.id)));
  }
}
