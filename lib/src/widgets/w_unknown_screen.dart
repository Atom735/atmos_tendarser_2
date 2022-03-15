import 'package:flutter/material.dart';

import 'w_siwtch_theme_mode_button.dart';
import 'wp_app.dart';

class WUnknownScreen extends StatelessWidget {
  const WUnknownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = WpApp.of(context).router;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(router.currentConfiguration?.url ?? ''),
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
                  'Неизвестная странница...',
                  style: theme.typography.englishLike.displayLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
