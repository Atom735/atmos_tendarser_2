import 'package:atmos_tendarser_2/src/backend/backend_app.dart';

Future<void> main(List<String> args) async {
  final app = BackendApp();
  await app.run(args);
  app.spawnNewUpdater(DateTime(2022, 4), DateTime(2020));
  // var now = DateTime.now();
  // now = DateTime(now.year, now.month, now.day);
  // app.pEtpGpb.spawnNewUpdater(
  //   MyDateTime(now, MyDateTimeQuality.day),
  //   MyDateTime(
  //       DateTime(now.year - 1, now.month, now.day), MyDateTimeQuality.day),
  // );
}
