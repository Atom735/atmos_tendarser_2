import '../routes/route_info.dart';

abstract class IRouter {
  /// Открыть новый роут
  void openRoute(CommonRouteInfo route);

  /// Вернутся на предыдущий роут
  void goBack();

  CommonRouteInfo? get currentConfiguration;
}
