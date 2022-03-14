import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app.dart';
import '../common/common_misc.dart';
import '../parser_etpgpb/updater_etpgpb.dart';
import 'w_siwtch_theme_mode_button.dart';

class WUpdatesScreen extends StatefulWidget {
  const WUpdatesScreen({Key? key}) : super(key: key);

  @override
  State<WUpdatesScreen> createState() => _WUpdatesScreenState();
}

class _WUpdatesScreenState extends State<WUpdatesScreen> {
  Widget itemBuilder(BuildContext context, int index) =>
      _WUpdaterListTile(app.pEtpGpb.updaters[index]);

  void addNew() {
    app.pEtpGpb.newUpdater(DateTime.now(), DateTime(2022));
  }

  late StreamSubscription ss;
  @override
  void initState() {
    super.initState();
    ss = app.pEtpGpb.updatesUpdaters.listen((_) => setState(kVoidFunc));
  }

  @override
  void dispose() {
    ss.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Список всех обновлений'),
          actions: const [WSwitchThemeModeButton()],
        ),
        body: ListView.builder(
          // prototypeItem: _WUpdaterListTile.prototype,
          itemBuilder: itemBuilder,
          itemCount: app.pEtpGpb.updaters.length,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addNew,
          child: const Icon(Icons.add_task),
        ),
      );
}

class _WUpdaterListTile extends StatefulWidget {
  const _WUpdaterListTile(this.data, {Key? key}) : super(key: key);

  final UpdaterEtpGpb data;

  static const prototype = ListTile(
    title: Text(
      '#',
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
    ),
  );

  @override
  State<_WUpdaterListTile> createState() => _WUpdaterListTileState();
}

class _WUpdaterListTileState extends State<_WUpdaterListTile> {
  late UpdaterEtpGpb data = widget.data;

  late StreamSubscription ss;

  void onData(UpdaterEtpGpb v) {
    data = v;
    setState(kVoidFunc);
  }

  @override
  void initState() {
    super.initState();
    ss = widget.data.updates.listen(onData);
  }

  @override
  void dispose() {
    ss.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          '${data.timestamp}   Обновление etpgpb.ru',
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Состояние:   '),
                  TextSpan(
                    text: data.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            SizedBox(
              width: double.infinity,
              height: 8,
              child: CustomPaint(
                painter: _LinearProgressIndicatorPainter(
                  data.progressDays,
                  data.progressDaysStep,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 8,
              child: CustomPaint(
                painter: _LinearProgressIndicatorPainter(
                  data.progressPages,
                  data.progressPagesStep,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
}

class _LinearProgressIndicatorPainter extends CustomPainter {
  _LinearProgressIndicatorPainter(
      this.value, this.step, this.color1, this.color2, this.backgroundColor);

  final double value;
  final double step;
  final Color color1;
  final Color color2;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = size.width * value;
    canvas
      ..drawRect(
        Offset.zero & size,
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill,
      )
      ..drawRect(
        Offset.zero & Size(p1, size.height),
        Paint()
          ..color = color1
          ..style = PaintingStyle.fill,
      )
      ..drawRect(
        Offset(p1, 0) & Size(size.width * step, size.height),
        Paint()
          ..color = color2
          ..style = PaintingStyle.fill,
      );
  }

  @override
  bool shouldRepaint(_LinearProgressIndicatorPainter oldPainter) =>
      oldPainter.value != value ||
      oldPainter.step != step ||
      oldPainter.color1 != color1 ||
      oldPainter.color2 != color2 ||
      oldPainter.backgroundColor != backgroundColor;
}
