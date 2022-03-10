import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../widgets/w_initializing_screen.dart';
import 'route_info.dart';
import 'router_interface.dart';

class MyRouterDelegate extends RouterDelegate<CommonRouteInfo>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin
    implements
        IRouter {
  static MyRouterDelegate of(BuildContext context) =>
      Router.of(context).routerDelegate as MyRouterDelegate;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<CommonRouteInfo> routeStack = [];

  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    Widget result = Navigator(
      key: navigatorKey,
      pages: initialized
          ? routeStack.toList()
          : const [
              MaterialPage(
                child: WInitializingScreen(),
                name: '#initializing-screen',
                restorationId: '#initializing-screen',
              ),
            ],
      onPopPage: onPopPage,
      restorationScopeId: 'navigator',
    );
    assert(() {
      result = Stack(
        alignment: Alignment.bottomLeft,
        children: [
          result,
          Material(
            type: MaterialType.transparency,
            child: IgnorePointer(
              child: ListView(
                reverse: true,
                children: routeStack.reversed
                    .map((e) => Text(e.url, style: style))
                    .toList(),
              ),
            ),
          ),
        ],
      );
      return true;
    }(), 'setup debug overlay');
    return result;
  }

  @override
  CommonRouteInfo? get currentConfiguration => routeStack.last;

  bool onPopPage<T>(Route<T> route, T? result) {
    if (!route.didPop(result)) return false;
    goBack();
    return true;
  }

  @override
  Future<void> setInitialRoutePath(CommonRouteInfo configuration) =>
      setNewRoutePath(configuration);

  @override
  Future<void> setNewRoutePath(CommonRouteInfo configuration) {
    routeStack.add(configuration);
    notifyListeners();
    return SynchronousFuture(null);
  }

  @override
  Future<void> setRestoredRoutePath(CommonRouteInfo configuration) {
    // TODO: implement setRestoredRoutePath
    throw UnimplementedError();
  }

  @override
  void openRoute(CommonRouteInfo route) => setNewRoutePath(route);

  @override
  void goBack() {
    if (routeStack.isNotEmpty) {
      routeStack.removeLast();
      notifyListeners();
    }
  }

  void handleInitizlizngEnd() {
    assert(!initialized, 'Повторная инициализация');
    initialized = true;
    notifyListeners();
  }
}
