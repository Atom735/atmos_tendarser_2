import 'dart:io';

import 'package:atmos_database/atmos_database.dart';
import 'package:atmos_logger/atmos_logger_io.dart';

import 'package:logging/logging.dart' as logging;

void backendAppLoggerAttach() {
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen(_logRecord);
}

void backendAppLoggerClose() {
  _loggerAtmos.close();
}

final Logger _loggerAtmos =
    LoggerConsole(LoggerFile(File('logs.backend.${DateTime.now()}.log')));

void _logRecord(logging.LogRecord record) {
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
  _loggerAtmos.log(LogData(
    record.time,
    logLevel,
    record.loggerName,
    record.message,
    sb.toString(),
  ));
}
