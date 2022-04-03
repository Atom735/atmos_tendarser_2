import 'dart:async';

import 'package:flutter/material.dart';

import '../interfaces/i_msg_connection.dart';
import 'w_siwtch_theme_mode_button.dart';
import 'wm_app.dart';
import 'wm_misc.dart';
import 'wm_theme.dart';

class WConnectingScreen extends StatefulWidget {
  const WConnectingScreen({Key? key}) : super(key: key);

  @override
  State<WConnectingScreen> createState() => _WConnectingScreenState();
}

class _WConnectingScreenState extends State<WConnectingScreen>
    with WmApp, WmMisc, WmTheme {
  late StreamSubscription ss;
  @override
  void onAppGetted() {
    super.onAppGetted();
    ss = app.connection.statusUpdates.listen(updateState);
  }

  @override
  void dispose() {
    ss.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = app.connection.statusCode;
    if (state == ConnectionStatus.error) {
      return Scaffold(
        backgroundColor: theme.colorScheme.error,
        appBar: AppBar(
          actions: const [WSwitchThemeModeButton()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ошибка подключения',
                          style: theme.typography.englishLike.displayLarge!
                              .copyWith(
                            color: theme.colorScheme.onError,
                          ),
                        ),
                        Text(
                          app.connection.statusMsg,
                          style: theme.typography.englishLike.displaySmall!
                              .copyWith(
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: app.connection.reconnect,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Переподключиться...'),
              ),
            ],
          ),
        ),
      );
    }

    if (state == ConnectionStatus.unconnected) {
      return Scaffold(
        appBar: AppBar(
          actions: const [WSwitchThemeModeButton()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Отключено от сервера',
                          style: theme.typography.englishLike.displayLarge!,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: app.connection.reconnect,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Переподключиться...'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
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
                  'Подключение к [${app.connection.remoteAdress}]...',
                  style: Theme.of(context).typography.englishLike.displayLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
