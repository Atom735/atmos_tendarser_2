import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgDbGetIntervalResponse implements IMsg {
  const MsgDbGetIntervalResponse(this.id, this.table, this.data);

  factory MsgDbGetIntervalResponse.decode(BinaryReader reader) {
    final id = reader.readSize();
    final table = reader.readSize();
    final data = MsgDbGetIntervalResponseTenderData.decode(
        BinaryReader(reader.readListUint8()));
    return MsgDbGetIntervalResponse(id, table, data);
  }

  static const typeId = 7;

  @override
  final int id;
  final int table;
  final MsgDbGetIntervalResponseTenderData data;

  @override
  Uint8List get toBytes {
    final d = data.toBytes;
    return (BinaryWriter()
          ..writeSize(typeId)
          ..writeSize(id)
          ..writeSize(table)
          ..writeListUint8(d))
        .takeBytes();
  }

  @override
  String toString() => '''MsgDbGetIntervalResponse(id=$id, table=$table)''';
}

class MsgDbGetIntervalResponseTenderData {
  MsgDbGetIntervalResponseTenderData(this.ids, this.tenders, this.companies,
      this.regions, this.props, this.regionsRefs, this.propsRefs);

  factory MsgDbGetIntervalResponseTenderData.decode(BinaryReader reader) {
    final ids = reader.readListSize();
    final tenders = reader.readListUint8();
    final companies = reader.readListUint8();
    final regions = reader.readListUint8();
    final props = reader.readListUint8();
    final regionsRefs = reader.readListUint8();
    final propsRefs = reader.readListUint8();
    return MsgDbGetIntervalResponseTenderData(
        ids, tenders, companies, regions, props, regionsRefs, propsRefs);
  }

  final List<int> ids;
  final Uint8List tenders;
  final Uint8List companies;
  final Uint8List regions;
  final Uint8List props;
  final Uint8List regionsRefs;
  final Uint8List propsRefs;

  Uint8List get toBytes => (BinaryWriter()
        ..writeListSize(ids)
        ..writeListUint8(tenders)
        ..writeListUint8(companies)
        ..writeListUint8(regions)
        ..writeListUint8(props)
        ..writeListUint8(regionsRefs)
        ..writeListUint8(propsRefs))
      .takeBytes();
}
