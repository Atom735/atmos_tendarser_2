import 'package:flutter/material.dart';

import '../common/common_misc.dart';
import 'w_app.dart';

class WSwitchThemeModeButton extends StatefulWidget {
  const WSwitchThemeModeButton({Key? key}) : super(key: key);

  @override
  State<WSwitchThemeModeButton> createState() => _WSwitchThemeModeButtonState();
}

class _WSwitchThemeModeButtonState extends State<WSwitchThemeModeButton> {
  void updateState() => setState(kVoidFunc);

  ValueNotifier<bool>? vnThemeModeDark;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vnThemeModeDark?.removeListener(updateState);
    vnThemeModeDark = context
        .findAncestorStateOfType<WAppState>()!
        .vnThemeModeDark
      ..addListener(updateState);
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
