import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' as logging;

import 'src/frontend/frontend_app.dart';
import 'src/widgets/w_app.dart';
import 'src/widgets/wp_app.dart';

final Logger logger = LoggerConsole(LoggerFile(File('frontend.log')));

void onLogRecord(logging.LogRecord record) {
  late final int logLevel;
  if (record.level.value <= logging.Level.FINE.value) {
    logLevel = LogLevel.trace;
  } else if (record.level.value < logging.Level.INFO.value) {
    logLevel = LogLevel.debug;
  } else if (record.level.value < logging.Level.WARNING.value) {
    logLevel = LogLevel.info;
  } else if (record.level.value < logging.Level.SEVERE.value) {
    logLevel = LogLevel.warn;
  } else if (record.level.value < logging.Level.SHOUT.value) {
    logLevel = LogLevel.error;
  } else {
    logLevel = LogLevel.fatal;
  }
  final sb = StringBuffer();
  if (record.error != null) {
    sb.write(record.error.toString());
  }
  if (record.stackTrace != null) {
    sb
      ..write('\n\n')
      ..write(record.stackTrace.toString());
  }
  logger.log(LogData(
    record.time,
    logLevel,
    record.loggerName,
    record.message,
    sb.toString(),
  ));
}

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  final app = FrontendApp()..run(args);
  runApp(WpApp(app, child: const WApp()));
}
