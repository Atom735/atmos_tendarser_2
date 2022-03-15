import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgSyncRequest implements IMsg {
  const MsgSyncRequest(this.id, this.timestamps);

  factory MsgSyncRequest.decode(Uint8List data) {
    final reader = BinaryReader(data);
    final type = reader.readSize();
    if (type != typeId) {
      throw Exception('Untyped msg');
    }
    final id = reader.readSize();
    final timestamps = Map.fromEntries(reader.readList(timestampReader));
    return MsgSyncRequest(id, timestamps);
  }

  static const typeId = 3;

  @override
  final int id;
  final Map<String, DateTime> timestamps;

  static MapEntry<String, DateTime> timestampReader(
      int i, BinaryReader reader) {
    final key = reader.readString();
    final value = reader.readDateTime();
    return MapEntry<String, DateTime>(key, value);
  }

  static void timestampWriter(
          MapEntry<String, DateTime> val, int i, BinaryWriter writer) =>
      writer
        ..writeString(val.key)
        ..writeDateTime(val.value);

  @override
  Uint8List get toBytes => (BinaryWriter()
        ..writeSize(typeId)
        ..writeSize(id)
        ..writeList(
          timestamps.entries.toList(),
          timestampWriter,
        ))
      .takeBytes();

  @override
  String toString() => 'MsgSyncRequest(id=$id, '
      '${timestamps.entries.map((e) => '${e.key}=${e.value}').join(', ')})';
}
