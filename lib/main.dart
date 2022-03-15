import 'package:flutter/material.dart';

import 'src/frontend/frontend_app.dart';
import 'src/widgets/w_app.dart';
import 'src/widgets/wp_app.dart';

void main(List<String> args) {
  final app = FrontendApp()..run(args);
  runApp(WpApp(app, child: const WApp()));
}
