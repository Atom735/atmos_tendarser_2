import 'package:sqlite3/sqlite3.dart';

import '../interfaces/i_web_client.dart';
import '../parser_etpgpb/app_etpgpb.dart';
import '../web_client/web_client.dart';

class App {
  final IWebClient webClient = WebClient();
  final db = sqlite3.open('data.db');

  late final pEtpGpb = AppEtpGpb(this);

  Future<void> init() async {
    await pEtpGpb.init();
  }

  Future<void> dispose() async {
    await webClient.dispose();
    await pEtpGpb.dispose();
  }
}

final app = App();
