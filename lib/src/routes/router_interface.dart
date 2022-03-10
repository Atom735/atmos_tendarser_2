import 'package:flutter/widgets.dart';

import 'route_info.dart';

abstract class IRouter {
  /// Открыть новый роут
  void openRoute(CommonRouteInfo route);

  /// Вернутся на предыдущий роут
  void goBack();

  static IRouter of(BuildContext context) =>
      Router.of(context).routerDelegate as IRouter;

  CommonRouteInfo? get currentConfiguration;
}
