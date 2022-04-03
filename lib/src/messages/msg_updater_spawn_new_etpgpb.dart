// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../common/common_misc.dart';
import '../interfaces/i_msg.dart';
import 'msg_done.dart';

/// Сообщение о необходимости заспавнить новый экзмепляр обновления тендеров
/// - Результатное сообщение будет [MsgDone]
@immutable
class MsgUpdaterSpawnNewEtpGpb implements IMsg {
  const MsgUpdaterSpawnNewEtpGpb(this.id, this.start, this.end);

  factory MsgUpdaterSpawnNewEtpGpb.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final start = DateTime.fromMillisecondsSinceEpoch(
      reader.readSize() * kMillisecondsInDay,
      isUtc: true,
    );
    final end = DateTime.fromMillisecondsSinceEpoch(
      reader.readSize() * kMillisecondsInDay,
      isUtc: true,
    );
    return MsgUpdaterSpawnNewEtpGpb(id, start, end);
  }

  static const typeId = 5;

  @override
  final int id;
  final DateTime start;
  final DateTime end;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id)
    ..writeSize(start.millisecondsSinceEpoch ~/ kMillisecondsInDay)
    ..writeSize(end.millisecondsSinceEpoch ~/ kMillisecondsInDay);

  @override
  String toString() =>
      '''MsgUpdaterSpawnNewEtpGpb(id: $id, start: $start, end: $end)''';
}
