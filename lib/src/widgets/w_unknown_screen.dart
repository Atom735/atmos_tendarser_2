import 'package:flutter/material.dart';

import '../routes/router_interface.dart';
import 'w_siwtch_theme_mode_button.dart';

class WUnknownScreen extends StatelessWidget {
  const WUnknownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(IRouter.of(context).currentConfiguration?.url ?? ''),
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
