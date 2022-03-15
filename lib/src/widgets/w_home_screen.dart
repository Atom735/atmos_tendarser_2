import 'package:flutter/material.dart';

import '../routes/route_info.dart';
import 'w_siwtch_theme_mode_button.dart';
import 'wp_app.dart';

class WHomeScreen extends StatelessWidget {
  const WHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = WpApp.of(context).router;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Домашняя страница'),
        actions: const [WSwitchThemeModeButton()],
      ),
      body: ListView(
        prototypeItem: _WHomeListTile.prototype,
        children: [
          _WHomeListTile(
            'Открыть:  ',
            'список всех тендеров',
            () => router.openRoute(const RouteInfoTenders()),
            icon: const Icon(Icons.menu_open),
          ),
          _WHomeListTile(
            'Открыть:  ',
            'список всех обновлений',
            () => router.openRoute(const RouteInfoUpdaters()),
            icon: const Icon(Icons.menu_open),
          ),
        ],
      ),
    );
  }
}

class _WHomeListTile extends StatelessWidget {
  const _WHomeListTile(
    this.title,
    this.subtitle,
    this.onTap, {
    Key? key,
    this.icon,
  }) : super(key: key);

  final Widget? icon;
  final String title;
  final String subtitle;
  final GestureTapCallback onTap;

  static const prototype = ListTile(
    title: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '# ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '  '),
        ],
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
    ),
  );

  @override
  Widget build(BuildContext context) => ListTile(
        leading: icon,
        onTap: onTap,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: subtitle),
            ],
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      );
}
