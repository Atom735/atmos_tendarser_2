import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../widgets/w_home_screen.dart';
import '../widgets/w_unknown_screen.dart';
import '../widgets/w_updates_screen.dart';

/// Информация о роутинге.
///
/// [T] - Возвращаемый тип данных.
abstract class CommonRouteInfo<T> extends MaterialPage<T> {
  const CommonRouteInfo(Widget child) : super(child: child);

  /// Отображаемая url.
  String get url;

  @override
  String get name => url;

  @override
  String get restorationId => url;
}

@immutable
class RouteInfoUnknown extends CommonRouteInfo<void> {
  @literal
  const RouteInfoUnknown(this.url) : super(const WUnknownScreen());

  @override
  final String url;

  @override
  String toString() => url;
}

@immutable
class RouteInfoHome extends CommonRouteInfo<void> {
  @literal
  const RouteInfoHome() : super(const WHomeScreen());

  @override
  String get url => '/home';
}

@immutable
class RouteInfoUpdaters extends CommonRouteInfo<void> {
  @literal
  const RouteInfoUpdaters([this.parserName = ''])
      : super(const WUpdatesScreen());

  final String parserName;

  @override
  String get url => parserName.isEmpty ? '/updaters' : '/updaters/$parserName';
}

@immutable
class RouteInfoTenders extends CommonRouteInfo<void> {
  @literal
  const RouteInfoTenders([this.parserName = ''])
      : super(const WUnknownScreen());

  final String parserName;

  @override
  String get url => parserName.isEmpty ? '/tenders' : '/tenders/$parserName';
}
