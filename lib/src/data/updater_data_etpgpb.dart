import '../common/common_date_time.dart';

class UpdaterDataEtpGpb {
  UpdaterDataEtpGpb(this.settings, this.state);

  final UpdaterDataSettingsEtpGpb settings;
  final UpdaterDataStateEtpGpb state;

  late final int intervalDays =
      settings.start.dt.difference(settings.end.dt).inDays + 1;
  int get elapsedDays => settings.start.dt.difference(state.date.dt).inDays;

  double get progressDays => (elapsedDays / intervalDays).clamp(0, 1.0);
  double get progressPages => (state.page - 1 / state.pageMax).clamp(0, 1.0);
  late final double progressDaysStep = 1 / intervalDays;
  double get progressPagesStep => 1 / state.pageMax;
}

class UpdaterDataSettingsEtpGpb {
  UpdaterDataSettingsEtpGpb(this.id, this.timestamp, this.start, this.end);

  final int id;
  final DateTime timestamp;
  final MyDateTime start;
  final MyDateTime end;
}

class UpdaterDataStateEtpGpb {
  UpdaterDataStateEtpGpb(this.id, this.timestamp, this.page, this.date,
      this.pageMax, this.statusCode, this.statusMessage);

  final int id;
  DateTime timestamp;
  int page;
  MyDateTime date;
  int pageMax;
  UpdaterStateStatus statusCode;
  String statusMessage;
}

enum UpdaterStateStatus {
  initializing,
  run,
  done,
  paused,
  error,
}