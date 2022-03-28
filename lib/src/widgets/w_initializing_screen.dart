import 'package:flutter/material.dart';

import 'w_loading_placeholder.dart';
import 'w_siwtch_theme_mode_button.dart';

class WInitializingScreen extends StatelessWidget {
  const WInitializingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: const [WSwitchThemeModeButton()],
        ),
        body: const WLoadingPlaceholder('Загрузка...'),
      );
}
