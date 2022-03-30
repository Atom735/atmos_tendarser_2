import 'dart:collection';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgDbGetIntervalIds implements IMsg {
  const MsgDbGetIntervalIds(this.id, this.table, this.data);

  factory MsgDbGetIntervalIds.decode(BinaryReader reader) {
    final id = reader.readSize();
    final table = reader.readSize();
    final data = MsgDbGetIntervalIdsTenderData.decode(
        BinaryReader(reader.readListUint8()));
    return MsgDbGetIntervalIds(id, table, data);
  }

  static const typeId = 8;

  @override
  final int id;
  final int table;
  final MsgDbGetIntervalIdsTenderData data;

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
  String toString() => '''MsgDbGetIntervalIds(id=$id, table=$table)''';
}

enum DbIntervalIdsType {
  /// Список айди пристусвующих на стороне
  contained,

  /// Список айди пристусвующих на стороне
  /// парами типа offset-length, где оффсет опорный rowid,
  /// а length длина последовательных айдишек
  containedI,

  /// Список айди отсутсвующих на стороне
  unknowed,

  /// Список айди отсутсвующих на стороне
  /// парами типа offset-length, где оффсет опорный rowid,
  /// а length длина последовательных айдишек
  unknowedI,
}

class MsgDbIntevalsIdsData {
  MsgDbIntevalsIdsData(this.type, this.nums);

  factory MsgDbIntevalsIdsData.decode(BinaryReader reader) {
    final type = DbIntervalIdsType.values[reader.readSize()];
    final nums = reader.readListSize();
    return MsgDbIntevalsIdsData(type, nums);
  }

  factory MsgDbIntevalsIdsData.e1(List<int> ids) {
    ids = ids.toList()..sort();
    final idsb = encode(ids);
    final w1 = (BinaryWriter()..writeListSize(ids)).length;
    final w2 = (BinaryWriter()..writeListSize(idsb)).length;
    if (w1 > w2) {
      return MsgDbIntevalsIdsData(DbIntervalIdsType.containedI, idsb);
    }
    return MsgDbIntevalsIdsData(DbIntervalIdsType.contained, ids);
  }

  factory MsgDbIntevalsIdsData.e2(List<int> ids, MsgDbIntevalsIdsData c) {
    final contained = MsgDbIntevalsIdsData.e1(ids);
    final diff = MsgDbIntevalsIdsData.e1(c.getDiff(contained));
    final w1 = (BinaryWriter()..writeListSize(contained.nums)).length;
    final w2 = (BinaryWriter()..writeListSize(diff.nums)).length;
    if (w1 > w2) {
      if (diff.type == DbIntervalIdsType.containedI) {
        return MsgDbIntevalsIdsData(DbIntervalIdsType.unknowedI, diff.nums);
      }
      return MsgDbIntevalsIdsData(DbIntervalIdsType.unknowed, diff.nums);
    }
    return contained;
  }

  static List<int> encode(List<int> ids) {
    if (ids.isEmpty) return ids;
    final o = <int>[ids.first];
    var i0 = 0;
    for (var i = 1; i < ids.length; i++) {
      if (ids[i] != ids[i - 1] + 1) {
        o
          ..add(i - i0)
          ..add(ids[i]);
        i0 = i;
      }
    }
    o.add(ids.length - i0);
    return o;
  }

  final DbIntervalIdsType type;
  final List<int> nums;
  List<int> get decodedNums {
    final o = <int>[];
    switch (type) {
      case DbIntervalIdsType.contained:
      case DbIntervalIdsType.unknowed:
        return nums.toList();
      case DbIntervalIdsType.containedI:
      case DbIntervalIdsType.unknowedI:
        for (var i = 0; i < nums.length ~/ 2; i++) {
          final offset = nums[i * 2 + 0];
          final length = nums[i * 2 + 1];
          o.addAll(Iterable.generate(length, (j) => j + offset));
        }
        return o;
    }
  }

  void write(BinaryWriter w) {
    w.writeSize(type.index);
    w.writeListSize(nums);
  }

  List<int> getDiff(MsgDbIntevalsIdsData r) {
    final d = r.decodedNums;
    switch (r.type) {
      case DbIntervalIdsType.contained:
      case DbIntervalIdsType.containedI:
        return decodedNums..removeWhere(d.contains);
      case DbIntervalIdsType.unknowed:
      case DbIntervalIdsType.unknowedI:
        return d;
    }
  }
}

class MsgDbGetIntervalIdsTenderData {
  MsgDbGetIntervalIdsTenderData(this.tenders, this.companies, this.regions,
      this.props, this.regionsRefs, this.propsRefs);

  factory MsgDbGetIntervalIdsTenderData.decode(BinaryReader reader) {
    final tenders = MsgDbIntevalsIdsData.decode(reader);
    final companies = MsgDbIntevalsIdsData.decode(reader);
    final regions = MsgDbIntevalsIdsData.decode(reader);
    final props = MsgDbIntevalsIdsData.decode(reader);
    final regionsRefs = MsgDbIntevalsIdsData.decode(reader);
    final propsRefs = MsgDbIntevalsIdsData.decode(reader);
    return MsgDbGetIntervalIdsTenderData(
        tenders, companies, regions, props, regionsRefs, propsRefs);
  }

  final MsgDbIntevalsIdsData tenders;
  final MsgDbIntevalsIdsData companies;
  final MsgDbIntevalsIdsData regions;
  final MsgDbIntevalsIdsData props;
  final MsgDbIntevalsIdsData regionsRefs;
  final MsgDbIntevalsIdsData propsRefs;

  Uint8List get toBytes {
    final w = BinaryWriter();
    tenders.write(w);
    companies.write(w);
    regions.write(w);
    props.write(w);
    regionsRefs.write(w);
    propsRefs.write(w);
    return w.takeBytes();
  }
}
