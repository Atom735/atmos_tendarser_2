import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'route_info.dart';

@immutable
class RouteParser implements RouteInformationParser<CommonRouteInfo> {
  @literal
  const RouteParser();

  @override
  Future<CommonRouteInfo> parseRouteInformation(
      RouteInformation routeInformation) {
    final url = routeInformation.location ?? '';
    switch (url) {
      case '':
      case '/':
      case '/home':
      case '/index':
        return SynchronousFuture(const RouteInfoHome());
      default:
    }
    return SynchronousFuture(RouteInfoUnknown(url));
  }

  @override
  RouteInformation? restoreRouteInformation(CommonRouteInfo configuration) =>
      RouteInformation(location: configuration.url);
}
