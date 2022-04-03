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
import 'msg_updater_get.dart';
import 'msg_updater_spawn_new_etpgpb.dart';

@immutable
class MessagesDecoder extends Converter<Uint8List, IMsg> {
  @literal
  const MessagesDecoder();

  @override
  IMsg convert(Uint8List input) {
    final reader = BinaryReader(input);
    final type = reader.readSize();
    reader.offset = 0;
    switch (type) {
      case MsgHandshake.typeId:
        return MsgHandshake.read(reader);
      case MsgError.typeId:
        return MsgError.read(reader);
      case MsgDone.typeId:
        return MsgDone.read(reader);

      case MsgUpdaterSpawnNewEtpGpb.typeId:
        return MsgUpdaterSpawnNewEtpGpb.read(reader);

      case MsgUpdaterGetRequest.typeId:
        return MsgUpdaterGetRequest.read(reader);
      case MsgUpdaterResponse.typeId:
        return MsgUpdaterResponse.read(reader);
      case MsgUpdaterGetInterval.typeId:
        return MsgUpdaterGetInterval.read(reader);
      case MsgUpdaterInterval.typeId:
        return MsgUpdaterInterval.read(reader);
      case MsgUpdaterLengthRequest.typeId:
        return MsgUpdaterLengthRequest.read(reader);
      case MsgUpdaterLengthResponse.typeId:
        return MsgUpdaterLengthResponse.read(reader);

      // case MsgDbGetLengthRequest.typeId:
      //   return MsgDbGetLengthRequest.decode(reader);
      // case MsgDbGetLengthResponse.typeId:
      //   return MsgDbGetLengthResponse.decode(reader);
      // case MsgDbGetIntervalRequest.typeId:
      //   return MsgDbGetIntervalRequest.decode(reader);
      // case MsgDbGetIntervalResponse.typeId:
      //   return MsgDbGetIntervalResponse.decode(reader);
      // case MsgDbGetIntervalIds.typeId:
      //   return MsgDbGetIntervalIds.read(reader);
      default:
        return MsgUnknown.read(reader);
    }
  }
}
