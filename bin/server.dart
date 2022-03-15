import 'package:atmos_tendarser_2/src/backend/backend_app.dart';
import 'package:atmos_tendarser_2/src/common/common_date_time.dart';

Future<void> main(List<String> args) async {
  final app = BackendApp();
  await app.run(args);
  // var now = DateTime.now();
  // now = DateTime(now.year, now.month, now.day);
  // app.pEtpGpb.spawnNewUpdater(
  //   MyDateTime(now, MyDateTimeQuality.day),
  //   MyDateTime(
  //       DateTime(now.year - 1, now.month, now.day), MyDateTimeQuality.day),
  // );
}
