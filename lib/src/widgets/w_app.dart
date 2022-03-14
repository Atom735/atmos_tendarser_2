import 'package:flutter/material.dart';

import '../app/app.dart';
import '../common/common_misc.dart';
import '../routes/route_parser.dart';
import '../routes/router_delegate.dart';
import '../theme/theme_themes.dart';

class WApp extends StatefulWidget {
  const WApp({Key? key}) : super(key: key);

  @override
  WAppState createState() => WAppState();
}

class WAppState extends State<WApp> {
  final vnThemeModeDark = ValueNotifier(true);

  final router = MyRouterDelegate();

  void updateState() => setState(kVoidFunc);

  Future<void> init(Object? _) async {
    await app.init();
    router.handleInitizlizngEnd();
  }

  @override
  void initState() {
    super.initState();
    vnThemeModeDark.addListener(updateState);

    var f = Future.value();
    assert(() {
      f = Future.delayed(const Duration(seconds: 3));
      return true;
    }(), 'set debug delay for initializing');

    f.then(init);
  }

  @override
  void dispose() {
    vnThemeModeDark.dispose();
    app.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ru'),
        color: (vnThemeModeDark.value ? themeDataDark : themeDataLight)
            .colorScheme
            .primary,
        theme: themeDataLight,
        darkTheme: themeDataDark,
        themeMode: vnThemeModeDark.value ? ThemeMode.dark : ThemeMode.light,
        routeInformationParser: const RouteParser(),
        routerDelegate: router,
        restorationScopeId: 'tendarser',
        title: 'Atmos Tendarser',
      );
}
