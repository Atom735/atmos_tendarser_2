import 'package:flutter/material.dart';

import '../frontend/frontend_app.dart';
import '../interfaces/i_router.dart';
import 'wp_app.dart';

mixin WmApp<T extends StatefulWidget> on State<T> {
  late FrontendApp app;
  bool _appNotGetted = true;
  IRouter get router => app.router;

  @mustCallSuper
  void onAppGetted() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    app = WpApp.of(context);
    if (_appNotGetted) {
      onAppGetted();
      _appNotGetted = false;
    }
  }
}
