import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';
import 'msg_done.dart';
import 'msg_error.dart';
import 'msg_handshake.dart';
import 'msg_sync_data_frame.dart';
import 'msg_sync_data_haved.dart';
import 'msg_sync_data_intervals.dart';
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
      case MsgHandshake.typeId:
        return MsgHandshake.decode(input);
      case MsgError.typeId:
        return MsgError.decode(input);
      case MsgDone.typeId:
        return MsgDone.decode(input);
      case MsgSyncRequest.typeId:
        return MsgSyncRequest.decode(input);
      case MsgSyncDataIntervals.typeId:
        return MsgSyncDataIntervals.decode(input);
      case MsgSyncDataHaved.typeId:
        return MsgSyncDataHaved.decode(input);
      case MsgSyncDataFrame.typeId:
        return MsgSyncDataFrame.decode(input);
      default:
        return MsgUnknown.decode(input);
    }
  }
}
