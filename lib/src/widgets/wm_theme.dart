import 'package:flutter/material.dart';

mixin WmTheme<T extends StatefulWidget> on State<T> {
  ThemeData theme = _themeFallback;

  static final _themeFallback = ThemeData();

  @mustCallSuper
  void onThemeUpdated() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newTheme = Theme.of(context);
    if (!identical(newTheme, theme)) {
      theme = newTheme;
      onThemeUpdated();
    }
    theme = newTheme;
  }
}
