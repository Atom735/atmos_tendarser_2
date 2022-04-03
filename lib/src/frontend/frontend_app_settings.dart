import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../common/common_connection.dart';

class FrontendAppSettings {
  FrontendAppSettings() {
    Directory(p.dirname(_file.path)).watch().listen(_onFileChanged);
    for (final vn in vns) {
      vn.addListener(_onChanged);
    }
  }

  final logger = Logger('Settings');
  final _file = File('frontend.settings.yaml').absolute;
  late StreamSubscription<FileSystemEvent> _fileSs;
  final vnThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  final vnServerAdress = ValueNotifier<String>('localhost');
  final vnServerPort = ValueNotifier<int>(kServerPortDefault);
  bool _fileChangedProc = false;
  List<ValueNotifier> get vns => [vnServerAdress, vnServerPort, vnThemeMode];

  void _onChanged() {
    if (_fileChangedProc) return;
    _file.writeAsStringSync('''
server_adress: '${vnServerAdress.value}'
server_port: ${vnServerPort.value}
theme_mode: '${vnThemeMode.value.name}'
''');
  }

  void _onFileChanged(FileSystemEvent event) {
    if (!p.equals(event.path, _file.path)) return;
    if (!_file.existsSync()) return;
    try {
      _fileChangedProc = true;
      final yaml = loadYamlDocument(
        _file.readAsStringSync(),
      ).contents as YamlMap;
      vnServerAdress.value = (yaml['server_adress'] as String?) ?? 'localhost';
      vnServerPort.value = (yaml['server_port'] as int?) ?? kServerPortDefault;
      switch (yaml['theme_mode']) {
        case 'light':
          vnThemeMode.value = ThemeMode.light;
          break;
        case 'dark':
          vnThemeMode.value = ThemeMode.dark;
          break;
        default:
          vnThemeMode.value = ThemeMode.system;
      }
    } on Object catch (e, st) {
      logger.severe('Exception on file settings changed', e, st);
    } finally {
      _fileChangedProc = false;
    }
  }

  void dispose() {
    _fileSs.cancel();
    for (final vn in vns) {
      vn.dispose();
    }
  }
}
