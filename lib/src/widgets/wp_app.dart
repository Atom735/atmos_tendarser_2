import 'package:flutter/widgets.dart';

import '../frontend/frontend_app.dart';

class WpApp extends InheritedWidget {
  const WpApp(this.app, {required Widget child, Key? key})
      : super(child: child, key: key);

  final FrontendApp app;

  static FrontendApp of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WpApp>()!.app;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
