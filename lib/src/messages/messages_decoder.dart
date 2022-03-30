import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';
import 'msg_db_get_interval_ids.dart';
import 'msg_db_get_interval_request.dart';
import 'msg_db_get_interval_response.dart';
import 'msg_db_get_length_request.dart';
import 'msg_db_get_length_response.dart';
import 'msg_done.dart';
import 'msg_error.dart';
import 'msg_handshake.dart';
import 'msg_unknown.dart';

@immutable
class MessagesDecoder extends Converter<Uint8List, IMsg> {
  @literal
  const MessagesDecoder();

  @override
  IMsg convert(Uint8List input) {
    final reader = BinaryReader(input);
    final type = reader.readSize();
    switch (type) {
      case MsgHandshake.typeId:
        return MsgHandshake.decode(reader);
      case MsgError.typeId:
        return MsgError.decode(reader);
      case MsgDone.typeId:
        return MsgDone.decode(reader);
      case MsgDbGetLengthRequest.typeId:
        return MsgDbGetLengthRequest.decode(reader);
      case MsgDbGetLengthResponse.typeId:
        return MsgDbGetLengthResponse.decode(reader);
      case MsgDbGetIntervalRequest.typeId:
        return MsgDbGetIntervalRequest.decode(reader);
      case MsgDbGetIntervalResponse.typeId:
        return MsgDbGetIntervalResponse.decode(reader);
      case MsgDbGetIntervalIds.typeId:
        return MsgDbGetIntervalIds.decode(reader);
      default:
        return MsgUnknown.decode(type, reader);
    }
  }
}
