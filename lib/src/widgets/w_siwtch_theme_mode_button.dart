import 'package:flutter/material.dart';

import 'wm_app.dart';
import 'wm_misc.dart';

class WSwitchThemeModeButton extends StatefulWidget {
  const WSwitchThemeModeButton({Key? key}) : super(key: key);

  @override
  State<WSwitchThemeModeButton> createState() => _WSwitchThemeModeButtonState();
}

class _WSwitchThemeModeButtonState extends State<WSwitchThemeModeButton>
    with WmApp, WmMisc {
  ValueNotifier<ThemeMode> get vnThemeMode => settings.vnThemeMode;

  @override
  void onAppGetted() {
    super.onAppGetted();
    vnThemeMode.addListener(updateState);
  }

  @override
  void dispose() {
    vnThemeMode.removeListener(updateState);
    super.dispose();
  }

  void handleSwitchThemeMode() {
    switch (vnThemeMode.value) {
      case ThemeMode.system:
        vnThemeMode.value = ThemeMode.light;
        break;
      case ThemeMode.light:
        vnThemeMode.value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        vnThemeMode.value = ThemeMode.system;
        break;
    }
  }

  IconData get _iconData {
    switch (vnThemeMode.value) {
      case ThemeMode.system:
        return Icons.light_mode;
      case ThemeMode.light:
        return Icons.dark_mode;
      case ThemeMode.dark:
        return Icons.mode_standby;
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: handleSwitchThemeMode,
        icon: Icon(_iconData),
      );
}
