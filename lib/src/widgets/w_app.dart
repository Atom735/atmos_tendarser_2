import 'package:flutter/material.dart';

import '../routes/route_parser.dart';
import '../routes/router_delegate.dart';
import '../theme/theme_color_sheme.dart';
import '../theme/theme_themes.dart';
import 'wm_app.dart';
import 'wm_misc.dart';

class WApp extends StatefulWidget {
  const WApp({Key? key}) : super(key: key);

  @override
  WAppState createState() => WAppState();
}

class WAppState extends State<WApp> with WmApp, WmMisc {
  @override
  void onAppGetted() {
    super.onAppGetted();
    settings.vnThemeMode.addListener(updateState);
  }

  @override
  void dispose() {
    app.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ru'),
        color: kThemeColorSchemeSeed,
        theme: themeDataLight,
        darkTheme: themeDataDark,
        themeMode: settings.vnThemeMode.value,
        routeInformationParser: const RouteParser(),
        routerDelegate: router as MyRouterDelegate,
        restorationScopeId: '#tendarser',
        title: 'Atmos Tendarser',
      );
}
