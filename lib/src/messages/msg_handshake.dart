import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../common/common_misc.dart';
import '../interfaces/i_msg.dart';

final _magics = [
  Uint8List.fromList([0]),
  Uint8List.fromList(
      'Привет первый мир'.codeUnits.map((e) => e ^ 0xa7).toList()),
];

@immutable
class MsgHandshake implements IMsg {
  const MsgHandshake(this.id, this.version);

  factory MsgHandshake.decode(BinaryReader reader) {
    final id = reader.readSize();
    final version = reader.readSize();
    final magic = reader.readListUint8(size: _magics[version].length);
    if (searchSublistBytes(_magics[version], magic) != 0) {
      throw Exception('MsgHandshake corrupted');
    }
    return MsgHandshake(id, version);
  }

  static const typeId = 1;

  @override
  final int id;
  final int version;

  @override
  Uint8List get toBytes => (BinaryWriter()
        ..writeSize(typeId)
        ..writeSize(id)
        ..writeSize(version)
        ..writeListUint8(_magics[version], size: _magics[version].length))
      .takeBytes();

  @override
  String toString() => 'MsgHandshake(id=$id, version=$version)';
}
