import 'package:flutter/material.dart';

import 'w_siwtch_theme_mode_button.dart';

class WInitializingScreen extends StatelessWidget {
  const WInitializingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: const [WSwitchThemeModeButton()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 128,
                    height: 128,
                    child: CircularProgressIndicator(strokeWidth: 8),
                  ),
                  Text(
                    'Загрузка...',
                    style:
                        Theme.of(context).typography.englishLike.displayLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
