import 'package:atmos_logger/atmos_logger.dart';
import 'package:sqlite3/sqlite3.dart';

import '../backend/web_client.dart';
import '../interfaces/i_web_client.dart';

class App {
  final IWebClient webClient = WebClient(const LoggerVoid());
  final db = sqlite3.open('data.db');

  Future<void> init() async {}

  Future<void> dispose() async {
    await webClient.dispose();
  }
}

final app = App();
