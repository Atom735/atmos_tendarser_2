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
  ValueNotifier<bool>? vnThemeModeDark;

  @override
  void onAppGetted() {
    super.onAppGetted();
    vnThemeModeDark = app.vnThemeModeDark..addListener(updateState);
  }

  @override
  void dispose() {
    vnThemeModeDark?.removeListener(updateState);
    super.dispose();
  }

  void handleSwitchThemeMode() =>
      vnThemeModeDark!.value = !vnThemeModeDark!.value;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: handleSwitchThemeMode,
        icon: Icon(
          vnThemeModeDark!.value ? Icons.light_mode : Icons.dark_mode,
        ),
      );
}
