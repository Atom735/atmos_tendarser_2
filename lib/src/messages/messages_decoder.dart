import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';
import 'msg_done.dart';
import 'msg_error.dart';
import 'msg_handshake.dart';
import 'msg_sync_request.dart';
import 'msg_unknown.dart';

@immutable
class MessagesDecoder extends Converter<Uint8List, IMsg> {
  @literal
  const MessagesDecoder();

  @override
  IMsg convert(Uint8List input) {
    final id = BinaryReader(input).readSize();
    switch (id) {
      case 1:
        return MsgHandshake.decode(input);
      case 2:
        return MsgError.decode(input);
      case 3:
        return MsgSyncRequest.decode(input);
      case 4:
        return MsgDone.decode(input);

      default:
        return MsgUnknown.decode(input);
    }
  }
}
