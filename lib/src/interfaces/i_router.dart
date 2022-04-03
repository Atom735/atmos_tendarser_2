import '../routes/route_info.dart';

abstract class IRouter {
  /// For implement only
  IRouter._();

  /// Открыть новый роут
  void openRoute(CommonRouteInfo route);

  /// Вернутся на предыдущий роут
  void goBack();

  CommonRouteInfo? get currentConfiguration;
}
